method RENDER_LAYOUT_LVL.

  DATA: lv_text   TYPE string,
        lt_text   TYPE stringtab,
        lv_tree_level_child TYPE i.

  FIELD-SYMBOLS: <ui_elements> LIKE LINE OF it_ui_elements.


  LOOP AT it_ui_elements ASSIGNING <ui_elements> WHERE parent_name = iv_parent_name.
    CLEAR: lt_text.
    lv_text = <ui_elements>-ui_element_def.
    TRANSLATE lv_text TO LOWER CASE.
    CONCATENATE lv_text <ui_elements>-element_name INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.

    io_render->add_wd_layout_item(
        it_text       = lt_text
        iv_tree_level = iv_tree_level
           ).

    lv_tree_level_child = iv_tree_level + 1.

    me->render_layout_lvl(
        iv_tree_level  = lv_tree_level_child
        iv_parent_name = <ui_elements>-element_name
        it_ui_elements = it_ui_elements[]
        io_render      = io_render
           ).
  ENDLOOP.


endmethod.