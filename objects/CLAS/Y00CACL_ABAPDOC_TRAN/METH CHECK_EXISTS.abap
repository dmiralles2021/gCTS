METHOD CHECK_EXISTS.


  SELECT COUNT(*) FROM tstc INTO @DATA(ls_tstc) WHERE tcode = @gv_obj_name.

  IF sy-subrc = 0.
    rv_exists = 'X'.
  ENDIF.

ENDMETHOD.