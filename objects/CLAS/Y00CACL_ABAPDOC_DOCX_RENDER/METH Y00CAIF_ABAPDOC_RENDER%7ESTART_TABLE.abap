  method Y00CAIF_ABAPDOC_RENDER~START_TABLE.
*----------------------------------------------------------------------*
* Method: ZIF_KCT_ABAP_DOC_RENDER~START_TABLE
*----------------------------------------------------------------------*
* Description:
* Start new table
*----------------------------------------------------------------------*

  DATA:
    lx_ex TYPE REF TO y00cacx_docx_render_s.

  TRY.
    me->docx->start_table( STYLE_TABLE ).
  CATCH y00cacx_docx_render_s INTO lx_ex.
    RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
      EXPORTING messages = lx_ex->messages.
  ENDTRY.
  endmethod.