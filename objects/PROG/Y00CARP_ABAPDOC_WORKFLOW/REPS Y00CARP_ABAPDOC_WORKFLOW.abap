*&---------------------------------------------------------------------*
*& Program         y00carp_abapdoc_workflow
*&
*&---------------HOW IT WORKS------------------------------------------*
*& It extracts the WF definition using class cl_swf_def_to_bpml09.
*& Then it fills a read-only XML editor (class cl_proxy_xml_edit)
*&   with the acquired data.
*& This file can be saved on the local disk.
*& The "BPMN conventor" service can then be called via a button.
*&---------------
*& The program is still under construction !

REPORT  y00carp_abapdoc_workflow.

** ==============================================================================
** ==============================================================================
** ==
** == Selection screen
** ==
** ==============================================================================
** ==============================================================================


" pa_wfkey  encodes the structure SWD_WFDKEY - format for example 'WS773001500000S'
PARAMETERS pa_wfkey TYPE char15 OBLIGATORY.
PARAMETERS pa_langu TYPE sy-langu DEFAULT sy-langu.


** ==============================================================================
** ==============================================================================
** ==
** == Events
** ==
** ==============================================================================
** ==============================================================================

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_wfkey .
  PERFORM dlg_select_wf.

START-OF-SELECTION.
  CALL SCREEN '0200'.

** ==============================================================================
** ==============================================================================
** ==
** == Types and globals
** ==
** ==============================================================================
** ==============================================================================


  types: t_doc_data type CHAR1024.
  types: tt_doc_data type TABLE OF t_doc_data . "Document for HTML viewer at screen 300

* ts_alv_msg - list of encountered messages (formerly displayed as ALV Grid)
  TYPES: BEGIN OF ts_alv_msg,
          type    TYPE char1,
          message TYPE char200,
         END OF ts_alv_msg.
  TYPES tt_alv_msg TYPE TABLE OF ts_alv_msg.


  DATA: BEGIN OF gs_scr2, "Globals related to screen 200
          m_xml_string type string, "Content of XML
* XML container
          mo_xml_container TYPE REF TO cl_gui_custom_container,
          mo_xml_editor    TYPE REF TO cl_proxy_xml_edit,
* List of messages
*          mo_msg_container TYPE REF TO cl_gui_custom_container,
*          mo_msg_alv_grid  TYPE REF TO cl_gui_alv_grid,
        END OF gs_scr2.


  DATA: BEGIN OF gs_scr3, "Globals related to screen 300
* HTML viewer
            mr_xml_string type REF TO string, "Content of XML  ("REF TO" used to save space
            mo_html_container TYPE REF TO cl_gui_custom_container,
            mo_html_viewer    TYPE REF TO cl_gui_html_viewer,
          END OF gs_scr3.



** ==============================================================================
** ==============================================================================
** ==
** == PBO / PAI
** ==
** ==============================================================================
** ==============================================================================


*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF0200'.
  SET TITLEBAR  'TIT0200'.

  IF gs_scr2-mo_xml_container IS INITIAL.

* ============================================================
* = Read WF definition (BPML09)
* ============================================================
    DATA lv_str_xml_def TYPE string.
    DATA lt_msg         TYPE tt_alv_msg WITH HEADER LINE.
    PERFORM selscr_to_wf_definition CHANGING lv_str_xml_def  lt_msg[].

* ============================================================
* = Display the first error message
* ============================================================
    LOOP AT lt_msg WHERE type NA 'SIW'.
      MESSAGE lt_msg-message TYPE 'E'.
      EXIT.   "Only first message
    ENDLOOP.

* ============================================================
* = Init XML editor
* ============================================================
    gs_scr2-m_xml_string = lv_str_xml_def.
    PERFORM scr2_container_xml_init.
    PERFORM scr2_container_xml_fill USING gs_scr2-m_xml_string.
  ENDIF.
ENDMODULE.                 " STATUS_0200  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS 'PF0300'.
  SET TITLEBAR  'TIT0300'.
  IF gs_scr3-mo_html_container IS INITIAL.

    CREATE OBJECT gs_scr3-mo_html_container
      EXPORTING
        container_name = 'CUST'
      EXCEPTIONS
        others         = 1.
    CASE sy-subrc.
      WHEN 0.
*
      WHEN OTHERS.
        RAISE cntl_error.
    ENDCASE.
  ENDIF.

  IF gs_scr3-mo_html_viewer IS INITIAL.
    CREATE OBJECT gs_scr3-mo_html_viewer
      EXPORTING
        parent = gs_scr3-mo_html_container.
    IF sy-subrc NE 0.
      RAISE cntl_error.
    ENDIF.

    PERFORM scr3_load_html.
  ENDIF.
ENDMODULE.                 " STATUS_0300  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT'.
      gs_scr2-mo_xml_container->free( ).
      clear gs_scr2.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM scr2_on_cmd_save.
    WHEN 'CALL_SERVICE'.
      PERFORM scr2_on_cmd_call_service.
    WHEN 'TOGGLE'.
      gs_scr2-mo_xml_editor->toggle_change_mode( ). "No longer used
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT'.
      gs_scr3-mo_html_container->free( ).
      clear gs_scr3.

      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT

** ==============================================================================
** ==============================================================================
** ==
** == Forms
** ==
** ==============================================================================
** ==============================================================================

*&---------------------------------------------------------------------*
*&      Form  scr2_container_xml_init
*&---------------------------------------------------------------------*
* Inits the XML editor
*----------------------------------------------------------------------*
FORM scr2_container_xml_init.
  CREATE OBJECT gs_scr2-mo_xml_container
    EXPORTING
      container_name              = 'CONT_XML'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CREATE OBJECT gs_scr2-mo_xml_editor
    EXPORTING
      parent = gs_scr2-mo_xml_container.

ENDFORM.                    "scr2_container_xml_init

*&---------------------------------------------------------------------*
*&      Form  lvc__append_fcat
*&---------------------------------------------------------------------*
* Appends a line into field-catalog
*---------------------------------------------------------------------*
FORM lvc__append_fcat USING p_fieldname TYPE c
                            p_col_text TYPE c
                            p_tooltip TYPE c
                            ps_fcat TYPE lvc_s_fcat
                      CHANGING   pt_fcat TYPE lvc_t_fcat.
  DATA ls_fcat LIKE LINE OF pt_fcat.
  ls_fcat = ps_fcat. " The caller can pass the less common fields in ps_fcat
  ls_fcat-fieldname = p_fieldname.
  ls_fcat-coltext = p_col_text.
  ls_fcat-tooltip = p_tooltip.
  APPEND ls_fcat TO pt_fcat.
ENDFORM.                    "lvc__append_fcat

*&---------------------------------------------------------------------*
*&      Form  scr2_container_xml_fill
*&---------------------------------------------------------------------*
*  Fills the XML editor with data
*----------------------------------------------------------------------*
FORM scr2_container_xml_fill USING p_str_xml_def TYPE string.


  DATA lt_str TYPE string_table.
  DATA lv_xml TYPE string.
  lv_xml   = p_str_xml_def.
  ASSERT lv_xml CS '<'.
  IF sy-fdpos > 0.
    lv_xml = lv_xml+sy-fdpos. "Remove the strange char before the first '<'.
  ENDIF.
  REPLACE ALL OCCURRENCES OF 'encoding="utf-16"' IN lv_xml WITH 'encoding="utf-8"'.
  APPEND lv_xml TO lt_str  .
  gs_scr2-mo_xml_editor->set_text(  lt_str  ).

ENDFORM.                    "scr2_container_xml_fill


*&---------------------------------------------------------------------*
*&      Form  selscr_to_wf_definition
*&---------------------------------------------------------------------*
* Returns the XML (BPML09) definition of the Workflow defined on sel. screen.
* Returns encountered messages in pt_alv_msg
*----------------------------------------------------------------------*
FORM selscr_to_wf_definition CHANGING p_str_xml TYPE string pt_alv_msg TYPE tt_alv_msg.

  CLEAR: p_str_xml , pt_alv_msg[].

  ASSERT pa_wfkey IS NOT INITIAL. "Tested above.

  DATA ls_wfd_key TYPE  swd_wfdkey.
  ls_wfd_key =  pa_wfkey.

  DATA lo_d2b TYPE REF TO cl_swf_def_to_bpml09.
  CREATE OBJECT lo_d2b.

  DATA lo_xml_doc TYPE REF TO cl_xml_document_base.

  lo_xml_doc  = lo_d2b->convert_db(
                   language = pa_langu
                   wfdkey  = ls_wfd_key ).


  ASSERT lo_xml_doc IS NOT INITIAL. " Can it fail?


  lo_xml_doc->set_encoding( 'UTF-16').

  CALL METHOD lo_xml_doc->render_2_string
    IMPORTING
      stream = p_str_xml.

* =======================================
* = Get course of the conversion
* =======================================

  DATA lt_swd_err TYPE swd_terror WITH HEADER LINE.
  CALL METHOD lo_d2b->get_messages
    IMPORTING
      t_messages = lt_swd_err[].

* Convert messages into pt_alv_msg
  LOOP AT lt_swd_err.
    DATA lv_msg TYPE char200.
    MESSAGE ID lt_swd_err-workarea TYPE lt_swd_err-type NUMBER lt_swd_err-message
         WITH lt_swd_err-variable1 lt_swd_err-variable2 lt_swd_err-variable3 lt_swd_err-variable4 INTO lv_msg .
    PERFORM msg__append_1 USING lt_swd_err-type lv_msg CHANGING pt_alv_msg.
  ENDLOOP.

ENDFORM.                    "selscr_to_wf_definition


*&---------------------------------------------------------------------*
*&      Form  msg__append_1
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM msg__append_1 USING p_type TYPE char1 p_msg TYPE c CHANGING pt_alv_msg TYPE tt_alv_msg.
  DATA ls_alv_msg LIKE LINE OF pt_alv_msg.
  ls_alv_msg-type = p_type.
  ls_alv_msg-message = p_msg.
  APPEND ls_alv_msg TO pt_alv_msg.
ENDFORM.                    "msg__append_1


*&---------------------------------------------------------------------*
*&      Form  dlg_select_wf
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM dlg_select_wf .
  DATA ls_wfd_key TYPE swd_wfdkey.
  CALL FUNCTION 'SWD_POPUP_SELECT_WORKFLOW_TASK'
*   EXPORTING
*     TITLE                            =
*     CURRENT_TASK                     =
*     STANDARD_OBJECTS_ONLY            = ' '
*     CURRENT_VERSION                  =
*     IN_NEW_WFD_WHEN_NO_VERSION       =
*     IN_EXETYP                        =
*     IN_NO_TASK_SELECTION             =
    IMPORTING
*       TASK                             =
*     TASK_SHORT                       =
*     TASK_STEXT                       =
*     COPY_CONTAINER                   =
*     COPY_BINDING                     =
      wfdkey                           = ls_wfd_key
    EXCEPTIONS
      popup_canceled                   = 1
      OTHERS                           = 2
            .
  IF sy-subrc <> 0 AND sy-msgid IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF ls_wfd_key IS NOT INITIAL.
    pa_wfkey = ls_wfd_key.
  ENDIF.
ENDFORM.                    "dlg_select_wf



*&---------------------------------------------------------------------*
*&      Form  scr2_on_cmd_save
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM scr2_on_cmd_save.

* === Read the editor content ===
  DATA lt_str TYPE string_table.
  lt_str = gs_scr2-mo_xml_editor->get_text( ).

* === Return if the content is empty ===
  IF LINES( lt_str ) <= 1.
    DELETE lt_str WHERE table_line IS INITIAL.
    IF LINES( lt_str ) = 0 .
      MESSAGE text-e31 TYPE 'I'.
      RETURN.
    ENDIF.
  ENDIF.

* === Let user enter the path ===

  DATA dummy TYPE string.
  DATA lv_path TYPE string.
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
     EXPORTING
*    window_title         =
      default_extension    = 'xml'
     default_file_name    = '*.xml'
*    with_encoding        =
*    file_filter          =
      initial_directory    = 'C:\'
*    prompt_on_overwrite  = 'X'
    CHANGING
      filename             = dummy
      path                 = dummy
      fullpath             = lv_path
*    user_action          =
*    file_encoding        =
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4
          .
  CHECK sy-subrc = 0.
  CHECK lv_path  IS NOT INITIAL.


* === Save the file ===

  DATA: l_codepage TYPE cpcodepage ,
          l_encoding TYPE abap_encod .

  CALL FUNCTION 'SCP_GET_CODEPAGE_NUMBER'  "Zjisti codepage pracovní stanice
    IMPORTING
      gui_codepage   = l_codepage
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  l_encoding = l_codepage . "Konverze na vhodný typ

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*   BIN_FILESIZE                    =
      filename                        = lv_path
      replacement                     = ''
*   filetype                        = 'ASC'
*   APPEND                          = ' '
*   WRITE_FIELD_SEPARATOR           = ' '
*   HEADER                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
       codepage                      =  l_encoding
*   IGNORE_CERR                     = ABAP_TRUE
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
*   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*   SHOW_TRANSFER_STATUS            = ABAP_TRUE
* IMPORTING
*   FILELENGTH                      =
    TABLES
      data_tab                        = lt_str[]
*   FIELDNAMES                      =
 EXCEPTIONS
   file_write_error                = 1
   no_batch                        = 2
   gui_refuse_filetransfer         = 3
   invalid_type                    = 4
   no_authority                    = 5
   unknown_error                   = 6
   header_not_allowed              = 7
   separator_not_allowed           = 8
   filesize_not_allowed            = 9
   header_too_long                 = 10
   dp_error_create                 = 11
   dp_error_send                   = 12
   dp_error_write                  = 13
   unknown_dp_error                = 14
   access_denied                   = 15
   dp_out_of_memory                = 16
   disk_full                       = 17
   dp_timeout                      = 18
   file_not_found                  = 19
   dataprovider_exception          = 20
   control_flush_error             = 21
   OTHERS                          = 22
            .

  IF sy-subrc  = 0.
    MESSAGE 'Saving succeeded'(sa1) TYPE 'S'.
  ELSE.
    DATA lv_msg TYPE string.
    lv_msg = sy-subrc.
    CONCATENATE 'Saving failed with subrc'(sa2) lv_msg INTO lv_msg  SEPARATED BY space.
    MESSAGE lv_msg TYPE 'I'.
  ENDIF.


ENDFORM.                    "scr2_on_cmd_save

*&---------------------------------------------------------------------*
*&      Form  scr2_on_cmd_call_service
*&---------------------------------------------------------------------*
*  Calls the web service which converts BPML09 to format BPMN
*----------------------------------------------------------------------*
FORM scr2_on_cmd_call_service.
  get reference of gs_scr2-m_xml_string INTO gs_scr3-mr_xml_string.
  call screen 0300.
  return. " ------ older implementation follows ------

  CONSTANTS co_service_url TYPE char100 VALUE 'http://cevrdev:3000' .  "URL of the service
  CALL FUNCTION 'CALL_BROWSER'
    EXPORTING
      url                    = co_service_url
      window_name            = 'CEVRDEV'
      new_window             = 'X'
    EXCEPTIONS
      frontend_not_supported = 1
      prog_not_found         = 3
      OTHERS                 = 4.

ENDFORM.                    "scr2_on_cmd_call_service


*&---------------------------------------------------------------------*
*&      Form  str__append_doc_data
*&---------------------------------------------------------------------*
* Appends a line to pt_doc_data.
* The last parameter is the line; this enables a well-arranged code quoting the HTML document
*----------------------------------------------------------------------*
form str__append_doc_data TABLES pt_doc_data type tt_doc_data USING p_doc_data type t_doc_data.
  append p_doc_data  to pt_doc_data .
ENDFORM.                    "str__append_doc_data


*&---------------------------------------------------------------------*
*&      Form  scr3_compose_html
*&---------------------------------------------------------------------*
* Composes the HTML document to be displayed on screen 300
*----------------------------------------------------------------------*
form scr3_compose_html CHANGING pt_data type tt_doc_data .
  refresh pt_data.
  perform str__append_doc_data TABLES pt_data using:
*        '  <!DOCTYPE html> ',
' <html>  ',
'   <head>  ',
'	    <title>KCT ABAPdoc - BPMN conventor	',
'     </title>  ',
'	    <link rel="stylesheet" href="/stylesheets/style.css">	',
'	  </head>	',
'	  <body><h1>KCT ABAPdoc - BPMN conventor</h1>	',
'     <!-- --------------------------- Input Options ------------------------  -->  ',
'     <form name="transform" method="post" action="http://cevrdev:3000/transform" enctype="multipart/form-data">  ',
'       <br>  ',
'       <label>Input XML file(text):  ',
'       </label>  ',
'       <br>  ',
'	      <textarea rows="10" cols="80" name="inputT">a',
'bcd',
'</textarea>  ',
'         ',
'       <br>  ',
'       <br>  ',
'       <label>Input file type/source:  ',
'       </label>  ',
'       <br>  ',
'       <input type="radio" name="inputFtype" value="BWF" checked>  ',
'	      <label>SAP Business Workflow ( BPML v0.9)	',
'       </label>  ',
'       <br>  ',
'       <input type="radio" name="inputFtype" value="BPM">  ',
'	      <label>SAP ccBPMN ( BPEL4ES )	',
'       </label>  ',
'       <br>  ',
'       <input type="radio" name="inputFtype" value="ABAPdoc">  ',
'	      <label>ABAPdoc internal	',
'       </label>  ',
'       <br>  ',
'	      <input type="radio" name="inputFtype" value="WDA" disabled>	',
'       <label>WDA ( ABAPdoc 1.0 )  ',
'       </label>  ',
'       <br>  ',
'	      <input type="radio" name="inputFtype" value="BSP" disabled>	',
'       <label>BSP ( ABAPdoc 1.0 )  ',
'       </label>  ',
'	      <!--br-->	',
'	      <!--br-->	',
'       <!--textarea(id="TAplHolder", placeholder="placeholder for tree komponent")-->  ',
'       <br>  ',
'       <br>  ',
'       <button name="btn_setInp" type="submit">Select Process Blocks and Branches  ',
'	      </button>	',
'       <br>  ',
'       <br>  ',
'	      <label>-enable to adjust process description granularity by selecting a whole Blocks and Branches to be depicted as a just one Activity of sub-process task type.	',
'       </label>  ',
'       <br>  ',
'       <br>  ',
'       <label>Output options:  ',
'       </label>  ',
'       <br>  ',
'	      <input type="checkbox" name="output_opt" value="BWF">	',
'       <label>Box Shapes off-set (%):  ',
'       </label>  ',
'       <input type="text" name="out_opt_offset" placeholder="10" width="3">  ',
'       <br>  ',
'	      <input type="checkbox" name="output_opt" value="BPM">	',
'	      <label>Avoid Rigrr bugs	',
'       </label>  ',
'       <br>  ',
'	      <input type="checkbox" name="output_opt" value="WDA">	',
'       <label>Generate IDs for all activities  ',
'       </label>  ',
'       <br>  ',
'       <br>  ',
'	      <button name="btn_setOut" type="submit">Generate BPMN XML	',
'	      </button>	',
'	    </form>	',
'	  </body>	',
'	</html>	'.


endform.                    "scr3_compose_html


*&---------------------------------------------------------------------*
*&      Form  scr3_load_html
*&---------------------------------------------------------------------*
*     Inits the html_viewer control
*----------------------------------------------------------------------*
FORM scr3_load_html.
  data lt_data type tt_doc_data .
  perform scr3_compose_html CHANGING lt_data.

  DATA: lv_url TYPE sdok_url  .
  CONCATENATE sy-uzeit '.htm' INTO lv_url .
  DATA: lv_url_assigned TYPE sdok_url  .

  CALL METHOD gs_scr3-mo_html_viewer->LOAD_DATA
*     EXPORTING
*     URL                  = lv_url
*    TYPE                 = 'text'
*    SUBTYPE              = 'html'
*    SIZE                 = 0
*    ENCODING             =
*    CHARSET              =
*    LANGUAGE             =
     IMPORTING
       ASSIGNED_URL         = lv_url_assigned
    CHANGING
      DATA_TABLE           = lt_data[]
    EXCEPTIONS
      DP_INVALID_PARAMETER = 1
      DP_ERROR_GENERAL     = 2
      CNTL_ERROR           = 3
      others               = 4
          .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  else.
    CALL METHOD gs_scr3-mo_html_viewer->show_url
      EXPORTING
        url = lv_url_assigned.
  ENDIF.
endform.                    "scr3_load_html