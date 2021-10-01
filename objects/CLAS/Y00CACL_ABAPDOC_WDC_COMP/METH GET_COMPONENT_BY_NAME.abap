method GET_COMPONENT_BY_NAME.

  DATA: lv_version TYPE r3state,
        lx_root TYPE REF TO cx_root.


  lv_version        = wdywb_version_active.

* Get component
  TRY.
      CALL METHOD cl_wdy_md_component=>get_object_by_key
        EXPORTING
          name      = iv_name
          version   = lv_version
        RECEIVING
          component = ir_object.
    CATCH cx_wdy_md_permission_failure INTO lx_root.
      MESSAGE lx_root TYPE 'E'.
    CATCH cx_wdy_md_not_existing.
      IF lv_version = wdywb_version_active.
        lv_version     = wdywb_version_inactive.
      ELSE.
        lv_version     = wdywb_version_active.
      ENDIF.
      TRY.
          CALL METHOD cl_wdy_md_component=>get_object_by_key
            EXPORTING
              name      = iv_name
              version   = lv_version
            RECEIVING
              component = ir_object.
        CATCH cx_wdy_md_permission_failure INTO lx_root.
          MESSAGE lx_root TYPE 'E'.
        CATCH cx_wdy_md_not_existing INTO lx_root.
          MESSAGE lx_root TYPE 'E'.
      ENDTRY.
  ENDTRY.

endmethod.