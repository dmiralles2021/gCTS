method RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs data parameters (type, length, decimals...), conversion routine
*&    and fixed values or entity table
*&
*& Uses the following flags in is_output_options
*&   tech_docu + print_empty_par to output content of "goto/documentation"
*& -----------------------------------------------------------------


  data: lv_text           type string,
        lv_text_num(10)   type c,
        lv_text2          type string,
        lt_text           type stringtab,
        lt_text2          TYPE stringtab,
        lv_header         type string,
        lv_value          type string,
        lv_row            type i,
        lv_int            type i,
*        lv_cnt            type i,
        lv_textid         type sotr_conc,
        lv_objname        type ddobjname,
        ls_dd01v          type dd01v,
        lt_dd07v          type standard table of dd07v,
        lt_dd07v_single   type standard table of dd07v,
        lt_dd07v_interv   type standard table of dd07v,
        ls_dd07v          type dd07v.

  clear ev_text_error.
  ef_result = abap_true.

* Read data
  lv_objname = gv_obj_name.
  call function 'DDIF_DOMA_GET'
    exporting
      name          = lv_objname
      langu         = sy-langu
    importing
      dd01v_wa      = ls_dd01v
    tables
      dd07v_tab     = lt_dd07v
*     dd05m_tab     = dd05m_tab
*     dd08v_tab     = dd08v_tab
*     dd12v_tab     = dd12v_tab
*     dd17v_tab     = dd17v_tab
*     dd35v_tab     = dd35v_tab
*     dd36m_tab     = dd36m_tab
    exceptions
      illegal_input = 1
      others        = 2.

  if sy-subrc = 0.

* Font setup and headline writing
    message i102(y00camsg_abpdoc) with is_object_alv-obj_type_txt is_object_alv-obj_name into lv_text.
    io_render->add_object_title( lv_text ).

* Short Descriptions
    clear lt_text.
    message i104(y00camsg_abpdoc) into lv_text.
    CONCATENATE lv_text ls_dd01v-ddtext into lv_text SEPARATED BY space.
    append lv_text to lt_text.
    io_render->add_description( lt_text ).

    clear lt_text.
*   Table definition for Data Type
    io_render->start_table( ).
    clear lt_text.
    message i301(y00camsg_abpdoc) into lv_text.
    append lv_text to lt_text.
    message i317(y00camsg_abpdoc) into lv_text.
    append lv_text to lt_text.
    io_render->add_table_header_row( lt_text ).
    CLEAR lt_text.
*   Data Type
    message i302(y00camsg_abpdoc) into lv_text.
    append lv_text to lt_text.
    CALL FUNCTION 'CONVERSION_EXIT_DTYPE_OUTPUT'
      EXPORTING
        input  = ls_dd01v-datatype
      IMPORTING
        OUTPUT = lv_text.
    APPEND lv_text TO lt_text.
    io_render->add_table_row( lt_text ).
    clear lt_text.

*   Data length
    message i303(y00camsg_abpdoc) into lv_text.
    append lv_text to lt_text.
    lv_text = ls_dd01v-leng.
    SHIFT lv_text left deleting leading '0'.
    APPEND lv_text TO lt_text.
    io_render->add_table_row( lt_text ).
*
    clear lt_text.
*   Decimals
    lv_text = ls_dd01v-decimals.
    IF lv_text > 0.
      message i314(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
*      lv_text = ls_dd01v-decimals.
      SHIFT lv_text left deleting leading '0'.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.
*
    clear lt_text.
*   Output length
    message i315(y00camsg_abpdoc) into lv_text.
    append lv_text to lt_text.
    lv_text = ls_dd01v-outputlen.
    SHIFT lv_text left deleting leading '0'.
    APPEND lv_text TO lt_text.
    io_render->add_table_row( lt_text ).

    clear lt_text.
*   Conversion routine
    lv_value = ls_dd01v-convexit.
    IF lv_value <> ' '.
      message i316(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      if lv_value is not initial.
        lv_text2 = me->get_domain_text( iv_domain_name = 'CONVEXIT' iv_domain_value = lv_value ).
        APPEND lv_text2 TO lt_text.
      else.
        lv_text = ' '.
        append lv_text to lt_text.
      endif.
      io_render->add_table_row( lt_text ).
    ENDIF.

    CLEAR lt_text.
*   Lowercase simple way
    message i319(y00camsg_abpdoc) into lv_text.
    APPEND lv_text TO lt_text.
    lv_value = ls_dd01v-lowercase.
    IF lv_value is not initial.
      APPEND 'Yes' to lt_text.
    ELSE.
      APPEND 'No' to lt_text.
    ENDIF.
    io_render->add_table_row( lt_text ).

*    CLEAR lt_text.
**   Lowercase complicated way, does not bring required result
*    lv_value = ls_dd01v-lowercase.
*    IF lv_value is not initial.
*      message i319(y00camsg_abpdoc) into lv_text.
*      APPEND lv_text TO lt_text.
*      clear lv_text.
*      lv_text = me->get_domain_text( iv_domain_name = 'LOWERCASE' iv_domain_value = lv_value ).
*      concatenate 'ls_dd01v-lowercase is not initial - lv_value: ' lv_value ', lv_text: ' lv_text into lv_text.
*      APPEND lv_text TO lt_text.
*    ELSE.
*      message i319(y00camsg_abpdoc) into lv_text.
*      APPEND lv_text TO lt_text.
*      clear lv_text.
*      concatenate 'ls_dd01v-lowercase is initial - lv_value: ' lv_value ', lv_text: ' lv_text into lv_text.
*      append lv_text TO lt_text.
*    ENDIF.
*    io_render->add_table_row( lt_text ).
    CLEAR lt_text.
*   Table end
    io_render->end_table( ).

    Clear lt_text.
*   Blank line
    io_render->add_description( lt_text ).

* =================================================================
* = Fixed values of the domain
* =================================================================

* Split data in lt_dd07v into two tables.
    move lt_dd07v to: lt_dd07v_single, lt_dd07v_interv.
    delete lt_dd07v_single WHERE domvalue_h is not INITIAL.
    delete lt_dd07v_interv WHERE domvalue_h is     INITIAL.

* Output a table with single values
    IF lines( lt_dd07v_single ) > 0.
      message i321(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      io_render->add_description( lt_text ).

*   Table for Single vaules
      io_render->start_table( ).
      clear lt_text.
      message i320(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      message i304(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      io_render->add_table_header_row( lt_text ).
      CLEAR lt_text.

      loop at lt_dd07v_single into ls_dd07v.
        lv_text = ls_dd07v-domvalue_l.
        shift lv_text right deleting trailing space.
        lv_int = strlen( lv_text ).
*        if lv_int > 2.
        append lv_text to lt_text.
        lv_text = ls_dd07v-ddtext.
        append lv_text to lt_text.
        io_render->add_table_row( lt_text ).
        CLEAR lt_text.
*        endif.
      ENDLOOP.
      io_render->end_table( ).
    ENDIF.

* Output a table with intervals
    IF lines( lt_dd07v_interv ) > 0.
*    Blank line
      clear lt_text.
      io_render->add_description( lt_text ).

      message i318(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      io_render->add_description( lt_text ).

*   Table for Value range
      io_render->start_table( ).
      clear lt_text.
      message i310(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      message i311(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      message i304(y00camsg_abpdoc) into lv_text.
      append lv_text to lt_text.
      io_render->add_table_header_row( lt_text ).
      CLEAR lt_text.

      loop at lt_dd07v_interv into ls_dd07v.
        lv_text = ls_dd07v-domvalue_l.
        shift lv_text right deleting trailing space.
*        lv_int = strlen( lv_text ).
*        if lv_int < 3 and lv_int <> 0.
        append lv_text to lt_text.
        lv_text = ls_dd07v-domvalue_h.
        append lv_text to lt_text.
        lv_text = ls_dd07v-ddtext.
        append lv_text to lt_text.
        io_render->add_table_row( lt_text ).
        CLEAR lt_text.
*        endif.
      ENDLOOP.
      io_render->end_table( ).

    ENDIF.


    CLEAR lt_text.

*   Table value display
    lv_text = ls_dd01v-entitytab.
    IF lv_text <> ' '.
*   Blank line
      io_render->add_description( lt_text ).
      message i322(y00camsg_abpdoc) into lv_text.
      CONCATENATE lv_text ls_dd01v-entitytab into lv_text SEPARATED BY space.
*    append lv_text to lt_text.
*    lv_text = ls_dd01v-entitytab.
      append lv_text to lt_text.
      io_render->add_description( lt_text ).
      clear lt_text.
    ENDIF.
*    Comment code italic and bigger font
*    io_render->add_comment_code( lt_text ).

  endif.

* -------------------------------------------------
* Documentation (+PJ 17th May 2014)

  CLEAR: lt_text2 .
  lt_text2 = get_documentation( gv_obj_name ).
  IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .
    CLEAR: lt_text, lv_text.

    APPEND lv_text TO lt_text.
    io_render->add_text( lt_text ).
* Heading
    CLEAR lt_text.
    lv_text = 'Documentation'(011).
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    io_render->add_documentation( lt_text2 ).

  ENDIF .


* Finalization
  ef_result = abap_true.
endmethod.