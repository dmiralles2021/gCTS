METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs program description, documentation, list of includes,
*&    screen elements and code comments.
*&
*&  Uses the following flags in is_output_options
*&  - tech_docu (output content of "goto/documentation")
*&  - prg_sel_screen, other_prg_screen - output the sel. screen
*&  - only_main_comments (code comments only for main program)
*&  - print_empty_par (output empty paragraphs in docu and in code comments)
*& -----------------------------------------------------------------



*  BREAK pelcm.
  DATA: lt_src_table TYPE STANDARD TABLE OF string,
        lt_screen TYPE tt_screen,
        lt_include TYPE tt_program_include,
        lt_program_include TYPE tt_program_include,
        ls_prog_attribs TYPE trdir,
        ls_field_list TYPE d021s,
        lv_name TYPE trdir-name,
        lv_string TYPE string,
        lv_subc LIKE ls_prog_attribs-subc,
        lv_field_type TYPE feld-gtyp,
        "
        lt_text TYPE stringtab,
        lt_text2 TYPE stringtab,
        lv_text TYPE string.

  FIELD-SYMBOLS: <ls_src_table> LIKE LINE OF lt_src_table,
                 <ls_screen> TYPE ts_screen,
                 <ls_program_include> LIKE LINE OF lt_program_include.
* -------------------------------------------------
* Check program type
  SELECT SINGLE *
    FROM trdir
    INTO ls_prog_attribs
    WHERE name = gv_obj_name.
  IF sy-subrc IS INITIAL.
    IF ls_prog_attribs-subc <> '1' AND ls_prog_attribs-subc <> 'I'. "Program or Include
      MESSAGE e106(y00camsg_abpdoc) INTO lv_text.
      RAISE EXCEPTION TYPE y00cacx_abapdoc
        EXPORTING
          textid = y00cacx_abapdoc=>error_message.
    ENDIF.

  ELSE.
    RAISE EXCEPTION TYPE y00cacx_abapdoc
      EXPORTING
        textid = y00cacx_abapdoc=>not_found.
  ENDIF.

  IF ls_prog_attribs-subc = 'I'. "Only Report, Includes of main program gotten for each main program below
    ef_result = abap_true.
    EXIT.
  ENDIF.

* -------------------------------------------------
* Get program description
  render_add_info_description( EXPORTING is_object_alv     = is_object_alv
                                         is_output_options = is_output_options
                                         io_render         = io_render
                                IMPORTING ev_text_error     = ev_text_error
                                          ef_result         = ef_result ).


* Documentation *****************************************************************

  IF is_output_options-tech_docu = abap_true.

* -------------------------------------------------
* main program documentation
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
      io_render->add_description2( lt_text ).

      io_render->add_documentation( lt_text2 ).

    ENDIF .

* -------------------------------------------------
* includes
    lt_program_include = get_program_includes( gv_obj_name ).
    LOOP AT lt_program_include ASSIGNING <ls_program_include>.
      lv_string = <ls_program_include>-name.
      CLEAR lt_text2 .
      lt_text2 = get_documentation( lv_string ).
      IF NOT lt_text2[] IS INITIAL . "OR NOT is_output_options-print_empty_par IS INITIAL .
* Heading with include name (render only when there is something to print)
        CLEAR lt_text.
        CONCATENATE 'Documentation'(011) ' ' lv_string INTO lv_text.
        APPEND lv_text TO lt_text.
        io_render->add_description2( lt_text ).
        io_render->add_documentation( lt_text2 ).
      ENDIF .
    ENDLOOP.

  ENDIF. "is_output_options-tech_docu = abap_true.


* Includes ********************************************************************
** Description
  CLEAR lt_text.
  CONCATENATE 'Includes'(012) '' INTO lv_text SEPARATED BY space.
  IF LINES( lt_program_include ) = 0.
    add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
  ENDIF.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  IF LINES( lt_program_include ) > 0.
** Header
    io_render->start_table( ).
    CLEAR lt_text.

    lv_text = 'Program include'(008).
    APPEND lv_text TO lt_text.

    lv_text = 'Description'(003).
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).

** Item
    lt_program_include = get_program_includes( gv_obj_name ).
    LOOP AT lt_program_include ASSIGNING <ls_program_include>.
      CLEAR lt_text.

      lv_text = <ls_program_include>-name.
      APPEND lv_text TO lt_text.

      lv_text = <ls_program_include>-text.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).

    ENDLOOP.

    io_render->end_table( ).
  ENDIF.

* -------------------------------------------------
* Screen elements
  IF is_output_options-prg_sel_screen = abap_true OR is_output_options-other_prg_screen = abap_true.

    lt_screen = get_screen( is_object_alv-obj_name ).
    IF is_output_options-prg_sel_screen = abap_false.
      DELETE lt_screen WHERE type = lco_parameter
                        OR type = lco_selection_option
                        OR type = lco_block.
    ENDIF.
    IF is_output_options-other_prg_screen = abap_false.
      DELETE lt_screen WHERE type <> lco_parameter
                        AND type <> lco_selection_option
                        AND type <> lco_block.
    ENDIF.

    LOOP AT lt_screen ASSIGNING <ls_screen>.

      AT NEW screen_id.

        CLEAR: lt_text, lv_text.
        APPEND lv_text TO lt_text.
        io_render->add_text( lt_text ).
** Description
        CLEAR lt_text.
        CONCATENATE 'Screen'(009) <ls_screen>-screen_id <ls_screen>-element_text INTO lv_text SEPARATED BY space.
        APPEND lv_text TO lt_text.
        io_render->add_description( lt_text ).
** Header
        io_render->start_table( ).
        CLEAR lt_text.
        lv_text = 'Screen element'(002).
        APPEND lv_text TO lt_text.
        lv_text = 'Description'(003).
        APPEND lv_text TO lt_text.
        lv_text = 'Type'(004).
        APPEND lv_text TO lt_text.
        io_render->add_table_header_row( lt_text ).

      ENDAT.

      IF <ls_screen>-type <> lco_screen_description.

        CLEAR lt_text.

        lv_text = <ls_screen>-element_id.
        APPEND lv_text TO lt_text.

        lv_text = <ls_screen>-element_text.
        APPEND lv_text TO lt_text.

*** Type
        CASE <ls_screen>-type.
*** Selection screen
          WHEN lco_parameter.
            lv_text = 'Parameter'(005).
          WHEN lco_selection_option.
            lv_text = 'Selection option'(006).
          WHEN lco_block.
            lv_text = 'Block of selection screen'(007).
*** Program screen
          WHEN OTHERS.
            ls_field_list-flg1 = <ls_screen>-type.
            CALL FUNCTION 'RS_SCRP_GET_FIELD_TYPE_TEXT'
              EXPORTING
                field      = ls_field_list
                text_kind  = 'SHORT'
              IMPORTING
                field_type = lv_field_type.
            lv_text = lv_field_type.
        ENDCASE.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).

      ENDIF. "IF <ls_screen>-type <> lco_screen_description.

      AT END OF screen_id.

        io_render->end_table( ).

      ENDAT.

    ENDLOOP.

  ENDIF. "IF is_output_options-prg_sel_screen = abap_true.



* -------------------------------------------------
* Code comments with string '*&'
* -------------------------------------------------

** main program
  CLEAR lt_text.
*  lt_text2 = get_code_comment( gv_obj_name ).
  CALL METHOD get_code_comment
    EXPORTING
      iv_obj_name  = gv_obj_name
      it_key_words = is_output_options-keyw_report
    RECEIVING
      rt_text      = lt_text2.
  APPEND LINES OF lt_text2 TO lt_text.

** inludes of main program
  IF is_output_options-only_main_comments = abap_false.

    CLEAR lv_text.
    APPEND lv_text TO lt_text.
    lt_program_include = get_program_includes( gv_obj_name ).
    LOOP AT lt_program_include ASSIGNING <ls_program_include>.
      lv_string = <ls_program_include>-name.
*      lt_text2 = get_code_comment( lv_string ).
      CALL METHOD get_code_comment
        EXPORTING
          iv_obj_name  = lv_string
          it_key_words = is_output_options-keyw_report
        RECEIVING
          rt_text      = lt_text2.
      APPEND LINES OF lt_text2 TO lt_text.
    ENDLOOP.

  ENDIF.

  IF NOT lt_text[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .

    CLEAR lt_text2 .
    lt_text2[] = lt_text[] .

    CLEAR: lt_text, lv_text.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

* Heading
    CLEAR lt_text.
    lv_text = 'Code comment'(010).
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    io_render->add_comment_code( lt_text2 ).

  ENDIF .


* -------------------------------------------------
* Finalization
* -------------------------------------------------
  ef_result = abap_true.

ENDMETHOD.