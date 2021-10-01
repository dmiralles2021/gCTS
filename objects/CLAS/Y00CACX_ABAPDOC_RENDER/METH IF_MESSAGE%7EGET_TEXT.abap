method IF_MESSAGE~GET_TEXT.
*----------------------------------------------------------------------*
* Method: IF_MESSAGE~GET_TEXT
*----------------------------------------------------------------------*
* Description:
* Method return text from messages or super.
*----------------------------------------------------------------------*

  DATA:
    ls_return TYPE BAPIRET2.

  IF NOT me->messages IS INITIAL.
    LOOP AT me->messages INTO ls_return.
      CONCATENATE result ls_return-message INTO result
                 SEPARATED BY SPACE.
    ENDLOOP.
  ELSE.
    result = super->if_message~get_text( ).
  ENDIF.
endmethod.