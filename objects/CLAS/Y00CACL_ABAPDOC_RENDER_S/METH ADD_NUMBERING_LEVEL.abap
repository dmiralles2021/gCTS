method ADD_NUMBERING_LEVEL.
*----------------------------------------------------------------------*
* Method: ADD_NUMBERING_LEVEL
*----------------------------------------------------------------------*
* Description:
* Add numbering level.
*----------------------------------------------------------------------*

  DATA:
    ls_level TYPE lts_docx_numbering_level,
    lx_ex        TYPE REF TO cx_ood_exception.

* Create object
  IF NOT me->numberings IS BOUND.
    CREATE OBJECT me->numberings.
  ENDIF.

* Move variables
  ls_level-id = iv_id.
  ls_level-level = iv_level.
  ls_level-start = iv_start.
  ls_level-format = iv_format.
  ls_level-style = iv_style.
  ls_level-level_text = iv_level_text.

  TRY.

*   Add level
    me->numberings->numbering_level_add( ls_level ).

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.
endmethod.