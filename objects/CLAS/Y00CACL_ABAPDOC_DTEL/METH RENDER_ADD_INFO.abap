method RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, domain name, data parameters (type,length,decimals etc.)
*&
*& Uses the following flags in is_output_options
*&   tech_docu + print_empty_par to output content of "goto/documentation"
*& -----------------------------------------------------------------

  DATA:
    lv_text           TYPE string,
    lv_text_num(10)   TYPE c,
    lv_header         TYPE string,
    lv_value          TYPE string,
    lv_row            TYPE i,
    lt_text           TYPE stringtab,
    lt_text2          TYPE stringtab,
    lv_objname        TYPE ddobjname,
    ls_dd01v          TYPE dd01v,
    ls_dd04v          TYPE dd04v.

  CLEAR ev_text_error.
  ef_result = abap_true.

* Read data
  lv_objname = gv_obj_name.

  CALL FUNCTION 'DDIF_DTEL_GET'
    EXPORTING
      name          = lv_objname
      langu         = sy-langu
    IMPORTING
      dd04v_wa      = ls_dd04v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
***  IF sy-subrc = 0 AND ls_dd04v-rollname IS NOT INITIAL.
***    rv_exists = abap_true.
***  ENDIF.

  IF sy-subrc = 0.
* move to the end of the document

* Font setup and headline writing
    CLEAR lt_text.
    MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
    io_render->add_object_title( lv_text ).

* Descriptions
    MESSAGE i104(y00camsg_abpdoc) INTO lv_text.
    CONCATENATE lv_text ls_dd04v-ddtext INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    MESSAGE i409(y00camsg_abpdoc) INTO lv_text.
    if ls_dd04v-scrtext_l is not INITIAL.
      CONCATENATE lv_text ls_dd04v-scrtext_l INTO lv_text SEPARATED BY space.
* PJ 17.4.2014: Je-li scrtext_l prázdné, použij _m nebo _s :
    elseif ls_dd04v-scrtext_m is not INITIAL.
      CONCATENATE lv_text ls_dd04v-scrtext_m INTO lv_text SEPARATED BY space.
    else.
      CONCATENATE lv_text ls_dd04v-scrtext_s INTO lv_text SEPARATED BY space.
    endif.
    APPEND lv_text TO lt_text.
***    me->get_object_text( importing ev_object_text_multi = lv_text ).
***    append lv_text to lt_text.
    lv_value = ls_dd04v-domname.
    lv_text = me->get_domain_text( iv_domain_name = 'DOMNAME' iv_domain_value = lv_value ).
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).


* Table creation with table entries
* title Data Type
    io_render->start_table( ).

*    render fields of ls_dd04v.
    IF ls_dd04v-datatype NE 'REF'.
      IF ls_dd04v-domname IS NOT INITIAL.
        CLEAR lt_text.
        MESSAGE i401(y00camsg_abpdoc) INTO lv_text.
        APPEND lv_text TO lt_text.
        lv_text = ls_dd04v-domname.
        APPEND lv_text TO lt_text.
        io_render->add_table_row( lt_text ).
      ENDIF.

      CLEAR lt_text.
      MESSAGE i406(y00camsg_abpdoc) INTO lv_text.
      APPEND lv_text TO lt_text.
      lv_text = ls_dd04v-datatype.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).
    ENDIF.

    IF ls_dd04v-datatype EQ 'REF'.
      CASE ls_dd04v-reftype.
        WHEN 'C' OR 'S'.
          CLEAR lt_text.
          MESSAGE i404(y00camsg_abpdoc) INTO lv_text.
          APPEND lv_text TO lt_text.
          lv_text = ls_dd04v-domname.
          APPEND lv_text TO lt_text.
          io_render->add_table_row( lt_text ).
        WHEN 'E'.
* Read domain data
          lv_objname = gv_obj_name.
          CALL FUNCTION 'DDIF_DOMA_GET'
            EXPORTING
              name          = ls_dd04v-domname
              langu         = sy-langu
            IMPORTING
              dd01v_wa      = ls_dd01v
            EXCEPTIONS
              illegal_input = 1
              OTHERS        = 2.
          IF sy-subrc = 0.
            CLEAR lt_text.
            MESSAGE i401(y00camsg_abpdoc) INTO lv_text.
            APPEND lv_text TO lt_text.
            lv_text = ls_dd01v-domname.
            APPEND lv_text TO lt_text.
            io_render->add_table_row( lt_text ).

            CLEAR lt_text.
            MESSAGE i406(y00camsg_abpdoc) INTO lv_text.
            APPEND lv_text TO lt_text.
            lv_text = ls_dd01v-datatype.
            APPEND lv_text TO lt_text.
            io_render->add_table_row( lt_text ).

            CLEAR lt_text.
            MESSAGE i407(y00camsg_abpdoc) INTO lv_text.
            APPEND lv_text TO lt_text.
            WRITE ls_dd01v-leng TO lv_text_num NO-GAP NO-ZERO.
            lv_text = lv_text_num.
            APPEND lv_text TO lt_text.
            io_render->add_table_row( lt_text ).

            IF ls_dd01v-decimals GT 0.
              CLEAR lt_text.
              MESSAGE i408(y00camsg_abpdoc) INTO lv_text.
              APPEND lv_text TO lt_text.
              WRITE ls_dd01v-decimals TO lv_text_num NO-GAP NO-ZERO.
              lv_text = lv_text_num.
              APPEND lv_text TO lt_text.
              io_render->add_table_row( lt_text ).
            ENDIF.
          ENDIF.
        WHEN 'B'.
          CLEAR lt_text.
          MESSAGE i406(y00camsg_abpdoc) INTO lv_text.
          APPEND lv_text TO lt_text.
          lv_text = ls_dd04v-domname.
          APPEND lv_text TO lt_text.
          io_render->add_table_row( lt_text ).
      ENDCASE.
    ENDIF.

    IF ls_dd04v-leng GT 0.
      CLEAR lt_text.
      MESSAGE i407(y00camsg_abpdoc) INTO lv_text.
      APPEND lv_text TO lt_text.
      WRITE ls_dd04v-leng TO lv_text_num NO-GAP NO-ZERO.
      lv_text = lv_text_num.
      APPEND lv_text TO lt_text.
      io_render->add_table_row( lt_text ).

      IF ls_dd04v-decimals GT 0.
        CLEAR lt_text.
        MESSAGE i408(y00camsg_abpdoc) INTO lv_text.
        APPEND lv_text TO lt_text.
        WRITE ls_dd04v-decimals TO lv_text_num NO-GAP NO-ZERO.
        lv_text = lv_text_num.
        APPEND lv_text TO lt_text.
        io_render->add_table_row( lt_text ).
      ENDIF.
    ENDIF.

    io_render->end_table( ).
  ENDIF.


* -------------------------------------------------
* Documentation
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
endmethod.