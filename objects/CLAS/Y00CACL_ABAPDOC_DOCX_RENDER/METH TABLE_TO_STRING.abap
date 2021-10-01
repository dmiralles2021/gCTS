method TABLE_TO_STRING.
*----------------------------------------------------------------------*
* Method: TABLE_TO_STRING
*----------------------------------------------------------------------*
* Description:
* Convert string table to string
*----------------------------------------------------------------------*

  DATA:
    lv_str TYPE string.

  LOOP AT it_text INTO lv_str.
    IF NOT rv_text IS INITIAL.
      CONCATENATE rv_text lv_str INTO rv_text
                 SEPARATED BY CL_ABAP_CHAR_UTILITIES=>CR_LF.
    ELSE.
      rv_text = lv_str.
    ENDIF.
  ENDLOOP.
endmethod.