METHOD TR_REQ_ID_TO_DESCRIPTION.

  CLEAR rv_description.

  DATA ls_chosen TYPE e07t.
  tr_req_id_to_descr__internal(
    EXPORTING
      iv_req_id          = iv_req_id
      iv_preferred_langu = iv_preferred_langu
     IMPORTING
*       et_e07t            =
      es_e07t_chosen     = ls_chosen ).
  rv_description = ls_chosen-as4text.
ENDMETHOD.