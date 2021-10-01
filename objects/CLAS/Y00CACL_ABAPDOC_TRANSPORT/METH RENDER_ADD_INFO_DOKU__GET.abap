METHOD RENDER_ADD_INFO_DOKU__GET.


  REFRESH et_doku.

  CONSTANTS co_dokil_id  TYPE dokil-id  VALUE 'TA'. " Means: Transport request
  CONSTANTS co_dokil_typ TYPE dokil-typ VALUE 'T' . " Experimentally found that there is 'T' there

* ========================================================
* = Find which languages the docu exists in

  FIELD-SYMBOLS <dokil> TYPE dokil.
  data lv_object TYPE dokil-object.
  lv_object  = iv_trkorr. "Typecast
  DATA lt_dokil_srt TYPE SORTED TABLE OF dokil WITH NON-UNIQUE KEY langu typ.
  SELECT * FROM dokil INTO TABLE lt_dokil_srt
    WHERE id      = co_dokil_id
      AND object  = lv_object.
  CHECK LINES( lt_dokil_srt ) > 0. "if no docu exists, don't output anything.


* ========================================================
* = Choose one of the languages

  DATA lt_langu_pref TYPE TABLE OF sylangu. "Which languages to prefer (sorted descending by our preference)
  lt_langu_pref = get_tab_preferred_langu( ).
  DATA lv_langu_pref TYPE sylangu.
  LOOP AT lt_langu_pref INTO lv_langu_pref.
    READ TABLE lt_dokil_srt ASSIGNING <dokil>
      WITH TABLE KEY langu = lv_langu_pref
                     typ   = co_dokil_typ.
    IF sy-subrc = 0.
* We will use THIS langu.
      EXIT. "No need to search any more
    ENDIF.
  ENDLOOP.
  IF <dokil> IS NOT ASSIGNED.
    READ TABLE lt_dokil_srt INDEX 1 ASSIGNING <dokil>.
  ENDIF.
  ASSERT <dokil> IS ASSIGNED. "See "check" above.

* ========================================================
* == Get lines of documentation

  DATA lt_tline TYPE TABLE OF tline.
  REFRESH lt_tline.
  CALL FUNCTION 'DOCU_GET'
    EXPORTING
*         EXTEND_EXCEPT                = ' '
      id                           = <dokil>-id
      langu                        = <dokil>-langu
      object                       = <dokil>-object
      typ                          = <dokil>-typ
*         VERSION                      = 0
      version_active_or_last       = 'A' "Active version
*         PRINT_PARAM_GET              = 'X'
*       IMPORTING
*         DOKSTATE                     =
*         DOKTITLE                     =
*         HEAD                         =
*         DOKTYP                       =
    TABLES
      line                         = lt_tline
    EXCEPTIONS
      no_docu_on_screen            = 1
      no_docu_self_def             = 2
      no_docu_temp                 = 3
      ret_code                     = 4
      OTHERS                       = 5
            .
  IF sy-subrc <> 0.
*???
  ENDIF.

* ========================================================
* == Convert to string tab

  CHECK LINES( lt_tline ) > 0.
  FIELD-SYMBOLS <tline> LIKE LINE OF lt_tline.
  DATA lv_x_nonempty TYPE xfeld.
  CLEAR lv_x_nonempty.
  DATA lt_stringtyb TYPE stringtab.
  LOOP AT lt_tline ASSIGNING <tline>.
    APPEND <tline>-tdline TO et_doku.
    IF <tline>-tdline NE space.
      lv_x_nonempty = 'X'.
    ENDIF.
  ENDLOOP.
  if lv_x_nonempty = space.
    REFRESH et_doku.  " Don't output an empty doku
  endif.

ENDMETHOD.