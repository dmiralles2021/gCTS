method CHECK_EXISTS.

  DATA: l_name   TYPE tnro-object.

  l_name = gv_obj_name.

  CALL FUNCTION 'NUMBER_RANGE_OBJECT_INIT'
    EXPORTING
      object                 = l_name
*     LANGUAGE               = SY-LANGU
   EXCEPTIONS
     object_not_found       = 1
     OTHERS                 = 2
            .
  IF sy-subrc <> 0.
    rv_exists = abap_false.
  ELSE.
    rv_exists = abap_true.
  ENDIF.


endmethod.