method GET_OBJECT_TEXT.
   DATA: lv_name  TYPE ddobjname,
        ls_DD04v TYPE DD04t,
        lt_DD04v TYPE TABLE OF DD04t,
        lv_text  TYPE string.

  CLEAR: ev_object_text_singl, ev_object_text_multi.
  SELECT * FROM DD04t INTO TABLE lt_DD04v WHERE   ROLLNAME = gv_obj_name.

  IF sy-subrc = 0.
    READ TABLE lt_DD04v INTO ls_DD04v WITH KEY ddlanguage = sy-langu.
    IF sy-subrc = 0.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_DD04v-ddlanguage ls_DD04v-ddtext INTO ev_object_text_singl.
    ENDIF.
    LOOP AT lt_DD04v INTO ls_DD04v.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_DD04v-ddlanguage ls_DD04v-ddtext INTO lv_text.
      IF strlen( ev_object_text_multi ) > 0.
        CONCATENATE ev_object_text_multi cl_abap_char_utilities=>newline lv_text INTO ev_object_text_multi.
      ELSE.
        ev_object_text_multi = lv_text.
      ENDIF.
    ENDLOOP.
  ENDIF.


endmethod.