METHOD XML_ADD_INFO_EVENT_PAGE_LAYOUT.

  DATA: lv_value            TYPE string,
        lf_found            TYPE flag,

        lv_text             TYPE string,
        lt_text             TYPE stringtab,
        ls_pagekey          TYPE o2pagkey,
        ls_page             LIKE LINE OF gt_page,

        lt_pageline         TYPE o2pageline_table,
        lt_event_handler    TYPE o2pagevh_tabletype,
        lt_navigation       LIKE gt_navigation,
        ls_navigation       LIKE LINE OF gt_navigation,

        lo_xml_node_3col_a  TYPE REF TO if_ixml_node,
        lo_xml_node_3col    TYPE REF TO if_ixml_node,
        lo_xml_node_4col    TYPE REF TO if_ixml_node,

        lo_bsp_page       TYPE REF TO cl_o2_api_pages.

  FIELD-SYMBOLS: <fs_navigation>    LIKE LINE OF gt_navigation,
                 <fs_event_handler> LIKE LINE OF lt_event_handler.

  CLEAR: ev_text_error.

  ef_result = abap_true.

  TRY.
* Get detail
      ls_pagekey-applname = is_page_attrib-applname.
      ls_pagekey-pagekey = is_page_attrib-pagekey.
      CALL METHOD cl_o2_api_pages=>load
        EXPORTING
          p_pagekey = ls_pagekey
        IMPORTING
          p_page    = lo_bsp_page.

** Event handlers
      CALL METHOD lo_bsp_page->get_event_handlers
        IMPORTING
          p_ev_handler = lt_event_handler.

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

      APPEND LINES OF gt_navigation TO lt_navigation.
      DELETE lt_navigation WHERE currname <> is_page_attrib-pagename.
* add event outbound plug if navigation
      LOOP AT lt_event_handler ASSIGNING <fs_event_handler>.

        lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
        io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_out node = lo_xml_node_3col ).
        lv_value = <fs_event_handler>-evhandler.
        io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).

        LOOP AT <fs_event_handler>-source INTO lv_text.

          IF lv_text IN is_output_options-keyw_bsp AND NOT is_output_options-keyw_bsp IS INITIAL.

            LOOP AT gt_navigation INTO ls_navigation WHERE currname = is_page_attrib-pagename.
              FIND FIRST OCCURRENCE OF ls_navigation-nodeexit IN lv_text.
              IF sy-subrc = 0.
                DELETE lt_navigation WHERE nodeexit = ls_navigation-nodeexit.
                READ TABLE gt_page WITH KEY pagename = ls_navigation-fupname INTO ls_page.
                IF sy-subrc = 0.

* Navigation
                  lo_xml_node_4col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_4col parent = lo_xml_node_3col ).
                  io_xml_document->set_attribute( name = 'typeObj' value = y00cacl_abapdoc_bsp=>co_obj_type_bsp node = lo_xml_node_4col ).

                  lv_value = ls_page-pagekey.
                  io_xml_document->set_attribute( name = 'nameObj' value = lv_value node = lo_xml_node_4col ).

                  CASE ls_page-pagetype.
                    WHEN 'C' .
                      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_controller node = lo_xml_node_4col ).
                    WHEN 'V'.
                      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_view node = lo_xml_node_4col ).
                    WHEN 'X' .
                      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_fragment node = lo_xml_node_4col ).
                    WHEN OTHERS .
                      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_flow node = lo_xml_node_4col ).
                  ENDCASE.

                  lv_value = 'inbound'.
                  io_xml_document->set_attribute( name = 'typePlg' value = lv_value node = lo_xml_node_4col ).
                  lv_value = 'IN'.
                  io_xml_document->set_attribute( name = 'namePlg' value = lv_value node = lo_xml_node_4col ).
                  io_xml_document->create_simple_element( name = 'descr' value = lv_text parent = lo_xml_node_4col ).

                ENDIF.
                EXIT.
              ENDIF.
            ENDLOOP.

          ENDIF.

        ENDLOOP.

      ENDLOOP.

      IF lt_navigation IS NOT INITIAL.
        LOOP AT lt_navigation ASSIGNING <fs_navigation>.
          lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
          io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_out node = lo_xml_node_3col ).
          lv_value = <fs_navigation>-nodeexit.
          io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
        ENDLOOP.
      ENDIF.

      CALL METHOD lo_bsp_page->get_page
        IMPORTING
          p_content = lt_pageline.

      CALL METHOD get_code_layout
        EXPORTING
          it_pageline  = lt_pageline
          it_key_words = is_output_options-keyw_bsp
        RECEIVING
          rt_text      = lt_text.

*   handler lisInclude, Controller
      lo_xml_node_3col_a = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col_a parent = io_xml_node ).
      io_xml_document->set_attribute( name = 'name' value = y00cacl_abapdoc_bsp=>co_handler_list_include node = lo_xml_node_3col_a ).

*   listInclude Inbound Plug
      lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
      io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_in node = lo_xml_node_3col ).
      lv_value = 'include'.
      io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).


      LOOP AT lt_text INTO lv_text.

        lf_found = abap_false.
        LOOP AT gt_page INTO ls_page.
          FIND FIRST OCCURRENCE OF ls_page-pagename IN lv_text.
          IF sy-subrc = 0.
            lf_found = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lf_found = abap_true.

*   listInclude Inbound Plug
          lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
          io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_include node = lo_xml_node_3col ).
          lv_value = ls_page-pagekey.
          io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
* Navigation
          lo_xml_node_4col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_4col parent = lo_xml_node_3col ).
          io_xml_document->set_attribute( name = 'typeObj' value = y00cacl_abapdoc_bsp=>co_obj_type_bsp node = lo_xml_node_4col ).

          lv_value = ls_page-pagekey.
          io_xml_document->set_attribute( name = 'nameObj' value = lv_value node = lo_xml_node_4col ).

          CASE ls_page-pagetype.
            WHEN 'C' .
              io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_controller node = lo_xml_node_4col ).
            WHEN 'V'.
              io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_view node = lo_xml_node_4col ).
            WHEN 'X' .
              io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_fragment node = lo_xml_node_4col ).
            WHEN OTHERS .
              io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_bsp_type_flow node = lo_xml_node_4col ).
          ENDCASE.

          lv_value = 'inbound'.
          io_xml_document->set_attribute( name = 'typePlg' value = lv_value node = lo_xml_node_4col ).
          lv_value = 'include'.
          io_xml_document->set_attribute( name = 'namePlg' value = lv_value node = lo_xml_node_4col ).
          io_xml_document->create_simple_element( name = 'descr' value = lv_text parent = lo_xml_node_4col ).
        ELSE.
*   listInclude Inbound Plug
          lo_xml_node_3col = io_xml_document->create_simple_element( name = y00cacl_abapdoc_bsp=>co_node_3col parent = lo_xml_node_3col_a ).
          io_xml_document->set_attribute( name = 'type' value = y00cacl_abapdoc_bsp=>co_plug_type_include node = lo_xml_node_3col ).
          lv_value = 'layout'.
          io_xml_document->set_attribute( name = 'name' value = lv_value node = lo_xml_node_3col ).
          io_xml_document->create_simple_element( name = 'descr' value = lv_text parent = lo_xml_node_3col ).
        ENDIF.

      ENDLOOP.

    CATCH cx_root.

      ef_result = abap_false.
      MESSAGE e451(y00camsg_abpdoc) WITH 'XML_ADD_INFO_EVENT_PAGE_LAYOUT' is_page_attrib-pagename INTO ev_text_error.

  ENDTRY.

ENDMETHOD.