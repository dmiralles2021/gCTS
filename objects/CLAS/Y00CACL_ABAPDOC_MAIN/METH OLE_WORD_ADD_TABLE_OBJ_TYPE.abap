method OLE_WORD_ADD_TABLE_OBJ_TYPE.

  DATA: lv_text         TYPE string,
        lv_row          TYPE i,
        lo_classobject  TYPE REF TO y00cacl_abapdoc.

  FIELD-SYMBOLS: <fs_object_alv> LIKE LINE OF gt_object_alv.

  CLEAR ev_text_error.

  ef_result = abap_true.

  IF is_plugin-count > 0.
* Move to the end of the document
    GET PROPERTY OF gs_ole_word 'Selection' = gs_ole_selection.
    GET PROPERTY OF gs_ole_selection 'Font' = gs_ole_font .
    CALL METHOD OF
        gs_ole_selection
        'EndKey'

      EXPORTING
        #1               = '6'.

* Indent by one position to the left
    GET PROPERTY OF gs_ole_selection 'Paragraphs' = gs_ole_paragraphs.
    CALL METHOD OF
        gs_ole_paragraphs
        'Indent'.

* Tble creation
    GET PROPERTY OF gs_ole_actdoc 'Tables' = gs_ole_tables .
    GET PROPERTY OF gs_ole_selection 'Range' = gs_ole_range .

    lv_text = is_plugin-count.
    CALL METHOD OF
        gs_ole_tables
        'Add'         = gs_ole_table
      EXPORTING
        #1            = gs_ole_range " Handle for range entity
        #2            = lv_text "is_plugin-count "Number of rows
        #3            = '2' "Number of columns
        #4            = '1'  "wdWord9TableBehavior
        #5            = '1'. "wdAutoFitContent

*-- Setup without a frame
    GET PROPERTY OF gs_ole_table 'Borders' = gs_ole_border .
    SET PROPERTY OF gs_ole_border 'Enable' = '0' . "No border

    LOOP AT gt_object_alv ASSIGNING <fs_object_alv> WHERE down_flag = 'X' AND select = 'X' AND obj_type = is_plugin-obj_type.
* Object creation
      lv_text = <fs_object_alv>-obj_name.
      CREATE OBJECT lo_classobject TYPE (is_plugin-class_name)
        EXPORTING
          name = lv_text.

      SET PROPERTY OF gs_ole_font 'Italic' = '1' . "Italic
      CALL METHOD OF
          gs_ole_selection
          'TypeText'

        EXPORTING
          #1               = <fs_object_alv>-obj_name.
      CALL METHOD OF
          gs_ole_selection
          'MoveRight'

        EXPORTING
          #1               = '1' "wdCharacter,
          #2               = '1'.

      lo_classobject->get_object_text( IMPORTING ev_object_text_multi = lv_text ).
      SET PROPERTY OF gs_ole_font 'Italic' = '0' . "not Italic
      CALL METHOD OF
          gs_ole_selection
          'TypeText'

        EXPORTING
          #1               = lv_text.
      CALL METHOD OF
          gs_ole_selection
          'MoveDown'

        EXPORTING
          #1               = '5' "wdLine,
          #2               = '1'.
      CALL METHOD OF
          gs_ole_selection
          'MoveLeft'

        EXPORTING
          #1               = '1' "wdCharacter,
          #2               = '1'.
    ENDLOOP.
    CALL METHOD OF
        gs_ole_selection
        'MoveRight'

      EXPORTING
        #1               = '1' "wdCharacter,
        #2               = '1'.

* Indent by one positon to the right
    CALL METHOD OF
        gs_ole_paragraphs
        'Outdent'.
    CALL METHOD OF
        gs_ole_selection
        'TypeParagraph'.

  ENDIF.

endmethod.