METHOD XML_ADD_INFO.

  DATA: lv_text           TYPE string,
        lv_value          TYPE string,

        lv_app_name       TYPE o2applname,
        ls_attrib         TYPE o2applattr,

        lo_bsp_app        TYPE REF TO cl_o2_api_application,

        lx_exc            TYPE REF TO cx_root,

        lo_xml_node_root  TYPE REF TO if_ixml_node,
        lo_xml_node_1col  TYPE REF TO if_ixml_node,
        lo_xml_node_2col  TYPE REF TO if_ixml_node,
        lo_xml_node_3col  TYPE REF TO if_ixml_node,
        lo_xml_node_4col  TYPE REF TO if_ixml_node.

  FIELD-SYMBOLS: <fs_page>          LIKE LINE OF gt_page.

  CLEAR: ev_text_error.

  ef_result = abap_true.

  lo_xml_node_root = io_xml_document->find_node( name = y00cacl_abapdoc_bsp=>co_node_root ).

  lo_xml_node_1col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_1col parent = lo_xml_node_root ).
  io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_obj_type_bsp node = lo_xml_node_1col ).
  lv_value = is_object_alv-obj_name.
  lv_app_name = is_object_alv-obj_name.
  io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_1col ).

  TRY.

      CALL METHOD cl_o2_api_application=>load
        EXPORTING
          p_application_name = lv_app_name
        IMPORTING
          p_application      = lo_bsp_app.

      CALL METHOD lo_bsp_app->get_attributes
        IMPORTING
          p_attributes = ls_attrib.

      lv_value = ls_attrib-text.
      io_xml_document->create_simple_element( name = 'descr' value = lv_value parent = lo_xml_node_1col ).

      CALL METHOD lo_bsp_app->get_navgraph
        IMPORTING
          p_navgraph = gt_navigation.

* BSP pages *********************************************************************
      CALL METHOD cl_o2_api_pages=>get_all_pages
        EXPORTING
          p_applname = lv_app_name
          p_version  = 'A'
        IMPORTING
          p_pages    = gt_page.

      LOOP AT gt_page ASSIGNING <fs_page>. " where pagetype = ' '.

        CALL METHOD me->xml_add_info_page
          EXPORTING
            io_xml_document   = io_xml_document
            io_xml_node       = lo_xml_node_1col
            is_page_attrib    = <fs_page>
            is_output_options = is_output_options
          IMPORTING
            ev_text_error     = ev_text_error
            ef_result         = ef_result.

        IF ef_result = abap_false.
          RETURN.
        ENDIF.

      ENDLOOP.

    CATCH cx_root INTO lx_exc.

      ef_result = abap_false.
      MESSAGE e017(y00camsg_abpdoc) INTO ev_text_error.

  ENDTRY.

ENDMETHOD.