  method Y00CAIF_ABAPDOC_RENDER~RENDER_TO_FILE.
*----------------------------------------------------------------------*
* Method: ZIF_KCT_ABAP_DOC_RENDER~RENDER_TO_FILE
*----------------------------------------------------------------------*
* Description:
* Render document to file.
*----------------------------------------------------------------------*

  DATA:
    lv_str TYPE string,
    lx_ex  TYPE REF TO y00cacx_docx_render_s.

  TRY.
      me->docx->save_to_file(
        iv_target_file_path = iv_target_file_path
        iv_encoding         = iv_encoding
        iv_location         = iv_location
      ).
    CATCH y00cacx_docx_render_s INTO lx_ex.
      RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
        EXPORTING messages = lx_ex->messages.
  ENDTRY.
ENDMETHOD.