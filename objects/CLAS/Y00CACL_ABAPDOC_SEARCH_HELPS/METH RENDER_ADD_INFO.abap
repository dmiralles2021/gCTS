METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, selection method, text table, FM exit and list of parameters
*&
*& Uses the following flags in is_output_options
*&   tech_docu + print_empty_par to output content of "goto/documentation"
*& -----------------------------------------------------------------



  DATA: lv_text           TYPE string,
        lt_text           TYPE stringtab,
        lt_text2          type stringtab,
        lv_dummy          TYPE string,
        lv_objname        TYPE shlpname,

        lt_dd32p          TYPE rsdg_t_dd32p,
        ls_dd32p          TYPE dd32p,
        ls_dd30t          TYPE dd30t,
        ls_dd30v          TYPE dd30v,
        lv_ddtext         TYPE string.


  CLEAR ev_text_error.
  ef_result = abap_true.

* Read data
  lv_objname = gv_obj_name.

  CALL FUNCTION 'DD_SHLP_GET'
    EXPORTING
*     GET_STATE           = 'M    '
      langu               = sy-langu
*     PRID                = 0
      shlp_name           = lv_objname
*     WITHTEXT            = ' '
*     ADD_TYPEINFO        = 'X'
*     TRACELEVEL          = 0
   IMPORTING
     dd30v_wa_a          = ls_dd30v
   TABLES
      dd32p_tab_a         = lt_dd32p
   EXCEPTIONS
     illegal_value       = 1
     op_failure          = 2
     OTHERS              = 3
     .

  IF sy-subrc = 0.
*   Font setup and headline writing
    MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
    io_render->add_object_title( lv_text ).

*   Short Descriptions
    CLEAR lt_text.
    CLEAR lv_ddtext.

    me->select_ddtext( IMPORTING es_dd30t  = ls_dd30t
                       EXCEPTIONS not_found = 1
                                  OTHERS    = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
    ELSE.
      lv_ddtext = ls_dd30t-ddtext.

      MESSAGE i104(y00camsg_abpdoc) INTO lv_text.
      CONCATENATE lv_text lv_ddtext INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

    ENDIF.


    CLEAR lt_text.
    IF ls_dd30v-selmethod IS NOT INITIAL.
      CONCATENATE 'Selection method:' ls_dd30v-selmethod INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.
    IF ls_dd30v-texttab IS NOT INITIAL.
      lv_text = ls_dd30v-texttab.
      CONCATENATE 'Text table:' lv_text INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.
    IF ls_dd30v-selmexit IS NOT INITIAL.
      lv_text = ls_dd30v-selmexit.
      CONCATENATE 'Search help exit' lv_text INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.

    io_render->add_text( lt_text ).


    CLEAR lt_text.
    lv_text = 'Parameters'.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    CLEAR lt_text.
*   Table definition
    io_render->start_table( ).
    CLEAR lt_text.

*   Header
    MESSAGE i301(y00camsg_abpdoc) INTO lv_text. "fieldname
    APPEND lv_text TO lt_text.

    lv_text = 'Input'.
    APPEND lv_text TO lt_text.

    lv_text = 'Output'.
    APPEND lv_text TO lt_text.

    lv_text = 'Default value'.
    APPEND lv_text TO lt_text.

*    lv_text = 'Data element'.
*    APPEND lv_text TO lt_text.
*
*    MESSAGE i312(y00camsg_abpdoc) INTO lv_text. "Domain Name
*    APPEND lv_text TO lt_text.

    MESSAGE i302(y00camsg_abpdoc) INTO lv_text. "Data type
    APPEND lv_text TO lt_text.

    MESSAGE i303(y00camsg_abpdoc) INTO lv_text. "Length
    APPEND lv_text TO lt_text.


* -------------------------------------------------
* documentation (+PJ 19th May 2014) - but I'm not sure that doku can be created for SHLP
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

* -------------------------------------------------
* Table
    io_render->add_table_header_row( lt_text ).
    CLEAR lt_text.

*   Data
    LOOP AT lt_dd32p INTO ls_dd32p.
      lv_text = ls_dd32p-fieldname.
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = ls_dd32p-shlpinput.
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = ls_dd32p-shlpoutput.
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = ls_dd32p-defaultval.
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

*      lv_text = ls_dd32p-rollname.
*      SHIFT lv_text RIGHT DELETING TRAILING space.
*      APPEND lv_text TO lt_text.
*
*      lv_text = ls_dd32p-domname.
*      SHIFT lv_text RIGHT DELETING TRAILING space.
*      APPEND lv_text TO lt_text.

      lv_text = ls_dd32p-datatype.
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = ls_dd32p-leng.
      SHIFT lv_text LEFT DELETING LEADING '0'.
      APPEND lv_text TO lt_text.


      io_render->add_table_row( lt_text ).
      CLEAR lt_text.
    ENDLOOP.

    io_render->end_table( ).

  ENDIF.

* Finalization
  ef_result = abap_true.

ENDMETHOD.