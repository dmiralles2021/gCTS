class Y00CACL_ABAPDOC_PROGRAM definition
  public
  inheriting from Y00CACL_ABAPDOC
  final
  create public .

*"* public components of class Y00CACL_ABAPDOC_PROGRAM
*"* do not include other source files here!!!
public section.

  methods OLE_WORD_ADD_INFO_ROW
    importing
      !IS_OLE_FONT type OLE2_OBJECT
      value(IS_OLE_SELECTION) type OLE2_OBJECT
      !IV_HEADER type STRING
      !IV_TEXT type STRING .
  methods RENDER_ADD_INFO_DESCRIPTION
    importing
      !IS_OBJECT_ALV type y00cast_abapdoc_object_alv_s
      !IS_OUTPUT_OPTIONS type y00cast_abapdoc_output_options
      !IO_RENDER type ref to y00caif_abapdoc_render
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG
    raising
      y00cacx_abapdoc_render
      y00cacx_abapdoc.

  methods CHECK_EXISTS
    redefinition .
  methods GET_OBJECT_ORDER
    redefinition .
  methods GET_OBJECT_TEXT
    redefinition .
  methods GET_OBJECT_TYPE
    redefinition .
  methods OLE_WORD_ADD_INFO
    redefinition .
  methods RENDER_ADD_INFO
    redefinition .