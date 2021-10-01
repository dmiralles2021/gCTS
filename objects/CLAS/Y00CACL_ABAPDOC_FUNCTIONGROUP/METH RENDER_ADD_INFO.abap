METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, documentation, code comments, includes,
*&   FM list, FM detail (interfaces, code comments) etc.
*&
*&  Uses the following flags in is_output_options:
*&  - tech_docu (output content of "goto/documentation" for FuGr and FM)
*&  - print_empty_par (output empty paragraphs in docu and in code comments)
*&  - module_interfaces (output FM parameters)
*&  - only_main_comments (code comments only for main program)
*& -----------------------------------------------------------------


  TYPES: BEGIN OF ls_tlibt_red,
           area TYPE tlibt-area,
           spras TYPE tlibt-spras,
           areat TYPE tlibt-areat,
         END OF ls_tlibt_red,

         BEGIN OF ls_funct_head,
           name TYPE rs38l-name,
           global TYPE rs38l-global,
           remote TYPE rs38l-remote,
           utask TYPE rs38l-utask,
           stext TYPE tftit-stext,
           area TYPE rs38l-area,
         END OF ls_funct_head.

  DATA: ls_progattribs TYPE trdir,
        ls_progdescript TYPE trdirt,
        lt_include TYPE tt_include,
        ls_tlibt_red TYPE ls_tlibt_red,
        lv_name TYPE tlibt-area,
        lv_main_program TYPE trdir-name,
        lt_text TYPE stringtab,
        lt_text2 TYPE stringtab,
        lt_text3 TYPE stringtab,
        lv_text TYPE string,
        lv_string TYPE string,
        lt_functab TYPE TABLE OF rs38l_incl,
        ls_funct_head TYPE ls_funct_head,
        "
        lt_import TYPE TABLE OF rsimp,
        lt_change TYPE TABLE OF rscha,
        lt_export TYPE TABLE OF rsexp,
        lt_tables TYPE TABLE OF rstbl,
        lt_excepl TYPE TABLE OF rsexc,
        lt_docume TYPE TABLE OF rsfdo,
        lt_source TYPE TABLE OF rssource,
        lt_source_new TYPE rsfb_source.

  FIELD-SYMBOLS: <ls_include> TYPE ts_include,
                 <ls_functab> TYPE rs38l_incl,
                 <ls_import> TYPE rsimp,
                 <ls_change> TYPE rscha,
                 <ls_export> TYPE rsexp,
                 <ls_tables> TYPE rstbl,
                 <ls_excepl> TYPE rsexc,
                 <ls_docume> TYPE rsfdo,
                 <ls_source> TYPE rssource,
                 <ls_source_new> TYPE rsfb_source.

  DATA: lv_key_line TYPE i,
        lt_trdir TYPE TABLE OF trdir,
        lt_penlfdir TYPE TABLE OF enlfdir,
        lt_funct TYPE TABLE OF funct,
        lt_fupararef TYPE TABLE OF sfupararef,
        lt_tfdir TYPE TABLE OF tfdir,
        lt_tftit TYPE TABLE OF tftit,
        lt_uincl TYPE TABLE OF abaptxt255,
        lv_area TYPE tvdir-area.

  FIELD-SYMBOLS: <ls_trdir> LIKE LINE OF lt_trdir.

* Initialization
  CONCATENATE 'SAPL' gv_obj_name INTO lv_main_program.
  lv_name = gv_obj_name.

* Get main program attributes
  SELECT SINGLE *
    FROM trdir
    INTO ls_progattribs
    WHERE name = lv_main_program
    AND subc = 'F'.
  IF sy-subrc IS NOT INITIAL.
*    clear ixmldocument.
*    RAISE EXCEPTION type zcx_saplink
*      EXPORTING
*        textid = zcx_saplink=>not_found.
  ENDIF.

* Get Function group attributes
  SELECT SINGLE *
    FROM tlibt
    INTO CORRESPONDING FIELDS OF ls_tlibt_red
    WHERE spras = sy-langu
    AND area  = lv_name.
  IF sy-subrc IS NOT INITIAL.
*    RAISE EXCEPTION TYPE zcx_saplink
*      EXPORTING
*        textid = zcx_saplink=>not_found.
  ENDIF.

* Heading
  CONCATENATE is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text SEPARATED BY space.
  io_render->add_object_title( lv_text ).

* Description
  CLEAR lt_text.
  CONCATENATE 'Description:'(001) ls_tlibt_red-areat INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

* Check if FG used for maintanance view
  SELECT SINGLE area FROM tvdir
    INTO lv_area
    WHERE area = gv_obj_name.
  IF sy-subrc IS INITIAL.
    CLEAR lt_text.
    lv_text = 'Functional group is generated FG'(026).
    APPEND lv_text TO lt_text.
    io_render->add_text( lt_text ).
* Finalization
    ef_result = abap_true.
    EXIT.
  ENDIF.


* FG Documentation **********************************************************************************
  IF is_output_options-tech_docu = abap_true.

    lt_text2 = get_documentation( gv_obj_name ).

    IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .
      CLEAR: lt_text, lv_text.
      APPEND lv_text TO lt_text.
      io_render->add_text( lt_text ).

* Heading
      CLEAR lt_text.
      lv_text = 'Documentation'(021).
      APPEND lv_text TO lt_text.
*
      io_render->add_description( lt_text ).

      io_render->add_documentation( lt_text2 ).

    ENDIF .

  ENDIF.

* FG code comment*********************************************************************************
  CLEAR lt_text2 .
  lt_text2 = get_code_comment( gv_obj_name ). "-??always empty??

  IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .

    CLEAR: lt_text, lv_text.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

* Heading
    CLEAR lt_text.
    lv_text = 'Code comment'(022).
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    CLEAR lt_text.
    "lt_text = get_code_comment( gv_obj_name ).
    io_render->add_comment_code( lt_text2 ).

  ENDIF .

* Includes ***************************************************************************************
  lt_include = get_includes( lv_name ).

  CLEAR: lt_text, lv_text.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

* Heading
  CLEAR lt_text.
  lv_text = 'Include list'(023).
  IF LINES( lt_include ) = 0.
    add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
  ENDIF.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  IF LINES( lt_include ) > 0.
    " Header
    io_render->start_table( ).
    CLEAR lt_text.
    lv_text = 'Include Id'(002).
    APPEND lv_text TO lt_text.
    lv_text = 'Description'(003).
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).
    " Item
    LOOP AT lt_include ASSIGNING <ls_include>.
      CLEAR lt_text.
      lv_text = <ls_include>-name.
      APPEND lv_text TO lt_text.

      SELECT SINGLE text FROM trdirt INTO lv_text WHERE name = <ls_include>-name.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).

    ENDLOOP.

    io_render->end_table( ).
  ENDIF.

* Functional module ***********************************************************************
* Now get the function pool contents
  CALL FUNCTION 'RS_FUNCTION_POOL_CONTENTS'
    EXPORTING
      function_pool           = lv_name
    TABLES
      functab                 = lt_functab
    EXCEPTIONS
      function_pool_not_found = 1
      OTHERS                  = 2.

* FM list
  LOOP AT lt_functab ASSIGNING <ls_functab>.

    CLEAR: lt_import, lt_change, lt_export, lt_tables, lt_excepl, lt_docume, lt_source, lt_source_new.

* Read the function module data
    CALL FUNCTION 'RPY_FUNCTIONMODULE_READ_NEW'
      EXPORTING
        functionname       = <ls_functab>-funcname
      IMPORTING
        global_flag        = ls_funct_head-global
        remote_call        = ls_funct_head-remote
        update_task        = ls_funct_head-utask
        short_text         = ls_funct_head-stext
*       FUNCTION_POOL      =
      TABLES
        import_parameter   = lt_import
        changing_parameter = lt_change
        export_parameter   = lt_export
        tables_parameter   = lt_tables
        exception_list     = lt_excepl
        documentation      = lt_docume
        SOURCE             = lt_source
      CHANGING
        new_source         = lt_source_new
      EXCEPTIONS
        error_message      = 1
        function_not_found = 2
        invalid_name       = 3

        OTHERS             = 4.

* FM Heading
    CONCATENATE 'Functional module'(007) <ls_functab>-funcname INTO lv_text SEPARATED BY space.
    io_render->add_object_subtitle( lv_text ).

* FM Description
    CLEAR lt_text.
    CONCATENATE 'Description:'(001) ls_funct_head-stext INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

* FM documentation **********************************************************************************
    IF is_output_options-tech_docu = abap_true.

      CLEAR lt_text2 .
      lv_string = <ls_functab>-funcname.
      lt_text2 = get_documentation( iv_obj_name = lv_string iv_document_class = 'FU' ).

      IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .

        CLEAR: lt_text, lv_text.
        APPEND lv_text TO lt_text.
        io_render->add_description( lt_text ).

* Heading
        CLEAR lt_text.
        lv_text = 'Documentation'(024).
        APPEND lv_text TO lt_text.
        io_render->add_description( lt_text ).

        io_render->add_documentation( lt_text2 ).

      ENDIF.

    ENDIF.

* FM detail **********************************************************************************
    IF is_output_options-module_interfaces = abap_true.

      CLEAR: lt_text, lv_text.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

* Heading
      CLEAR lt_text.
      lv_text = 'Interface'(025).
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

* Header
      lv_text = ''.
      APPEND lv_text TO lt_text.
      io_render->start_table( ).
      CLEAR lt_text.
      lv_text = 'Parameter'(011).
      APPEND lv_text TO lt_text.
      lv_text = 'Parameter description'(005).
      APPEND lv_text TO lt_text.
      lv_text = 'Parameter type'(004).
      APPEND lv_text TO lt_text.
      lv_text = 'Optional'(012).
      APPEND lv_text TO lt_text.
      lv_text = 'Pass value'(013).
      APPEND lv_text TO lt_text.
      io_render->add_table_header_row( lt_text ).

* Item
** Import parameter
      LOOP AT lt_import ASSIGNING <ls_import>.

        CLEAR lt_text.
        "
        lv_text = <ls_import>-parameter.
        APPEND lv_text TO lt_text.
        "
        READ TABLE lt_docume ASSIGNING <ls_docume> WITH KEY parameter = <ls_import>-parameter.
        IF sy-subrc IS INITIAL.
          lv_text = <ls_docume>-stext.
          APPEND lv_text TO lt_text.
        ENDIF.
        "
        lv_text = 'Import'(006).
        APPEND lv_text TO lt_text.
        "
        IF  <ls_import>-optional = abap_true.
          lv_text = 'Yes'(015).
        ELSE.
          lv_text = 'No'(016).
        ENDIF.
        APPEND lv_text TO lt_text.
        "
        IF  <ls_import>-reference = abap_true.
          lv_text = 'Yes'(015).
        ELSE.
          lv_text = 'No'(016).
        ENDIF.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).

      ENDLOOP.
      UNASSIGN <ls_import>.

** Export parameter
      LOOP AT lt_export ASSIGNING <ls_export>.

        CLEAR lt_text.
        "
        lv_text = <ls_export>-parameter.
        APPEND lv_text TO lt_text.
        "
        READ TABLE lt_docume ASSIGNING <ls_docume> WITH KEY parameter = <ls_export>-parameter.
        IF sy-subrc IS INITIAL.
          lv_text = <ls_docume>-stext.
          APPEND lv_text TO lt_text.
        ENDIF.
        "
        lv_text = 'Export'(008).
        APPEND lv_text TO lt_text.
        "
        lv_text = '-'(017).
        APPEND lv_text TO lt_text.
        "
        IF  <ls_export>-reference = abap_true.
          lv_text = 'Yes'(015).
        ELSE.
          lv_text = 'No'(016).
        ENDIF.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).

      ENDLOOP.
      UNASSIGN <ls_export>.

** Changing parameter
      LOOP AT lt_change ASSIGNING <ls_change>.

        CLEAR lt_text.
        "
        lv_text = <ls_change>-parameter.
        APPEND lv_text TO lt_text.
        "
        READ TABLE lt_docume ASSIGNING <ls_docume> WITH KEY parameter = <ls_change>-parameter.
        IF sy-subrc IS INITIAL.
          lv_text = <ls_docume>-stext.
          APPEND lv_text TO lt_text.
        ENDIF.
        "
        lv_text = 'Changing'(009).
        APPEND lv_text TO lt_text.
        "
        IF  <ls_change>-optional = abap_true.
          lv_text = 'Yes'(015).
        ELSE.
          lv_text = 'No'(016).
        ENDIF.
        APPEND lv_text TO lt_text.
        "
        IF  <ls_change>-reference = abap_true.
          lv_text = 'Yes'(015).
        ELSE.
          lv_text = 'No'(016).
        ENDIF.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).

      ENDLOOP.
      UNASSIGN <ls_change>.

** Tables parameter
      LOOP AT lt_tables ASSIGNING <ls_tables>.

        CLEAR lt_text.
        "
        lv_text = <ls_tables>-parameter.
        APPEND lv_text TO lt_text.
        "
        READ TABLE lt_docume ASSIGNING <ls_docume> WITH KEY parameter = <ls_tables>-parameter.
        IF sy-subrc IS INITIAL.
          lv_text = <ls_docume>-stext.
          APPEND lv_text TO lt_text.
        ENDIF.
        "
        lv_text = 'Table'(010).
        APPEND lv_text TO lt_text.
        "
        IF  <ls_tables>-optional = abap_true.
          lv_text = 'Yes'(015).
        ELSE.
          lv_text = 'No'(016).
        ENDIF.
        APPEND lv_text TO lt_text.
        "
        lv_text = '-'(017).
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).

      ENDLOOP.
      UNASSIGN <ls_tables>.

** Exeption paramater
      LOOP AT lt_excepl ASSIGNING <ls_excepl>.

        CLEAR lt_text.
        "Parameter
        lv_text = <ls_excepl>-exception.
        APPEND lv_text TO lt_text.
        "Parameter description
        READ TABLE lt_docume ASSIGNING <ls_docume> WITH KEY parameter = <ls_excepl>-exception.
        IF sy-subrc IS INITIAL.
          lv_text = <ls_docume>-stext.
          APPEND lv_text TO lt_text.
        ENDIF.
        "Parameter type
        lv_text = 'Exception'(011).
        APPEND lv_text TO lt_text.
        "Optional
        lv_text = ''.
        APPEND lv_text TO lt_text.
        "Pass value
        lv_text = ''.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).

      ENDLOOP.
      UNASSIGN <ls_excepl>.

      io_render->end_table( ).

    ENDIF. "IF is_output_options-module_interfaces = abap_true.

** FM code comment ***************************************************************


    CLEAR: lt_text2, lt_text3 .
    "get key line with string "ENDFUNCTION."
    LOOP AT lt_source ASSIGNING <ls_source>.
      IF <ls_source> CS 'ENDFUNCTION.'.
        lv_key_line = sy-tabix.
        EXIT.
      ENDIF.
    ENDLOOP.
    CALL FUNCTION 'FUNC_GET_OBJECT'
      EXPORTING
        funcname           = <ls_functab>-funcname
      TABLES
        penlfdir           = lt_penlfdir
        ptrdir             = lt_trdir
        pfunct             = lt_funct
        pfupararef         = lt_fupararef
        ptfdir             = lt_tfdir
        ptftit             = lt_tftit
        uincl              = lt_uincl
      EXCEPTIONS
        function_not_exist = 1
        version_not_found  = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno "TODO
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    READ TABLE lt_trdir ASSIGNING <ls_trdir> INDEX 1.
    CHECK sy-subrc IS INITIAL. "TODO
    lv_string = <ls_trdir>-name.
*    lt_text3 = get_code_comment( iv_obj_name = lv_string iv_up_to_line = lv_key_line ).
    CALL METHOD get_code_comment
      EXPORTING
        iv_obj_name   = lv_string
        iv_up_to_line = lv_key_line
        it_key_words  = is_output_options-keyw_report
      RECEIVING
        rt_text       = lt_text3.

    APPEND LINES OF lt_text3 TO lt_text2.

    IF is_output_options-only_main_comments = abap_false.
      CLEAR: lt_text3 .
*      lt_text3 = get_code_comment( iv_obj_name = lv_string iv_from_line = lv_key_line ).
      CALL METHOD get_code_comment
        EXPORTING
          iv_obj_name  = lv_string
          iv_from_line = lv_key_line
          it_key_words = is_output_options-keyw_report
        RECEIVING
          rt_text      = lt_text3.


      APPEND LINES OF lt_text3 TO lt_text2.

    ENDIF.

    IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .

      CLEAR: lt_text, lv_text.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

* Heading
      CLEAR lt_text.
      lv_text = 'Code comment'(022).
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

      io_render->add_comment_code( lt_text2 ).

    ENDIF .

*  ENDLOOP. "LOOP AT lt_include ASSIGNING <ls_include>.



  ENDLOOP. "LOOP AT lt_funct ASSIGNING <ls_funct>.

* Finalization
  ef_result = abap_true.

ENDMETHOD.