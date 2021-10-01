METHOD XML_ADD_INFO_EVENT_CONTROLLER.

  DATA: lv_value            TYPE string,
        lv_value_2          TYPE string,
        lf_found            TYPE flag,

        lv_text             TYPE string,
        lt_text             TYPE stringtab,

        ls_page             LIKE LINE OF gt_page,

        lv_clskey           TYPE seoclskey,

        lt_method           TYPE seop_methods_w_include,

        lo_xml_node_3col_a  TYPE REF TO if_ixml_node,
        lo_xml_node_3col    TYPE REF TO if_ixml_node,
        lo_xml_node_4col    TYPE REF TO if_ixml_node.

  FIELD-SYMBOLS: <fs_method>      LIKE LINE OF lt_method,
                 <fs_navigation>  LIKE LINE OF gt_navigation.

  CLEAR: ev_text_error.

  ef_result = abap_true.

  lv_clskey = is_page_attrib-implclass.
  lv_value = lv_clskey.
  io_xml_document->set_attribute( name = 'class' value = lv_value node = io_xml_node ).

* - Inbound Plug and Outbound Plug
  lo_xml_node_3col_a = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col_a parent = io_xml_node ).
  io_xml_document->set_attribute( name = 'name' value = y00cacl_abapdoc_bsp=>co_handler_event node = lo_xml_node_3col_a ).

* add default inbound plug if navigation
  READ TABLE gt_navigation WITH KEY applname = is_page_attrib-applname fupname = is_page_attrib-pagename TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
    io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_in node = lo_xml_node_3col ).
    lv_value = 'IN'.
    io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
  ENDIF.

* add default outbound plug if navigation
  READ TABLE gt_navigation WITH KEY applname = is_page_attrib-applname currname = is_page_attrib-pagename ASSIGNING <fs_navigation>.
  IF sy-subrc = 0.
    lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
    io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_out node = lo_xml_node_3col ).
    lv_value = 'DEFAULT'.
    io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
  ENDIF.

*   handler lisInclude, Controller
  lo_xml_node_3col_a = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col_a parent = io_xml_node ).
  io_xml_document->set_attribute( name = 'name' value = y00cacl_abapdoc_bsp=>co_handler_list_include node = lo_xml_node_3col_a ).

*   listInclude Inbound Plug
  lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
  io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_in node = lo_xml_node_3col ).
  lv_value = 'include'.
  io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).

  CALL FUNCTION 'SEO_CLASS_GET_METHOD_INCLUDES'
    EXPORTING
      clskey                       = lv_clskey
    IMPORTING
      includes                     = lt_method
    EXCEPTIONS
      _internal_class_not_existing = 1
      OTHERS                       = 2.
  IF sy-subrc IS NOT INITIAL.

    ef_result = abap_false.
    MESSAGE e451(y00camsg_abpdoc) WITH 'XML_ADD_INFO_EVENT_CONTROLLER' is_page_attrib-pagename INTO ev_text_error.

  ELSE.

    LOOP AT lt_method ASSIGNING <fs_method> WHERE cpdkey-cpdname = 'DO_HANDLE_EVENT'
                                OR  cpdkey-cpdname = 'DO_HANDLE_DATA'
                                OR  cpdkey-cpdname = 'DO_REQUEST'.

      CLEAR: lv_text.

      lv_text = <fs_method>-incname.

*   listInclude Inbound Plug
      lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_include node = lo_xml_node_3col ).
      lv_value = <fs_method>-cpdkey-cpdname.
      io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
      io_xml_document->create_simple_element( name = 'descr' value = 'Description method' parent = lo_xml_node_3col ).

      CALL METHOD get_code_comment
        EXPORTING
          iv_obj_name  = lv_text
          it_key_words = is_output_options-keyw_bsp
        RECEIVING
          rt_text      = lt_text.

      LOOP AT lt_text INTO lv_text.

        lf_found = abap_false.
        LOOP AT gt_page INTO ls_page WHERE pagetype = 'V'.
          FIND FIRST OCCURRENCE OF ls_page-pagename IN lv_text.
          IF sy-subrc = 0.
            lf_found = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lf_found = abap_true.
* Navigation
          lo_xml_node_4col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_4col parent = lo_xml_node_3col ).
          io_xml_document->set_attribute( name = 'typeObj' value = y00cacl_abapdoc_bsp=>co_obj_type_bsp node = lo_xml_node_4col ).

          lv_value = ls_page-pagekey.
          io_xml_document->set_attribute( name = 'nameObj' value = lv_value node = lo_xml_node_4col ).
          lv_value = y00cacl_abapdoc_bsp=>co_bsp_type_view.
          io_xml_document->set_attribute( name = 'typeCmp' value = lv_value node = lo_xml_node_4col ).

          lv_value = 'inbound'.
          io_xml_document->set_attribute( name = 'typePlg' value = lv_value node = lo_xml_node_4col ).
          lv_value = 'include'.
          io_xml_document->set_attribute( name = 'namePlg' value = lv_value node = lo_xml_node_4col ).
          io_xml_document->create_simple_element( name = 'descr' value = lv_text parent = lo_xml_node_4col ).
        ELSE.
          io_xml_document->create_simple_element( name = 'descr_meth' value = lv_text parent = lo_xml_node_3col ).
        ENDIF.

      ENDLOOP.

    ENDLOOP . "  AT lt_method_include INTO ls_method_include.

  ENDIF.

ENDMETHOD.