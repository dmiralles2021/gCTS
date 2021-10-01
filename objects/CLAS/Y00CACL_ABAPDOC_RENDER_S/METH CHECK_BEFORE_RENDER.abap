method CHECK_BEFORE_RENDER.
*----------------------------------------------------------------------*
* Method: CHECK_BEFORE_RENDER
*----------------------------------------------------------------------*
* Description:
* Check before render start.
*----------------------------------------------------------------------*

* Check for opened table
  IF me->current_table IS BOUND.

    me->raise_message_exception( '040' ).
    IF 1 = 0. MESSAGE E040. ENDIF.
*   Finish table definition before render.
  ENDIF.
endmethod.