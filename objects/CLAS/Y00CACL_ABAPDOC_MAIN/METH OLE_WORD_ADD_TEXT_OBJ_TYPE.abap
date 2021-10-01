method OLE_WORD_ADD_TEXT_OBJ_TYPE.

  DATA: lv_text TYPE string.

  CLEAR ev_text_error.

  ef_result = abap_true.

  MESSAGE i100(y00camsg_abpdoc) WITH is_plugin-obj_type is_plugin-text INTO lv_text.

* Move to the end of the document
  GET PROPERTY OF gs_ole_word 'Selection' = gs_ole_selection.
  CALL METHOD OF gs_ole_selection 'EndKey' EXPORTING #1 = '6'.

* Font setup and headline writing
  GET PROPERTY OF gs_ole_selection 'Font' = gs_ole_font.
  SET PROPERTY OF gs_ole_font 'Bold' = '1' . "Bold
  SET PROPERTY OF gs_ole_font 'Size' = '14' .
  CALL METHOD OF gs_ole_selection 'TypeText' EXPORTING #1 = lv_text.
  SET PROPERTY OF gs_ole_font 'Size' = '10' .
  SET PROPERTY OF gs_ole_font 'Bold' = '0' . "Not bold
  CALL METHOD OF gs_ole_selection 'TypeParagraph'.

endmethod.