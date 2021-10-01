class Y00CACL_ABAPDOC_TRANSPORT definition
  public
  inheriting from Y00CACL_ABAPDOC
  final
  create public .

*"* public components of class Y00CACL_ABAPDOC_TRANSPORT
*"* do not include other source files here!!!
public section.

  class-methods RENDER_ADD_INFO_DOKU
    importing
      !IS_OUTPUT_OPTIONS type y00cast_abapdoc_output_options
      !IO_RENDER type ref to y00caif_abapdoc_render
      !IT_REQUESTS type y00catt_abapdoc_trkorr_t .
  class-methods RENDER_ADD_INFO_DOKU__GET
    importing
      !IV_TRKORR type TRKORR
    exporting
      !ET_DOKU type STRINGTAB .
  class-methods RENDER_ADD_INFO_DOKU__PRINT
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render
      !IV_TRKORR type TRKORR
      !IT_DOKU type STRINGTAB .
  class-methods RENDER_DOKU_FOR_TRANSPORT .
  class-methods TR_REQ_ID_TO_DESCRIPTION
    importing
      !IV_REQ_ID type TRKORR
      !IV_PREFERRED_LANGU type SYLANGU default SY-LANGU
    returning
      value(RV_DESCRIPTION) type STRING .
  class-methods TR_REQ_ID_TO_DESCR__INTERNAL
    importing
      !IV_REQ_ID type TRKORR
      !IV_PREFERRED_LANGU type SYLANGU default SY-LANGU
    exporting
      value(ET_E07T) type y00catt_abapdoc_e07t_t
      !ES_E07T_CHOSEN type E07T .
  methods OLE_WORD_ADD_INFO_ROW
    importing
      !IS_OLE_FONT type OLE2_OBJECT
      value(IS_OLE_SELECTION) type OLE2_OBJECT
      !IV_HEADER type STRING
      !IV_TEXT type STRING .

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