method CHECK_EXISTS.

  DATA: lv_name TYPE o2applname,
        lv_exist TYPE c LENGTH 1.

  lv_name = gv_obj_name.

  CALL METHOD cl_o2_api_application=>check_exist
    EXPORTING
      p_application = lv_name
    IMPORTING
      p_exists      = lv_exist.

  IF lv_exist = 'A'.
    rv_exists = abap_true.
  ELSE.
    rv_exists = abap_false.
  ENDIF.

endmethod.