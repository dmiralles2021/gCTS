method CHECK_EXISTS.

  DATA: classkey   TYPE SEOCLSKEY,
        not_active TYPE SEOX_BOOLEAN.

  classKey-clsName = gv_obj_name.
  rv_exists = abap_false.

  CALL FUNCTION 'SEO_CLASS_EXISTENCE_CHECK'
    EXPORTING
      clskey       = classkey
    IMPORTING
      not_active   = not_active
    EXCEPTIONS
      not_existing = 2.

  if sy-subrc <> 2.
    rv_exists = 'X'.
  endif.

endmethod.