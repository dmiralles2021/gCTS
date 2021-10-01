METHOD GET_ROW_TYPE__INTERNAL.
* Field y00cacl_abapdoc_MAIN->GT_OBJECT_ALV-OBJ_TYPE can contain two kinds of values
*   a) IF this line of GT_OBJECT_ALV contains a development object from TADIR table,
*        then GT_OBJECT_ALV-OBJ_TYPE = TADIR-OBJECT.
*   b) IF this line of GT_OBJECT_ALV contains something else (this happens from June 2014)
*        then GT_OBJECT_ALV-OBJ_TYPE = for example y00cacl_abapdoc_MAIN=>CO_NTT_TRANSPORT_REQ

* !!! This method should be called as a "blackbox"; its implementation can change any time.

  ASSERT iv_obj_type NE space.
  CLEAR ev_ntt_description.

  IF iv_obj_type(2) NE '++'. "We chose to start NON_TADIR types with '++' but this may change in the future.
    ev_row_type = co_row_type__tadir.
    RETURN.
  ENDIF.

* Now we know it is NON_TADIR
  ev_row_type = co_row_type__non_tadir.
  CASE  iv_obj_type .
    WHEN y00cacl_abapdoc_main=>co_ntt_transport_req.
      MESSAGE i116(y00camsg_abpdoc) WITH space INTO ev_ntt_description. "Transport request &1
    WHEN OTHERS.
      MESSAGE 'Unknown NON_TADIR object type' TYPE 'X'.
  ENDCASE.
ENDMETHOD.