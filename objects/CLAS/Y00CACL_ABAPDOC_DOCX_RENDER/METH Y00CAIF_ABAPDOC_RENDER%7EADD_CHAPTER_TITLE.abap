  method Y00CAIF_ABAPDOC_RENDER~ADD_CHAPTER_TITLE.
*----------------------------------------------------------------------*
* Method: ZIF_KCT_ABAP_DOC_RENDER~ADD_CHAPTER_TITLE
*----------------------------------------------------------------------*
* Description:
* Add chapter title
*----------------------------------------------------------------------*

  DATA:
    lx_ex TYPE REF TO y00cacx_docx_render_s.

  TRY.
      me->docx->append_paragraph(
        iv_style = style_chapter
        iv_text  = iv_text
      ).
    CATCH y00cacx_docx_render_s INTO lx_ex.
      RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
        EXPORTING messages = lx_ex->messages.
  ENDTRY.
  endmethod.