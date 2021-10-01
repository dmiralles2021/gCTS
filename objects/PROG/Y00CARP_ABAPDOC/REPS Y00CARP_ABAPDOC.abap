*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& This report is the main part of a Documentation tool developed by
*& intended to generate technical documentation of customer's
*& ABAP development.
*&
*&---------------PURPOSE-----------------------------------------------*
*& The purpose of this tool is to generate a technical documentation
*& which, when added to a Functional specification document, significantly
*& helps to complete a complex documentation of your solution.
*& It can also help to generate "JavaDoc like", API documentation
*& of your reusable SW components (FMs, class methods, ..)
*& and last but not least - it can help you to check your developers
*& compliance to required coding conventions and also motivate them
*& to use standard ABAP workbench documentation means (used as a
*& KCT ABAPdoc sources) for consistent and rich documentation
*& of the development.
*&
*&---------------HOW IT WORKS------------------------------------------*
*& It generates a MS Word document (DOCX format) with a list of all
*& the common repository object types including their attributes,
*& descriptions, comments in the source-code (started e.g. with " *& ")
*& and program  documentation (see SELECT-OPTIONS so_krep and
*& application-specific others).
*& Its technical design is inspired by the SAPlink tool (easily
*& enhanceable, having plug-in class for each object type etc.) which
*& has a similar user interface as well.
*& Copyright (C)
*&---------------------------------------------------------------------*


REPORT  y00carp_abapdoc                          MESSAGE-ID y00camsg_abpdoc.

INCLUDE y00caincl_abapdoc_dta.                          " global Data
INCLUDE y00caincl_abapdoc_sel.                          " Select option
INCLUDE y00caincl_abapdoc_f01.                          " FORM-Routines

*/----------------------selection screen events-----------------------\
INITIALIZATION.
  pb_wf = TEXT-pwf.
  DATA: lv_default_ext TYPE string.

  IF go_main_obj IS INITIAL.
    go_main_obj = y00cacl_abapdoc_main=>get( ).

    go_main_obj->get_plugin( ).
  ENDIF.
  PERFORM fill_so_default .

  CALL 'C_SAPGPARAM'
    ID 'NAME'
    FIELD 'DIR_HOME'
    ID 'VALUE'
    FIELD p_a_file.                                       "#EC CI_CCALL

  IF p_rexml = abap_true.
    lv_default_ext = 'xml'.
  ELSE.
    lv_default_ext = 'docx'.
  ENDIF.

  CONCATENATE 'c:\temp\' 'tech_doc' '.' lv_default_ext INTO p_l_file.

  IF p_a_file CA '/'.
    CONCATENATE p_a_file '/' 'tech_doc' '.' lv_default_ext INTO p_a_file.
  ELSE.
    CONCATENATE p_a_file '\' 'tech_doc' '.' lv_default_ext INTO p_a_file.
  ENDIF.

AT SELECTION-SCREEN.
  DATA: lv_file      TYPE dsvasdocid,
        lv_directory TYPE dsvasdocid,
        lv_filename  TYPE dsvasdocid,
        lv_extension TYPE dsvasdocid,

        lv_len       TYPE i.

  CASE sscrfields-ucomm.
    WHEN 'WF_DOC'.
      SUBMIT y00carp_abapdoc_workflow VIA SELECTION-SCREEN AND RETURN.
    WHEN 'CHTYPEFILE'.

      IF p_rexml = abap_true.
        lv_default_ext = 'xml'.
      ELSE.
        lv_default_ext = 'docx'.
      ENDIF.

      lv_file = p_l_file.
      y00cacl_abapdoc=>filename_split( EXPORTING pf_docid     = lv_file
                                       IMPORTING pf_directory = lv_directory
                                                 pf_filename  = lv_filename
                                                 pf_extension = lv_extension ).
      lv_len = strlen( p_l_file ) - strlen( lv_extension ).
      IF lv_extension IS NOT INITIAL.
        CONCATENATE p_l_file(lv_len) lv_default_ext INTO p_l_file.
      ENDIF.

      lv_file = p_a_file.
      y00cacl_abapdoc=>filename_split( EXPORTING pf_docid     = lv_file
                                       IMPORTING pf_directory = lv_directory
                                                 pf_filename  = lv_filename
                                                 pf_extension = lv_extension ).
      lv_len = strlen( p_a_file ) - strlen( lv_extension ).
      IF lv_extension IS NOT INITIAL.
        CONCATENATE p_a_file(lv_len) lv_default_ext INTO p_a_file.
      ENDIF.

  ENDCASE.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF p_doco = 'X'.
      IF screen-group1 = 'PKG' OR screen-group1 = 'TRN'.
        screen-active = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF p_docp = 'X'.
      IF screen-group1 = 'OBJ' OR screen-group1 = 'TRN'.
        screen-active = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF p_doct = 'X'.
      IF screen-group1 = 'OBJ' OR screen-group1 = 'PKG'.
        screen-active = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF p_reole = 'X'.
      IF screen-group1 = 'A_F' OR screen-group1 = 'A_R'.
        screen-active = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
      p_local = 'X'.
      p_appl = ''.
    ENDIF.

    IF p_local = 'X' OR p_reole = 'X'.
      IF screen-group1 = 'A_F'.
        screen-input = '0'.
        screen-value_help = '0'.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF p_appl = 'X'.
      IF screen-group1 = 'L_F'.
        screen-input = '0'.
        screen-value_help = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

  ENDLOOP.

* --> ZOLDOSP (10.01.2014 10:59:18): zobrazení loga KCT *****
  IF sy-batch = abap_false.
    PERFORM display_logo.
  ENDIF.
* <-- konec úpravy ******************************************

*** value request for input fields
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_objtyp.
  DATA: lt_value  TYPE TABLE OF t_plugin,
        lt_plugin TYPE Y00CATT_ABAPDOC_PLUGIN_T.

  FIELD-SYMBOLS: <fs_plugin> LIKE LINE OF lt_plugin,
                 <fs_value>  LIKE LINE OF lt_value.

  lt_plugin = go_main_obj->get_plugin( ).

  LOOP AT lt_plugin ASSIGNING <fs_plugin>.
    APPEND INITIAL LINE TO lt_value ASSIGNING <fs_value>.
*>>-> PaM 01.11.2013 10:26:22
*    MOVE-CORRESPONDING <fs_plugin> TO <fs_value>.
    <fs_value>-object = <fs_plugin>-obj_type.
    <fs_value>-text   = <fs_plugin>-text.
*<-<< PaM 01.11.2013 10:26:22
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'OBJECT'
      window_title    = TEXT-f41
      dynpprog        = sy-repid
      dynpnr          = '1000'
      dynprofield     = 'P_OBJTYP'
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_l_file.
  DATA: lv_fullpath    TYPE string,
        lv_filename    TYPE string,
        lv_path        TYPE string,
        lv_default_ext TYPE string,
        lv_title       TYPE string,

        lv_user_action TYPE i.

  IF p_rexml = abap_true.
    lv_default_ext = 'xml'.
  ELSE.
    lv_default_ext = 'docx'.
  ENDIF.

  lv_fullpath = p_l_file.
  lv_title = TEXT-t03.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      file_filter       = 'XML files (*.xml)|*.xml|Word files (*.docx)|*.docx'
      default_extension = lv_default_ext
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath
      user_action       = lv_user_action.
  IF lv_user_action = 0.
    p_l_file = lv_fullpath.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_object.
  DATA: lo_targetobject TYPE REF TO y00cacl_abapdoc,
        lt_plugin       TYPE y00catt_abapdoc_plugin_t,

        lv_objname      TYPE string,
        lv_objtyp       TYPE string.

  FIELD-SYMBOLS: <fs_plugin> LIKE LINE OF lt_plugin.

  PERFORM get_current_screen_value USING 'P_OBJTYP' '1000' CHANGING p_objtyp.

  IF  p_objtyp IS NOT INITIAL.
    lt_plugin = go_main_obj->get_plugin( ).
    lv_objtyp = p_objtyp.
    READ TABLE lt_plugin ASSIGNING <fs_plugin> WITH KEY obj_type = p_objtyp.
    IF sy-subrc = 0.
*    if it is found...intanciate it so you can call the right value help
      CREATE OBJECT lo_targetobject
        TYPE
          (<fs_plugin>-class_name)
        EXPORTING
          name                     = lv_objname.
      CALL METHOD lo_targetobject->value_help
        EXPORTING
          iv_obj_type = lv_objtyp
        RECEIVING
          rv_obj_name = lv_objname.
      IF lv_objname IS NOT INITIAL.
        p_object = lv_objname.
      ENDIF.

    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_trkorr-low.
  DATA: ls_selected_request TYPE trwbo_request_header,
        lv_organizer_type   TYPE trwbo_calling_organizer,
        ls_selection        TYPE trwbo_selection.

  lv_organizer_type = 'W'.
*  ls_selection-reqstatus = 'R'.
  CALL FUNCTION 'TR_PRESENT_REQUESTS_SEL_POPUP'
    EXPORTING
      iv_organizer_type   = lv_organizer_type
      is_selection        = ls_selection
    IMPORTING
      es_selected_request = ls_selected_request.

  s_trkorr-low = ls_selected_request-trkorr.

*\--------------------------------------------------------------------/

*/----------------------main------------------------------------------\
START-OF-SELECTION.

  DATA: lv_text       TYPE string,
        lt_object_alv TYPE y00catt_abapdoc_object_alv_t,

        lv_doc_type   TYPE y00cadt_abapdoc_output_type,

        lf_result     TYPE flag.

  REFRESH: lt_object_alv.

*******************************************************************************
* set ouput document type
*******************************************************************************
  CLEAR: gv_file_name.

* Test if enter directory
  IF p_local = abap_true.
    gv_file_name = p_l_file.
  ELSEIF p_appl = abap_true.

    gv_file_name = p_a_file.
  ENDIF.

* Test if extension file
  IF p_reole = abap_true.
    lv_doc_type = y00cacl_abapdoc_main=>co_output_document_ole_doc.
  ELSEIF p_rexml = abap_true.
    lv_doc_type = y00cacl_abapdoc_main=>co_output_document_xml.
  ELSE.
    lv_doc_type = y00cacl_abapdoc_main=>co_output_document_docx.
  ENDIF.

*******************************************************************************
* object entry assigned
*******************************************************************************
  IF p_doco = abap_true.
* check up entered parameters
    IF p_objtyp IS INITIAL.
      MESSAGE s001(y00camsg_abpdoc).
      EXIT.
    ELSEIF p_object IS INITIAL.
      MESSAGE s002(y00camsg_abpdoc).
      EXIT.
    ELSEIF gv_file_name IS INITIAL.
      MESSAGE s003(y00camsg_abpdoc).
      EXIT.
    ENDIF.

    IF go_main_obj->init_object( iv_output_type = lv_doc_type iv_obj_type = p_objtyp iv_object = p_object ) = abap_true.
      PERFORM add_objects_to_alv.
    ELSE.
      MESSAGE s008(y00camsg_abpdoc) WITH p_objtyp p_object.
      RETURN.
    ENDIF.

*******************************************************************************
* assigned entry from packet
*******************************************************************************
  ELSEIF p_docp = abap_true.
    IF p_packag IS INITIAL.
      MESSAGE s004(y00camsg_abpdoc).
      EXIT.
    ENDIF.
    IF gv_file_name IS INITIAL.
      MESSAGE s003(y00camsg_abpdoc).
      EXIT.
    ENDIF.

    IF go_main_obj->init_object( iv_output_type = lv_doc_type iv_package = p_packag ) = abap_true.
      PERFORM add_objects_to_alv.
    ELSE.
      MESSAGE s006(y00camsg_abpdoc) WITH p_packag.
      RETURN.
    ENDIF.

*******************************************************************************
* adding object to transport
*******************************************************************************
  ELSEIF p_doct = abap_true.
    IF gv_file_name IS INITIAL.
      MESSAGE s003(y00camsg_abpdoc).
      EXIT.
    ENDIF.

    IF s_trkorr[] IS INITIAL.
      MESSAGE s005(y00camsg_abpdoc).
      EXIT.
    ENDIF.

    IF go_main_obj->init_object( iv_output_type = lv_doc_type iv_transport = s_trkorr-low ) = abap_true.
      PERFORM add_objects_to_alv.
    ELSE.
      MESSAGE s010(y00camsg_abpdoc) WITH s_trkorr-low.
      RETURN.
    ENDIF.

  ENDIF.

**\--------------------------------------------------------------------/