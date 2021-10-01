method XML_ADD_INFO.

  DATA: lv_text           TYPE string,
        lv_value          TYPE string,
        lv_component_name TYPE wdy_component_name,

        ls_comp_usage     TYPE wdy_compo_usage,
        ls_md_view_key    TYPE wdy_md_view_key,

        lo_component      TYPE REF TO if_wdy_md_component,
        lo_object_map     TYPE REF TO if_object_map,
        lo_iter           TYPE REF TO if_object_collection_iterator,
        lo_view           TYPE REF TO if_wdy_md_abstract_view,
        lo_comp_usage     TYPE REF TO if_wdy_md_component_usage,

        lo_xml_node_root  TYPE REF TO if_ixml_node,
        lo_xml_node_1col  TYPE REF TO if_ixml_node,
        lo_xml_node_2col  TYPE REF TO if_ixml_node,
        lo_xml_node_3col  TYPE REF TO if_ixml_node,
        lo_xml_node_4col  TYPE REF TO if_ixml_node.

  CLEAR: ev_text_error.

  ef_result = abap_true.

  lo_xml_node_root = io_xml_document->find_node( name = y00cacl_abapdoc_wdc_comp=>co_node_root ).

  lo_xml_node_1col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_1col parent = lo_xml_node_root ).
  io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_obj_type_wdc node = lo_xml_node_1col ).
  lv_value = is_object_alv-obj_name.
  lv_component_name = lv_value.
  io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_1col ).

* - WD component or WD component IF?
  IF cl_wdy_md_component=>is_component_interface_def( lv_component_name ) = abap_false. ""wd component

* Get component
    y00cacl_abapdoc_wdc_comp=>get_component_by_name(
      EXPORTING
        iv_name   = lv_component_name
      IMPORTING
        ir_object = lo_component
      EXCEPTIONS
        error     = 1
        OTHERS    = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ev_text_error.
      ef_result = abap_false.
      RETURN.
    ENDIF.

    lv_value = lo_component->if_wdy_md_object~get_description( ).
    io_xml_document->create_simple_element( name = 'descr' value = lv_value parent = lo_xml_node_1col ).

* -- Window-views
    lo_object_map ?= lo_component->get_windows( ).
    lo_iter = lo_object_map->get_values_iterator( ).

    WHILE lo_iter->has_next( ) = 'X'.
* --- Window-views
      CLEAR: gt_navigation_links, gt_navigation_target_refs, gt_my_vsh_nodes, gt_vsh_placeholders.

      lo_view ?= lo_iter->get_next( ).
      ls_md_view_key-view_name = lo_view->if_wdy_md_object~get_name( ).
      ls_md_view_key-component_name = lo_view->if_wdy_md_object~get_parent_name( ).
      me->xml_add_info_window(
        EXPORTING
          if_tree_view    = abap_true
          io_xml_document = io_xml_document
          io_xml_node     = lo_xml_node_1col
          is_md_view_key  = ls_md_view_key
        IMPORTING
          ev_text_error   = ev_text_error
          ef_result       = ef_result ).

      IF ef_result = abap_false.
        RETURN.
      ENDIF.

    ENDWHILE.

* -- List Views in WDC
    lo_object_map ?= lo_component->get_views( ).
    lo_iter = lo_object_map->get_values_iterator( ).

    WHILE lo_iter->has_next( ) = 'X'.

      CLEAR: gt_navigation_links, gt_navigation_target_refs, gt_my_vsh_nodes, gt_vsh_placeholders.

      lo_view ?= lo_iter->get_next( ).
      ls_md_view_key-view_name = lo_view->if_wdy_md_object~get_name( ).
      ls_md_view_key-component_name = lo_view->if_wdy_md_object~get_parent_name( ).
      me->xml_add_info_view(
        EXPORTING
          if_tree_view    = abap_false
          io_xml_document = io_xml_document
          io_xml_node     = lo_xml_node_1col
          is_md_view_key  = ls_md_view_key
        IMPORTING
          ev_text_error   = ev_text_error
          ef_result       = ef_result ).

      IF ef_result = abap_false.
        RETURN.
      ENDIF.
    ENDWHILE.

** - Component Usages
    lo_object_map ?= lo_component->get_component_usages( ).
    lo_iter = lo_object_map->get_values_iterator( ).

    WHILE lo_iter->has_next( ) = 'X'.

      lo_comp_usage ?= lo_iter->get_next( ).
      lo_comp_usage->get_definition( IMPORTING definition = ls_comp_usage ).

      lo_xml_node_2col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_2col parent = lo_xml_node_1col ).
      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_wdc_type_used node = lo_xml_node_2col ).
      lv_value = ls_comp_usage-compo_usage_name.
      io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_2col ).

      lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col parent = lo_xml_node_2col ).
      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_plug_type_include node = lo_xml_node_3col ).
      io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).

      lo_xml_node_4col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_4col parent = lo_xml_node_3col ).
      io_xml_document->set_attribute( name = 'typeObj' value = y00cacl_abapdoc_wdc_comp=>co_obj_type_wdc node = lo_xml_node_4col ).
      lv_value = ls_comp_usage-used_component.
      io_xml_document->set_attribute( name = 'nameObj' value = lv_value node = lo_xml_node_4col ).
      io_xml_document->set_attribute( name = 'typeCmp' value = y00cacl_abapdoc_wdc_comp=>co_obj_type_wdc node = lo_xml_node_4col ).
      lv_value = ls_comp_usage-compo_usage_name.
      io_xml_document->set_attribute( name = 'nameCmp' value = lv_value node = lo_xml_node_4col ).

    ENDWHILE.

  ENDIF.

endmethod.