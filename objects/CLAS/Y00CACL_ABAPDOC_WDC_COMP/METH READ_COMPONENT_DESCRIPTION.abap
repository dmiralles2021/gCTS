method READ_COMPONENT_DESCRIPTION.

  DATA: lt_wdy_componentt TYPE TABLE OF wdy_componentt.

  FIELD-SYMBOLS: <wdy_componentt> LIKE LINE OF lt_wdy_componentt.


  SELECT *
    FROM wdy_componentt
    INTO TABLE lt_wdy_componentt
    WHERE component_name = iv_name AND
          langu = iv_langu.
  IF sy-subrc = 0.
    READ TABLE lt_wdy_componentt ASSIGNING <wdy_componentt> INDEX 1.
    IF sy-subrc = 0.
      ev_description = <wdy_componentt>-description.
    ENDIF.
  ENDIF.

endmethod.