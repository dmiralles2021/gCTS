method OLE_WORD_FREE.

  CLEAR: gs_ole_application, gs_ole_documents, gs_ole_actdoc, gs_ole_options, gs_ole_actwin, gs_ole_view,
         gs_ole_selection, gs_ole_font, gs_ole_parformat, gs_ole_tables, gs_ole_range,
         gs_ole_table, gs_ole_border, gs_ole_cell, gs_ole_paragraphs.

  CLEAR ev_text_error.

  ef_result = abap_true.

  FREE OBJECT gs_ole_word.

endmethod.