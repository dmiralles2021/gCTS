METHOD CHECK_EXISTS.

  DATA: lv_name  TYPE ddobjname,
        ls_dd25v TYPE dd25v.

  lv_name = gv_obj_name.

  rv_exists = abap_false.

  CALL FUNCTION 'DDIF_VIEW_GET'
    EXPORTING
      name          = lv_name
    IMPORTING
*     GOTSTATE      =
      dd25v_wa      = ls_dd25v
*     DD09L_WA      =
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc = 0 AND ls_dd25v-viewname IS NOT INITIAL.
    rv_exists = abap_true.
  ENDIF.

ENDMETHOD.