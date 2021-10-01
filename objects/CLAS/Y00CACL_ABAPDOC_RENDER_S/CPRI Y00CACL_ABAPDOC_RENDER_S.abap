private section.
*"* private components of class Y00CACL_ABAPDOC_RENDER_S
*"* do not include other source files here!!!

  data FONTS type ref to LCL_OOD_FONTS_FILE .
  data STYLES type ref to LCL_OOD_STYLES_FILE .
  data NUMBERINGS type ref to LCL_OOD_NUMBERINGS_FILE .
  data DOCUMENT type ref to LCL_OOD_DOCUMENT_FILE .
  data HEADER type ref to LCL_OOD_HEADER_FILE .
  data FOOTER type ref to LCL_OOD_FOOTER_FILE .
  data CURRENT_TABLE type ref to LCL_TABLE_ELEMENT .
  data CURRENT_TABLE_ROW type FLAG .

  methods RAISE_MESSAGE_EXCEPTION
    importing
      value(IV_MSGV2) type MSGV2 default 'ZKCT_OOD'
      value(IV_MSGV3) type MSGV3 optional
      value(IV_MSGV4) type MSGV4 optional
      value(IV_MSGID) type MSGID optional
      value(IV_MSGNO) type MSGNO
      value(IV_MSGV1) type MSGV1 optional
    raising
      y00cacx_docx_render_s .
  methods RAISE_EXCEPTION
    importing
      !IO_LOCAL_EXCEPTION type ref to CX_OOD_EXCEPTION
    raising
      y00cacx_docx_render_s .
  methods CHECK_BEFORE_RENDER
    raising
      y00cacx_docx_render_s .