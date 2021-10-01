METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, domain name, data parameters (type,length,decimals etc.)
*&
*& Uses the following flags in is_output_options
*&   tech_docu + print_empty_par to output content of "goto/documentation"
*& -----------------------------------------------------------------

  DATA:
    lv_text         TYPE string,
    lv_text_num(10) TYPE c,
    lv_header       TYPE string,
    lv_value        TYPE string,
    lv_row          TYPE i,
    lt_text         TYPE stringtab,
    lt_text2        TYPE stringtab,
    lv_objname      TYPE ddobjname,
    ls_dd01v        TYPE dd01v,
    ls_dd04v        TYPE dd04v.

  CLEAR ev_text_error.
  ef_result = abap_true.

* Read data
  lv_objname = gv_obj_name.

  SELECT SINGLE * FROM tstc INTO @DATA(ls_tstc) WHERE tcode = @lv_objname.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM tstct INTO @DATA(ls_tstct) WHERE tcode = @lv_objname AND sprsl = @sy-langu. " Description
    SELECT SINGLE * FROM tstca INTO @DATA(ls_tstca) WHERE tcode = @lv_objname. " Auth Objects
    SELECT SINGLE * FROM tstcc INTO @DATA(ls_tstcc) WHERE tcode = @lv_objname. " Classification
  ENDIF.


  IF sy-subrc = 0.

* Font setup and headline writing
    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
    io_render->add_object_title( lv_text ).


* Description
    CLEAR lt_text.
    MESSAGE i104(y00camsg_abpdoc) INTO lv_text.
    CONCATENATE lv_text ls_tstct-ttext INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).


* Table creation with table entries
* title Data Type
    io_render->start_table( ).

    IF ls_tstc-pgmna IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'Program' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstc-pgmna.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.

    IF ls_tstc-dypno IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'Selection screen' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstc-dypno.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.

    IF ls_tstca-objct IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'Auth Objet' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstca-objct.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.


    IF ls_tstcc-s_service IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'Service' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstcc-s_service.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.

    IF ls_tstcc-s_pervas IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'Pervasive Enabled' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstcc-s_pervas.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.


    IF ls_tstcc-s_webgui IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'SAP GUI for HTML' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstcc-s_webgui.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.

    IF ls_tstcc-s_win32 IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'SAP GUI for Windows' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstcc-s_win32.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.

    IF ls_tstcc-s_platin IS NOT INITIAL.
      CLEAR lt_text.
      MESSAGE i102(y00camsg_abpdoc) WITH 'SAP GUI for Java' INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_tstcc-s_platin.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.

    io_render->end_table( ).
  ENDIF.


** -------------------------------------------------
** Documentation
*  CLEAR: lt_text2 .
*  lt_text2 = get_documentation( gv_obj_name ).
*  IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .
*    CLEAR: lt_text, lv_text.
*    APPEND lv_text TO lt_text.
*    io_render->add_text( lt_text ).
** Heading
*    CLEAR lt_text.
*    lv_text = 'Documentation'(011).
*    APPEND lv_text TO lt_text.
*    io_render->add_description( lt_text ).
*
*    io_render->add_documentation( lt_text2 ).

*  ENDIF .
ENDMETHOD.