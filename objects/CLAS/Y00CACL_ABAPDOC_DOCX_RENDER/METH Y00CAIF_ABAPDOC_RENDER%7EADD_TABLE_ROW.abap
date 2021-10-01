  method Y00CAIF_ABAPDOC_RENDER~ADD_TABLE_ROW.
*----------------------------------------------------------------------*
* Method: ZIF_KCT_ABAP_DOC_RENDER~ADD_TABLE_ROW
*----------------------------------------------------------------------*
* Description:
* Add table row.
*----------------------------------------------------------------------*

  DATA:
    lv_str TYPE string,
    lx_ex  TYPE REF TO y00cacx_docx_render_s.

  TRY.
      me->docx->start_table_row( ).
      LOOP AT it_cells INTO lv_str.
        me->docx->append_table_cell( iv_text = lv_str ).
      ENDLOOP.
      me->docx->end_table_row( ).
    CATCH y00cacx_docx_render_s INTO lx_ex.
      RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
        EXPORTING messages = lx_ex->messages.
  ENDTRY.
  endmethod.