method CHECK_EXISTS.

  DATA: lv_name TYPE ddobjname,
        ls_dd40v type dd40v.

*  rv_exists = abap_false.
  lv_name = gv_obj_name.

  CALL FUNCTION 'DDIF_TTYP_GET'
    EXPORTING
      name          = lv_name
    IMPORTING
      dd40v_wa      = ls_dd40v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc IS INITIAL AND ls_dd40v-TYPENAME IS NOT INITIAL.
    rv_exists = abap_true.
  else.
    rv_exists = abap_false.
  endif.

endmethod.