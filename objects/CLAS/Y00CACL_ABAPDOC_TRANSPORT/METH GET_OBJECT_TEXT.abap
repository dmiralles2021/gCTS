METHOD GET_OBJECT_TEXT.

  CLEAR: ev_object_text_singl, ev_object_text_multi.

  data lv_trkorr type trkorr.
  lv_trkorr  = gv_obj_name. "Convert to the needed type

  data ls_e07t_chosen TYPE          e07t. "We'll use this for ev_object_text_singl
  data lt_e07t        TYPE TABLE OF e07t.
  data wa_e07t        like line of lt_e07t.
  data lv_text type string.

    tr_req_id_to_descr__internal(
        EXPORTING
          iv_req_id          = lv_trkorr
*          iv_preferred_langu =
         IMPORTING
          et_e07t            = lt_e07t
          es_e07t_chosen     = ls_e07t_chosen ).


* fill ev_object_text_singl (Description in any language, preferably sy-langu)
  MESSAGE i101(y00camsg_abpdoc) WITH ls_e07t_chosen-langu ls_e07t_chosen-as4text INTO ev_object_text_singl.

* fill ev_object_text_multi
  LOOP AT lt_e07t INTO wa_e07t.
    MESSAGE i101(y00camsg_abpdoc) WITH wa_e07t-langu wa_e07t-as4text INTO lv_text.
    IF STRLEN( ev_object_text_multi ) > 0.
      CONCATENATE ev_object_text_multi cl_abap_char_utilities=>newline lv_text INTO ev_object_text_multi.
    ELSE.
      ev_object_text_multi = lv_text.
    ENDIF.
  ENDLOOP.
ENDMETHOD.