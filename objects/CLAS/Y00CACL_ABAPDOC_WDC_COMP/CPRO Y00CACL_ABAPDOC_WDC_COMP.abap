protected section.
*"* protected components of class Y00CACL_ABAPDOC_WDC_COMP
*"* do not include other source files here!!!

  data GT_NAVIGATION_TARGET_REFS type WDY_NAV_TARGREF_TABLE .
  data GT_MY_VSH_NODES type TT_MY_WDY_VSH_NODE_TABLE .
  data GT_VSH_PLACEHOLDERS type WDY_VSH_PHOLDER_TABLE .
  data GT_NAVIGATION_LINKS type WDY_NAV_LINK_TABLE .

  methods COPY_VSH_NODES
    importing
      !IT_VSH_NODES type WDY_VSH_NODE_TABLE .
  methods XML_ADD_INFO_PLUG_INCLUDE
    importing
      !IF_TREE_VIEW type FLAG
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
      !IO_XML_NODE type ref to IF_IXML_NODE
      !IS_MY_VSH_NODE type TS_MY_WDY_VSH_NODE
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG .
  methods XML_ADD_INFO_PLUG_IOBOUND
    importing
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
      !IO_XML_NODE type ref to IF_IXML_NODE
      !IS_IOBOUND_PLUG type WDY_IOBOUND_PLUG
      !IS_IOBOUND_PLUG_TEXT type WDY_IOBOUND_PLGT
      !IF_WINDOW type FLAG
      !IF_TREE_VIEW type FLAG
      !IV_VUSE_NAME type STRING optional
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG .
  methods XML_ADD_INFO_VIEW
    importing
      !IF_TREE_VIEW type FLAG
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
      !IO_XML_NODE type ref to IF_IXML_NODE
      !IS_MD_VIEW_KEY type WDY_MD_VIEW_KEY
      !IS_MY_VSH_NODE type TS_MY_WDY_VSH_NODE optional
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG .
  methods XML_ADD_INFO_WINDOW
    importing
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
      !IO_XML_NODE type ref to IF_IXML_NODE
      !IF_TREE_VIEW type FLAG
      !IS_MD_VIEW_KEY type WDY_MD_VIEW_KEY
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG .