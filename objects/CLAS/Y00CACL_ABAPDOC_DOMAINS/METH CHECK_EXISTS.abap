method CHECK_EXISTS.

  DATA: l_name   TYPE ddobjname,
        dd01v_wa TYPE dd01v.

  l_name = gv_obj_name.
  rv_exists = abap_false.

  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      name          = l_name
    IMPORTING
      dd01v_wa      = dd01v_wa
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc = 0 AND dd01v_wa-domname IS NOT INITIAL.
    rv_exists = 'X'.
  ENDIF.

endmethod.