import CID "mo:cid";
import Result "mo:core/Result";
import List "mo:core/List";
import Iter "mo:core/Iter";
import DagCbor "mo:dag-cbor";
import Array "mo:core/Array";
import Runtime "mo:core/Runtime";
import IterX "mo:xtended-iter/IterX";
import Nat "mo:core/Nat";
import Blob "mo:core/Blob";
import LEB128 "mo:leb128";
import PeekableIter "mo:xtended-iter/PeekableIter";
import Buffer "mo:buffer";

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
    let buffer = List.empty<Nat8>();

    // 1. Encode header to temporary buffer to get its length
    let headerBuffer = List.empty<Nat8>();
    let headerDagCbor = toDagCborHeader(file.header);

    switch (DagCbor.toBytesBuffer(Buffer.fromList(headerBuffer), headerDagCbor)) {
      case (#ok(bytesWritten)) bytesWritten;
      case (#err(err)) return Runtime.trap("Failed to encode header: " # debug_show (err)); // Should never happen
    };

    // 2. Write header length as varint, then header data
    LEB128.toUnsignedBytesBuffer(Buffer.fromList(buffer), List.size(headerBuffer));
    List.addAll(buffer, List.values(headerBuffer));

    // 3. Write blocks
    let blockBuffer = List.empty<Nat8>();
    for (block in file.blocks.vals()) {
      // Temporary buffer for block data
      let sizeBeforeBlock = List.size(blockBuffer);
      CID.toBytesBuffer(Buffer.fromList(blockBuffer), block.cid);
      let cidByteLength : Nat = List.size(blockBuffer) - sizeBeforeBlock;
      List.addAll(blockBuffer, block.data.vals());
      let totalBlockSize = cidByteLength + block.data.size();

      // Write block size as varint
      LEB128.toUnsignedBytesBuffer(Buffer.fromList(buffer), totalBlockSize);
      // Write CID bytes
      List.addAll(buffer, List.values(blockBuffer));
      List.clear(blockBuffer); // Clear for next iteration
    };

    List.toArray(buffer);
  };

  public func fromBytes(bytes : Iter.Iter<Nat8>) : Result.Result<File, Text> {
    let headerLength = switch (LEB128.fromUnsignedBytes(bytes)) {
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
      let blockSize = switch (LEB128.fromUnsignedBytes(peekableBytes)) {
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
