method GET_COMP_USAGE_INFO.

  DATA: ls_component_key            TYPE wdy_md_component_key.
  DATA: lt_component_definition     TYPE STANDARD TABLE OF wdy_component,
        lt_component_descriptions   TYPE wdy_componentt_table,
        lt_component_usages         TYPE wdy_compo_usage_table,
        lt_interface_implementings  TYPE wdy_intf_implem_table,
        lt_library_usages           TYPE wdy_library_use_table,
        lt_ext_ctlr_usages          TYPE wdy_external_ctlr_usage_table,
        lt_ext_ctx_mappings         TYPE wdy_external_ctx_mapping_table,
        lt_psmodisrc                TYPE STANDARD TABLE OF smodisrc,
        lt_psmodilog                TYPE STANDARD TABLE OF smodilog.

  ls_component_key-component_name = me->gv_obj_name.

  CALL FUNCTION 'WDYD_GET_OBJECT'
    EXPORTING
      component_key           = ls_component_key
      r3state                 = 'A'
      get_all_translations    = 'X'
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
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
  ELSE.
    rt_comp_usage[] = lt_component_usages[].
  ENDIF.


endmethod.