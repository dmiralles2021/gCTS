private section.
*"* private components of class Y00CACL_ABAPDOC_WDC_COMP
*"* do not include other source files here!!!

  methods ADD_WD_CONTEXT
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render
      !IT_CTX_NODES type WDY_CTX_NODE_TABLE
      !IT_CTX_ATTRS type WDY_CTX_ATTRIB_TABLE
      !IT_CTX_MAPPINGS type WDY_CTX_MAPPING_TABLE .
  methods ADD_WD_VIEW_LAYOUT
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render
      value(IT_UI_ELEMENTS) type WDY_UI_ELEMENT_TABLE
    raising
      Y00CACX_ABAPDOC_RENDER .
  class-methods CONVERT_METHOD_TYPE_DESCR
    importing
      !IV_CMP_TYPE type WDY_MD_OBJECT_TYPE
    returning
      value(RV_DESCR) type STRING .
  methods GET_COMP_USAGE_INFO
    returning
      value(RT_COMP_USAGE) type WDY_COMPO_USAGE_TABLE
    exceptions
      ERROR .
  class-methods GET_DATA_TYPE_DESCR
    importing
      !IV_DATA_TYPE type STRING
    returning
      value(RV_DESCR) type STRING .
  methods RENDER_CTX_ATTRS
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render
      !IV_NODE_NAME type WDY_CONTEXT_NODE_NAME
      !IV_TREE_LEVEL type I
      !IT_CTX_ATTRS type WDY_CTX_ATTRIB_TABLE .
  methods RENDER_CTX_NODES_TREE_RCS
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render
      !IV_PARENT_ND_NAME type WDY_CONTEXT_NODE_NAME
      !IV_TREE_LEVEL type I
      !IT_CTX_NODES type WDY_CTX_NODE_TABLE
      !IT_CTX_ATTRS type WDY_CTX_ATTRIB_TABLE .
  methods RENDER_EMPTY_LINE
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render .
  methods RENDER_LAYOUT_LVL
    importing
      value(IV_TREE_LEVEL) type I
      value(IV_PARENT_NAME) type WDY_UI_ELEMENT_NAME
      value(IT_UI_ELEMENTS) type WDY_UI_ELEMENT_TABLE
      !IO_RENDER type ref to y00caif_abapdoc_render
    raising
      Y00CACX_ABAPDOC_RENDER .