method START_TABLE.
*----------------------------------------------------------------------*
* Method: START_TABLE
*----------------------------------------------------------------------*
* Description:
* Start new table.
*----------------------------------------------------------------------*

* Check for previous table open in edit
  IF me->current_table IS BOUND.

    me->raise_message_exception( '033' ).
    IF 1 = 0. MESSAGE E033. ENDIF.
*   Finish previous table before starting new one.
  ENDIF.

* Create table
  CREATE OBJECT me->current_table
    EXPORTING
      iv_style = iv_style.
endmethod.