class Y00CACL_ABAPDOC_MAIN definition
  public
  final
  create public .

*"* public components of class Y00CACL_ABAPDOC_MAIN
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ICON .

  constants CO_OUTPUT_DOCUMENT_XML type y00cadt_abapdoc_output_type value 'XML' ##NO_TEXT.
  constants CO_OUTPUT_DOCUMENT_OLE_DOC type y00cadt_abapdoc_output_type value 'OLE_DOC' ##NO_TEXT.
  constants CO_OUTPUT_DOCUMENT_DOCX type y00cadt_abapdoc_output_type value 'DOCX' ##NO_TEXT.
  constants CO_NTT_TRANSPORT_REQ type y00cadt_abapdoc_non_tadir_otyp value '++TR' ##NO_TEXT.
  constants CO_ROW_TYPE__TADIR type CHAR1 value 'T' ##NO_TEXT.
  constants CO_ROW_TYPE__NON_TADIR type CHAR1 value '+' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !IS_OUTPUT_OPTIONS type y00cast_abapdoc_output_options optional .
  methods GENERATE_TECH_DOC
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render optional
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT optional
    exporting
      value(EF_RESULT) type FLAG
      value(EV_TEXT_ERROR) type STRING .
  class-methods GET
    importing
      !IS_OUTPUT_OPTIONS type Y00CAST_ABAPDOC_OUTPUT_OPTIONS optional
    returning
      value(RO_MAIN) type ref to Y00CACL_ABAPDOC_MAIN .
  methods GET_OBJECT_ALV
    returning
      value(RT_OBJECT_ALV) type y00catt_abapdoc_object_alv_t.
  methods GET_PLUGIN
    returning
      value(RT_PLUGIN) type y00catt_abapdoc_plugin_t.
  class-methods GET_ROW_TYPE
    importing
      !IV_OBJ_TYPE type TROBJTYPE
    returning
      value(RV_ROW_TYPE) type CHAR1 .
  class-methods GET_ROW_TYPE__INTERNAL
    importing
      !IV_OBJ_TYPE type TROBJTYPE
    exporting
      !EV_NTT_DESCRIPTION type STRING
      value(EV_ROW_TYPE) type CHAR1 .
  methods INIT_OBJECT
    importing
      !IV_OUTPUT_TYPE type y00cadt_abapdoc_output_type
      !IV_OBJ_TYPE type TROBJTYPE optional
      !IV_OBJECT type STRING optional
      !IV_PACKAGE type DEVCLASS optional
      !IV_TRANSPORT type TRKORR optional
    returning
      value(RF_RESULT) type FLAG .
  methods SET_OBJECT_ALV
    importing
      value(IT_OBJECT_ALV) type y00catt_abapdoc_object_alv_t .
  methods SET_OUTPUT_OPTIONS
    importing
      !IS_OUTPUT_OPTIONS type y00cast_abapdoc_output_options.