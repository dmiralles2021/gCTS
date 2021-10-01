  METHOD y00caif_abapdoc_render~add_comment_code.
*----------------------------------------------------------------------*
* Method: ZIF_KCT_ABAP_DOC_RENDER~ADD_COMMENT_CODE
*----------------------------------------------------------------------*
* Description:
* Add comment code.
*----------------------------------------------------------------------*

    DATA:
      lv_str TYPE string,
      lx_ex  TYPE REF TO y00cacx_docx_render_s.

    lv_str = me->table_to_string( it_text ).
    TRY.
        me->docx->append_paragraph(
          iv_style = style_comment
          iv_text  = lv_str
        ).
      CATCH y00cacx_docx_render_s INTO lx_ex.
        RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
          EXPORTING
            messages = lx_ex->messages.
    ENDTRY.
  ENDMETHOD.