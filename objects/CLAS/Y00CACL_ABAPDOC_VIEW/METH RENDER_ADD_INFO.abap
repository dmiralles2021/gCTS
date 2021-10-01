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


  DATA: lv_objtype       TYPE string,
        lv_text2         TYPE string,
        lv_value         TYPE string,
        lv_objname       TYPE ddobjname,
        ls_dd25v         TYPE dd25v,
        lt_joins         TYPE STANDARD TABLE OF dd26v,
        lt_join_cond     TYPE STANDARD TABLE OF dd28j,

        lt_dd03p         TYPE STANDARD TABLE OF dd03p,
        ls_dd03p         TYPE dd03p,
        lv_text          TYPE string,
        lt_text          TYPE stringtab,
        lt_text2         TYPE stringtab,
        lv_textid        TYPE sotr_conc,
        text             TYPE string,
        inheritanceprops TYPE vseoextend,
        attribkey        TYPE seocmpkey,
        attribdescr      TYPE abap_attrdescr,
        attribproperties TYPE vseoattrib,
        methoddescr      TYPE abap_methdescr,
        methodkey        TYPE seocpdkey,
        clsmethkey       TYPE seocmpkey,
        methodproperties TYPE vseomethod,
        lv_row           TYPE i.

* Font setup and headline writing
  MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
  io_render->add_object_title( lv_text ).

* Data reading
  lv_objname = gv_obj_name.

  CALL FUNCTION 'DDIF_VIEW_GET'
    EXPORTING
      name          = lv_objname
    IMPORTING
      dd25v_wa      = ls_dd25v
    TABLES
      dd26v_tab     = lt_joins
      dd28j_tab     = lt_join_cond
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc = 0.
* Implement suitable error handling here


* Description
    CLEAR lt_text.
    SELECT SINGLE ddtext INTO ls_dd25v-ddtext FROM dd25t WHERE viewname  = lv_objname AND ddlanguage = sy-langu.
    MESSAGE i104(y00camsg_abpdoc)  WITH ls_dd25v-ddtext INTO lv_text.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH 'Root Table: ' INTO lv_text.
    CONCATENATE lv_text ls_dd25v-roottab INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH 'Data Browser/Table View Edit: ' INTO lv_text.
    CASE ls_dd25v-globalflag.
      WHEN 'X'.
        CONCATENATE lv_text 'Display/Maintenance Allowed' INTO lv_text SEPARATED BY space.
      WHEN 'N'.
        CONCATENATE lv_text 'Display/Maintenance Not Allowed' INTO lv_text SEPARATED BY space.
      WHEN OTHERS.
        CONCATENATE lv_text  'Display/Maintenance Allowed with Restrictions' INTO lv_text SEPARATED BY space.
    ENDCASE.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    CLEAR lt_text.
    MESSAGE i104(y00camsg_abpdoc) WITH 'Table Joins' INTO lv_text.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    LOOP AT lt_joins INTO DATA(ls_joins).
      CLEAR: lt_text, lv_text.
      CONCATENATE 'Table: ' ls_joins-tabname INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).
    ENDLOOP.

*   Table definiton
    io_render->start_table( ).
    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH 'Table' INTO lv_text.
    APPEND lv_text TO lt_text.

*    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH 'Field name' INTO lv_text.
    APPEND lv_text TO lt_text.

*    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH 'Operator' INTO lv_text.
    APPEND lv_text TO lt_text.

*    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH 'Table' INTO lv_text.
    APPEND lv_text TO lt_text.

*    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH 'field name' INTO lv_text.
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).


    LOOP AT lt_join_cond INTO DATA(ls_join_cond).

      CLEAR lt_text.
      lv_text = ls_join_cond-ltab.
      APPEND lv_text TO lt_text.

*      CLEAR lt_text.
      lv_text = ls_join_cond-lfield.
      APPEND lv_text TO lt_text.

*      CLEAR lt_text.
      lv_text = ls_join_cond-operator.
      APPEND lv_text TO lt_text.

*      CLEAR lt_text.
      lv_text = ls_join_cond-rtab.
      APPEND lv_text TO lt_text.

*      CLEAR lt_text.
      lv_text = ls_join_cond-rfield.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).

    ENDLOOP.

    io_render->end_table( ).

  ENDIF.

  ef_result = abap_true.
ENDMETHOD.