method CHECK_EXISTS.

  DATA: progattribs  TYPE trdir,
        sourcestring TYPE string,
        lv_fg_include TYPE trdir-name.

  CONCATENATE 'SAPL' gv_obj_name INTO lv_fg_include.
  SELECT SINGLE * FROM trdir INTO progattribs
    WHERE name = lv_fg_include
      AND SUBC = 'F'.

  IF sy-subrc = 0.
    rv_exists = abap_true.
  ELSE.
    rv_exists = abap_false.
  ENDIF.

endmethod.