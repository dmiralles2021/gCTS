protected section.
*"* protected components of class Y00CACL_ABAPDOC_DOCX_RENDER
*"* do not include other source files here!!!

  methods CREATE_RENDER
    returning
      value(RO_RENDER) type ref to Y00CACL_ABAPDOC_RENDER_S
    raising
      Y00CACX_ABAPDOC_RENDER .