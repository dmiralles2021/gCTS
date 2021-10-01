method IS_SUPPORT_OUTPUT_TYPE.

  rv_support = abap_false.

  CASE iv_output_type.
    WHEN y00cacl_abapdoc_main=>co_output_document_docx.
      rv_support = abap_true.
    WHEN y00cacl_abapdoc_main=>co_output_document_ole_doc.
      rv_support = abap_true.
  ENDCASE.

endmethod.