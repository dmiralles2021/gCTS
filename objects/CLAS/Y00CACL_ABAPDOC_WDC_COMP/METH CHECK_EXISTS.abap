method CHECK_EXISTS.

  DATA: lv_name TYPE char30.


  lv_name = gv_obj_name.

  CALL METHOD cl_wdy_md_component=>check_existency
    EXPORTING
      name     = lv_name
*      active   = SPACE
    RECEIVING
      existent = rv_exists
      .

  IF rv_exists = abap_true.
    RETURN.
  ENDIF.

*Pozn.: PaM, 20.01.2014 16:42:32 - objekt WDYN muze byt WD komponenta nebo WD interface
  CALL METHOD cl_wdy_md_component_intf_def=>check_existency
    EXPORTING
      name     = lv_name
*      active   = SPACE
    RECEIVING
      existent = rv_exists
      .

endmethod.