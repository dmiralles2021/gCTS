method GET_OBJECT_TEXT.

  DATA: lv_name  TYPE ddobjname,
        ls_dd01v TYPE dd01t,
        lt_dd01v TYPE TABLE OF dd01t,
        lv_text  TYPE string.

  CLEAR: ev_object_text_singl, ev_object_text_multi.
  SELECT * FROM dd01t INTO TABLE lt_dd01v WHERE domname = gv_obj_name.

  IF sy-subrc = 0.
    READ TABLE lt_dd01v INTO ls_dd01v WITH KEY ddlanguage = sy-langu.
    IF sy-subrc = 0.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_dd01v-ddlanguage ls_dd01v-ddtext INTO ev_object_text_singl.
    ENDIF.
    LOOP AT lt_dd01v INTO ls_dd01v.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_dd01v-ddlanguage ls_dd01v-ddtext INTO lv_text.
      IF strlen( ev_object_text_multi ) > 0.
        CONCATENATE ev_object_text_multi cl_abap_char_utilities=>newline lv_text INTO ev_object_text_multi.
      ELSE.
        ev_object_text_multi = lv_text.
      ENDIF.
    ENDLOOP.
  ENDIF.

endmethod.