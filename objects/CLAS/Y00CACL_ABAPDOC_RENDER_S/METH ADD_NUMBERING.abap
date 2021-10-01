method ADD_NUMBERING.
*----------------------------------------------------------------------*
* Method: ADD_NUMBERING
*----------------------------------------------------------------------*
* Description:
* Add numbering.
*----------------------------------------------------------------------*

  DATA:
    ls_numbering TYPE lts_docx_numbering,
    lx_ex        TYPE REF TO cx_ood_exception.

* Create object
  IF NOT me->numberings IS BOUND.
    CREATE OBJECT me->numberings.
  ENDIF.

* Move variables
  ls_numbering-multi_type = iv_multi_type.

  TRY.

*   Add numbering
    rv_id = me->numberings->numbering_add( ls_numbering ).

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.
endmethod.