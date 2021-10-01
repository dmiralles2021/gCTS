METHOD CHOOSE_BY_PREFERRED_LANGU.
* Pavel Jelínek, KCT Data, June 2014
*  This method  makes it more convenient to call GET_TAB_PREFERRED_LANGU
*  It chooses one line of LT_LANG_DEP
*   - preferably the one in language IV_PREFERRED_LANGU.
*   - secondly a line in ANY preferred language (see method get_tab_preferred_langu)
*   - thirdly any line (picks the first line)


* ================================================================
* = Handle trivial cases
* ================================================================
  ASSERT iv_langu_field IS NOT INITIAL. "Tells us which component contains the language
  CLEAR es_lang_dep.
  CHECK LINES( it_lang_dep ) > 0.
  IF LINES( it_lang_dep ) = 1.
    READ TABLE it_lang_dep INTO es_lang_dep INDEX 1.
    RETURN.
  ENDIF.

* ================================================================
* = Fill table "language -> position in table"
* ================================================================
  TYPES: BEGIN OF ts_lang_pos,
            langu TYPE sylangu,
            pos   TYPE syst-index,  "position in IT_LANG_DEP
         END OF ts_lang_pos.
  DATA lt_lang_pos TYPE SORTED TABLE OF ts_lang_pos WITH NON-UNIQUE KEY langu.
  DATA wa_lang_pos LIKE LINE OF lt_lang_pos .
  FIELD-SYMBOLS <line>  TYPE ANY.
  FIELD-SYMBOLS <langu> TYPE sylangu.
  LOOP AT it_lang_dep ASSIGNING <line>.
    wa_lang_pos-pos = sy-tabix.
    ASSIGN COMPONENT iv_langu_field OF STRUCTURE <line> TO <langu>.
    ASSERT sy-subrc = 0.
    wa_lang_pos-langu = <langu>.
    INSERT wa_lang_pos INTO TABLE lt_lang_pos.
  ENDLOOP.

* ================================================================
* = Check all preferred languages, starting with the MOST preferred one.
* ================================================================
  DATA lt_pref TYPE TABLE OF sylangu.
  DATA lv_pref TYPE sylangu.
  lt_pref = get_tab_preferred_langu( iv_preferred_langu ).
  LOOP AT lt_pref INTO lv_pref.
* Does IT_LANG_DEP contain an entry in THIS language?
    READ TABLE lt_lang_pos INTO wa_lang_pos WITH TABLE KEY langu = lv_pref.
    IF sy-subrc = 0.
      READ TABLE it_lang_dep INTO es_lang_dep INDEX wa_lang_pos-pos.
      ASSERT sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDLOOP.

* ================================================================
* = If there's no preferred language, take any record
* ================================================================
  READ TABLE it_lang_dep INTO es_lang_dep INDEX 1.
ENDMETHOD.