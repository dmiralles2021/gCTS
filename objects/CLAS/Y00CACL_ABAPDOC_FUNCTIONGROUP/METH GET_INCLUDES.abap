method GET_INCLUDES.

  DATA: lt_funct TYPE TABLE OF rs38l_incl,
        ls_funct TYPE  rs38l_incl,
        lt_include type tt_include,
        ls_include TYPE ts_include,
        ls_progattribs type trdir,
        lv_main_program TYPE sy-repid.

* Initialization
  CONCATENATE 'SAPL' iv_function_group INTO lv_main_program.

  CALL FUNCTION 'RS_FUNCTION_POOL_CONTENTS'
    EXPORTING
      function_pool           = iv_function_group
    TABLES
      functab                 = lt_funct
    EXCEPTIONS
      function_pool_not_found = 1
      OTHERS                  = 2.

* Get all includes
  CALL FUNCTION 'RS_GET_ALL_INCLUDES'
    EXPORTING
      program      = lv_main_program
    TABLES
      includetab   = rt_include
    EXCEPTIONS
      not_existent = 1
      no_program   = 2
      OTHERS       = 3.

* Get rid of any includes that are for the function modules
* and any includes that are in SAP namespace
  LOOP AT lt_include INTO ls_include.
    READ TABLE lt_funct
      INTO ls_funct
      WITH KEY include = ls_include-name.
    IF sy-subrc  = 0.
      DELETE lt_include WHERE name = ls_include-name.
      CONTINUE.
    ENDIF.
    SELECT SINGLE * FROM trdir
      INTO ls_progattribs
      WHERE name = ls_include-name.
    IF ls_progattribs-cnam = 'SAP'.
      DELETE lt_include WHERE name = ls_include-name.
      CONTINUE.
    ENDIF.
    IF ls_include-name(2) <> 'LZ'
       AND ls_include-name(2) <> 'LY'
       AND ls_include-name(1) <> 'Z'
       AND ls_include-name(1) <> 'Y'.
      DELETE lt_include WHERE name = ls_include-name.
      CONTINUE.
    ENDIF.
  ENDLOOP.

endmethod.