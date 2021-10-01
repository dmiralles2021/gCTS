class-pool MESSAGE-ID Y00CAMSG_ABPDOC.
*"* class pool for class Y00CACL_ABAPDOC_TABLE_TYPE

*"* local type definitions
include Y00CACL_ABAPDOC_TABLE_TYPE====ccdef.

*"* class Y00CACL_ABAPDOC_TABLE_TYPE definition
*"* public declarations
  include Y00CACL_ABAPDOC_TABLE_TYPE====cu.
*"* protected declarations
  include Y00CACL_ABAPDOC_TABLE_TYPE====co.
*"* private declarations
  include Y00CACL_ABAPDOC_TABLE_TYPE====ci.
endclass. "Y00CACL_ABAPDOC_TABLE_TYPE definition

*"* macro definitions
include Y00CACL_ABAPDOC_TABLE_TYPE====ccmac.
*"* local class implementation
include Y00CACL_ABAPDOC_TABLE_TYPE====ccimp.

class Y00CACL_ABAPDOC_TABLE_TYPE implementation.
*"* method's implementations
  include methods.
endclass. "Y00CACL_ABAPDOC_TABLE_TYPE implementation
