METHOD GET_OBJECT_TEXT.

  DATA: lv_name  TYPE ddobjname,
        lv_text  TYPE string.

  CLEAR: ev_object_text_singl, ev_object_text_multi.
  SELECT * FROM tstct INTO TABLE @DATA(lt_TSTCT) WHERE tcode = @gv_obj_name.

  IF sy-subrc = 0.
    READ TABLE lt_TSTCT INTO DATA(ls_TSTCT) WITH KEY sprsl = sy-langu.
    IF sy-subrc = 0.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_TSTCT-sprsl ls_TSTCT-ttext INTO ev_object_text_singl.
    ENDIF.
    LOOP AT lt_TSTCT INTO ls_TSTCT.
      MESSAGE i101(y00camsg_abpdoc) WITH ls_TSTCT-sprsl ls_TSTCT-ttext INTO lv_text.
      IF strlen( ev_object_text_multi ) > 0.
        CONCATENATE ev_object_text_multi cl_abap_char_utilities=>newline lv_text INTO ev_object_text_multi.
      ELSE.
        ev_object_text_multi = lv_text.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMETHOD.