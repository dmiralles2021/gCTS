METHOD GET_ROW_TYPE.
* The purpose of this method is explained in GET_ROW_TYPE__INTERNAL


* Call the internal method and discard the parameter ev_ntt_description
CALL METHOD y00cacl_abapdoc_main=>get_row_type__internal
  EXPORTING
    iv_obj_type        =  iv_obj_type
   IMPORTING
*    ev_ntt_description =
     ev_row_type        = rv_row_type
    .
ENDMETHOD.