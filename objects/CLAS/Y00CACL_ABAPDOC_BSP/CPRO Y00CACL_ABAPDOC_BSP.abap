protected section.
*"* protected components of class Y00CACL_ABAPDOC_BSP
*"* do not include other source files here!!!

  methods GET_CODE_LAYOUT
    importing
      !IT_PAGELINE type O2PAGELINE_TABLE
      !IT_KEY_WORDS type y00catt_abapdoc_kword_so_t optional
    returning
      value(RT_TEXT) type STRINGTAB .
  methods XML_ADD_INFO_EVENT_CONTROLLER
    importing
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
      !IO_XML_NODE type ref to IF_IXML_NODE
      !IS_PAGE_ATTRIB type O2PAGATTR
      !IS_OUTPUT_OPTIONS type y00cast_abapdoc_output_options
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG .
  methods XML_ADD_INFO_EVENT_PAGE_LAYOUT
    importing
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
      !IO_XML_NODE type ref to IF_IXML_NODE
      !IS_PAGE_ATTRIB type O2PAGATTR
      !IS_OUTPUT_OPTIONS type y00cast_abapdoc_output_options
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG .
  methods XML_ADD_INFO_PAGE
    importing
      !IO_XML_DOCUMENT type ref to CL_XML_DOCUMENT
      !IO_XML_NODE type ref to IF_IXML_NODE
      !IS_PAGE_ATTRIB type O2PAGATTR
      !IS_OUTPUT_OPTIONS type y00cast_abapdoc_output_options
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG .