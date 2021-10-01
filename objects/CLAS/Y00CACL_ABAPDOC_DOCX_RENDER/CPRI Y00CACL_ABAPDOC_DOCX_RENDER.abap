private section.
*"* private components of class Y00CACL_ABAPDOC_DOCX_RENDER
*"* do not include other source files here!!!

  data DOCX type ref to Y00CACL_ABAPDOC_RENDER_S .

  methods TABLE_TO_STRING
    importing
      !IT_TEXT type STRINGTAB
    returning
      value(RV_TEXT) type STRING .