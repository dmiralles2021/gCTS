method GET_PROGRAM_INCLUDES.

  DATA: lt_include TYPE tt_include.

  FIELD-SYMBOLS: <ls_include> TYPE ts_include,
                 <ls_program_include> TYPE ts_program_include.

* Program includes
  CALL FUNCTION 'GET_INCLUDETAB'
    EXPORTING
      progname = gv_obj_name
    TABLES
      incltab  = lt_include.

  LOOP AT lt_include ASSIGNING <ls_include>.

    APPEND INITIAL LINE TO rt_program_include ASSIGNING <ls_program_include>.
    <ls_program_include>-name = <ls_include>-name.
    SELECT SINGLE text
      FROM trdirt
      INTO <ls_program_include>-text
      WHERE name = gv_obj_name
        AND sprsl = sy-langu.

  ENDLOOP.

endmethod.