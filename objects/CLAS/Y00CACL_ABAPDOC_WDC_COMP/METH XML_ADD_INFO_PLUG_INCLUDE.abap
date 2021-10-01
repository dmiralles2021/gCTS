method XML_ADD_INFO_PLUG_INCLUDE.

  DATA: lv_value          TYPE string,
        lv_value_2        TYPE string,

        lo_xml_node_3col  TYPE REF TO if_ixml_node,
        lo_xml_node_4col  TYPE REF TO if_ixml_node.

  CLEAR: ev_text_error.

  ef_result = abap_true.

* Plug Include on root View
  lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col parent = io_xml_node ).
  io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_plug_type_include node = lo_xml_node_3col ).
  lv_value = is_my_vsh_node-used_view.
  io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).

  lo_xml_node_4col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_4col parent = lo_xml_node_3col ).
  io_xml_document->set_attribute( name = 'typeObj' value = y00cacl_abapdoc_wdc_comp=>co_obj_type_wdc node = lo_xml_node_4col ).
  IF is_my_vsh_node-used_component IS INITIAL.
    lv_value = is_my_vsh_node-component_name.
    lv_value_2 = y00cacl_abapdoc_wdc_comp=>co_wdc_type_view.
  ELSE.
    lv_value = is_my_vsh_node-used_component.
    lv_value_2 = y00cacl_abapdoc_wdc_comp=>co_wdc_type_window.
  ENDIF.
  io_xml_document->set_attribute( name = 'nameObj' value = lv_value node = lo_xml_node_4col ).
  io_xml_document->set_attribute( name = 'typeCmp' value = lv_value_2 node = lo_xml_node_4col ).
  IF if_tree_view = abap_true.
    lv_value = is_my_vsh_node-name_comp.
  ELSE.
    lv_value = is_my_vsh_node-used_view.
  ENDIF.
  io_xml_document->set_attribute( name = 'nameCmp' value = lv_value node = lo_xml_node_4col ).

  lv_value = 'inbound'.
  io_xml_document->set_attribute( name = 'typePlg' value = lv_value node = lo_xml_node_4col ).
  lv_value = 'include'.
  io_xml_document->set_attribute( name = 'namePlg' value = lv_value node = lo_xml_node_4col ).

endmethod.