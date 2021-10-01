private section.
*"* private components of class Y00CACL_ABAPDOC_MAIN
*"* do not include other source files here!!!

  data OUTPUT_OPTIONS type y00cast_abapdoc_output_options.
  data GS_OLE_APPLICATION type OLE2_OBJECT .
  data GS_OLE_WORD type OLE2_OBJECT .
  data GS_OLE_DOCUMENTS type OLE2_OBJECT .
  data GS_OLE_ACTDOC type OLE2_OBJECT .
  data GS_OLE_OPTIONS type OLE2_OBJECT .
  data GS_OLE_ACTWIN type OLE2_OBJECT .
  data GS_OLE_VIEW type OLE2_OBJECT .
  data GS_OLE_SELECTION type OLE2_OBJECT .
  data GS_OLE_FONT type OLE2_OBJECT .
  data GS_OLE_PARFORMAT type OLE2_OBJECT .
  data GS_OLE_TABLES type OLE2_OBJECT .
  data GS_OLE_RANGE type OLE2_OBJECT .
  data GS_OLE_TABLE type OLE2_OBJECT .
  data GS_OLE_BORDER type OLE2_OBJECT .
  data GS_OLE_CELL type OLE2_OBJECT .
  data GS_OLE_PARAGRAPHS type OLE2_OBJECT .
  data GT_PLUGIN type y00catt_abapdoc_plugin_t.
  data GT_OBJECT_ALV type y00catt_abapdoc_object_alv_t .

  class-methods GET_TEXT_FOR_OBJ_TYPE
    importing
      !IV_OBJ_TYPE type TROBJTYPE
    exporting
      !EV_OBJ_TYPE_TEXT type STRING .
  methods OLE_WORD_ADD_TABLE_OBJ_TYPE
    importing
      !IS_PLUGIN type y00cast_abapdoc_plugin_s
    exporting
      !EV_TEXT_ERROR type STRING
      !EF_RESULT type FLAG .
  methods OLE_WORD_ADD_TEXT_OBJ_TYPE
    importing
      !IS_PLUGIN type y00cast_abapdoc_plugin_s
    exporting
      !EV_TEXT_ERROR type STRING
      !EF_RESULT type FLAG .
  methods OLE_WORD_FREE
    exporting
      !EV_TEXT_ERROR type STRING
      !EF_RESULT type FLAG .
  methods OLE_WORD_INITIALIZE
    exporting
      !EV_TEXT_ERROR type STRING
      !EF_RESULT type FLAG .
  methods RENDER_TECH_DOC
    importing
      value(IO_RENDER) type ref to Y00CAIF_ABAPDOC_RENDER optional
    exporting
      value(EF_RESULT) type FLAG
      value(EV_TEXT_ERROR) type STRING .
  methods XML_TECH_DOC
    importing
      value(IO_XML_DOCUMENT) type ref to CL_XML_DOCUMENT optional
    exporting
      value(EF_RESULT) type FLAG
      value(EV_TEXT_ERROR) type STRING .