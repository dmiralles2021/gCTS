method OLE_WORD_ADD_INFO.

  data: lt_src_table      type standard table of string.
  data: progattribs       type trdir,
        progdescript      type trdirt,
        sourcestring      type string,
        ls_ole_actdoc     type ole2_object,
        ls_ole_selection  type ole2_object,
        ls_ole_font       type ole2_object,
        ls_ole_paragraphs type ole2_object,
        ls_ole_tables     type ole2_object,
        ls_ole_table      type ole2_object,
        ls_ole_border     type ole2_object,
        ls_ole_range      type ole2_object,
        lv_rows           type i,
        ls_src_table      type string,
        lv_name           type trdir-name,
        lv_text           type string.

  select single * from trdirt into progdescript where name = gv_obj_name.

  if sy-subrc = 0.

    get property of is_ole_word 'Selection' = ls_ole_selection.
    get property of ls_ole_selection 'Font' = ls_ole_font .
    call method of
        ls_ole_selection
        'EndKey'

      exporting
        #1               = '6'.

* Font setup ant headline writing
    message i102(y00camsg_abpdoc) with is_object_alv-obj_type_txt is_object_alv-obj_name into lv_text.
    set property of ls_ole_font 'Bold' = '1' . "Bold
    set property of ls_ole_font 'Size' = '14' .
    call method of
        ls_ole_selection
        'TypeText'

      exporting
        #1               = lv_text.
    set property of ls_ole_font 'Size' = '10' .
    set property of ls_ole_font 'Bold' = '0' . "Not bold
    call method of
        ls_ole_selection
        'TypeParagraph'.

    get property of ls_ole_selection 'Paragraphs' = ls_ole_paragraphs.
    call method of
        ls_ole_paragraphs
        'Indent'.

* ----------------------------
* Display of the program information
* ----------------------------

* Creation of a table containing program information
    lv_name = gv_obj_name.

    read report lv_name into lt_src_table.

    lv_rows = 1.

    loop at lt_src_table into ls_src_table.
      if ls_src_table cp '*&*'.
        lv_rows = lv_rows + 1.
      endif.
    endloop.

    get property of is_ole_word 'ActiveDocument' = ls_ole_actdoc .
    get property of ls_ole_actdoc 'Tables' = ls_ole_tables .
    get property of ls_ole_selection 'Range' = ls_ole_range .

    call method of
        ls_ole_tables
        'Add'         = ls_ole_table
      exporting
        #1            = ls_ole_range " Handle for range entity
        #2            = lv_rows "is_plugin-count "Number of rows
        #3            = '2' "Number of columns
        #4            = '1'  "wdWord9TableBehavior
        #5            = '1'. "wdAutoFitContent

* Setup without a frame
    get property of ls_ole_table 'Borders' = ls_ole_border .
    set property of ls_ole_border 'Enable' = '0' .

    data lv_progdescript type string.

    lv_progdescript = progdescript-text.

    message i104(y00camsg_abpdoc) into lv_text.
    me->ole_word_add_info_row( is_ole_font      = ls_ole_font
                               is_ole_selection = ls_ole_selection
                               iv_header        = lv_text
                               iv_text          = lv_progdescript ).

    loop at lt_src_table into ls_src_table.
      if ls_src_table cp '*&*'.
        me->ole_word_add_info_row( is_ole_font  = ls_ole_font
                               is_ole_selection = ls_ole_selection
                               iv_header        = ''
                               iv_text          = ls_src_table ).
      endif.
    endloop.



    get property of is_ole_word 'Selection' = ls_ole_selection.
    get property of ls_ole_selection 'Font' = ls_ole_font .
    call method of
        ls_ole_selection
        'EndKey'

      exporting
        #1               = '6'.

* indent by one position to the right
    call method of
        ls_ole_paragraphs
        'Outdent'.
    call method of
        ls_ole_selection
        'TypeParagraph'.
  else.

  endif.

endmethod.