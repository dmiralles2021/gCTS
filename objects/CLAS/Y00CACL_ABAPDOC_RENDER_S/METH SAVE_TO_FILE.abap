method SAVE_TO_FILE.
*----------------------------------------------------------------------*
* Method: SAVE_TO_FILE
*----------------------------------------------------------------------*
* Description:
* Render document and save to file
*----------------------------------------------------------------------*

  DATA:
    lo_render    TYPE REF TO lcl_ood_render,
    lx_ex        TYPE REF TO cx_ood_exception,
    lv_rel_id    TYPE string.


* Do check before render
  me->check_before_render( ).

  TRY.

*   Create render
      CREATE OBJECT lo_render.

*   Render fonts
      me->fonts->lif_docx_file~render( lo_render ).

*   Render styles
      me->styles->lif_docx_file~render( lo_render ).

*   Render numberings
      IF me->numberings IS BOUND.
        me->numberings->lif_docx_file~render( lo_render ).
      ENDIF.

*   Render header
      me->header->lif_docx_file~render( lo_render ).
      lv_rel_id = me->header->relation_id_get( ).
      me->document->header_relation_id_add( lv_rel_id ).

*   Render footer
      me->footer->lif_docx_file~render( lo_render ).
      lv_rel_id = me->footer->relation_id_get( ).
      me->document->footer_relation_id_add( lv_rel_id ).

*   Render document
      me->document->lif_docx_file~render( lo_render ).

*   Save to file
      lo_render->save_to_file(
        iv_target_file_path = iv_target_file_path
        iv_encoding         = iv_encoding
        iv_location         = iv_location
      ).

    CATCH cx_ood_exception INTO lx_ex.

      me->raise_exception( lx_ex ).
  ENDTRY.
endmethod.