method RENDER_CTX_ATTRS.

  DATA: lv_text           TYPE string,
        lt_text           TYPE stringtab,
        lv_tree_lev       LIKE iv_tree_level,
        lv_attr_type      TYPE string,
        lv_attr_descr     TYPE string.
  DATA: lt_ctx_attrs_sort LIKE it_ctx_attrs,
        wa_ctx_attr       LIKE LINE OF lt_ctx_attrs_sort.

* tree level
  lv_tree_lev = iv_tree_level + 1.

  lt_ctx_attrs_sort[] = it_ctx_attrs[].
  SORT lt_ctx_attrs_sort BY attrib_position ASCENDING.

* getting list of attributes
  LOOP AT lt_ctx_attrs_sort INTO wa_ctx_attr WHERE node_name EQ iv_node_name.
    CLEAR: lv_text, lv_attr_descr.

*   writting down the attribute name
    lv_text = wa_ctx_attr-attribute_name.

*   appending description
    lv_attr_type = wa_ctx_attr-abap_type.
    lv_attr_descr = Y00CACL_ABAPDOC_WDC_COMP=>get_data_type_descr( lv_attr_type ).
    IF lv_attr_descr IS NOT INITIAL.
      CONCATENATE lv_text lv_attr_descr INTO lv_text SEPARATED BY ' - '.
    ENDIF.

    APPEND lv_text TO lt_text.
  ENDLOOP.


  CHECK lt_text IS NOT INITIAL.
  io_render->add_wd_ctx_attribute( EXPORTING it_text        = lt_text
                                             iv_tree_level  = lv_tree_lev ).

endmethod.