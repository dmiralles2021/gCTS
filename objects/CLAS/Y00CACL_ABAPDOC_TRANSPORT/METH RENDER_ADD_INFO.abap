METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*& Pavel Jelínek, June 2014
*& We added (into ZCL_KCT_ABAP_DOC_MAIN=>gt_object_alv) a new object type '++TR' (description of transport request),
*&  which is special because it is not an object from TADIR
*&  (see method ZCL_KCT_ABAP_DOC_MAIN=>GET_ROW_TYPE)
*&
*& Outputs the description and data parameters (type, length, decimals...), conversion routine
*&    and fixed values or entity table
*& -----------------------------------------------------------------


  DATA: lv_text           TYPE string,
        lv_text_num(10)   TYPE c,
        lv_text2          TYPE string,
        lt_text           TYPE stringtab,
        lt_text2          TYPE stringtab,
        lv_header         TYPE string,
        lv_value          TYPE string,
        lv_row            TYPE i,
        lv_int            TYPE i,
*        lv_cnt            type i,
        lv_textid         TYPE sotr_conc,
        lt_req_for_doku   TYPE TABLE OF trkorr, " requests and task for which we'll output the long texts
        lv_objname        TYPE ddobjname.
  .

  CLEAR ev_text_error.
  ef_result = abap_true.
  lv_objname = gv_obj_name.
  APPEND gv_obj_name TO lt_req_for_doku.

* Font setup and headline writing
  MESSAGE i116(y00camsg_abpdoc) WITH is_object_alv-obj_name INTO lv_text. "Transport req. describtion &1
  io_render->add_object_title( lv_text ).

* Short Description
  CLEAR lt_text.
  DATA lv_obj_text TYPE string.
  me->get_object_text( IMPORTING ev_object_text_singl = lv_obj_text  ).
  IF lv_obj_text IS INITIAL.
    MESSAGE i204(y00camsg_abpdoc) INTO lv_text. " 'Missing'
  ENDIF.
  MESSAGE i104(y00camsg_abpdoc) INTO lv_text WITH lv_obj_text .
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

* ========================================
* == Table with subordinate tasks
  CLEAR lt_text.
  MESSAGE i340(y00camsg_abpdoc) INTO lv_text WITH lv_obj_text . "Subordinate tasks
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).
*   Table definition for Data Type
  io_render->start_table( ).
  CLEAR lt_text.
  MESSAGE i341(y00camsg_abpdoc) INTO lv_text. "Tr.request
  APPEND lv_text TO lt_text.

  MESSAGE i342(y00camsg_abpdoc) INTO lv_text. "Owner
  APPEND lv_text TO lt_text.

  MESSAGE i344(y00camsg_abpdoc) INTO lv_text. "Req. type
  APPEND lv_text TO lt_text.

  MESSAGE i343(y00camsg_abpdoc) INTO lv_text. "Description
  APPEND lv_text TO lt_text.

  io_render->add_table_header_row( lt_text ).

*
  DATA lt_subord TYPE TABLE OF e070. "Subordinate items
  FIELD-SYMBOLS <subord> LIKE LINE OF lt_subord .
  SELECT * FROM e070 INTO TABLE lt_subord WHERE strkorr = gv_obj_name.
  LOOP AT lt_subord  ASSIGNING <subord>.
    APPEND <subord>-trkorr TO lt_req_for_doku.
    CLEAR lt_text.
    lv_text = <subord>-trkorr.
    APPEND lv_text TO lt_text.
    lv_text = <subord>-as4user.
    APPEND lv_text TO lt_text.

* Transport req. type
    DATA lv_lang_indep TYPE string.
    DATA lv_dummy      TYPE string.
    lv_lang_indep = <subord>-trfunction.
    lv_text = get_domain_text( iv_domain_name = 'TRFUNCTION' iv_domain_value = lv_lang_indep  ).
*We need a short abbreviation (we don't want the table line to exceed the width of Word page
*So we'll use the first word only (but I'm not sure if this works well in other lang. than EN) - Jelínek, June 2014
    SPLIT lv_text AT ' ' INTO lv_text lv_dummy.
    IF lv_text CS '['. " get_domain_text returned something like "[R] Repair"
      SPLIT lv_dummy AT ' ' INTO lv_text lv_dummy. "Get the first word (for example "Repair").
    ENDIF.
    IF lv_text IS INITIAL.
      lv_text = lv_lang_indep. "Better than nothing
    ENDIF.
    REPLACE ALL OCCURRENCES OF 'Development' IN lv_text  WITH 'Devel.'.
    REPLACE ALL OCCURRENCES OF 'Correction'  IN lv_text  WITH 'Corr.'.
    APPEND lv_text TO lt_text.

* Get description of subord. req.

    lv_text = tr_req_id_to_description( <subord>-trkorr ).
    IF lv_text IS INITIAL.
      MESSAGE i204(y00camsg_abpdoc) INTO lv_text. "Missing
    ENDIF.
    APPEND lv_text TO lt_text.
* Finish the table row
    io_render->add_table_row( lt_text ).
  ENDLOOP.
  io_render->end_table( ).
* -------------------------------------------------
* Documentation

  render_add_info_doku( is_output_options = is_output_options
                        io_render         = io_render
                        it_requests       = lt_req_for_doku
                      ).

* Finalization
  ef_result = abap_true.
ENDMETHOD.