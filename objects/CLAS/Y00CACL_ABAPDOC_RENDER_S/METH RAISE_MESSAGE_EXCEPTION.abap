method RAISE_MESSAGE_EXCEPTION.
*----------------------------------------------------------------------*
* Method: RAISE_EXCEPTION
*----------------------------------------------------------------------*
* Description:
* This method collect all messages from local exception and all previous
* exceptions.
*----------------------------------------------------------------------*

  DATA:
    lt_return TYPE BAPIRETTAB,
    ls_return TYPE BAPIRET2.

* Create BAPI message
  ls_return-id         = iv_msgid.
  ls_return-number     = iv_msgno.
  ls_return-message_v1 = iv_msgv1.
  ls_return-message_v2 = iv_msgv2.
  ls_return-message_v3 = iv_msgv3.
  ls_return-message_v4 = iv_msgv4.
  MESSAGE ID ls_return-id TYPE 'E' NUMBER ls_return-number
         WITH ls_return-message_v1 ls_return-message_v2
              ls_return-message_v3 ls_return-message_v4
         INTO ls_return-message.
  APPEND ls_return TO lt_return.

* Raise exception
  RAISE EXCEPTION TYPE y00cacx_docx_render_s
       EXPORTING messages = lt_return.

endmethod.