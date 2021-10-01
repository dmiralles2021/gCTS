  METHOD filename_split.
    DATA: lf_fullname TYPE text255,
          lf_filename TYPE text255,
          lf_dirlen   TYPE i.

    lf_fullname = pf_docid.
    CLEAR: pf_directory, pf_filename, pf_extension.

* Dateiname suchen
    WHILE lf_fullname CA ':\/'.
      ADD 1 TO sy-fdpos.
      ADD sy-fdpos TO lf_dirlen.
      SHIFT lf_fullname LEFT BY sy-fdpos PLACES.
    ENDWHILE.
    lf_filename = pf_filename = lf_fullname.

* Directory bestimmen
    IF lf_dirlen > 0.
      pf_directory = pf_docid(lf_dirlen).
    ENDIF.

* Extension bestimmen
    WHILE lf_filename CS'.'.
      ADD 1 TO sy-fdpos.
      SHIFT lf_filename LEFT BY sy-fdpos PLACES.
    ENDWHILE.
    IF sy-subrc = 0.
      pf_extension = lf_filename.
    ENDIF.

  ENDMETHOD.