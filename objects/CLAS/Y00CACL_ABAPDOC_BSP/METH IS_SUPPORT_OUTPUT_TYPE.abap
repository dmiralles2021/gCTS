method IS_SUPPORT_OUTPUT_TYPE.

  CALL METHOD super->is_support_output_type
    EXPORTING
      iv_output_type = iv_output_type
    RECEIVING
      rv_support     = rv_support.

  IF iv_output_type = y00cacl_abapdoc_main=>co_output_document_xml.
    rv_support = abap_true.
  ENDIF.

endmethod.