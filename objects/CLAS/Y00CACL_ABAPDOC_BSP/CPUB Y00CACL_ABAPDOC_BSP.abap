class Y00CACL_ABAPDOC_BSP definition
  public
  inheriting from Y00CACL_ABAPDOC
  final
  create public .

*"* public components of class Y00CACL_ABAPDOC_BSP
*"* do not include other source files here!!!
public section.

  data GT_NAVIGATION type O2APPLGRAP_TABLE .
  data GT_PAGE type O2PAGELIST .

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
  methods IS_SUPPORT_OUTPUT_TYPE
    redefinition .
  methods OLE_WORD_ADD_INFO
    redefinition .
  methods RENDER_ADD_INFO
    redefinition .
  methods XML_ADD_INFO
    redefinition .