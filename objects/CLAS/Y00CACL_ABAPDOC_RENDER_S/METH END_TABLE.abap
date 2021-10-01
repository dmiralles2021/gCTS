method END_TABLE.
*----------------------------------------------------------------------*
* Method: END_TABLE
*----------------------------------------------------------------------*
* Description:
* End current table definition and add it to document.
*----------------------------------------------------------------------*

  DATA:
    lx_ex TYPE REF TO cx_ood_exception.

* Check current table open
  IF NOT me->current_table IS BOUND.

    me->raise_message_exception( '038' ).
    IF 1 = 0. MESSAGE E038. ENDIF.
*   No table started.
  ENDIF.

* Check no row opened
  IF me->current_table_row EQ abap_true.

    me->raise_message_exception( '037' ).
    IF 1 = 0. MESSAGE E037. ENDIF.
*   Finish row before table.
  ENDIF.

  TRY.

*   Add current table to document
    me->document->body_element_add( me->current_table ).

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.

* Clear current table
  CLEAR me->current_table.
endmethod.