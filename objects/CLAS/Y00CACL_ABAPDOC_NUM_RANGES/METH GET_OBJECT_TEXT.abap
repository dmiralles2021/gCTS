method GET_OBJECT_TEXT.

  DATA: lv_name  TYPE dd30v-shlpname,
        ls_dd30v TYPE dd30v,
        lt_dd30v TYPE TABLE OF dd30v,
        lv_text  TYPE string.

  CLEAR: ev_object_text_singl, ev_object_text_multi.

  lv_name = gv_obj_name.

  SELECT * FROM dd30v INTO TABLE lt_dd30v WHERE shlpname = lv_name.

  IF sy-subrc = 0.
    READ TABLE lt_dd30v INTO ls_dd30v WITH KEY ddlanguage = sy-langu.
    IF sy-subrc = 0.
     MESSAGE i101(y00camsg_abpdoc) WITH ls_dd30v-ddlanguage ls_dd30v-ddtext INTO ev_object_text_singl.
    ENDIF.

    LOOP AT lt_dd30v INTO ls_dd30v.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_dd30v-ddlanguage ls_dd30v-ddtext INTO lv_text.

      IF STRLEN( ev_object_text_multi ) > 0.
        CONCATENATE ev_object_text_multi cl_abap_char_utilities=>newline lv_text INTO ev_object_text_multi.
      ELSE.
        ev_object_text_multi = lv_text.
      ENDIF.
    ENDLOOP.
  ENDIF.

endmethod.