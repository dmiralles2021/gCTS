METHOD GET_OBJECT_TEXT.

  DATA: lv_name  TYPE ddobjname,
        ls_dd25v TYPE dd25v,
        lv_text  TYPE string.

  lv_name = gv_obj_name.

  CALL FUNCTION 'DDIF_VIEW_GET'
    EXPORTING
      name          = lv_name
    IMPORTING
      dd25v_wa      = ls_dd25v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc = 0.
    MESSAGE i101(y00camsg_abpdoc) WITH ls_dd25v-ddlanguage ls_dd25v-ddtext INTO ev_object_text_singl.
  ENDIF.

ENDMETHOD.