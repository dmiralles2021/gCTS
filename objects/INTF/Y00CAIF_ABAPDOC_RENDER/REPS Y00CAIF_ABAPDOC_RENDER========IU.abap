interface Y00CAIF_ABAPDOC_RENDER
  public .


  methods ADD_CHAPTER_TITLE
    importing
      value(IV_TEXT) type STRING
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_COMMENT_CODE
    importing
      !IT_TEXT type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_DESCRIPTION
    importing
      !IT_TEXT type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_DESCRIPTION2
    importing
      !IT_TEXT type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_WD_CTX_ATTRIBUTE
    importing
      !IT_TEXT type STRINGTAB
      !IV_TREE_LEVEL type I
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_WD_CTX_NODE
    importing
      !IT_TEXT type STRINGTAB
      !IV_TREE_LEVEL type I
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_WD_LAYOUT_ITEM
    importing
      !IT_TEXT type STRINGTAB
      !IV_TREE_LEVEL type I
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_DOCUMENTATION
    importing
      !IT_TEXT type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_OBJECT_SUBTITLE
    importing
      value(IV_TEXT) type STRING
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_OBJECT_SUBTITLE2
    importing
      value(IV_TEXT) type STRING
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_OBJECT_TITLE
    importing
      value(IV_TEXT) type STRING
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_TABLE_HEADER_ROW
    importing
      !IT_CELLS type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_TABLE_ROW
    importing
      !IT_CELLS type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods ADD_TEXT
    importing
      !IT_TEXT type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods END_TABLE
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods RENDER_TO_FILE
    importing
      value(IV_TARGET_FILE_PATH) type STRING
      value(IV_ENCODING) type STRING optional
      value(IV_LOCATION) type DXLOCATION default 'P'
    raising
      Y00CACX_ABAPDOC_RENDER .
  methods START_TABLE
    raising
      Y00CACX_ABAPDOC_RENDER .
endinterface.