method RAISE_EXCEPTION.
*----------------------------------------------------------------------*
* Method: RAISE_EXCEPTION
*----------------------------------------------------------------------*
* Description:
* This method collect all messages from local exception and all previous
* exceptions.
*----------------------------------------------------------------------*

  DATA:
    lt_return TYPE BAPIRETTAB,
    ls_return TYPE BAPIRET2,
    lv_str    TYPE string,
    lo_ex     TYPE REF TO cx_ood_exception,
    lo_rx     TYPE REF TO cx_root.

  lo_rx = io_local_exception.

* Loop trough all previous
  WHILE lo_rx IS BOUND.

*   Check if exception is local or unknown
    TRY.
      lo_ex ?= lo_rx.
    CATCH cx_root.
      CLEAR lo_ex.
    ENDTRY.

*   Add exception
    IF lo_ex IS BOUND.

*     Bapi message
      ls_return-id         = lo_ex->msgid.
      ls_return-number     = lo_ex->msgno.
      ls_return-message_v1 = lo_ex->msgv1.
      ls_return-message_v2 = lo_ex->msgv2.
      ls_return-message_v3 = lo_ex->msgv3.
      ls_return-message_v4 = lo_ex->msgv4.
      MESSAGE ID ls_return-id TYPE 'E' NUMBER ls_return-number
             WITH ls_return-message_v1 ls_return-message_v2
                  ls_return-message_v3 ls_return-message_v4
             INTO ls_return-message.

    ELSE.

*     Just text
      CLEAR ls_return.
      lv_str = lo_rx->if_message~get_text( ).
      ls_return-message = lv_str.

    ENDIF.
    APPEND ls_return TO lt_return.

*   Get previous exception
    lo_rx = lo_rx->previous.

  ENDWHILE.

* Raise exception
  RAISE EXCEPTION TYPE y00cacx_docx_render_s
       EXPORTING messages = lt_return.

endmethod.