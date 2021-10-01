method RENDER_ADD_INFO.

  DATA: lv_text TYPE string,
        lt_text TYPE stringtab,
        lv_description TYPE wdy_md_description.

  DATA: lx_root TYPE REF TO cx_root,
        lr_component TYPE REF TO if_wdy_md_component,
        lr_component_interface TYPE REF TO if_wdy_md_component_interface,
        lv_component_name TYPE wdy_component_name,
        lr_map TYPE REF TO if_object_map,
        lr_iter TYPE REF TO if_object_collection_iterator,
        lr_view TYPE REF TO if_wdy_md_abstract_view,
        lr_controller TYPE REF TO if_wdy_md_controller,
        ls_component_key TYPE wdy_md_component_key,
        ls_wdyd_object TYPE wdy_md_component_meta_data.

  DATA: lt_component_definition TYPE STANDARD TABLE OF wdy_component,
        lt_component_descriptions TYPE wdy_componentt_table,
        lt_component_usages TYPE wdy_compo_usage_table,
        lt_interface_implementings TYPE wdy_intf_implem_table,
        lt_library_usages TYPE wdy_library_use_table,
        lt_ext_ctlr_usages TYPE wdy_external_ctlr_usage_table,
        lt_ext_ctx_mappings TYPE wdy_external_ctx_mapping_table,
        lt_psmodisrc TYPE STANDARD TABLE OF smodisrc,
        lt_psmodilog TYPE STANDARD TABLE OF smodilog.

  FIELD-SYMBOLS: <component_descriptions> LIKE LINE OF lt_component_descriptions,
                 <component_usage> LIKE LINE OF lt_component_usages.


  lv_component_name = is_object_alv-obj_name.
  ls_component_key-component_name = lv_component_name.

  CALL FUNCTION 'WDYD_GET_OBJECT'
    EXPORTING
      component_key           = ls_component_key
      r3state                 = 'A'
      get_all_translations    = 'X'
    IMPORTING
      object                  = ls_wdyd_object
    TABLES
      definition              = lt_component_definition
      descriptions            = lt_component_descriptions
      component_usages        = lt_component_usages
      interface_implementings = lt_interface_implementings
      library_usages          = lt_library_usages
      psmodilog               = lt_psmodilog
      psmodisrc               = lt_psmodisrc
      ext_ctlr_usages         = lt_ext_ctlr_usages
      ext_ctx_mappings        = lt_ext_ctx_mappings
    EXCEPTIONS
      not_existing            = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    ""err
  ENDIF.

* - Heading
  CONCATENATE is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text SEPARATED BY space.
  io_render->add_object_title( lv_text ).

* - Description
  IF LINES( lt_component_descriptions ) <> 0.
    CLEAR lt_text.
    LOOP AT lt_component_descriptions ASSIGNING <component_descriptions> WHERE component_name = lv_component_name AND
                                                                               langu          = sy-langu.
*      CONCATENATE 'Description:'(001) <component_descriptions>-description INTO lv_text SEPARATED BY space.
      lv_text = <component_descriptions>-description.
      APPEND lv_text TO lt_text.
    ENDLOOP.
    io_render->add_text( lt_text ).
    me->render_empty_line( io_render ).
  ENDIF.


* - WD component or WD component IF?
  IF cl_wdy_md_component=>is_component_interface_def( lv_component_name ) = abap_false. ""wd component

* Get component
    y00cacl_abapdoc_wdc_comp=>get_component_by_name(
      EXPORTING
        iv_name   = lv_component_name
      IMPORTING
        ir_object = lr_component
      EXCEPTIONS
        error     = 1
        OTHERS    = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ev_text_error.
      RETURN.
    ENDIF.

* - Assistence Class
    IF ls_wdyd_object-definition-assistance_class IS NOT INITIAL.
      CLEAR lt_text.
      lv_text = 'Assistence Class'(002).
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

      CLEAR lt_text.
      lv_text = ls_wdyd_object-definition-assistance_class.
      APPEND lv_text TO lt_text.
      io_render->add_text( lt_text ).
      me->render_empty_line( io_render ).
    ENDIF.

* - Component Usages
    IF LINES( lt_component_usages[] ) <> 0.
      CLEAR: lt_text.
      lv_text = 'Component Usages'(021).
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

      io_render->start_table( ).
      CLEAR: lt_text.
      lv_text = 'Component Use'(003).
      APPEND lv_text TO lt_text.
      lv_text = 'Component'(004).
      APPEND lv_text TO lt_text.
      lv_text = 'Description of Component'(005).
      APPEND lv_text TO lt_text.
      io_render->add_table_header_row( lt_text ).

      LOOP AT lt_component_usages ASSIGNING <component_usage>.
        CLEAR: lt_text,
               lv_description.

        lv_text = <component_usage>-compo_usage_name.
        APPEND lv_text TO lt_text.
        lv_text = <component_usage>-used_component.
        APPEND lv_text TO lt_text.

        y00cacl_abapdoc_wdc_comp=>read_component_description(
          EXPORTING
            iv_name        = <component_usage>-used_component
          IMPORTING
            ev_description = lv_description
               ).
        lv_text = lv_description.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).
      ENDLOOP.
      io_render->end_table( ).
      me->render_empty_line( io_render ).
    ENDIF.

* - Component Controller
    lv_text = 'Component Controller'(006).
    io_render->add_object_subtitle( lv_text ).

    CALL METHOD lr_component->get_component_controller
      RECEIVING
        component_controller = lr_controller.

    me->render_add_info_controller(
      EXPORTING
        io_render     = io_render
        ir_controller = lr_controller
      IMPORTING
        ev_text_error = ev_text_error
        ef_result     = ef_result ).

    IF ef_result = abap_false.
      RETURN.
    ENDIF.

* -- Window-views
    lr_map ?= lr_component->get_windows( ).
    lr_iter = lr_map->get_values_iterator( ).

    IF lr_iter->has_next( ) = 'X'.
      lv_text = 'Windows'(007).
      io_render->add_object_subtitle( lv_text ).
    ENDIF.

    WHILE lr_iter->has_next( ) = 'X'.
      TRY.
* --- Window-views
          lr_view ?= lr_iter->get_next( ).
          me->render_add_info_view(
            EXPORTING
              io_render     = io_render
              ir_view       = lr_view
            IMPORTING
              ev_text_error = ev_text_error
              ef_result     = ef_result ).

          IF ef_result = abap_false.
            RETURN.
          ENDIF.
* ---- Window-views controller
          lr_controller = lr_view->get_view_controller( ).
          me->render_add_info_controller(
            EXPORTING
              io_render     = io_render
              ir_controller = lr_controller
            IMPORTING
              ev_text_error = ev_text_error
              ef_result     = ef_result ).

          IF ef_result = abap_false.
            RETURN.
          ENDIF.

        CATCH cx_wdy_md_already_existing.
*          WRITE: / icon_led_yellow AS ICON, lv_component_name, 'Window-view controller already existing'.
      ENDTRY.
    ENDWHILE.

* -- Views
    lr_map ?= lr_component->get_views( ).
    lr_iter = lr_map->get_values_iterator( ).

    IF lr_iter->has_next( ) = 'X'.
      lv_text = 'Views'(008).
      io_render->add_object_subtitle( lv_text ).
    ENDIF.

    WHILE lr_iter->has_next( ) = 'X'.
      TRY.
* --- Views
          lr_view ?= lr_iter->get_next( ).
          me->render_add_info_view(
            EXPORTING
              io_render     = io_render
              ir_view       = lr_view
            IMPORTING
              ev_text_error = ev_text_error
              ef_result     = ef_result ).

          IF ef_result = abap_false.
            RETURN.
          ENDIF.

* --- Views controller
          lr_controller = lr_view->get_view_controller( ).
          me->render_add_info_controller(
            EXPORTING
              io_render     = io_render
              ir_controller = lr_controller
            IMPORTING
              ev_text_error = ev_text_error
              ef_result     = ef_result ).

          IF ef_result = abap_false.
            RETURN.
          ENDIF.

        CATCH cx_wdy_md_already_existing.

      ENDTRY.
    ENDWHILE.

  ELSE. ""wd component interface

* - Get component IF
    y00cacl_abapdoc_wdc_comp=>get_component_if_by_name(
      EXPORTING
        iv_name   = lv_component_name
      IMPORTING
        ir_object = lr_component_interface
      EXCEPTIONS
        error     = 1
        OTHERS    = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ev_text_error.
      RETURN.
    ENDIF.

* - Interface Controller
    lv_text = 'Interface Controller'(024).
    io_render->add_object_subtitle( lv_text ).

    CALL METHOD lr_component_interface->get_interface_controller
      RECEIVING
        interface_controller = lr_controller.

    me->render_add_info_controller(
      EXPORTING
        io_render     = io_render
        ir_controller = lr_controller
      IMPORTING
        ev_text_error = ev_text_error
        ef_result     = ef_result ).

    IF ef_result = abap_false.
      RETURN.
    ENDIF.

* -- Interface views
    lr_map ?= lr_component_interface->get_interface_views( ).
    lr_iter = lr_map->get_values_iterator( ).

    IF lr_iter->has_next( ) = 'X'.
      lv_text = 'Interface Views'(009).
      io_render->add_object_subtitle( lv_text ).
    ENDIF.

    WHILE lr_iter->has_next( ) = 'X'.
      TRY.
* --- Interface views
          lr_view ?= lr_iter->get_next( ).
          me->render_add_info_view(
            EXPORTING
              io_render     = io_render
              ir_view       = lr_view
            IMPORTING
              ev_text_error = ev_text_error
              ef_result     = ef_result ).

          IF ef_result = abap_false.
            RETURN.
          ENDIF.

* --- Interface views controller
          lr_controller = lr_view->get_view_controller( ).
          me->render_add_info_controller(
            EXPORTING
              io_render     = io_render
              ir_controller = lr_controller
            IMPORTING
              ev_text_error = ev_text_error
              ef_result     = ef_result ).

          IF ef_result = abap_false.
            RETURN.
          ENDIF.
        CATCH cx_wdy_md_already_existing.
*              WRITE: / ICON_LED_YELLOW AS ICON, LV_COMPONENT_NAME, 'Interface view controller already existing'.
      ENDTRY.
    ENDWHILE.
  ENDIF.

endmethod.