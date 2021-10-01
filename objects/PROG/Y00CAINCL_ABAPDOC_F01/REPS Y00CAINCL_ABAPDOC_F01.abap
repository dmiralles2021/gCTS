*&---------------------------------------------------------------------*
*&  Include           ZKCT_ABAP_DOC_F01
*&---------------------------------------------------------------------*

*/---------------------get_current_screen_value-----------------------\
FORM get_current_screen_value  USING    uv_screen_field
                                        uv_screen_number
                               CHANGING cv_screen_value.

  DATA: lt_dynpfields TYPE STANDARD TABLE OF dynpread,
        ls_dynpfields TYPE dynpread.


  ls_dynpfields-fieldname = uv_screen_field.
  APPEND ls_dynpfields TO lt_dynpfields.


  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = uv_screen_number
      translate_to_upper   = 'X'
*     REQUEST              = ' '
*     PERFORM_CONVERSION_EXITS = ' '
*     PERFORM_INPUT_CONVERSION = ' '
*     DETERMINE_LOOP_INDEX = ' '
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc = 0.
    READ TABLE lt_dynpfields INTO ls_dynpfields WITH KEY fieldname = uv_screen_field.
    IF sy-subrc = 0.
      cv_screen_value = ls_dynpfields-fieldvalue.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_current_screen_value

*/-------------------------pf_status_set-------------------\
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'SELOBJ' EXCLUDING rt_extab.

ENDFORM.                    "pf_status_set

*/-------------------------user_command_user-------------------\
FORM user_command_user USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN 'TAKE'.
* --> ZOLDOSP (15.01.2014 17:09:21): skrývání loga (při vykreslení ALV se znovu zobrazí) *****
*                                   = ošetření situace, kdy logo zůstane zobrazeno nechtěně **
      PERFORM hide_pf_logo CHANGING go_picture_control_1.
* <-- konec úpravy ******************************************

      rs_selfield-exit = 'X'.
  ENDCASE.
ENDFORM.                    "user_command_user

*---------------build_fieldCatalog---------------------------------*
FORM build_field_catalog.

  DATA: ls_fieldcat  LIKE LINE OF gt_fieldcat.

  REFRESH: gt_fieldcat.

  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-icon = 'X'.
  ls_fieldcat-seltext_l = 'Status'.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'OBJ_TYPE'.
  ls_fieldcat-seltext_l = TEXT-s01.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'OBJ_TYPE_TXT'.
  ls_fieldcat-seltext_l = TEXT-s02.
  ls_fieldcat-just = 'L'.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'OBJ_NAME'.
  ls_fieldcat-seltext_l = TEXT-s03.
  ls_fieldcat-just = 'L'.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'DOWN_FLAG'.
  ls_fieldcat-seltext_l = TEXT-s04.
  ls_fieldcat-just = 'C'.
  APPEND ls_fieldcat TO gt_fieldcat.

  ls_fieldcat-fieldname = 'MSG'.
  ls_fieldcat-just = 'L'.
  ls_fieldcat-seltext_l = TEXT-s05.
  APPEND ls_fieldcat TO gt_fieldcat.

  gs_layout-box_fieldname     = 'SELECT'.
  gs_layout-f2code            = 'MYPICK' .
  gs_layout-colwidth_optimize = 'X'.

ENDFORM.                    " build_fieldCatalog


*&---------------------------------------------------------------------*
*&      Form  Show_Initial_ALV
*&---------------------------------------------------------------------*
FORM show_initial_alv.

  DATA: lt_object_alv TYPE Y00CATT_ABAPDOC_OBJECT_ALV_T,
        lv_grid_title TYPE lvc_title.

  lv_grid_title = TEXT-t01.

* --> ZOLDOSP (13.01.2014 14:33:46): skryti loga ****
  PERFORM hide_pf_logo CHANGING go_picture_control_1.
  gv_alv_mode = cv_alv_init.
* <-- konec úpravy ******************************************

  lt_object_alv = go_main_obj->get_object_alv( ).
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = 'Y00CARP_ABAPDOC'
      i_callback_pf_status_set    = 'PF_STATUS_SET'
*     i_callback_top_of_page      = 'ALV_TOP_OF_PAGE'
      i_callback_html_top_of_page = 'ALV_HTML_TOP_OF_PAGE'
      i_html_height_top           = '13'
      i_callback_user_command     = 'USER_COMMAND_USER'
*     i_grid_title                = lv_grid_title
      it_fieldcat                 = gt_fieldcat
      is_layout                   = gs_layout
    TABLES
      t_outtab                    = lt_object_alv
    EXCEPTIONS
      OTHERS                      = 0.

*>>-> PaM 16.01.2014 14:30:23 - refresh selection
  go_main_obj->set_object_alv( lt_object_alv ).
*<-<< PaM 16.01.2014 14:30:23

ENDFORM.                    " Show_Initial_ALV


*&---------------------------------------------------------------------*
*&      Form  show_Results_ALV
*&---------------------------------------------------------------------*
FORM show_results_alv.

  DATA: lt_object_alv TYPE y00catt_abapdoc_object_alv_t.

* --> ZOLDOSP (13.01.2014 14:33:46): skryti loga pro ALV ****
  PERFORM hide_pf_logo CHANGING go_picture_control_1.
  gv_alv_mode = cv_alv_result.
* <-- konec úpravy ******************************************

  lt_object_alv = go_main_obj->get_object_alv( ).
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = 'Y00CARP_ABAPDOC'
      i_callback_html_top_of_page = 'ALV_HTML_TOP_OF_PAGE'
      i_html_height_top           = '13'
      i_callback_user_command     = 'USER_COMMAND_USER'
*     i_grid_title                = text-t02
      it_fieldcat                 = gt_fieldcat
      is_layout                   = gs_layout
    TABLES
      t_outtab                    = lt_object_alv
    EXCEPTIONS
      OTHERS                      = 0.

ENDFORM.                    " showResultsGrid

*&---------------------------------------------------------------------*
*&      Form  ALV_HTML_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CL_DD      text
*----------------------------------------------------------------------*
FORM alv_html_top_of_page USING cl_dd TYPE REF TO cl_dd_document.

  DATA: lv_text(255) TYPE c,  "Text
        lv_text2     LIKE lv_text,
        lv_header    LIKE lv_text,
        lv_logo_name TYPE sdydo_key,
        lc_doctable  TYPE REF TO cl_dd_table_element,
        lc_column1   TYPE REF TO cl_dd_area,
        lc_column2   TYPE REF TO cl_dd_area.

* Insert Table into Document
  CALL METHOD cl_dd->add_table
    EXPORTING
      no_of_columns               = 2
      cell_background_transparent = 'X'
      border                      = '0'
      width                       = '100%'
    IMPORTING
      table                       = lc_doctable.


* Use doctable parameter for all operations at table level
  CALL METHOD lc_doctable->add_column
*    EXPORTING
*      width  = '98%'
    IMPORTING
      column = lc_column1.

  CALL METHOD lc_doctable->add_column
*    EXPORTING
*      width  = '2%'
*       width  = '397px'
    IMPORTING
      column = lc_column2.

  CASE gv_alv_mode.
    WHEN cv_alv_init.
      lv_header = TEXT-t01.
    WHEN cv_alv_result.
      lv_header = TEXT-t02.
  ENDCASE.

  CALL METHOD lc_column1->add_text
    EXPORTING
      text      = lv_header
      sap_style = cl_dd_area=>heading
*     sap_fontsize = cl_dd_area=>medium
*     sap_color = cl_dd_area=>list_heading_int
    .

  lv_text = 'Documentation for '.
  CALL METHOD lc_column1->new_line.
  CALL METHOD lc_column1->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_area=>heading.

  IF p_doco EQ abap_true.     " object documentation
    CONCATENATE 'object type' p_objtyp  INTO lv_text SEPARATED BY space.
    CONCATENATE lv_text 'object name'   INTO lv_text SEPARATED BY ', '.
    CONCATENATE lv_text p_object        INTO lv_text SEPARATED BY space.

  ELSEIF p_docp EQ abap_true. " packet documentation
    CONCATENATE 'objects from packet' p_packag INTO lv_text SEPARATED BY space.

  ELSEIF p_doct EQ abap_true. " transport documentation
    CONCATENATE 'objects from transport' s_trkorr-low INTO lv_text SEPARATED BY space.
  ENDIF.


  CALL METHOD lc_column1->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_area=>heading
*     sap_color    = cl_dd_area=>list_negative_inv
    .
  CALL METHOD lc_column1->add_text
    EXPORTING
      text         = ' | '
      sap_emphasis = cl_dd_area=>heading
*     sap_color    = cl_dd_area=>list_negative_inv
    .

*  CALL METHOD lc_column1->new_line.
  lv_text = 'Generated method'.
  IF p_redcx EQ abap_true.
    CONCATENATE lv_text 'DOCX' INTO lv_text SEPARATED BY ': '.
*  ELSEIF p_reole EQ abap_true.
*    CONCATENATE lv_text 'OLE' INTO lv_text SEPARATED BY ': '.
*  ELSEIF p_rexml EQ abap_true.
*    CONCATENATE lv_text 'XML' INTO lv_text SEPARATED BY ': '.
  ENDIF.

  CONCATENATE 'Output file' gv_file_name INTO lv_text2 SEPARATED BY ': '.
  CONCATENATE lv_text2 lv_text INTO lv_text SEPARATED BY ' | '.


  CALL METHOD lc_column1->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_area=>heading.

  lv_logo_name = cv_logo_alv_name.
  CALL METHOD lc_column2->add_picture
    EXPORTING
      picture_id = lv_logo_name
      width      = '360px'
      tabindex   = 2.

ENDFORM.                    "ALV_HTML_top_of_page


*&---------------------------------------------------------------------*
*&      Form  ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_top_of_page." USING cl_dd TYPE REF TO cl_dd_document..

  DATA: lt_list_comm TYPE slis_t_listheader,
        wa_list_comm LIKE LINE OF lt_list_comm.



  wa_list_comm-typ  = 'H'. "= Header, S = Selection, A = Action
*  wa_list_comm-key  = 'H2'.
  wa_list_comm-info = 'Select objects for documentation'.
*  wa_list_comm-info = 'Selection Criteria List: '.
  APPEND wa_list_comm TO lt_list_comm.

  wa_list_comm-typ  = 'S'. "= Header, S = Selection, A = Action
*  wa_list_comm-key  = 'H2'.
*  wa_list_comm-info = 'Select objects for documentation'.
  wa_list_comm-info = 'TOP OF PAGE UNDER CONSTRUCTION '.
  APPEND wa_list_comm TO lt_list_comm.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_list_comm
      i_logo             = 'KCT_LOGO'
*     i_logo             = 'Z_PERF_BY_KCT_LOGO'
*     I_END_OF_LIST_GRID =
    .

ENDFORM.                    "ALV_TOP_OF_PAGE


*&---------------------------------------------------------------------*
*&      Form  add_Objects_to_alv
*&---------------------------------------------------------------------*
FORM add_objects_to_alv.

  DATA: lv_count   TYPE i,
        lv_perc    TYPE i,
        ls_options TYPE y00cast_abapdoc_output_options,
        lo_main    TYPE REF TO y00cacl_abapdoc_main,
        lv_file    TYPE string,
        lv_rc      TYPE sysubrc.

  PERFORM build_field_catalog.

  IF sy-batch = abap_false.

    PERFORM show_initial_alv.

    IF sy-ucomm <> 'TAKE'.
      RETURN.
    ENDIF .

  ENDIF.

  CLEAR: go_render, go_xml_document.
* Render method
  IF p_redcx EQ abap_true.
    PERFORM create_docx_render CHANGING go_render
                                        lv_rc.
  ELSEIF p_rexml EQ abap_true.
    PERFORM create_xml_render CHANGING go_xml_document
                                        lv_rc.
  ENDIF.
  CHECK lv_rc IS INITIAL.

* Fill and output options
  PERFORM oop_fill CHANGING ls_options.
  go_main_obj->set_output_options( ls_options ).

* Generate doc
  go_main_obj->generate_tech_doc( EXPORTING io_render = go_render io_xml_document = go_xml_document ).

* Save render
  IF p_redcx EQ abap_true.
    PERFORM save_render USING go_render
                              gv_file_name
                     CHANGING lv_rc.
    CHECK lv_rc IS INITIAL.
  ELSEIF p_rexml EQ abap_true.
    PERFORM save_xml USING go_xml_document
                              gv_file_name
                     CHANGING lv_rc.
    CHECK lv_rc IS INITIAL.
  ENDIF.

  IF sy-batch = abap_false.

    PERFORM show_results_alv.

  ENDIF.

ENDFORM.                    " add_Objects_to_alv


*&---------------------------------------------------------------------*
*&      Form  CREATE_DOCX_RENDER
*&---------------------------------------------------------------------*
*       Create DOCX render object
*----------------------------------------------------------------------*
*      <--pyo_render  Render object
*      <--pyv_rc      Operation return code
*----------------------------------------------------------------------*
FORM create_docx_render  CHANGING pyo_render    TYPE REF TO y00caif_abapdoc_render
                                  VALUE(pyv_rc) TYPE sysubrc.

  DATA:
    lx_ex TYPE REF TO y00cacx_abapdoc_render.

* Try to create render
  TRY.
      CREATE OBJECT pyo_render TYPE y00cacl_abapdoc_docx_render.
    CATCH y00cacx_abapdoc_render INTO lx_ex.
      PERFORM write_render_errors USING '014'
                                        lx_ex.
      IF 1 = 0. MESSAGE e014. ENDIF.
*   Failed to create render object.
      pyv_rc = 4.
  ENDTRY.
ENDFORM.                    " CREATE_DOCX_RENDER


*&---------------------------------------------------------------------*
*&      Form  SAVE_RENDER
*&---------------------------------------------------------------------*
*       Render documentation and save to file
*----------------------------------------------------------------------*
*      -->pxo_render     Render object
*      -->pxv_file_path  Target file path
*      <--pyv_rc         Operation return code
*----------------------------------------------------------------------*
FORM save_render  USING    pxo_render    TYPE REF TO Y00CAIF_ABAPDOC_RENDER
                           VALUE(pxv_file_path)
                  CHANGING VALUE(pyv_rc) TYPE sysubrc.

  DATA:
    lv_file_path TYPE string,
    lx_ex        TYPE REF TO y00cacx_abapdoc_render.

* Save
  TRY.
      lv_file_path = pxv_file_path.

      IF p_local = abap_true.
        pxo_render->render_to_file( lv_file_path ).
      ELSE.
        pxo_render->render_to_file( iv_target_file_path = lv_file_path iv_location = 'A').
      ENDIF.
    CATCH y00cacx_abapdoc_render INTO lx_ex.
      PERFORM write_render_errors USING '015'
                                        lx_ex.
      IF 1 = 0. MESSAGE i015. ENDIF.
*   Documentation generate failed.
      pyv_rc = 4.
  ENDTRY.
ENDFORM.                    " SAVE_RENDER


*&---------------------------------------------------------------------*
*&      Form  WRITE_RENDER_ERRORS
*&---------------------------------------------------------------------*
*       Write render errors to spool
*----------------------------------------------------------------------*
*      -->pxv_header_message   Message number to be displayed as first
*      -->pxo_ex               Exception object
*----------------------------------------------------------------------*
FORM write_render_errors  USING    VALUE(pxv_header_message) TYPE msgno
                                   pxo_ex TYPE REF TO y00cacx_abapdoc_render.

  DATA:
    ls_return TYPE bapiret2.

* Write heading message
  MESSAGE ID 'Y00CAMSG_ABAPDOC' TYPE 'E' NUMBER pxv_header_message
         INTO ls_return-message.
  WRITE: / ls_return-message.

* Write all exception messages
  LOOP AT pxo_ex->messages INTO ls_return.
    WRITE: / ls_return-message.
  ENDLOOP.
ENDFORM.                    " WRITE_RENDER_ERRORS

*&---------------------------------------------------------------------*
*&      Form  OOP_FILL
*&---------------------------------------------------------------------*
*       Fill options structure from report parameters values.
*----------------------------------------------------------------------*
*      <--pys_options  Options structure
*----------------------------------------------------------------------*
FORM oop_fill  CHANGING pys_options TYPE y00cast_abapdoc_output_options.

* Move options to structure
  MOVE:
    p_optech TO pys_options-tech_docu,
    p_opmcom TO pys_options-only_main_comments,
    p_opsels TO pys_options-prg_sel_screen,
    p_oposcr TO pys_options-other_prg_screen,
    p_opintf TO pys_options-module_interfaces,
    p_empty1 TO pys_options-print_empty_par .

  pys_options-keyw_report = so_krep[] .
  pys_options-keyw_bsp = so_kbsp[] .
  pys_options-keyw_wda = so_kwda[] .

ENDFORM.                    " OOP_FILL


*&---------------------------------------------------------------------*
*&      Form  show_logo
*&---------------------------------------------------------------------*
*       Display KCT Data logo (Performed by Kct data
*----------------------------------------------------------------------*
FORM display_logo.

  DATA: lo_docking  TYPE REF TO cl_gui_docking_container,
        lv_url(256) TYPE c.
  DATA: lt_query_table    LIKE w3query OCCURS 1 WITH HEADER LINE,
        lt_html_table     LIKE w3html OCCURS 1,
        lv_return_code    LIKE w3param-ret_code,
        lv_content_type   LIKE w3param-cont_type,
        lv_content_length LIKE w3param-cont_len,
        lt_pic_data       LIKE w3mime OCCURS 0,
        lv_pic_size       TYPE i.
*  DATA: repid LIKE sy-repid.
*  repid = sy-repid.

  CHECK go_picture_control_1 IS NOT BOUND.

  CREATE OBJECT go_picture_control_1
    EXPORTING
      parent = lo_docking.

  CHECK sy-subrc = 0.

* picture_control_1->set_3d_border( EXPORTING border = 5 ). " border not needed
  go_picture_control_1->set_display_mode( EXPORTING display_mode = cl_gui_picture=>display_mode_fit ).

  PERFORM set_pf_logo_position_ss CHANGING go_picture_control_1.


  IF lv_url IS INITIAL.
    REFRESH lt_query_table.
    lt_query_table-name  = '_OBJECT_ID'.
    lt_query_table-value = cv_logo_ss_name.
    APPEND lt_query_table.

    CALL FUNCTION 'WWW_GET_MIME_OBJECT'
      TABLES
        query_string        = lt_query_table
        html                = lt_html_table
        mime                = lt_pic_data
      CHANGING
        return_code         = lv_return_code
        content_type        = lv_content_type
        content_length      = lv_content_length
      EXCEPTIONS
        object_not_found    = 1
        parameter_not_found = 2
        OTHERS              = 3.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type     = 'image'
        subtype  = cndp_sap_tab_unknown
        size     = lv_pic_size
        lifetime = cndp_lifetime_transaction
      TABLES
        data     = lt_pic_data
      CHANGING
        url      = lv_url
      EXCEPTIONS
        OTHERS   = 1.

  ENDIF.

  go_picture_control_1->load_picture_from_url( EXPORTING url = lv_url ).

*Syntax for URL
*url = 'file://D:\corp-gbanerji\pickut\cartoon_184.gif'.
*url = 'http://l.yimg.com/a/i/ww/beta/y3.gif'.

ENDFORM.                    "show_pic


*&---------------------------------------------------------------------*
*&      Form  set_logo_position_SS
*&---------------------------------------------------------------------*
*       Setting logo position for selection screen
*----------------------------------------------------------------------*
*      -->CR_PICTURE_CONTROL  text
*----------------------------------------------------------------------*
FORM set_pf_logo_position_ss CHANGING cr_picture_control LIKE go_picture_control_1.
  cr_picture_control->set_position( EXPORTING left   = cv_logo_ss_left
                                              top    = cv_logo_ss_top
                                              height = cv_logo_ss_height     "hold on to ratio 1:2!
                                              width  = cv_logo_ss_width ).
  cr_picture_control->set_visible( abap_true ).

ENDFORM.                    "set_logo_position_SS


*&---------------------------------------------------------------------*
*&      Form  set_logo_position_alv
*&---------------------------------------------------------------------*
*       Setting logo position for screen with ALV
*----------------------------------------------------------------------*
*      -->CR_PICTURE_CONTROL  text
*----------------------------------------------------------------------*
FORM set_pf_logo_position_alv CHANGING cr_picture_control LIKE go_picture_control_1.
  PERFORM hide_pf_logo CHANGING cr_picture_control.

*  cr_picture_control->set_position( EXPORTING left   = 0
*                                              top    = 1
*                                              height = 16     "hold on to ratio 1:2!
*                                              width  = 32 ).
*  cr_picture_control->set_visible( abap_true ).

ENDFORM.                    "set_logo_position_alv


*&---------------------------------------------------------------------*
*&      Form  hide_pf_logo
*&---------------------------------------------------------------------*
*       Logo hidding
*----------------------------------------------------------------------*
*      -->CR_PICTURE_CONTROL  text
*----------------------------------------------------------------------*
FORM hide_pf_logo CHANGING cr_picture_control LIKE go_picture_control_1.

  IF cr_picture_control IS NOT INITIAL.
    cr_picture_control->set_visible( abap_false ).
  ENDIF.

ENDFORM.                    "hide_pf_logo
*&---------------------------------------------------------------------*
*&      Form  FILL_SO_DEFAULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_so_default .
*& fill select-options with default value

  so_krep-sign = 'I' . so_krep-option = 'CP' .
  so_krep-low =   '#*&*' .
  APPEND  so_krep .

  so_kbsp-sign = 'I' . so_kbsp-option = 'CP' .
  so_kbsp-low =  '*navigation->*page*' .
  APPEND so_kbsp .
  so_kbsp-low =   '#*&*' .
  APPEND  so_kbsp .
  so_kbsp-low =   '*.htm*' .
  APPEND  so_kbsp .

ENDFORM.                    " FILL_SO_DEFAULT

*&---------------------------------------------------------------------*
*&      Form  CREATE_XML_RENDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--CO_XML_DOCUMENT  text
*      <--CV_RC  text
*----------------------------------------------------------------------*
FORM create_xml_render  CHANGING co_xml_document TYPE REF TO cl_xml_document
                                 VALUE(cv_rc) TYPE sysubrc.

  CREATE OBJECT co_xml_document.

  co_xml_document->create_simple_element( name = 'schemaModel' ).

ENDFORM.                    " CREATE_XML_RENDER

*&---------------------------------------------------------------------*
*&      Form  SAVE_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_XML_DOCUMENT  text
*      -->PV_FILE  text
*      <--CV_RC  text
*----------------------------------------------------------------------*
FORM save_xml  USING    po_xml_document TYPE REF TO cl_xml_document
                        VALUE(pv_file)
               CHANGING VALUE(cv_rc) TYPE sysubrc.

  DATA: lv_file_path TYPE localfile,
        lv_text      TYPE string,

        lv_size      TYPE sytabix,

        lx_ex        TYPE REF TO y00cacx_abapdoc_render,

        lt_data      TYPE STANDARD TABLE OF char255,
        ls_data      LIKE LINE OF lt_data.

* Save
  TRY.
      lv_file_path = pv_file.

      IF sy-batch = abap_false.
        po_xml_document->display( ).
      ENDIF.

      IF p_local = abap_true.

        cv_rc = po_xml_document->export_to_file( lv_file_path ).
        IF cv_rc <> 0.
          MESSAGE e015(y00camsg_abpdoc) INTO lv_text.

          WRITE: / lv_text.
        ENDIF.

      ELSE.

        CALL METHOD po_xml_document->render_2_table
          EXPORTING
            pretty_print = abap_true
          IMPORTING
            retcode      = cv_rc
            table        = lt_data
            size         = lv_size.

        IF cv_rc = 0.
          OPEN DATASET pv_file FOR OUTPUT IN BINARY MODE. "TEXT MODE ENCODING DEFAULT.
          IF sy-subrc = 0.
            LOOP AT lt_data INTO ls_data.
              IF lv_size < 510.
                TRANSFER ls_data TO pv_file LENGTH lv_size.
              ELSE.
                lv_size = lv_size - 510.
                TRANSFER ls_data TO pv_file.
              ENDIF.
            ENDLOOP.
            CLOSE DATASET pv_file.
          ENDIF.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE y00cacx_abapdoc_render.
          ENDIF.
        ENDIF.

      ENDIF.
    CATCH y00cacx_abapdoc_render INTO lx_ex.
      PERFORM write_render_errors USING '015'
                                        lx_ex.
      IF 1 = 0. MESSAGE i015. ENDIF.
*   Documentation generate failed.
      cv_rc = 4.

  ENDTRY.

ENDFORM.                    " SAVE_XML