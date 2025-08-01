import { test } "mo:test";
import CAR "../src";
import Blob "mo:core/Blob";
import Runtime "mo:core/Runtime";

test(
  "to/fromBytes",
  func() {
    type TestCase = {
      file : CAR.File;
      expectedBytes : Blob;
    };
    let testCases : [TestCase] = [{
      file = {
        blocks = [
          {
            cid = #v1({
              codec = #dagCbor;
              hash = "\F8\8B\C8\53\80\4C\F2\94\FE\41\7E\4F\A8\30\28\68\9F\CD\B1\B1\59\2C\51\02\E1\47\4D\BC\20\0F\AB\8B";
              hashAlgorithm = #sha2256;
            });
            data = "\A2\64\6C\69\6E\6B\D8\2A\58\23\00\12\20\02\AC\EC\C5\DE\24\38\EA\41\26\A3\01\0E\CB\1F\8A\59\9C\8E\FF\22\FF\F1\A1\DC\FF\E9\99\B2\7F\D3\DE\64\6E\61\6D\65\64\62\6C\69\70";
          },
          {
            cid = #v0({
              hash = "\02\AC\EC\C5\DE\24\38\EA\41\26\A3\01\0E\CB\1F\8A\59\9C\8E\FF\22\FF\F1\A1\DC\FF\E9\99\B2\7F\D3\DE";
            });
            data = "\12\2E\0A\24\01\55\12\20\B6\FB\D6\75\F9\8E\2A\BD\22\D4\ED\29\FD\C8\31\50\FE\DC\48\59\7E\92\DD\1A\7A\24\38\1D\44\A2\74\51\12\04\62\65\61\72\18\04\12\2F\0A\22\12\20\79\A9\82\DE\3C\99\07\95\3D\4D\32\3C\EE\1D\0F\B1\ED\8F\45\F8\EF\02\87\0C\0C\B9\E0\92\46\BD\53\0A\12\06\73\65\63\6F\6E\64\18\95\01";
          },
          {
            cid = #v1({
              codec = #raw;
              hash = "\B6\FB\D6\75\F9\8E\2A\BD\22\D4\ED\29\FD\C8\31\50\FE\DC\48\59\7E\92\DD\1A\7A\24\38\1D\44\A2\74\51";
              hashAlgorithm = #sha2256;
            });
            data = "\63\63\63\63";
          },
          {
            cid = #v0({
              hash = "\79\A9\82\DE\3C\99\07\95\3D\4D\32\3C\EE\1D\0F\B1\ED\8F\45\F8\EF\02\87\0C\0C\B9\E0\92\46\BD\53\0A";
            });
            data = "\12\2D\0A\24\01\55\12\20\81\CC\5B\17\01\86\74\B4\01\B4\2F\35\BA\07\BB\79\E2\11\23\9C\23\BF\FE\65\8D\A1\57\7E\3E\64\68\77\12\03\64\6F\67\18\04\12\2D\0A\22\12\20\E7\DC\48\6E\97\E6\EB\E5\CD\AB\AB\3E\39\2B\DA\D1\28\B6\E0\9A\CC\94\BB\4E\2A\A2\AF\7B\98\6D\24\D0\12\05\66\69\72\73\74\18\33";
          },
          {
            cid = #v1({
              codec = #raw;
              hash = "\81\CC\5B\17\01\86\74\B4\01\B4\2F\35\BA\07\BB\79\E2\11\23\9C\23\BF\FE\65\8D\A1\57\7E\3E\64\68\77";
              hashAlgorithm = #sha2256;
            });
            data = "\62\62\62\62";
          },
          {
            cid = #v0({
              hash = "\E7\DC\48\6E\97\E6\EB\E5\CD\AB\AB\3E\39\2B\DA\D1\28\B6\E0\9A\CC\94\BB\4E\2A\A2\AF\7B\98\6D\24\D0";
            });
            data = "\12\2D\0A\24\01\55\12\20\61\BE\55\A8\E2\F6\B4\E1\72\33\8B\DD\F1\84\D6\DB\EE\29\C9\88\53\E0\A0\48\5E\CE\E7\F2\7B\9A\F0\B4\12\03\63\61\74\18\04";
          },
          {
            cid = #v1({
              codec = #raw;
              hash = "\61\BE\55\A8\E2\F6\B4\E1\72\33\8B\DD\F1\84\D6\DB\EE\29\C9\88\53\E0\A0\48\5E\CE\E7\F2\7B\9A\F0\B4";
              hashAlgorithm = #sha2256;
            });
            data = "\61\61\61\61";
          },
          {
            cid = #v1({
              codec = #dagCbor;
              hash = "\69\EA\07\40\F9\80\7A\28\F4\D9\32\C6\2E\7C\1C\83\BE\05\5E\55\07\2C\90\26\6A\B3\E7\9D\F6\3A\36\5B";
              hashAlgorithm = #sha2256;
            });
            data = "\A2\64\6C\69\6E\6B\F6\64\6E\61\6D\65\65\6C\69\6D\62\6F";
          },
        ];
        header = {
          roots = [#v1({ codec = #dagCbor; hash = "\F8\8B\C8\53\80\4C\F2\94\FE\41\7E\4F\A8\30\28\68\9F\CD\B1\B1\59\2C\51\02\E1\47\4D\BC\20\0F\AB\8B"; hashAlgorithm = #sha2256 }), #v1({ codec = #dagCbor; hash = "\69\EA\07\40\F9\80\7A\28\F4\D9\32\C6\2E\7C\1C\83\BE\05\5E\55\07\2C\90\26\6A\B3\E7\9D\F6\3A\36\5B"; hashAlgorithm = #sha2256 })];
          version = 1;
        };
      };
      expectedBytes = "\63\a2\65\72\6f\6f\74\73\82\d8\2a\58\25\00\01\71\12\20\f8\8b\c8\53\80\4c\f2\94\fe\41\7e\4f\a8\30\28\68\9f\cd\b1\b1\59\2c\51\02\e1\47\4d\bc\20\0f\ab\8b\d8\2a\58\25\00\01\71\12\20\69\ea\07\40\f9\80\7a\28\f4\d9\32\c6\2e\7c\1c\83\be\05\5e\55\07\2c\90\26\6a\b3\e7\9d\f6\3a\36\5b\67\76\65\72\73\69\6f\6e\01\5b\01\71\12\20\f8\8b\c8\53\80\4c\f2\94\fe\41\7e\4f\a8\30\28\68\9f\cd\b1\b1\59\2c\51\02\e1\47\4d\bc\20\0f\ab\8b\a2\64\6c\69\6e\6b\d8\2a\58\23\00\12\20\02\ac\ec\c5\de\24\38\ea\41\26\a3\01\0e\cb\1f\8a\59\9c\8e\ff\22\ff\f1\a1\dc\ff\e9\99\b2\7f\d3\de\64\6e\61\6d\65\64\62\6c\69\70\83\01\12\20\02\ac\ec\c5\de\24\38\ea\41\26\a3\01\0e\cb\1f\8a\59\9c\8e\ff\22\ff\f1\a1\dc\ff\e9\99\b2\7f\d3\de\12\2e\0a\24\01\55\12\20\b6\fb\d6\75\f9\8e\2a\bd\22\d4\ed\29\fd\c8\31\50\fe\dc\48\59\7e\92\dd\1a\7a\24\38\1d\44\a2\74\51\12\04\62\65\61\72\18\04\12\2f\0a\22\12\20\79\a9\82\de\3c\99\07\95\3d\4d\32\3c\ee\1d\0f\b1\ed\8f\45\f8\ef\02\87\0c\0c\b9\e0\92\46\bd\53\0a\12\06\73\65\63\6f\6e\64\18\95\01\28\01\55\12\20\b6\fb\d6\75\f9\8e\2a\bd\22\d4\ed\29\fd\c8\31\50\fe\dc\48\59\7e\92\dd\1a\7a\24\38\1d\44\a2\74\51\63\63\63\63\80\01\12\20\79\a9\82\de\3c\99\07\95\3d\4d\32\3c\ee\1d\0f\b1\ed\8f\45\f8\ef\02\87\0c\0c\b9\e0\92\46\bd\53\0a\12\2d\0a\24\01\55\12\20\81\cc\5b\17\01\86\74\b4\01\b4\2f\35\ba\07\bb\79\e2\11\23\9c\23\bf\fe\65\8d\a1\57\7e\3e\64\68\77\12\03\64\6f\67\18\04\12\2d\0a\22\12\20\e7\dc\48\6e\97\e6\eb\e5\cd\ab\ab\3e\39\2b\da\d1\28\b6\e0\9a\cc\94\bb\4e\2a\a2\af\7b\98\6d\24\d0\12\05\66\69\72\73\74\18\33\28\01\55\12\20\81\cc\5b\17\01\86\74\b4\01\b4\2f\35\ba\07\bb\79\e2\11\23\9c\23\bf\fe\65\8d\a1\57\7e\3e\64\68\77\62\62\62\62\51\12\20\e7\dc\48\6e\97\e6\eb\e5\cd\ab\ab\3e\39\2b\da\d1\28\b6\e0\9a\cc\94\bb\4e\2a\a2\af\7b\98\6d\24\d0\12\2d\0a\24\01\55\12\20\61\be\55\a8\e2\f6\b4\e1\72\33\8b\dd\f1\84\d6\db\ee\29\c9\88\53\e0\a0\48\5e\ce\e7\f2\7b\9a\f0\b4\12\03\63\61\74\18\04\28\01\55\12\20\61\be\55\a8\e2\f6\b4\e1\72\33\8b\dd\f1\84\d6\db\ee\29\c9\88\53\e0\a0\48\5e\ce\e7\f2\7b\9a\f0\b4\61\61\61\61\36\01\71\12\20\69\ea\07\40\f9\80\7a\28\f4\d9\32\c6\2e\7c\1c\83\be\05\5e\55\07\2c\90\26\6a\b3\e7\9d\f6\3a\36\5b\a2\64\6c\69\6e\6b\f6\64\6e\61\6d\65\65\6c\69\6d\62\6f";
    }];
    for (testCase in testCases.vals()) {
      // let actualBlob = Blob.fromArray(CAR.toBytes(testCase.file));

      // if (actualBlob != testCase.expectedBytes) {
      //   Runtime.trap("toBytes failed\nExpected: " # debug_show (testCase.expectedBytes) # "\nActual:    " # debug_show (actualBlob));
      // };
      let fileFromBytes = switch (CAR.fromBytes(testCase.expectedBytes.vals())) {
        case (#ok(file)) file;
        case (#err(err)) Runtime.trap("fromBytes failed: " # err);
      };
      if (fileFromBytes != testCase.file) {
        Runtime.trap("fromBytes did not return the original file\nExpected: " # debug_show (testCase.file) # "\nActual:   " # debug_show (fileFromBytes));
      };
    };
  },
);
