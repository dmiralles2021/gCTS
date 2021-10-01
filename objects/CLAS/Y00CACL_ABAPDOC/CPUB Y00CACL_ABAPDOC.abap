class Y00CACL_ABAPDOC definition
  public
  abstract
  create public .

*"* public components of class Y00CACL_ABAPDOC
*"* do not include other source files here!!!
public section.

  data GV_OBJ_NAME type STRING .
  constants CO_NODE_1COL type STRING value 'object' ##NO_TEXT.
  constants CO_NODE_2COL type STRING value 'component' ##NO_TEXT.
  constants CO_NODE_3COL_A type STRING value 'handler' ##NO_TEXT.
  constants CO_NODE_3COL type STRING value 'plug' ##NO_TEXT.
  constants CO_NODE_4COL type STRING value 'navigation' ##NO_TEXT.
  constants CO_NODE_ROOT type STRING value 'schemaModel' ##NO_TEXT.
  constants CO_OBJ_TYPE_WDC type STRING value 'webDynproComponent' ##NO_TEXT.
  constants CO_OBJ_TYPE_BSP type STRING value 'bspAplication' ##NO_TEXT.
  constants CO_HANDLER_EVENT type STRING value 'event' ##NO_TEXT.
  constants CO_HANDLER_LIST_INCLUDE type STRING value 'listInclude' ##NO_TEXT.
  constants CO_HANDLER_TREE_INCLUDE type STRING value 'treeInclude' ##NO_TEXT.
  constants CO_WDC_TYPE_USED type STRING value 'usedComponent' ##NO_TEXT.
  constants CO_WDC_TYPE_VIEW type STRING value 'view' ##NO_TEXT.
  constants CO_WDC_TYPE_WINDOW type STRING value 'window' ##NO_TEXT.
  constants CO_PLUG_TYPE_IN type STRING value 'inbound' ##NO_TEXT.
  constants CO_PLUG_TYPE_INCLUDE type STRING value 'include' ##NO_TEXT.
  constants CO_PLUG_TYPE_OUT type STRING value 'outbound' ##NO_TEXT.
  constants CO_BSP_TYPE_CONTROLLER type STRING value 'controller' ##NO_TEXT.
  constants CO_BSP_TYPE_VIEW type STRING value 'view' ##NO_TEXT.
  constants CO_BSP_TYPE_FLOW type STRING value 'flowLogic' ##NO_TEXT.
  constants CO_BSP_TYPE_FRAGMENT type STRING value 'fragment' ##NO_TEXT.

  class-methods CHOOSE_BY_PREFERRED_LANGU
    importing
      !IT_LANG_DEP type STANDARD TABLE
      !IV_LANGU_FIELD type FIELDNAME
      !IV_PREFERRED_LANGU type SYLANGU default SY-LANGU
    exporting
      !ES_LANG_DEP type ANY .
  methods CHECK_EXISTS
  abstract
    returning
      value(RV_EXISTS) type FLAG .
  class-methods CLDES_TO_SUPERCLASS
    importing
      !IV_CLDES type ref to CL_ABAP_CLASSDESCR
    returning
      value(RV_CLDES_SUPERCLASS) type ref to CL_ABAP_CLASSDESCR .
  methods CONSTRUCTOR
    importing
      !NAME type STRING .
  methods GET_CODE_COMMENT
    importing
      !IV_OBJ_NAME type STRING
      !IV_FROM_LINE type I optional
      !IV_UP_TO_LINE type I optional
      !IT_KEY_WORDS type Y00CATT_ABAPDOC_KWORD_SO_T optional
    returning
      value(RT_TEXT) type STRINGTAB .
  methods GET_DOCUMENTATION
    importing
      !IV_OBJ_NAME type STRING
      !IV_DOCUMENT_CLASS type DOKIL-ID optional
    returning
      value(RT_DOCUMENTATION) type STRINGTAB
    raising
      Y00CACX_ABAPDOC_RENDER
      Y00CACX_ABAPDOC .
  class-methods GET_DOMAIN_TEXT
    importing
      !IV_DOMAIN_NAME type STRING
      !IV_DOMAIN_VALUE type STRING
    returning
      value(RV_DOMAIN_TEXT) type STRING .
  methods GET_OBJECT_ORDER
  abstract
    returning
      value(RV_OBJECT_ORDER) type INT4 .
  methods GET_OBJECT_TEXT
  abstract
    exporting
      value(EV_OBJECT_TEXT_SINGL) type STRING
      value(EV_OBJECT_TEXT_MULTI) type STRING .
  methods GET_OBJECT_TYPE
  abstract
    returning
      value(RV_OBJECT_TYPE) type STRING .
  class-methods GET_TAB_PREFERRED_LANGU
    importing
      !IV_MOST_PREFERRED_LANGU type SYLANGU default SY-LANGU
    preferred parameter IV_MOST_PREFERRED_LANGU
    returning
      value(RT_PREFERRED_LANGU) type Y00CATT_ABAPDOC_LANGU_T .
  methods IS_SUPPORT_OUTPUT_TYPE
    importing
      !IV_OUTPUT_TYPE type Y00CADT_ABAPDOC_OUTPUT_TYPE
    returning
      value(RV_SUPPORT) type FLAG .
  methods OLE_WORD_ADD_INFO
  abstract
    importing
      !IS_OBJECT_ALV type Y00CAST_ABAPDOC_OBJECT_ALV_S
      !IS_OUTPUT_OPTIONS type Y00CAST_ABAPDOC_OUTPUT_OPTIONS
      value(IS_OLE_WORD) type OLE2_OBJECT
    exporting
      !EV_TEXT_ERROR type STRING
      !EF_RESULT type FLAG
    raising
      Y00CACX_ABAPDOC .
  methods RENDER_ADD_INFO
  abstract
    importing
      !IS_OBJECT_ALV type Y00CAST_ABAPDOC_OBJECT_ALV_S
      !IS_OUTPUT_OPTIONS type Y00CAST_ABAPDOC_OUTPUT_OPTIONS
      !IO_RENDER type ref to Y00CAIF_ABAPDOC_RENDER
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG
    raising
      Y00CACX_ABAPDOC_RENDER
      Y00CACX_ABAPDOC .
  methods VALUE_HELP
    importing
      !IV_OBJ_TYPE type STRING
    returning
      value(RV_OBJ_NAME) type STRING .
  methods XML_ADD_INFO
    importing
      !IS_OBJECT_ALV type Y00CAST_ABAPDOC_OBJECT_ALV_S
      !IS_OUTPUT_OPTIONS type Y00CAST_ABAPDOC_OUTPUT_OPTIONS
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
    exporting
      !EV_TEXT_ERROR type STRING
      !EF_RESULT type FLAG .
  class-methods FILENAME_SPLIT
    importing
      !PF_DOCID type TEXT255
    exporting
      !PF_DIRECTORY type TEXT255
      !PF_FILENAME type TEXT255
      !PF_EXTENSION type TEXT255 .