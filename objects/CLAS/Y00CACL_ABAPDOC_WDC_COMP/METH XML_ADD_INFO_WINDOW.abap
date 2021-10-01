method XML_ADD_INFO_WINDOW.

  DATA: lv_text                     TYPE string,
        lv_value                    TYPE string,
        lv_value_2                  TYPE string,

        lv_pholder_owner            TYPE wdy_vsh_node_name,

        ls_io_bound                 TYPE wdy_iobound_plug,
        ls_md_view_key              TYPE wdy_md_view_key,

        lo_xml_node_2col            TYPE REF TO if_ixml_node,
        lo_xml_node_3col            TYPE REF TO if_ixml_node,
        lo_xml_node_3col_a          TYPE REF TO if_ixml_node,
        lo_xml_node_4col            TYPE REF TO if_ixml_node.

  DATA: lt_view_definition          TYPE STANDARD TABLE OF wdy_view_vrs,
        lt_view_descriptions        TYPE wdy_viewt_table,
        lt_view_containers          TYPE wdy_view_cntr_table,
        lt_view_container_texts     TYPE  wdy_view_cntrt_table,
        lt_iobound_plugs            TYPE wdy_iobound_plug_table,

        lt_iobound_plug_texts       TYPE wdy_iobound_plgt_table,
        ls_iobound_plug_text        LIKE LINE OF lt_iobound_plug_texts,

        lt_plug_parameters          TYPE wdy_plug_param_table,
        lt_plug_parameter_texts     TYPE wdy_plug_paramt_table,
        lt_ui_elements              TYPE wdy_ui_element_table,
        lt_ui_context_bindings      TYPE wdy_ui_ctx_bind_table,
        lt_ui_event_bindings        TYPE wdy_ui_evt_bind_table,
        lt_ui_ddic_bindings         TYPE wdy_ui_ddic_bind_table,
        lt_ui_properties            TYPE wdy_ui_property_table,
        lt_navigation_links         TYPE wdy_nav_link_table,
        lt_navigation_target_refs   TYPE  wdy_nav_targref_table,
        lt_vsh_nodes                TYPE wdy_vsh_node_table,
        lt_vsh_placeholders         TYPE wdy_vsh_pholder_table,
        lt_viewset_properties       TYPE wdy_vs_property_table,
        lt_ui_texts                 TYPE wdy_ui_text_table,
        lt_psmodisrc                TYPE STANDARD TABLE OF smodisrc,
        lt_psmodilog                TYPE STANDARD TABLE OF smodilog.

  FIELD-SYMBOLS: <fs_iobound_plugs>           LIKE LINE OF lt_iobound_plugs,
                 <fs_view_descriptions>       LIKE LINE OF lt_view_descriptions,
                 <fs_vsh_nodes>               LIKE LINE OF gt_my_vsh_nodes.

  CLEAR: ev_text_error.

  ef_result = abap_true.

  lo_xml_node_2col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_2col parent = io_xml_node ).
  io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_wdc_type_window node = lo_xml_node_2col ).

  lv_value = is_md_view_key-view_name.
  io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_2col ).

  CALL FUNCTION 'WDYV_GET_OBJECT'
    EXPORTING
      view_key               = is_md_view_key
      r3state                = 'A'
      get_all_translations   = 'X'
*    IMPORTING
*      object                 = cs_wdyv_object
    TABLES
      definition             = lt_view_definition
      descriptions           = lt_view_descriptions
      view_containers        = lt_view_containers
      view_container_texts   = lt_view_container_texts
      iobound_plugs          = lt_iobound_plugs
      iobound_plug_texts     = lt_iobound_plug_texts
      plug_parameters        = lt_plug_parameters
      plug_parameter_texts   = lt_plug_parameter_texts
      ui_elements            = lt_ui_elements
      ui_context_bindings    = lt_ui_context_bindings
      ui_event_bindings      = lt_ui_event_bindings
      ui_ddic_bindings       = lt_ui_ddic_bindings
      ui_properties          = lt_ui_properties
      navigation_links       = lt_navigation_links
      navigation_target_refs = lt_navigation_target_refs
      vsh_nodes              = lt_vsh_nodes
      vsh_placeholders       = lt_vsh_placeholders
      viewset_properties     = lt_viewset_properties
      psmodilog              = lt_psmodilog
      psmodisrc              = lt_psmodisrc
      ui_texts               = lt_ui_texts
    EXCEPTIONS
      not_existing           = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ev_text_error.
    ef_result = abap_false.
    RETURN.
  ENDIF.

  APPEND LINES OF lt_navigation_links TO gt_navigation_links.
  APPEND LINES OF lt_navigation_target_refs TO gt_navigation_target_refs.
  APPEND LINES OF lt_vsh_placeholders TO gt_vsh_placeholders.

  me->copy_vsh_nodes( lt_vsh_nodes ).

  READ TABLE lt_view_descriptions WITH KEY langu = sy-langu ASSIGNING <fs_view_descriptions>.
  IF sy-subrc = 0.
    lv_value = <fs_view_descriptions>-description.
  ELSE.
    CLEAR lv_value.
  ENDIF.
  io_xml_document->create_simple_element( name = 'descr' value = lv_value parent = lo_xml_node_2col ).

* - Inbound Plug and Outbound Plug
  lo_xml_node_3col_a = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col_a parent = lo_xml_node_2Col ).
  io_xml_document->set_attribute( name = 'name' value = y00cacl_abapdoc_wdc_comp=>co_handler_event node = lo_xml_node_3col_a ).

  LOOP AT lt_iobound_plugs ASSIGNING <fs_iobound_plugs>.

    CLEAR: ls_iobound_plug_text.
    READ TABLE lt_iobound_plug_texts WITH KEY component_name = <fs_iobound_plugs>-component_name
            view_name = <fs_iobound_plugs>-view_name plug_name = <fs_iobound_plugs>-plug_name langu = sy-langu INTO ls_iobound_plug_text.

    CALL METHOD me->xml_add_info_plug_iobound
      EXPORTING
        if_tree_view         = if_tree_view
        if_window            = abap_true
        io_xml_document      = io_xml_document
        io_xml_node          = lo_xml_node_3col_a
        is_iobound_plug      = <fs_iobound_plugs>
        is_iobound_plug_text = ls_iobound_plug_text
        iv_vuse_name         = ''
      IMPORTING
        ev_text_error        = ev_text_error
        ef_result            = ef_result.

  ENDLOOP.

  IF if_tree_view = abap_true.

*   handler lisInclude
    lo_xml_node_3col_a = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col_a parent = lo_xml_node_2Col ).
    io_xml_document->set_attribute( name = 'name' value = y00cacl_abapdoc_wdc_comp=>co_handler_list_include node = lo_xml_node_3col_a ).

*   listInclude Inbound Plug
    lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col parent = lo_xml_node_3col_a ).
    io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_plug_type_in node = lo_xml_node_3col ).
    lv_value = 'include'.
    io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
* Plug Include on root View
    LOOP AT gt_my_vsh_nodes ASSIGNING <fs_vsh_nodes> WHERE pholder_owner = ''.

      CALL METHOD me->xml_add_info_plug_include
        EXPORTING
          if_tree_view    = abap_false
          io_xml_document = io_xml_document
          io_xml_node     = lo_xml_node_3col_a
          is_my_vsh_node  = <fs_vsh_nodes>
        IMPORTING
          ev_text_error   = ev_text_error
          ef_result       = ef_result.

    ENDLOOP.

*   handler treeInclude
    lo_xml_node_3col_a = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col_a parent = lo_xml_node_2Col ).
    io_xml_document->set_attribute( name = 'name' value = y00cacl_abapdoc_wdc_comp=>co_handler_tree_include node = lo_xml_node_3col_a ).

*   TreeInclude Inbound Plug
    lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_wdc_comp=>co_node_3col parent = lo_xml_node_3col_a ).
    io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_wdc_comp=>co_plug_type_in node = lo_xml_node_3col ).
    lv_value = 'include'.
    io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
* Plug Include on tree View
    LOOP AT gt_my_vsh_nodes ASSIGNING <fs_vsh_nodes> WHERE pholder_owner = ''.

      CALL METHOD me->xml_add_info_plug_include
        EXPORTING
          if_tree_view    = if_tree_view
          io_xml_document = io_xml_document
          io_xml_node     = lo_xml_node_3col_a
          is_my_vsh_node  = <fs_vsh_nodes>
        IMPORTING
          ev_text_error   = ev_text_error
          ef_result       = ef_result.

    ENDLOOP.

* - Include View ( Window -> View or Window -> Window (used component) or View -> View or View -> Window (used component)
    LOOP AT gt_my_vsh_nodes ASSIGNING <fs_vsh_nodes>.

      IF <fs_vsh_nodes>-used_component IS INITIAL.

        ls_md_view_key-component_name = <fs_vsh_nodes>-component_name.
        ls_md_view_key-view_name = <fs_vsh_nodes>-used_view.

        CALL METHOD me->xml_add_info_view
          EXPORTING
            if_tree_view    = abap_true
            io_xml_document = io_xml_document
            io_xml_node     = io_xml_node
            is_md_view_key  = ls_md_view_key
            is_my_vsh_node  = <fs_vsh_nodes>
          IMPORTING
            ev_text_error   = ev_text_error
            ef_result       = ef_result.
      ENDIF.

    ENDLOOP.

  ENDIF.

endmethod.