method RENDER_EMPTY_LINE.

  DATA: lt_text TYPE string_table,
        lv_text TYPE string.


  APPEND lv_text TO lt_text.
  io_render->add_text( lt_text ).

endmethod.