  method Y00CAIF_ABAPDOC_RENDER~ADD_WD_CTX_NODE.
*----------------------------------------------------------------------*
* Method: ZIF_KCT_ABAP_DOC_RENDER~ADD_WD_CTX_NODE
*----------------------------------------------------------------------*
* Description: Add context node for node
*----------------------------------------------------------------------*

  DATA: lv_str    TYPE string,
        lx_ex     TYPE REF TO y00cacx_docx_render_s,
        lv_indent TYPE i.

  lv_str = me->table_to_string( it_text ).
  lv_indent = iv_tree_level * 200.

  TRY.
      me->docx->append_paragraph(
        iv_style        = style_wd_ctx_node
        iv_text         = lv_str
        iv_indent_left  = lv_indent
      ).
    CATCH y00cacx_docx_render_s INTO lx_ex.
      RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
        EXPORTING messages = lx_ex->messages.
  ENDTRY.
  endmethod.