method CONVERT_METHOD_TYPE_DESCR.

  CASE iv_cmp_type.
    WHEN cl_wdy_md_controller_method=>if_wdy_md_param_feature~co_ctlr_event_handler.
      rv_descr = 'Event Handler'.

    WHEN cl_wdy_md_controller_method=>if_wdy_md_param_feature~co_controller_method.
      rv_descr = 'Method'.

    WHEN cl_wdy_md_controller_method=>if_wdy_md_param_feature~co_supply_function.
      rv_descr = 'Supply Function'.



    WHEN cl_wdy_md_controller_method=>if_wdy_md_param_feature~co_framework_event.
      rv_descr = 'Framework Event'.

    WHEN cl_wdy_md_controller_method=>if_wdy_md_param_feature~co_error_handler.
      rv_descr = 'Error Handler'.

    WHEN cl_wdy_md_controller_method=>if_wdy_md_param_feature~co_action.
      rv_descr = 'Action'.

    WHEN OTHERS.
      rv_descr = iv_cmp_type.

  ENDCASE.

endmethod.