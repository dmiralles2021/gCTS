method APPEND_TABLE_CELL.
*----------------------------------------------------------------------*
* Method: APPEND_TABLE_CELL
*----------------------------------------------------------------------*
* Description:
* Append cell to table.
*----------------------------------------------------------------------*

  DATA:
    lx_ex TYPE REF TO cx_ood_exception.

* Check current table and row opened.
  IF NOT me->current_table IS BOUND OR me->current_table_row NE abap_true.

    me->raise_message_exception( '036' ).
    IF 1 = 0. MESSAGE E036. ENDIF.
*   Start table and row before adding cells.
  ENDIF.

  TRY.

*   Add new rod
    me->current_table->cell_add( iv_style = iv_style iv_text = iv_text ).

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.

endmethod.