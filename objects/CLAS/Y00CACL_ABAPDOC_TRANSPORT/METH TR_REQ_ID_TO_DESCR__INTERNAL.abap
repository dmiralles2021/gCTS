METHOD TR_REQ_ID_TO_DESCR__INTERNAL.
* Output:
* - ET_E07T - all available languages
* - ES_E07T_CHOSEN - in iv_preferred_langu (but if does not exist, then picks any language)

  CLEAR: et_e07t[], es_e07t_chosen.
  SELECT * FROM e07t INTO TABLE et_e07t
     WHERE trkorr = iv_req_id.

  CHECK LINES( et_e07t ) > 0.

* lt_preferred_langu - the languages that we prefer (index 1 is the most preferred)
  DATA lt_preferred_langu TYPE TABLE OF sylangu.
  lt_preferred_langu = GET_TAB_PREFERRED_LANGU( ).

  DATA lv_pref LIKE LINE OF lt_preferred_langu .
  LOOP AT lt_preferred_langu INTO lv_pref.
    READ TABLE et_e07t INTO es_e07t_chosen WITH KEY langu = lv_pref.
    IF sy-subrc = 0.
      RETURN. "We have what we want.
    ENDIF.
  ENDLOOP.

* Now we take any language
  READ TABLE et_e07t INTO es_e07t_chosen INDEX 1.
ENDMETHOD.