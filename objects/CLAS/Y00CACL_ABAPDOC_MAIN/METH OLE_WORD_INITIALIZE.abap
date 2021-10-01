method OLE_WORD_INITIALIZE.

    CLEAR ev_text_error.

    ef_result = abap_true.

    CREATE OBJECT gs_ole_word 'WORD.APPLICATION' .
    IF sy-subrc <> 0 .
      MESSAGE s011(y00camsg_abpdoc) INTO ev_text_error.
      ef_result = abap_false.
    ELSE.
*--Setting object's visibility property
      SET PROPERTY OF gs_ole_word 'Visible' = '1' .
*--Opening a new document
      GET PROPERTY OF gs_ole_word 'Documents' = gs_ole_documents .
      CALL METHOD OF gs_ole_documents 'Add'.
*--Getting active document handle
      GET PROPERTY OF gs_ole_word 'ActiveDocument' = gs_ole_actdoc .
*--Getting active window document handle
      GET PROPERTY OF gs_ole_actdoc 'ActiveWindow' = gs_ole_actwin .
*--Getting view window document handle
      GET PROPERTY OF gs_ole_actwin 'View' = gs_ole_view .
*--Setting the view to the main document again
      SET PROPERTY OF gs_ole_view 'SeekView' = '0' . "Main document view

*--Getting applications handle
      GET PROPERTY OF gs_ole_actdoc 'Application' = gs_ole_application .

*  GET PROPERTY OF gs_application 'Options' = gs_options .
      GET PROPERTY OF gs_ole_word 'Options' = gs_ole_options .
      SET PROPERTY OF gs_ole_options 'MeasurementUnit' = '1' . "CM

      GET PROPERTY OF gs_ole_word 'Selection' = gs_ole_selection.
      GET PROPERTY OF gs_ole_selection 'Font' = gs_ole_font.
      GET PROPERTY OF gs_ole_selection 'ParagraphFormat' = gs_ole_parformat .
*--Setting font attributes
      SET PROPERTY OF gs_ole_font 'Name' = 'Arial' .
      SET PROPERTY OF gs_ole_font 'Size' = '10' .
      SET PROPERTY OF gs_ole_font 'Bold' = '0' . "bold
      SET PROPERTY OF gs_ole_font 'Italic' = '0' . "Not italic
      SET PROPERTY OF gs_ole_font 'Underline' = '0' . "Not underlined
*--Setting paragraph format attribute
      SET PROPERTY OF gs_ole_parformat 'Alignment' = '0' . "Left-justified

    ENDIF .

endmethod.