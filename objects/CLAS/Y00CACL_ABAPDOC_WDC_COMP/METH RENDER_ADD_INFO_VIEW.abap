method RENDER_ADD_INFO_VIEW.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, assistence class, comp. usages,
*&   controller (methods, events, actions...), window-views.
*&  If the object is an interface rather than component,
*&   it outputs interface views and controller.
*&
*&  Does not use any flags in is_output_options.
*& -----------------------------------------------------------------


  DATA: ls_view_key TYPE wdy_md_view_key,
        lr_view TYPE REF TO cl_wdy_md_abstract_view,
        lr_wdy_md_view TYPE REF TO cl_wdy_md_view,
        lr_wdy_md_window TYPE REF TO cl_wdy_md_window,
        lv_ddtext TYPE dd07v-ddtext,
        lv_domvalue TYPE dd07v-domvalue_l,
        lv_domname TYPE dd07v-domname,
        lv_text TYPE string,
        lt_text TYPE stringtab.

  DATA: ls_wdyv_object TYPE wdy_md_view_meta_data,
        lt_view_definition TYPE STANDARD TABLE OF wdy_view_vrs,
        lt_view_descriptions TYPE wdy_viewt_table,
        lt_view_containers TYPE wdy_view_cntr_table,
        lt_view_container_texts TYPE  wdy_view_cntrt_table,
        lt_iobound_plugs TYPE wdy_iobound_plug_table,
        lt_iobound_plug_texts TYPE wdy_iobound_plgt_table,
        lt_plug_parameters TYPE wdy_plug_param_table,
        lt_plug_parameter_texts TYPE wdy_plug_paramt_table,
        lt_ui_elements TYPE wdy_ui_element_table,
        lt_ui_context_bindings TYPE wdy_ui_ctx_bind_table,
        lt_ui_event_bindings TYPE wdy_ui_evt_bind_table,
        lt_ui_ddic_bindings TYPE wdy_ui_ddic_bind_table,
        lt_ui_properties TYPE wdy_ui_property_table,
        lt_navigation_links TYPE wdy_nav_link_table,
        lt_navigation_target_refs TYPE  wdy_nav_targref_table,
        lt_vsh_nodes TYPE wdy_vsh_node_table,
        lt_vsh_placeholders TYPE wdy_vsh_pholder_table,
        lt_viewset_properties TYPE wdy_vs_property_table,
        lt_ui_texts TYPE wdy_ui_text_table,
        lt_psmodisrc TYPE STANDARD TABLE OF smodisrc,
        lt_psmodilog TYPE STANDARD TABLE OF smodilog.

  FIELD-SYMBOLS: <iobound_plugs> LIKE LINE OF lt_iobound_plugs,
                 <iobound_plug_texts> LIKE LINE OF lt_iobound_plug_texts,
                 <view_descriptions> LIKE LINE OF lt_view_descriptions,
                 <navigation_links> LIKE LINE OF lt_navigation_links,
                 <navigation_target_refs> LIKE LINE OF lt_navigation_target_refs.


  lr_view ?= ir_view.

  TRY.
      lr_wdy_md_window ?= lr_view.
    CATCH cx_sy_move_cast_error.
  ENDTRY.

  TRY.
      lr_wdy_md_view ?= lr_view.
    CATCH cx_sy_move_cast_error.
  ENDTRY.

  ls_view_key-component_name  = lr_view->if_wdy_md_object~get_parent_name( ).
  ls_view_key-view_name = lr_view->if_wdy_md_object~get_name( ).

  CALL FUNCTION 'WDYV_GET_OBJECT'
    EXPORTING
      view_key               = ls_view_key
      r3state                = 'A'
      get_all_translations   = 'X'
    IMPORTING
      object                 = ls_wdyv_object
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
    RETURN.
  ENDIF.

* - Heading
  lv_text = ls_view_key-view_name.
  io_render->add_object_subtitle2( lv_text ).

* - Description
  IF LINES( lt_view_descriptions ) <> 0.
    CLEAR lt_text.
    LOOP AT lt_view_descriptions ASSIGNING <view_descriptions> WHERE component_name = ls_wdyv_object-definition-component_name AND
                                                                     view_name      = ls_wdyv_object-definition-view_name AND
                                                                     langu          = sy-langu.
      lv_text = <view_descriptions>-description.
      APPEND lv_text TO lt_text.
    ENDLOOP.
    io_render->add_text( lt_text ).
    me->render_empty_line( io_render ).
  ENDIF.

* - Inbound/Outbound plugs
  IF LINES( lt_iobound_plugs[] ) <> 0.
    CLEAR: lt_text.
    lv_text = 'Inbound/Outbound plugs'(022).
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    io_render->start_table( ).
    CLEAR: lt_text.
    lv_text = 'Inbound/Outbound'(010).
    APPEND lv_text TO lt_text.
    lv_text = 'Plug name'(011).
    APPEND lv_text TO lt_text.
    IF lr_wdy_md_window IS BOUND.
      lv_text = 'Is interface?'(012).
      APPEND lv_text TO lt_text.
      lv_text = 'Plug type'(013).
      APPEND lv_text TO lt_text.
    ENDIF.
    lv_text = 'Description'(014).
    APPEND lv_text TO lt_text.
    io_render->add_table_header_row( lt_text ).

    LOOP AT lt_iobound_plugs ASSIGNING <iobound_plugs>.
      CLEAR: lt_text,
             lv_ddtext.

      IF <iobound_plugs>-plug_type = cl_wdy_md_inbound_plug=>if_wdy_md_param_feature~co_inbound_plug.
        lv_text = 'Inbound'(015).
      ELSEIF <iobound_plugs>-plug_type = cl_wdy_md_inbound_plug=>if_wdy_md_param_feature~co_outbound_plug.
        lv_text = 'Outbound'(016).
      ENDIF.
      APPEND lv_text TO lt_text.

      lv_text = <iobound_plugs>-plug_name.
      APPEND lv_text TO lt_text.

      IF lr_wdy_md_window IS BOUND.
        IF <iobound_plugs>-is_intf_item = abap_true.
          lv_text = 'X'.
        ELSEIF <iobound_plugs>-is_intf_item = abap_false.
          lv_text = space.
        ENDIF.
        APPEND lv_text TO lt_text.

        IF <iobound_plugs>-plug_type = cl_wdy_md_inbound_plug=>if_wdy_md_param_feature~co_inbound_plug.
          lv_domvalue = <iobound_plugs>-in_plug_type.
          lv_domname  = 'WDY_MD_INBOUND_PLUG_TYPE'.
        ELSEIF <iobound_plugs>-plug_type = cl_wdy_md_inbound_plug=>if_wdy_md_param_feature~co_outbound_plug.
          lv_domvalue = <iobound_plugs>-out_plug_type.
          lv_domname  = 'WDY_MD_OUTBOUND_PLUG_TYPE'.
        ENDIF.

        CALL FUNCTION 'DOMAIN_VALUE_GET'
          EXPORTING
            i_domname  = lv_domname
            i_domvalue = lv_domvalue
          IMPORTING
            e_ddtext   = lv_ddtext
          EXCEPTIONS
            not_exist  = 1
            OTHERS     = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ev_text_error.
          RETURN.
        ENDIF.

        lv_text = lv_ddtext.
        APPEND lv_text TO lt_text.
      ENDIF.

      CLEAR lv_text.
      READ TABLE lt_iobound_plug_texts ASSIGNING <iobound_plug_texts> WITH KEY component_name = <iobound_plugs>-component_name
                                                                               view_name      = <iobound_plugs>-view_name
                                                                               plug_name      = <iobound_plugs>-plug_name
                                                                               langu          = sy-langu.
      IF sy-subrc = 0.
        lv_text = <iobound_plug_texts>-description.
      ENDIF.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).
    ENDLOOP.
    io_render->end_table( ).
    me->render_empty_line( io_render ).
  ENDIF.


* - Navigation
  IF LINES( lt_navigation_links[] ) <> 0.
    CLEAR: lt_text.
    lv_text = 'Navigation'(023).
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    io_render->start_table( ).
    CLEAR: lt_text.
    lv_text = 'Source plug view'(017).
    APPEND lv_text TO lt_text.
    lv_text = 'Source plug name'(018).
    APPEND lv_text TO lt_text.
    lv_text = 'Target plug view'(019).
    APPEND lv_text TO lt_text.
    lv_text = 'Target plug name'(020).
    APPEND lv_text TO lt_text.
    io_render->add_table_header_row( lt_text ).

    LOOP AT lt_navigation_links ASSIGNING <navigation_links>.
      CLEAR: lt_text.

      lv_text = <navigation_links>-source_plug_view.
      APPEND lv_text TO lt_text.
      lv_text = <navigation_links>-source_plug_name.
      APPEND lv_text TO lt_text.

      READ TABLE lt_navigation_target_refs ASSIGNING <navigation_target_refs> WITH KEY component_name = <navigation_links>-component_name
                                                                                       window_name    = <navigation_links>-window_name
                                                                                       nav_link_name  = <navigation_links>-nav_link_name.
      IF sy-subrc = 0.
        lv_text = <navigation_target_refs>-target_plug_view.
        APPEND lv_text TO lt_text.
        lv_text = <navigation_target_refs>-target_plug_name.
        APPEND lv_text TO lt_text.
      ENDIF.
      io_render->add_table_row( lt_text ).
    ENDLOOP.
    io_render->end_table( ).
    me->render_empty_line( io_render ).
  ENDIF.

* - Layout
** todo hierarchicke zobrazeni stranky
  IF LINES( lt_ui_elements[] ) <> 0.
    me->add_wd_view_layout(
        io_render      = io_render
        it_ui_elements = lt_ui_elements[]
           ).
  ENDIF.

  ef_result = abap_true.

endmethod.