method GET_OBJECT_TEXT.

  DATA: lv_name  TYPE ddobjname,
        ls_dd02v TYPE dd02t,
        lt_dd02v TYPE TABLE OF dd02t,
        lv_text  TYPE string.

  CLEAR: ev_object_text_singl, ev_object_text_multi.
  SELECT * FROM dd02t INTO TABLE lt_dd02v WHERE tabname = gv_obj_name.

  IF sy-subrc = 0.
    READ TABLE lt_dd02v INTO ls_dd02v WITH KEY ddlanguage = sy-langu.
    IF sy-subrc = 0.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_dd02v-ddlanguage ls_dd02v-ddtext INTO ev_object_text_singl.
    ENDIF.
    LOOP AT lt_dd02v INTO ls_dd02v.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_dd02v-ddlanguage ls_dd02v-ddtext INTO lv_text.
      IF strlen( ev_object_text_multi ) > 0.
        CONCATENATE ev_object_text_multi cl_abap_char_utilities=>newline lv_text INTO ev_object_text_multi.
      ELSE.
        ev_object_text_multi = lv_text.
      ENDIF.
    ENDLOOP.
  ENDIF.

endmethod.