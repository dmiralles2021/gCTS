class Y00CACL_ABAPDOC_WDC_COMP definition
  public
  inheriting from Y00CACL_ABAPDOC
  final
  create public .

*"* public components of class Y00CACL_ABAPDOC_WDC_COMP
*"* do not include other source files here!!!
public section.

  class-methods GET_COMPONENT_BY_NAME
    importing
      value(IV_NAME) type WDY_COMPONENT_NAME
    exporting
      value(IR_OBJECT) type ref to IF_WDY_MD_COMPONENT
    exceptions
      ERROR .
  class-methods GET_COMPONENT_IF_BY_NAME
    importing
      value(IV_NAME) type WDY_COMPONENT_NAME
    exporting
      value(IR_OBJECT) type ref to IF_WDY_MD_COMPONENT_INTERFACE
    exceptions
      ERROR .
  class-methods READ_COMPONENT_DESCRIPTION
    importing
      value(IV_NAME) type WDY_COMPONENT_NAME
      value(IV_LANGU) type SY-LANGU default SY-LANGU
    exporting
      value(EV_DESCRIPTION) type WDY_MD_DESCRIPTION .
  methods RENDER_ADD_INFO_CONTROLLER
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render
      !IR_CONTROLLER type ref to IF_WDY_MD_CONTROLLER
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG
    raising
      Y00CACX_ABAPDOC_RENDER
      y00cacx_abapdoc .
  methods RENDER_ADD_INFO_VIEW
    importing
      !IO_RENDER type ref to y00caif_abapdoc_render
      !IR_VIEW type ref to IF_WDY_MD_ABSTRACT_VIEW
    exporting
      value(EV_TEXT_ERROR) type STRING
      value(EF_RESULT) type FLAG
    raising
      Y00CACX_ABAPDOC_RENDER
      y00cacx_abapdoc .

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