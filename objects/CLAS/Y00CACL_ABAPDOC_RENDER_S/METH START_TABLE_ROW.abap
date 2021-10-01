method START_TABLE_ROW.
*----------------------------------------------------------------------*
* Method: START_TABLE_ROW
*----------------------------------------------------------------------*
* Description:
* Start new table row.
*----------------------------------------------------------------------*

  DATA:
    lx_ex TYPE REF TO cx_ood_exception.

* Check current table open
  IF NOT me->current_table IS BOUND.

    me->raise_message_exception( '035' ).
    IF 1 = 0. MESSAGE E035. ENDIF.
*   Start table before adding rows.
  ENDIF.

* Check no row opened
  IF me->current_table_row EQ abap_true.

    me->raise_message_exception( '034' ).
    IF 1 = 0. MESSAGE E034. ENDIF.
*   Finish previous row before adding new one.
  ENDIF.

  TRY.

*   Add new rod
    me->current_table->row_add( iv_style ).

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.

* Set row
  me->current_table_row = abap_true.

endmethod.