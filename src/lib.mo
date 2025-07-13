import CID "mo:cid";
import Result "mo:new-base/Result";
import Buffer "mo:base/Buffer";
import Iter "mo:new-base/Iter";
import DagCbor "mo:dag-cbor";
import VarInt "mo:multiformats/VarInt";
import Array "mo:new-base/Array";
import Runtime "mo:new-base/Runtime";
import IterX "mo:xtended-iter/IterX";
import List "mo:new-base/List";
import Nat "mo:new-base/Nat";
import Blob "mo:new-base/Blob";
import PeekableIter "mo:xtended-iter/PeekableIter";

module {
    public type File = {
        header : Header;
        blocks : [Block];
    };

    public type Block = {
        cid : CID.CID;
        data : Blob;
    };

    public type Header = {
        version : Nat;
        roots : [CID.CID];
    };

    public func toBytes(file : File) : [Nat8] {
        let buffer = Buffer.Buffer<Nat8>(0);

        // 1. Encode header to temporary buffer to get its length
        let headerBuffer = Buffer.Buffer<Nat8>(0);
        let headerDagCbor = toDagCborHeader(file.header);

        let headerBytesWritten = switch (DagCbor.toBytesBuffer(headerBuffer, headerDagCbor)) {
            case (#ok(bytesWritten)) bytesWritten;
            case (#err(err)) return Runtime.trap("Failed to encode header: " # debug_show (err)); // Should never happen
        };

        // 2. Write header length as varint, then header data
        VarInt.toBytesBuffer(buffer, headerBytesWritten);
        buffer.append(headerBuffer);

        // 3. Write blocks
        let blockBuffer = Buffer.Buffer<Nat8>(40);
        for (block in file.blocks.vals()) {
            // Temporary buffer for block data
            let cidByteLength = CID.toBytesBuffer(blockBuffer, block.cid);
            for (byte in block.data.vals()) {
                blockBuffer.add(byte);
            };
            let totalBlockSize = cidByteLength + block.data.size();

            // Write block size as varint
            VarInt.toBytesBuffer(buffer, totalBlockSize);
            // Write CID bytes
            buffer.append(blockBuffer);
            blockBuffer.clear(); // Clear for next iteration
        };

        Buffer.toArray(buffer);
    };

    public func fromBytes(bytes : Iter.Iter<Nat8>) : Result.Result<File, Text> {
        // if (true) {
        //     Runtime.trap("Debug: fromBytes called with bytes: " # debug_show (Blob.fromArray(Iter.toArray(bytes))));
        // };
        let headerLength = switch (VarInt.fromBytes(bytes)) {
            case (#ok(length)) length;
            case (#err(err)) return #err("Failed to read header length: " # debug_show (err));
        };
        let headerBytes = Iter.take(bytes, headerLength);
        let headerDagCbor = switch (DagCbor.fromBytes(headerBytes)) {
            case (#ok(value)) value;
            case (#err(err)) return #err("Failed to decode header: " # debug_show (err));
        };
        let header = switch (fromDagCborHeader(headerDagCbor)) {
            case (#ok(h)) h;
            case (#err(err)) return #err("Failed to parse header: " # err);
        };
        let blocksList = List.empty<Block>();
        let peekableBytes = IterX.toPeekable(bytes);
        while (PeekableIter.hasNext(peekableBytes)) {
            let blockSize = switch (VarInt.fromBytes(peekableBytes)) {
                case (#ok(size)) size;
                case (#err(err)) return #err("Failed to read size for block at index " # Nat.toText(List.size(blocksList)) # ": " # debug_show (err));
            };
            let blockBytes = Iter.take(peekableBytes, blockSize);
            let blockCID = switch (CID.fromBytes(blockBytes)) {
                case (#ok(cid)) cid;
                case (#err(err)) return #err("Failed to decode block CID for block at index " # Nat.toText(List.size(blocksList)) # ": " # debug_show (err));
            };
            List.add(
                blocksList,
                {
                    cid = blockCID;
                    data = Blob.fromArray(Iter.toArray(blockBytes));
                },
            );
        };

        #ok({
            header = header;
            blocks = List.toArray(blocksList);
        });
    };

    func toDagCborHeader(header : Header) : DagCbor.Value {
        let rootsDagCborArray = Array.map(
            header.roots,
            func(cid : CID.CID) : DagCbor.Value = #cid(cid),
        );
        #map([
            ("version", #int(header.version)),
            ("roots", #array(rootsDagCborArray)),
        ]);
    };

    func fromDagCborHeader(value : DagCbor.Value) : Result.Result<Header, Text> {
        let #map(fields) = value else return #err("Invalid header format, expected a map");
        var version : ?Nat = null;
        var roots : ?[CID.CID] = null;
        for (field in fields.vals()) {
            switch (field) {
                case ("version", versionDagCbor) {
                    let #int(v) = versionDagCbor else return #err("Invalid version field, expected an integer");
                    if (v < 0) {
                        return #err("Invalid version field, version must be a non-negative integer");
                    };
                    version := ?Nat.fromInt(v);
                };
                case ("roots", #array(rootsDagCborArray)) {
                    let rootsList = List.empty<CID.CID>();
                    for (root in rootsDagCborArray.vals()) {
                        let #cid(rootCID) = root else return #err("Invalid roots field, expected an array of CIDs");
                        List.add(rootsList, rootCID);
                    };
                    roots := ?List.toArray(rootsList);
                };
                case (_) (); // Ignore unknown fields
            };
        };
        switch (version, roots) {
            case (?v, ?r) #ok({
                version = v;
                roots = r;
            });
            case (null, null) return #err("Header is missing required fields: version and roots");
            case (null, _) return #err("Header is missing required field: version");
            case (_, null) return #err("Header is missing required field: roots");
        };
    };
};
