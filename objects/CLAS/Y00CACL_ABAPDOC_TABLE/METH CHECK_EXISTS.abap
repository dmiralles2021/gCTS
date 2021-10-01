method CHECK_EXISTS.

  DATA: lv_name   TYPE ddobjname,
        ls_dd02v  TYPE dd02v.

  lv_name = gv_obj_name.

  rv_exists = abap_false.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = lv_name
    IMPORTING
      dd02v_wa      = ls_dd02v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc = 0 AND ls_dd02v-tabname IS NOT INITIAL.
    rv_exists = abap_true.
  ENDIF.

endmethod.