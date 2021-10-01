method XML_ADD_INFO_PLUG_IOBOUND.

  DATA: lv_value          TYPE string,
        lv_value_2        TYPE string,
        ls_dd07v          TYPE dd07v,

        lo_xml_node_3col  TYPE REF TO if_ixml_node,
        lo_xml_node_4col  TYPE REF TO if_ixml_node.

  FIELD-SYMBOLS: <fs_navigation_links>        LIKE LINE OF gt_navigation_links,
                 <fs_navigation_target_refs>  LIKE LINE OF gt_navigation_target_refs,
                 <fs_vsh_nodes>               LIKE LINE OF gt_my_vsh_nodes.

  CLEAR: ev_text_error.

  ef_result = abap_true.

* Plug Inbound or Outbound
  lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col parent = io_xml_node ).
  IF is_iobound_plug-plug_type = 'CL_WDY_MD_INBOUND_PLUG'.
    io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_plug_type_in node = lo_xml_node_3col ).
  ELSE.
    io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_plug_type_out node = lo_xml_node_3col ).
  ENDIF.
  lv_value = is_iobound_plug-plug_name.
  io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
  lv_value = is_iobound_plug-is_intf_item.
  IF if_window = abap_true.
    io_xml_document->set_attribute( name = 'interface' value = lv_value node = lo_xml_node_3col ).
    IF is_iobound_plug-plug_type = 'CL_WDY_MD_INBOUND_PLUG'.
      ls_dd07v-domvalue_l = is_iobound_plug-in_plug_type.
      CALL FUNCTION 'DOMAIN_VALUE_GET'
        EXPORTING
          i_domname  = 'WDY_MD_INBOUND_PLUG_TYPE'
          i_domvalue = ls_dd07v-domvalue_l
        IMPORTING
          e_ddtext   = ls_dd07v-ddtext
        EXCEPTIONS
          not_exist  = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        ls_dd07v-ddtext = is_iobound_plug-in_plug_type.
      ENDIF.
      lv_value = ls_dd07v-ddtext.
      io_xml_document->set_attribute( name = 'plugType' value = lv_value node = lo_xml_node_3col ).
    ELSE.
      ls_dd07v-domvalue_l = is_iobound_plug-out_plug_type.
      CALL FUNCTION 'DOMAIN_VALUE_GET'
        EXPORTING
          i_domname  = 'WDY_MD_OUTBOUND_PLUG_TYPE'
          i_domvalue = ls_dd07v-domvalue_l
        IMPORTING
          e_ddtext   = ls_dd07v-ddtext
        EXCEPTIONS
          not_exist  = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        ls_dd07v-ddtext = is_iobound_plug-out_plug_type.
      ENDIF.
      lv_value = ls_dd07v-ddtext.
      io_xml_document->set_attribute( name = 'plugType' value = lv_value node = lo_xml_node_3col ).
    ENDIF.
  ENDIF.
  lv_value = is_iobound_plug_text-description.
  io_xml_document->create_simple_element( name = 'descr' value = lv_value parent = lo_xml_node_3col ).

  IF if_tree_view = abap_true.
* only outbound
    IF is_iobound_plug-plug_type = 'CL_WDY_MD_OUTBOUND_PLUG'.
      READ TABLE gt_navigation_links WITH KEY component_name = is_iobound_plug-component_name
                  source_plug_name = is_iobound_plug-plug_name source_plug_view = is_iobound_plug-view_name
                  source_vuse_name = iv_vuse_name ASSIGNING <fs_navigation_links>.
      IF sy-subrc = 0.

        LOOP AT gt_navigation_target_refs ASSIGNING <fs_navigation_target_refs> WHERE component_name = <fs_navigation_links>-component_name
                    AND window_name = <fs_navigation_links>-window_name
                    AND nav_link_name = <fs_navigation_links>-nav_link_name.

          READ TABLE gt_my_vsh_nodes WITH KEY used_view = <fs_navigation_target_refs>-target_plug_view
                      vsh_node_name = <fs_navigation_target_refs>-target_vuse_name
                      ASSIGNING <fs_vsh_nodes>.
          IF sy-subrc = 0.
            lo_xml_node_4col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_4col parent = lo_xml_node_3col ).
            io_xml_document->set_attribute( name = 'typeObj' value = y00cacl_abapdoc_wdc_comp=>co_obj_type_wdc node = lo_xml_node_4col ).
            IF <fs_vsh_nodes>-used_component IS INITIAL.
              lv_value = <fs_vsh_nodes>-component_name.
              lv_value_2 = y00cacl_abapdoc_wdc_comp=>co_wdc_type_view.
            ELSE.
              lv_value = <fs_vsh_nodes>-used_component.
              lv_value_2 = y00cacl_abapdoc_wdc_comp=>co_wdc_type_window.
            ENDIF.
            io_xml_document->set_attribute( name = 'nameObj' value = lv_value node = lo_xml_node_4col ).
            io_xml_document->set_attribute( name = 'typeCmp' value = lv_value_2 node = lo_xml_node_4col ).
            lv_value = <fs_vsh_nodes>-name_comp.
            io_xml_document->set_attribute( name = 'nameCmp' value = lv_value node = lo_xml_node_4col ).
            lv_value = 'inbound'.
            io_xml_document->set_attribute( name = 'typePlg' value = lv_value node = lo_xml_node_4col ).
            lv_value = <fs_navigation_target_refs>-target_plug_name.
            io_xml_document->set_attribute( name = 'namePlg' value = lv_value node = lo_xml_node_4col ).
          ELSE.
            IF <fs_navigation_target_refs>-target_vuse_name IS INITIAL.
* link the Window
              lo_xml_node_4col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_4col parent = lo_xml_node_3col ).
              io_xml_document->set_attribute( name = 'typeObj' value = y00cacl_abapdoc_wdc_comp=>co_obj_type_wdc node = lo_xml_node_4col ).
              lv_value = <fs_navigation_target_refs>-component_name.
              lv_value_2 = y00cacl_abapdoc_wdc_comp=>co_wdc_type_window.
              io_xml_document->set_attribute( name = 'nameObj' value = lv_value node = lo_xml_node_4col ).
              io_xml_document->set_attribute( name = 'typeCmp' value = lv_value_2 node = lo_xml_node_4col ).
              lv_value = <fs_navigation_target_refs>-target_plug_view.
              io_xml_document->set_attribute( name = 'nameCmp' value = lv_value node = lo_xml_node_4col ).
              lv_value = 'inbound'.
              io_xml_document->set_attribute( name = 'typePlg' value = lv_value node = lo_xml_node_4col ).
              lv_value = <fs_navigation_target_refs>-target_plug_name.
              io_xml_document->set_attribute( name = 'namePlg' value = lv_value node = lo_xml_node_4col ).
            ENDIF.
          ENDIF.

        ENDLOOP.

      ENDIF.
    ENDIF.

  ENDIF.

endmethod.