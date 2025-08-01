# Motoko CAR Library

[![MOPS](https://img.shields.io/badge/MOPS-car-blue)](https://mops.one/car)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/edjCase/motoko_car/blob/main/LICENSE)

A Motoko library for working with Content Addressable Archive (CAR) files used in IPFS, IPLD, and AT Protocol. CAR files are a binary format for storing and transmitting content-addressed data, containing both a header with metadata and a sequence of blocks with their corresponding Content Identifiers (CIDs).

## Package

### MOPS

```bash
mops add car
```

To set up MOPS package manager, follow the instructions from the [MOPS Site](https://mops.one)

## Quick Start

### Import

```motoko
import CAR "mo:car"
import CID "mo:cid"
```

### Example 1: Creating and Encoding a CAR File

```motoko
// Create some sample blocks
let blocks = [
  {
    cid = #v1({
      codec = #dagCbor;
      hash = "\F8\8B\C8\53\80\4C\F2\94\FE\41\7E\4F\A8\30\28\68\9F\CD\B1\B1\59\2C\51\02\E1\47\4D\BC\20\0F\AB\8B";
      hashAlgorithm = #sha2256;
    });
    data = "\A2\64\6C\69\6E\6B\D8\2A\58\23\00\12\20\02\AC\EC\C5";
  },
  {
    cid = #v0({
      hash = "\02\AC\EC\C5\DE\24\38\EA\41\26\A3\01\0E\CB\1F\8A\59\9C\8E\FF\22\FF\F1\A1\DC\FF\E9\99\B2\7F\D3\DE";
    });
    data = "\12\2E\0A\24\01\55\12\20\B6\FB\D6\75\F9\8E";
  }
];

// Create a CAR file with header and blocks
let carFile : CAR.File = {
  header = {
    version = 1;
    roots = [
      #v1({
        codec = #dagCbor;
        hash = "\F8\8B\C8\53\80\4C\F2\94\FE\41\7E\4F\A8\30\28\68\9F\CD\B1\B1\59\2C\51\02\E1\47\4D\BC\20\0F\AB\8B";
        hashAlgorithm = #sha2256;
      })
    ];
  };
  blocks = blocks;
};

// Encode to bytes
let carBytes = CAR.toBytes(carFile);
Debug.print("CAR file encoded to " # Nat.toText(carBytes.size()) # " bytes");
```

### Example 2: Parsing a CAR File from Bytes

```motoko
// Parse CAR file from bytes
switch (CAR.fromBytes(carBytes.vals())) {
  case (#ok(parsedFile)) {
    Debug.print("Successfully parsed CAR file");
    Debug.print("Version: " # Nat.toText(parsedFile.header.version));
    Debug.print("Root CIDs: " # Nat.toText(parsedFile.header.roots.size()));
    Debug.print("Blocks: " # Nat.toText(parsedFile.blocks.size()));
  };
  case (#err(error)) {
    Debug.print("Failed to parse CAR file: " # error);
  };
};
```

### Example 3: Working with Multiple Root CIDs

```motoko
// Create a CAR file with multiple root CIDs
let multiRootCarFile : CAR.File = {
  header = {
    version = 1;
    roots = [
      #v1({
        codec = #dagCbor;
        hash = "\F8\8B\C8\53\80\4C\F2\94\FE\41\7E\4F\A8\30\28\68\9F\CD\B1\B1\59\2C\51\02\E1\47\4D\BC\20\0F\AB\8B";
        hashAlgorithm = #sha2256;
      }),
      #v1({
        codec = #dagCbor;
        hash = "\69\EA\07\40\F9\80\7A\28\F4\D9\32\C6\2E\7C\1C\83\BE\05\5E\55\07\2C\90\26\6A\B3\E7\9D\F6\3A\36\5B";
        hashAlgorithm = #sha2256;
      })
    ];
  };
  blocks = [
    // ... your blocks here
  ];
};

// Process each root CID
for (rootCid in multiRootCarFile.header.roots.vals()) {
  switch (rootCid) {
    case (#v0(cidV0)) {
      Debug.print("Root CIDv0: " # CID.V0.toText(cidV0));
    };
    case (#v1(cidV1)) {
      Debug.print("Root CIDv1: " # CID.V1.toText(cidV1, #base32));
    };
  };
};
```

## Features

### CAR File Format Support

- **CAR v1**: Full support for Content Addressable Archive format version 1
- **Header encoding/decoding**: Using DAG-CBOR format with version and root CIDs
- **Block storage**: Efficient storage of content-addressed blocks with their CIDs
- **Varint encoding**: LEB128 variable-length integer encoding for sizes

### CID Compatibility

- **CIDv0**: Legacy format support for IPFS compatibility
- **CIDv1**: Modern format with multiple codecs and hash algorithms
- **Mixed CID versions**: Support for files containing both CIDv0 and CIDv1 blocks

### Supported Codecs

- `#raw`: Raw binary data blocks
- `#dagPb`: DAG-PB (Protocol Buffers) for IPFS compatibility
- `#dagCbor`: DAG-CBOR for structured data

### Supported Hash Algorithms

- `#sha2256`: SHA-256 (32 bytes) - most common
- `#sha2512`: SHA-512 (64 bytes)

## Use Cases

### IPFS Integration

CAR files are the standard format for importing/exporting data from IPFS nodes and for data transfer between IPFS systems.

### AT Protocol (Bluesky)

CAR files are used extensively in the AT Protocol for repository synchronization and data exchange.

### Content Distribution

Efficient packaging of related content-addressed blocks for distribution and storage.

### Archival Storage

Long-term storage of content-addressed data with merkle-tree verification.

## API Reference

### Types

```motoko
// Main CAR file structure
public type File = {
    header : Header;
    blocks : [Block];
};

// Individual block with CID and data
public type Block = {
    cid : CID.CID;  // Content Identifier
    data : Blob;    // Raw block data
};

// CAR file header
public type Header = {
    version : Nat;      // CAR format version (currently 1)
    roots : [CID.CID]; // Array of root CIDs
};
```

### Main Functions

```motoko
// Encode CAR file to binary format
public func toBytes(file : File) : [Nat8];

// Parse CAR file from binary format
public func fromBytes(bytes : Iter.Iter<Nat8>) : Result.Result<File, Text>;
```

### Binary Format

The CAR binary format consists of:

1. **Header Length**: LEB128-encoded length of the header
2. **Header Data**: DAG-CBOR encoded header containing version and root CIDs
3. **Blocks**: Sequence of blocks, each with:
   - Block size (LEB128-encoded)
   - CID bytes
   - Block data

### Error Handling

The library provides detailed error messages for:

- Invalid header format or missing fields
- Malformed CID data
- Incorrect varint encoding
- DAG-CBOR parsing errors

## Dependencies

This library depends on several Motoko packages:

- `mo:cid` - Content Identifier support
- `mo:dag-cbor` - DAG-CBOR encoding/decoding
- `mo:core` - Core utilities (Result, Iter, etc.)
- `mo:leb128` - Variable-length integer encoding
- `mo:xtended-iter` - Extended iterator utilities
- `mo:buffer` - Buffer utilities

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
