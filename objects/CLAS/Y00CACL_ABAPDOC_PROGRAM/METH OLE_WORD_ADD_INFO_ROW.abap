method OLE_WORD_ADD_INFO_ROW.

    SET PROPERTY OF is_ole_font 'Italic' = '1' . "Italic

    CALL METHOD OF is_ole_selection 'TypeText'
      EXPORTING
        #1               = iv_header.

    CALL METHOD OF is_ole_selection 'MoveRight'
      EXPORTING
        #1               = '1' "wdCharacter,
        #2               = '1'.

    SET PROPERTY OF is_ole_font 'Italic' = '0' . "not Italic
    CALL METHOD OF is_ole_selection 'TypeText'
      EXPORTING
        #1               = iv_text.
    CALL METHOD OF is_ole_selection 'MoveDown'
      EXPORTING
        #1               = '5' "wdLine,
        #2               = '1'.
    CALL METHOD OF is_ole_selection 'MoveLeft'
      EXPORTING
        #1               = '1' "wdCharacter,
        #2               = '1'.

endmethod.