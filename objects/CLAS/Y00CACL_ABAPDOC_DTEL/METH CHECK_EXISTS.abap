method CHECK_EXISTS.

  DATA: lv_name   TYPE ddobjname,
        ls_dd04v  TYPE dd04v.

  lv_name = gv_obj_name.

  rv_exists = abap_false.

  CALL FUNCTION 'DDIF_DTEL_GET'
    EXPORTING
      name          = lv_name
    IMPORTING
      dd04v_wa      = ls_dd04v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc = 0 AND ls_dd04v-rollname IS NOT INITIAL.
    rv_exists = abap_true.
  ENDIF.

endmethod.