method GET_DOMAIN_TEXT.

 DATA: lv_domname  TYPE domname,
        lt_dd07v    TYPE TABLE OF dd07v,
        ls_dd07v    TYPE dd07v.

  CLEAR rv_domain_text.

  lv_domname = iv_domain_name.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = lv_domname
    TABLES
      values_tab      = lt_dd07v
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.
  IF sy-subrc = 0.
    READ TABLE lt_dd07v INTO ls_dd07v WITH KEY domvalue_l = iv_domain_value.
    IF sy-subrc = 0.
      MESSAGE i103(y00camsg_abpdoc) WITH ls_dd07v-domvalue_l ls_dd07v-ddtext into rv_domain_text.
    ENDIF.
  ENDIF.

endmethod.