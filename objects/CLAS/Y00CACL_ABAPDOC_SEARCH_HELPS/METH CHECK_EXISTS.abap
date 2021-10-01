method CHECK_EXISTS.

  DATA: l_name   TYPE dd30l-shlpname.

  l_name = gv_obj_name.

  CALL FUNCTION 'DD_SHLP_GET'
    EXPORTING
*     GET_STATE           = 'M    '
*     LANGU               = SY-LANGU
*     PRID                = 0
      shlp_name           = l_name
      withtext            = ' '
      add_typeinfo        = ' '
*     TRACELEVEL          = 0
*   IMPORTING
*     DD30V_WA_A          =
*     DD30V_WA_N          =
*     GOT_STATE           =
*   TABLES
*     DD31V_TAB_A         =
*     DD31V_TAB_N         =
*     DD32P_TAB_A         =
*     DD32P_TAB_N         =
*     DD33V_TAB_A         =
*     DD33V_TAB_N         =
    EXCEPTIONS
      illegal_value       = 1
      op_failure          = 2
      OTHERS              = 3
            .
  IF sy-subrc <> 0.
    rv_exists = abap_false.
  ELSE.
    rv_exists = abap_true.
  ENDIF.


endmethod.