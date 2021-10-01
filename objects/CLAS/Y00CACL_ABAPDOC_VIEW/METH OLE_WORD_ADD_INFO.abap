method OLE_WORD_ADD_INFO.

  DATA: lv_text           TYPE string,
        lv_text_num(10)   TYPE c,
        lv_text2          TYPE string,
        lv_header         TYPE string,
        lv_value          TYPE string,
        lv_row            TYPE i,

        lv_objname        TYPE ddobjname,
        ls_dd02v          TYPE dd02v,
        lt_dd03p          TYPE STANDARD TABLE OF dd03p,
        ls_dd03p          TYPE dd03p,

        ls_ole_actdoc     TYPE ole2_object,
        ls_ole_selection  TYPE ole2_object,
        ls_ole_font       TYPE ole2_object,
        ls_ole_paragraphs TYPE ole2_object,
        ls_ole_tables     TYPE ole2_object,
        ls_ole_table      TYPE ole2_object,
        ls_ole_border     TYPE ole2_object,
        ls_ole_range      TYPE ole2_object.

  CLEAR ev_text_error.

  ef_result = abap_true.

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

  IF sy-subrc = 0.
* Move to the end of the document
    GET PROPERTY OF is_ole_word 'Selection' = ls_ole_selection.
    GET PROPERTY OF ls_ole_selection 'Font' = ls_ole_font .
    CALL METHOD OF
        ls_ole_selection
        'EndKey'

      EXPORTING
        #1               = '6'.

* Font setup and headline writing
    MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    SET PROPERTY OF ls_ole_font 'Size' = '14' .
    CALL METHOD OF
        ls_ole_selection
        'TypeText'

      EXPORTING
        #1               = lv_text.
    SET PROPERTY OF ls_ole_font 'Size' = '10' .
    SET PROPERTY OF ls_ole_font 'Bold' = '0' . "Not bold
    CALL METHOD OF
        ls_ole_selection
        'TypeParagraph'.

* Indent by one position to the left
    GET PROPERTY OF ls_ole_selection 'Paragraphs' = ls_ole_paragraphs.
    CALL METHOD OF
        ls_ole_paragraphs
        'Indent'.

****************************************************
* Creation of the table containig entries of another table
    GET PROPERTY OF is_ole_word 'ActiveDocument' = ls_ole_actdoc .
    GET PROPERTY OF ls_ole_actdoc 'Tables' = ls_ole_tables .
    GET PROPERTY OF ls_ole_selection 'Range' = ls_ole_range .

    CALL METHOD OF ls_ole_tables 'Add' = ls_ole_table
      EXPORTING
        #1            = ls_ole_range " Handle for range entity
        #2            = '4' "is_plugin-count "Number of rows
        #3            = '2' "Number of columns
        #4            = '1'  "wdWord9TableBehavior
        #5            = '1'. "wdAutoFitContent
*--Setup without a frame
    GET PROPERTY OF ls_ole_table 'Borders' = ls_ole_border .
    SET PROPERTY OF ls_ole_border 'Enable' = '0' . "No border

    lv_header = text-hi1.
    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = gv_obj_name ).

    lv_header = text-hi2.
    me->get_object_text( IMPORTING ev_object_text_multi = lv_text ).
    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = lv_text ).

    lv_header = text-hi3.
    lv_value = ls_dd02v-tabclass.
    lv_text = me->get_domain_text( iv_domain_name = 'TABCLASS' iv_domain_value = lv_value ).
    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = lv_text ).

    lv_header = text-hi4.
    lv_value = ls_dd02v-clidep.
    lv_text = me->get_domain_text( iv_domain_name = 'CLIDEP' iv_domain_value = lv_value ).
    lv_value = ls_dd02v-buffered.
    IF lv_value IS NOT INITIAL.
      lv_text2 = me->get_domain_text( iv_domain_name = 'BUFFERED' iv_domain_value = lv_value ).
      CONCATENATE lv_text cl_abap_char_utilities=>newline lv_text2 INTO lv_text.
    ENDIF.
    lv_value = ls_dd02v-mainflag.
    IF lv_value IS NOT INITIAL.
      lv_text2 = me->get_domain_text( iv_domain_name = 'MAINTFLAG' iv_domain_value = lv_value ).
      CONCATENATE lv_text cl_abap_char_utilities=>newline lv_text2 INTO lv_text.
    ENDIF.
    lv_value = ls_dd02v-contflag.
    IF lv_value IS NOT INITIAL.
      lv_text2 = me->get_domain_text( iv_domain_name = 'CONTFLAG' iv_domain_value = lv_value ).
      CONCATENATE lv_text cl_abap_char_utilities=>newline lv_text2 INTO lv_text.
    ENDIF.
    me->ole_word_add_info_row( is_ole_font = ls_ole_font is_ole_selection = ls_ole_selection iv_header = lv_header iv_text = lv_text ).

    GET PROPERTY OF is_ole_word 'Selection' = ls_ole_selection.
    GET PROPERTY OF ls_ole_selection 'Font' = ls_ole_font .
    CALL METHOD OF ls_ole_selection 'EndKey' EXPORTING #1 = '6'.

* Indent by one position to the right
    CALL METHOD OF ls_ole_paragraphs 'Outdent'.
    CALL METHOD OF ls_ole_selection 'TypeParagraph'.

****************************************************
* Creation of the table containig entries of another table
    GET PROPERTY OF is_ole_word 'ActiveDocument' = ls_ole_actdoc .
    GET PROPERTY OF ls_ole_actdoc 'Tables' = ls_ole_tables .
    GET PROPERTY OF ls_ole_selection 'Range' = ls_ole_range .

    lv_row = lines( lt_dd03p ) + 1.
    CALL METHOD OF ls_ole_tables 'Add' = ls_ole_table
      EXPORTING
        #1            = ls_ole_range " Handle for range entity
        #2            = lv_row "is_plugin-count "Number of rows
        #3            = '8' "Number of columns
        #4            = '1'  "wdWord9TableBehavior
        #5            = '1'. "wdAutoFitContent
*-- Setup with a frame
    GET PROPERTY OF ls_ole_table 'Borders' = ls_ole_border .
    SET PROPERTY OF ls_ole_border 'Enable' = '1' . "No border
*--Title
    lv_header = text-hp1.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    lv_header = text-hp2.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    lv_header = text-hp3.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    lv_header = text-hp4.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    lv_header = text-hp6.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    lv_header = text-hp7.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    lv_header = text-hp8.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    lv_header = text-hp9.
    SET PROPERTY OF ls_ole_font 'Bold' = '1' . "Bold
    CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_header.
    CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

    LOOP AT lt_dd03p INTO ls_dd03p.
      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = ls_dd03p-fieldname.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = ls_dd03p-keyflag.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = ls_dd03p-notnull.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = ls_dd03p-rollname.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

      CALL FUNCTION 'CONVERSION_EXIT_DTYPE_OUTPUT'
        EXPORTING
          input         = ls_dd03p-datatype
       IMPORTING
         OUTPUT        = lv_text.
      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_text.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

      WRITE ls_dd03p-leng NO-GAP NO-ZERO TO lv_text_num.
      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_text_num.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

      WRITE ls_dd03p-decimals NO-GAP NO-ZERO TO lv_text_num.
      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = lv_text_num.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.

      CALL METHOD OF ls_ole_selection 'TypeText' EXPORTING #1 = ls_dd03p-ddtext.
      CALL METHOD OF ls_ole_selection 'MoveRight' EXPORTING #1 = '1' #2 = '1'.
    ENDLOOP.

    GET PROPERTY OF is_ole_word 'Selection' = ls_ole_selection.
    GET PROPERTY OF ls_ole_selection 'Font' = ls_ole_font .
    CALL METHOD OF ls_ole_selection 'EndKey' EXPORTING #1 = '6'.

    CALL METHOD OF ls_ole_selection 'TypeParagraph'.

  ENDIF.
endmethod.