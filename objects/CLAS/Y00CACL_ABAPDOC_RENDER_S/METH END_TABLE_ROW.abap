method END_TABLE_ROW.
*----------------------------------------------------------------------*
* Method: END_TABLE_ROW
*----------------------------------------------------------------------*
* Description:
* End table row.
*----------------------------------------------------------------------*

* Check row opened
  IF me->current_table_row NE abap_true.

    me->raise_message_exception( '039' ).
    IF 1 = 0. MESSAGE E039. ENDIF.
*   No row started.
  ENDIF.

* End row
  CLEAR me->current_table_row.
endmethod.