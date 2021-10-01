method CHECK_EXISTS.

  data: progattribs  type trdir,
        sourcestring type string.

  select single * from trdir into progattribs where name = gv_obj_name.

  if sy-subrc = 0.
    rv_exists = abap_true.
  else.
    rv_exists = abap_false.
  endif.

endmethod.