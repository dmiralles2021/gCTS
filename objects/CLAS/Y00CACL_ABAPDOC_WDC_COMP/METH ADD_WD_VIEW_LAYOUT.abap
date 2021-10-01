method ADD_WD_VIEW_LAYOUT.

  DATA: lt_text TYPE string_table,
        lv_text TYPE string.


  CLEAR: lt_text.
  lv_text = 'View Layout'(025).
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  DELETE it_ui_elements WHERE aggregation_name = 'LAYOUT' OR
                              aggregation_name = 'LAYOUT_DATA'.
  SORT it_ui_elements BY parent_name element_position.

  me->render_layout_lvl(
      iv_tree_level  = 0
      iv_parent_name = space ""root
      it_ui_elements = it_ui_elements[]
      io_render      = io_render
         ).

  me->render_empty_line( io_render ).
endmethod.