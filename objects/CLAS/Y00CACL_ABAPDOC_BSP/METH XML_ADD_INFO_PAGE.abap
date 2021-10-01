METHOD XML_ADD_INFO_PAGE.

  DATA: lv_text               TYPE string,
        lv_value              TYPE string,
        lv_value_2            TYPE string,

        ls_page_key           TYPE o2pagkey,

        lo_xml_node_2col      TYPE REF TO if_ixml_node,
        lo_xml_node_3col      TYPE REF TO if_ixml_node,
        lo_xml_node_3col_a    TYPE REF TO if_ixml_node,
        lo_xml_node_4col      TYPE REF TO if_ixml_node,

        lo_bsp_page           TYPE REF TO cl_o2_api_pages,

        lx_exc                TYPE REF TO cx_root.

  FIELD-SYMBOLS: <fs_navigation>  LIKE LINE OF gt_navigation.

  CLEAR: ev_text_error.

  ef_result = abap_true.

  TRY.
      MOVE-CORRESPONDING is_page_attrib TO ls_page_key.

      CALL METHOD cl_o2_api_pages=>load
        EXPORTING
          p_pagekey = ls_page_key
        IMPORTING
          p_page    = lo_bsp_page.

      lo_xml_node_2col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_2col parent = io_xml_node ).
      lv_value = is_page_attrib-pagekey.
      io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_2col ).
      lv_value = is_page_attrib-descript.
      io_xml_document->create_simple_element( name = 'descr' value = lv_value parent = lo_xml_node_2col ).

      CASE is_page_attrib-pagetype.
        WHEN 'C' .
          io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_controller node = lo_xml_node_2col ).
        WHEN 'X' .
          io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_fragment node = lo_xml_node_2col ).
        WHEN 'V' .
          io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_view node = lo_xml_node_2col ).
        WHEN OTHERS .
          io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_flow node = lo_xml_node_2col ).
      ENDCASE.

      IF is_page_attrib-pagetype = 'C'.
        CALL METHOD me->xml_add_info_event_controller
          EXPORTING
            io_xml_document   = io_xml_document
            io_xml_node       = lo_xml_node_2col
            is_page_attrib    = is_page_attrib
            is_output_options = is_output_options
          IMPORTING
            ev_text_error     = ev_text_error
            ef_result         = ef_result.
      ELSE.
        CALL METHOD me->xml_add_info_event_page_layout
          EXPORTING
            io_xml_document   = io_xml_document
            io_xml_node       = lo_xml_node_2col
            is_page_attrib    = is_page_attrib
            is_output_options = is_output_options
          IMPORTING
            ev_text_error     = ev_text_error
            ef_result         = ef_result.
      ENDIF.
    CATCH cx_root INTO lx_exc.

      ef_result = abap_false.
      MESSAGE e017(y00camsg_abpdoc) INTO ev_text_error.

  ENDTRY.

ENDMETHOD.