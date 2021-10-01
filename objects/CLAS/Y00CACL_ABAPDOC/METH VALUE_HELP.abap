method VALUE_HELP.

  DATA: lv_obj_type  TYPE euobj-id,
        lv_obj_name(40)  TYPE c.

  lv_obj_type = iv_obj_type.

  CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
    EXPORTING
      object_type           = lv_obj_type
      object_name           = lv_obj_name
      suppress_selection    = 'X'
      use_alv_grid          = ''
      without_personal_list = ''
    IMPORTING
      object_name_selected  = lv_obj_name
    EXCEPTIONS
      cancel                = 1.

  rv_obj_name = lv_obj_name.

endmethod.