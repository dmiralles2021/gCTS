class Y00CACX_ABAPDOC_RENDER definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_KCT_ABAP_DOC_RENDER
*"* do not include other source files here!!!
public section.

  constants Y00CACX_ABAPDOC_RENDER type SOTR_CONC value '487B6B7ACCED1EDB9FACB737D7328263' ##NO_TEXT.
*  constants ZCX_KCT_ABAP_DOC_RENDER type SOTR_CONC value 'E2F475820B536CF19D95005056815D12'. "#EC NOTEXT
  data MESSAGES type BAPIRETTAB .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !MESSAGES type BAPIRETTAB optional .

  methods IF_MESSAGE~GET_TEXT
    redefinition .