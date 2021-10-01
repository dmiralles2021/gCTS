method OLE_WORD_ADD_INFO.

*  DATA: lv_text           TYPE string,
*        lv_text_num(10)   TYPE c,
*        lv_text2          TYPE string,
*        lv_header         TYPE string,
*        lv_value          TYPE string,
*        lv_row            TYPE i,
*
*        lv_objname        TYPE shlpname,
*        lt_dd32p          TYPE rsdg_t_dd32p,
*        ls_dd32p          TYPE dd32p,
*
*
*        ls_dd01v          TYPE dd01v,
*        ls_ole_actdoc     TYPE ole2_object,
*        ls_ole_selection  TYPE ole2_object,
*        ls_ole_font       TYPE ole2_object,
*        ls_ole_paragraphs TYPE ole2_object,
*        ls_ole_tables     TYPE ole2_object,
*        ls_ole_table      TYPE ole2_object,
*        ls_ole_border     TYPE ole2_object,
*        ls_ole_range      TYPE ole2_object.
*
*  CLEAR ev_text_error.
*
*  ef_result = abap_true.
*
** Read data
*  lv_objname = gv_obj_name.
*  CALL FUNCTION 'DD_SHLP_GET'
*    EXPORTING
**     GET_STATE           = 'M    '
*     langu               = sy-langu
**     PRID                = 0
*      shlp_name           = lv_objname
**     WITHTEXT            = ' '
**     ADD_TYPEINFO        = 'X'
**     TRACELEVEL          = 0
**   IMPORTING
**     DD30V_WA_A          =
**     DD30V_WA_N          =
**     GOT_STATE           =
*   TABLES
**     DD31V_TAB_A         =
**     DD31V_TAB_N         =
*     dd32p_tab_a         = lt_dd32p
**     DD32P_TAB_N         =
**     DD33V_TAB_A         =
**     DD33V_TAB_N         =
*   EXCEPTIONS
*     illegal_value       = 1
*     op_failure          = 2
*     OTHERS              = 3
*     .
*
*  IF sy-subrc = 0.
**   move to the end of the document
*    GET PROPERTY OF is_ole_word 'Selection' = ls_ole_selection.
*    GET PROPERTY OF ls_ole_selection 'Font' = ls_ole_font .
*    CALL METHOD OF
*      ls_ole_selection
*      'EndKey'
*      EXPORTING
*      #1 = '6'.
*
**   Font setup and headline writing
*    MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    SET PROPERTY OF ls_ole_font 'Size' = '14' .
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_text.
*    SET PROPERTY OF ls_ole_font 'Size' = '10' .
*    SET PROPERTY OF ls_ole_font 'Bold' = '0' . "Not bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeParagraph'.
*
**   Intend by one to the left
*    GET PROPERTY OF ls_ole_selection 'Paragraphs' = ls_ole_paragraphs.
*    CALL METHOD OF
*      ls_ole_paragraphs
*      'Indent'.
*
**   Table creation with table entries
*    GET PROPERTY OF is_ole_word 'ActiveDocument' = ls_ole_actdoc .
*    GET PROPERTY OF ls_ole_actdoc 'Tables' = ls_ole_tables .
*    GET PROPERTY OF ls_ole_selection 'Range' = ls_ole_range .
*
*    CALL METHOD OF
*        ls_ole_tables
*        'Add'         = ls_ole_table
*      EXPORTING
*        #1            = ls_ole_range " Handle for range entity
*        #2            = '4' "is_plugin-count "Number of rows
*        #3            = '2' "Number of columns
*        #4            = '1'  "wdWord9TableBehavior
*        #5            = '1'. "wdAutoFitContent
*
**   Setup without a frame
*    GET PROPERTY OF ls_ole_table 'Borders' = ls_ole_border .
*    SET PROPERTY OF ls_ole_border 'Enable' = '0' . "No border
*
*    lv_header = text-hi1.
*    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = gv_obj_name ).
*
*    lv_header = text-hi2.
*    me->get_object_text( IMPORTING ev_object_text_multi = lv_text ).
*    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = lv_text ).
*
*    lv_header = text-hi3.
*    lv_value = ls_dd01v-datatype.
*    lv_text = me->get_domain_text( iv_domain_name = 'DATATYPE' iv_domain_value = lv_value ).
*    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = lv_text ).
*
*    lv_header = text-hi4.
*    lv_value = ls_dd01v-lowercase.
*    lv_text = me->get_domain_text( iv_domain_name = 'LOWERCASE' iv_domain_value = lv_value ).
*    lv_value = ls_dd01v-convexit.
*    IF lv_value IS NOT INITIAL.
*      lv_text2 = me->get_domain_text( iv_domain_name = 'BUFFERED' iv_domain_value = lv_value ).
*      CONCATENATE lv_text cl_abap_char_utilities=>newline lv_text2 INTO lv_text.
*    ENDIF.
*    lv_value = ls_dd01v-signflag.
*    IF lv_value IS NOT INITIAL.
*      lv_text2 = me->get_domain_text( iv_domain_name = 'SIGNFLAG' iv_domain_value = lv_value ).
*      CONCATENATE lv_text cl_abap_char_utilities=>newline lv_text2 INTO lv_text.
*    ENDIF.
*    lv_value = ls_dd01v-langflag.
*    IF lv_value IS NOT INITIAL.
*      lv_text2 = me->get_domain_text( iv_domain_name = 'LANGFLAG' iv_domain_value = lv_value ).
*      CONCATENATE lv_text cl_abap_char_utilities=>newline lv_text2 INTO lv_text.
*    ENDIF.
*    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = lv_text ).
*
*    GET PROPERTY OF is_ole_word 'Selection' = ls_ole_selection.
*    GET PROPERTY OF ls_ole_selection 'Font' = ls_ole_font .
*    CALL METHOD OF
*      ls_ole_selection
*      'EndKey'
*      EXPORTING
*      #1 = '6'.
*
**   Intend by one to the right
*    CALL METHOD OF
*      ls_ole_paragraphs
*      'Outdent'.
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeParagraph'.
*
**   Table creation with table entries
*    GET PROPERTY OF is_ole_word 'ActiveDocument' = ls_ole_actdoc .
*    GET PROPERTY OF ls_ole_actdoc 'Tables' = ls_ole_tables .
*    GET PROPERTY OF ls_ole_selection 'Range' = ls_ole_range .
*
*    lv_row = LINES( lt_dd32P ) + 1.
*    CALL METHOD OF
*        ls_ole_tables
*        'Add'         = ls_ole_table
*      EXPORTING
*        #1            = ls_ole_range " Handle for range entity
*        #2            = lv_row "is_plugin-count "Number of rows
*        #3            = '8' "Number of columns
*        #4            = '1'  "wdWord9TableBehavior
*        #5            = '1'. "wdAutoFitContent
*
**   Setup with a frame
*    GET PROPERTY OF ls_ole_table 'Borders' = ls_ole_border .
*    SET PROPERTY OF ls_ole_border 'Enable' = '1' . "No border
*
**   title
*    lv_header = text-hp1.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*    lv_header = text-hp2.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*    lv_header = text-hp3.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*    lv_header = text-hp4.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*    lv_header = text-hp6.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*    lv_header = text-hp7.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*    lv_header = text-hp8.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*    lv_header = text-hp9.
*    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeText'
*      EXPORTING
*      #1 = lv_header.
*    CALL METHOD OF
*      ls_ole_selection
*      'MoveRight'
*      EXPORTING
*      #1 = '1'
*      #2 = '1'.
*
*    LOOP AT lt_dd32p INTO ls_dd32p.
*      CALL METHOD OF
*        ls_ole_selection
*        'TypeText'
*        EXPORTING
*        #1 = ls_dd32p-fieldname.
*      CALL METHOD OF
*        ls_ole_selection
*        'MoveRight'
*        EXPORTING
*        #1 = '1'
*        #2 = '1'.
*
*      CALL METHOD OF
*        ls_ole_selection
*        'MoveRight'
*        EXPORTING
*        #1 = '1'
*        #2 = '1'.
*
*      CALL METHOD OF
*        ls_ole_selection
*        'TypeText'
*        EXPORTING
*        #1 = ls_dd32p-rollname.
*      CALL METHOD OF
*        ls_ole_selection
*        'MoveRight'
*        EXPORTING
*        #1 = '1'
*        #2 = '1'.
*
*      CALL METHOD OF
*        ls_ole_selection
*        'TypeText'
*        EXPORTING
*        #1 = ls_dd32p-defaultval.
*      CALL METHOD OF
*        ls_ole_selection
*        'MoveRight'
*        EXPORTING
*        #1 = '1'
*        #2 = '1'.
*
*      CALL METHOD OF
*        ls_ole_selection
*        'TypeText'
*        EXPORTING
*        #1 = ls_dd32p-domname.
*      CALL METHOD OF
*        ls_ole_selection
*        'MoveRight'
*        EXPORTING
*        #1 = '1'
*        #2 = '1'.
*
*      CALL METHOD OF
*        ls_ole_selection
*        'TypeText'
*        EXPORTING
*        #1 = ls_dd32p-datatype.
*      CALL METHOD OF
*        ls_ole_selection
*        'MoveRight'
*        EXPORTING
*        #1 = '1'
*        #2 = '1'.
*
*      CALL METHOD OF
*        ls_ole_selection
*        'TypeText'
*        EXPORTING
*        #1 = ls_dd32p-leng.
*      CALL METHOD OF
*        ls_ole_selection
*        'MoveRight'
*        EXPORTING
*        #1 = '1'
*        #2 = '1'.
*    ENDLOOP.
*
*    GET PROPERTY OF is_ole_word 'Selection' = ls_ole_selection.
*    GET PROPERTY OF ls_ole_selection 'Font' = ls_ole_font .
*    CALL METHOD OF
*      ls_ole_selection
*      'EndKey'
*      EXPORTING
*      #1 = '6'.
*
*    CALL METHOD OF
*      ls_ole_selection
*      'TypeParagraph'.
*
*  ENDIF.

endmethod.