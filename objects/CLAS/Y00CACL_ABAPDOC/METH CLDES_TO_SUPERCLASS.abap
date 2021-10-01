METHOD CLDES_TO_SUPERCLASS.
* Jelínek, KCT Data, 21.4.2014
* Returns the superclass; does NOT throws exceptin on failure

  CHECK iv_cldes IS NOT INITIAL.
  CALL METHOD iv_cldes->get_super_class_type
    RECEIVING
      p_descr_ref           = rv_cldes_superclass
    EXCEPTIONS
      super_class_not_found = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    CLEAR rv_cldes_superclass.
  ENDIF.
ENDMETHOD.