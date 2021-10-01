class Y00CACX_DOCX_RENDER_S definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_KCT_DOCX_RENDER_S
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of Y00CACX_DOCX_RENDER_S,
      msgid type symsgid value 'Y00CAMSG_ABAPDOC_OOD',
      msgno type symsgno value '027',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of Y00CACX_DOCX_RENDER_S .
  data MESSAGES type BAPIRETTAB .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MESSAGES type BAPIRETTAB optional .