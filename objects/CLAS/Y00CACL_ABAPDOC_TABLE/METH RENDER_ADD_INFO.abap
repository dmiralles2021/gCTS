METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, table class, client dependency, maintenance flag,
*&   buffering and list of components
*&
*&  Uses the following flags in is_output_options
*&   tech_docu + print_empty_par to output content of "goto/documentation"
*& -----------------------------------------------------------------


  DATA: lv_objtype        TYPE string,
        lv_text2          TYPE string,
        lv_value          TYPE string,
        lv_objname        TYPE ddobjname,
        ls_dd02v          TYPE dd02v,
        lt_dd03p          TYPE STANDARD TABLE OF dd03p,
        ls_dd03p          TYPE dd03p,
        lv_text           TYPE string,
        lt_text           TYPE stringtab,
        lt_text2          TYPE stringtab,
        lv_textid         TYPE sotr_conc,
        text              TYPE string,
        inheritanceprops  TYPE vseoextend,
        attribkey         TYPE seocmpkey,
        attribdescr       TYPE abap_attrdescr,
        attribproperties  TYPE vseoattrib,
        methoddescr       TYPE abap_methdescr,
        methodkey         TYPE seocpdkey,
        clsmethkey        TYPE seocmpkey,
        methodproperties  TYPE vseomethod,
        lv_row            TYPE i.

* Font setup and headline writing
  MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
  io_render->add_object_title( lv_text ).

* Data reading
  lv_objname = gv_obj_name.
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = lv_objname
      langu         = sy-langu
    IMPORTING
      dd02v_wa      = ls_dd02v
    TABLES
      dd03p_tab     = lt_dd03p
*     dd05m_tab     = dd05m_tab
*     dd08v_tab     = dd08v_tab
*     dd12v_tab     = dd12v_tab
*     dd17v_tab     = dd17v_tab
*     dd35v_tab     = dd35v_tab
*     dd36m_tab     = dd36m_tab
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

* Description
  CLEAR lt_text.
  MESSAGE i104(y00camsg_abpdoc) INTO lv_text.
  CONCATENATE lv_text ls_dd02v-ddtext INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).
  CLEAR lt_text.

* TABCLASS
  lv_value = ls_dd02v-tabclass.
  IF lv_value IS NOT INITIAL.
    lv_text2 = me->get_domain_text( iv_domain_name = 'TABCLASS' iv_domain_value = lv_value ).
    MESSAGE i325(y00camsg_abpdoc) INTO lv_text.
    IF lv_text2 <> ' '.
      CONCATENATE lv_text lv_text2 INTO lv_text SEPARATED BY space.
    ELSE.
      CONCATENATE lv_text ls_dd02v-tabclass INTO lv_text SEPARATED BY space.
    ENDIF.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).
  ENDIF.

* Client dependency
  CLEAR lt_text.
  lv_value = ls_dd02v-clidep.
  IF lv_value IS NOT INITIAL.
    lv_text2 = me->get_domain_text( iv_domain_name = 'CLIDEP' iv_domain_value = lv_value ).
    MESSAGE i326(y00camsg_abpdoc) INTO lv_text.
    CONCATENATE lv_text lv_text2 INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).
  ENDIF.

* Maintenance flag
  CLEAR lt_text.
  lv_value = ls_dd02v-contflag.
  IF lv_value IS NOT INITIAL.
    lv_text2 = me->get_domain_text( iv_domain_name = 'CONTFLAG' iv_domain_value = lv_value ).
    MESSAGE i327(y00camsg_abpdoc) INTO lv_text.
    CONCATENATE lv_text lv_text2 INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).
  ENDIF.

* Buffering
  CLEAR lt_text.
  lv_value = ls_dd02v-buffered.
  IF lv_value IS NOT INITIAL.
    lv_text2 = me->get_domain_text( iv_domain_name = 'BUFFERED' iv_domain_value = lv_value ).
    MESSAGE i328(y00camsg_abpdoc) INTO lv_text.
    CONCATENATE lv_text lv_text2 INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).
  ENDIF.


* -------------------------------------------------
* documentation (+PJ 19th May 2014)
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

*   Table definiton
  io_render->start_table( ).
  CLEAR lt_text.
  MESSAGE i301(y00camsg_abpdoc) INTO lv_text.
  APPEND lv_text TO lt_text.
  MESSAGE i305(y00camsg_abpdoc) INTO lv_text.
  APPEND lv_text TO lt_text.
  MESSAGE i302(y00camsg_abpdoc) INTO lv_text.
  APPEND lv_text TO lt_text.
  MESSAGE i303(y00camsg_abpdoc) INTO lv_text.
  APPEND lv_text TO lt_text.
  MESSAGE i304(y00camsg_abpdoc) INTO lv_text.
  APPEND lv_text TO lt_text.
  MESSAGE i306(y00camsg_abpdoc) INTO lv_text.
  APPEND lv_text TO lt_text.
  MESSAGE i307(y00camsg_abpdoc) INTO lv_text.
  APPEND lv_text TO lt_text.
  io_render->add_table_header_row( lt_text ).

  LOOP AT lt_dd03p INTO ls_dd03p.
    CLEAR lt_text.
    lv_text = ls_dd03p-fieldname.
    APPEND lv_text TO lt_text.
    lv_text = ls_dd03p-rollname.
    APPEND lv_text TO lt_text.
    lv_text = ls_dd03p-datatype.
    APPEND lv_text TO lt_text.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_dd03p-leng
      IMPORTING
        output = lv_text.
    SHIFT lv_text RIGHT DELETING TRAILING space.
    APPEND lv_text TO lt_text.
    lv_text = ls_dd03p-ddtext.
    APPEND lv_text TO lt_text.
    lv_text = ls_dd03p-shlpname.
    APPEND lv_text TO lt_text.
    lv_text = ls_dd03p-checktable.
    APPEND lv_text TO lt_text.

    io_render->add_table_row( lt_text ).

  ENDLOOP.

  io_render->end_table( ).

  ef_result = abap_true.
ENDMETHOD.