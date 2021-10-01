  method Y00CAIF_ABAPDOC_RENDER~ADD_TEXT.
*----------------------------------------------------------------------*
* Method: ZIF_KCT_ABAP_DOC_RENDER~ADD_TEXT
*----------------------------------------------------------------------*
* Description:
* Add simple text paragraph.
*----------------------------------------------------------------------*
  DATA:
    lv_str TYPE string,
    lx_ex  TYPE REF TO y00cacx_docx_render_s.

  lv_str = me->table_to_string( it_text ).
  TRY.
      me->docx->append_paragraph(
        iv_text  = lv_str
      ).
    CATCH y00cacx_docx_render_s INTO lx_ex.
      RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
        EXPORTING messages = lx_ex->messages.
  ENDTRY.
  endmethod.