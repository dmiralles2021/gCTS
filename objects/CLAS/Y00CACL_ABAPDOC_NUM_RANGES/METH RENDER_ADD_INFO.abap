method RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, subobj data element, %warning,
*&   memory buffering, list of intervals etc.
*&
*&  Uses no flags in is_output_options.
*& -----------------------------------------------------------------

  DATA: lv_objname        TYPE nrobj,
        lv_text           TYPE string,
        lt_text           TYPE stringtab,
        lv_dummy          TYPE string,
        lx_int_exists     TYPE xflag,

        ls_tnro           TYPE tnro,
        ls_tnrot          TYPE tnrot,
        lt_intervals      TYPE STANDARD TABLE OF inriv,
        wa_intervals      LIKE LINE OF lt_intervals,
        lv_descr          TYPE string.


  CLEAR ev_text_error.
  ef_result = abap_true.

* Read data
  lv_objname = gv_obj_name.

  CALL FUNCTION 'NUMBER_RANGE_OBJECT_READ'
    EXPORTING
*     LANGUAGE                = SY-LANGU
      object                  = lv_objname
   IMPORTING
     interval_exists         = lx_int_exists
     object_attributes       = ls_tnro
     object_text             = ls_tnrot
   EXCEPTIONS
     object_not_found        = 1
     OTHERS                  = 2
            .

  IF sy-subrc = 0.
*   Font setup and headline writing
    MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
    io_render->add_object_title( lv_text ).

*   Short Descriptions
    CLEAR: lt_text, lv_descr.

    lv_descr = ls_tnrot-txt.

    MESSAGE i104(y00camsg_abpdoc) INTO lv_text.
    CONCATENATE lv_text lv_descr INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).


    CLEAR lt_text.
    IF ls_tnro-dtelsobj IS NOT INITIAL.
      CONCATENATE 'Subobject data element:' ls_tnro-dtelsobj INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.

    IF ls_tnro-domlen IS NOT INITIAL.
      CONCATENATE 'Number length domain:' ls_tnro-domlen INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.

    IF ls_tnro-code IS NOT INITIAL.
      lv_text = ls_tnro-code.
      CONCATENATE 'Number range transaction:' lv_text INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.

    IF ls_tnro-percentage IS NOT INITIAL.
      lv_text = ls_tnro-percentage.
      CONCATENATE 'Warning %: ' lv_text INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.

    IF ls_tnro-buffer IS NOT INITIAL.
      lv_text = 'Yes'.
    ELSE.
      lv_text = 'No'.
    ENDIF.
    CONCATENATE 'Main memory buffering:' lv_text INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.

    IF ls_tnro-noivbuffer IS NOT INITIAL.
      lv_text = ls_tnro-noivbuffer.
      CONCATENATE 'No. of numbers in buffer:' lv_text INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
    ENDIF.


    io_render->add_text( lt_text ).

*   intervals:
    CALL FUNCTION 'NUMBER_RANGE_INTERVAL_LIST'
      EXPORTING
        object                     = lv_objname
      TABLES
        interval                   = lt_intervals
      EXCEPTIONS
        nr_range_nr1_not_found     = 1
        nr_range_nr1_not_intern    = 2
        nr_range_nr2_must_be_space = 3
        nr_range_nr2_not_extern    = 4
        nr_range_nr2_not_found     = 5
        object_not_found           = 6
        subobject_must_be_space    = 7
        subobject_not_found        = 8
        OTHERS                     = 9.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.

    ELSE.
      CLEAR lt_text.
      lv_text = 'Intervals'.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

*     Table definition
      io_render->start_table( ).
      CLEAR lt_text.

*     Header
      lv_text = 'Object'.
      APPEND lv_text TO lt_text.

      lv_text = 'Subobject'.
      APPEND lv_text TO lt_text.

      lv_text = 'Number range num.'.
      APPEND lv_text TO lt_text.

      lv_text = 'To fisc. year'.
      APPEND lv_text TO lt_text.

      lv_text = 'From number'.
      APPEND lv_text TO lt_text.

      lv_text = 'To number'.
      APPEND lv_text TO lt_text.

      lv_text = 'Current number'.
      APPEND lv_text TO lt_text.

      io_render->add_table_header_row( lt_text ).
      CLEAR lt_text.

*     Data
      LOOP AT lt_intervals INTO wa_intervals.
        lv_text = lv_objname.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        lv_text = wa_intervals-subobject.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        lv_text = wa_intervals-nrrangenr.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        lv_text = wa_intervals-toyear.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        lv_text = wa_intervals-fromnumber.
        SHIFT lv_text LEFT DELETING LEADING '0'.
        APPEND lv_text TO lt_text.

        lv_text = wa_intervals-tonumber.
        SHIFT lv_text LEFT DELETING LEADING '0'.
        APPEND lv_text TO lt_text.

        lv_text = wa_intervals-nrlevel.
        SHIFT lv_text LEFT DELETING LEADING '0'.
        IF lv_text IS INITIAL.
          lv_text = '0'.
        ENDIF.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).
        CLEAR lt_text.
      ENDLOOP.

      io_render->end_table( ).

    ENDIF.
  ENDIF.

* Finalization
  ef_result = abap_true.

endmethod.