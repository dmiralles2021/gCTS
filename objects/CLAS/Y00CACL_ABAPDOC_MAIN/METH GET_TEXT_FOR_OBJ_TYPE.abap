  METHOD GET_TEXT_FOR_OBJ_TYPE.
* Returns the description for object type (for example FUGR)

    ASSERT iv_obj_type IS NOT INITIAL.
    DATA lv_row_type TYPE char1.
    CALL METHOD y00cacl_abapdoc_main=>get_row_type__internal
      EXPORTING
        iv_obj_type        = iv_obj_type
      IMPORTING
        ev_ntt_description = ev_obj_type_text
        ev_row_type        = lv_row_type.

    IF lv_row_type = co_row_type__non_tadir.
      RETURN. "We already know the description
    ELSE.
      DATA:lt_typesin  TYPE TABLE OF ko105,
           ls_typesin  LIKE LINE OF lt_typesin,

           lt_typesout TYPE TABLE OF ko100,
           ls_typesout LIKE LINE OF lt_typesout.

      REFRESH: lt_typesin, lt_typesout.
      CLEAR ls_typesin.
      ls_typesin-object = iv_obj_type.
      APPEND ls_typesin TO lt_typesin.

      CALL FUNCTION 'TRINT_OBJECT_TABLE' "Returns description for a given obj type
        TABLES
          tt_types_in  = lt_typesin
          tt_types_out = lt_typesout.
      ASSERT LINES( lt_typesout ) = 1.
      READ TABLE lt_typesout INDEX 1 INTO ls_typesout.
      ASSERT sy-subrc IS INITIAL.

      ASSERT ls_typesout-object = iv_obj_type  .
      ev_obj_type_text = ls_typesout-text.
    ENDIF.

  ENDMETHOD.