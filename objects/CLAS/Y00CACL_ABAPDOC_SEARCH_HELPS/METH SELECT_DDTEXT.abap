method SELECT_DDTEXT.

  DATA: lv_name  TYPE shlpname,
        ls_dd30t TYPE dd30t,
        lt_dd30t TYPE TABLE OF dd30t.

  lv_name = gv_obj_name.

  SELECT * FROM dd30t INTO TABLE lt_dd30t WHERE shlpname = lv_name.

  IF sy-subrc EQ 0.
    READ TABLE lt_dd30t INTO ls_dd30t WITH KEY ddlanguage = sy-langu.
    IF sy-subrc NE 0.
      READ TABLE lt_dd30t INTO ls_dd30t INDEX 1.
    ENDIF.

  ELSE.
    RAISE not_found.
  ENDIF.

  es_dd30t = ls_dd30t.

endmethod.