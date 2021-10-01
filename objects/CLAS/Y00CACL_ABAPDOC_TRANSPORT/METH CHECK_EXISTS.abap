method CHECK_EXISTS.

  rv_exists = abap_false.
  data ls_e070_dummy type E070.
  select SINGLE * from E070 into ls_e070_dummy
    WHERE TRKORR = gv_obj_name.
  if sy-subrc = 0.
    rv_exists = abap_true.
  endif.
endmethod.