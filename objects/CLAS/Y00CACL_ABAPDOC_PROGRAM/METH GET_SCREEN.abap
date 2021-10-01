method GET_SCREEN.

  DATA: lt_dynpro_list TYPE TABLE OF d020s,
        lt_fieldlist TYPE TABLE OF d021s,
        lt_text_pool TYPE SORTED TABLE OF textpool WITH UNIQUE KEY id key,
        ls_header TYPE d020s,
        lv_dynprotext TYPE d020t-dtxt,
        lt_params TYPE TABLE OF d023s, "not used
        lt_fieldtexts TYPE TABLE OF d021t,
        lv_field_type TYPE feld-gtyp.

  FIELD-SYMBOLS: <ls_screen> LIKE LINE OF rt_screen,
                 <ls_dynpro_list> LIKE LINE OF lt_dynpro_list,
                 <ls_fieldlist> LIKE LINE OF lt_fieldlist,
                 <ls_text_pool> LIKE LINE OF lt_text_pool,
                 <ls_fieldtexts> LIKE LINE OF lt_fieldtexts.

* Get dynpro list
  SELECT prog dnum type INTO TABLE lt_dynpro_list
    FROM d020s
    WHERE prog = iv_program.
*                AND type <> 'S'    " No Selection Screens
*                AND type <> 'J'.   " No selection subscreens
  CHECK sy-subrc  = 0 .

  LOOP AT lt_dynpro_list ASSIGNING <ls_dynpro_list>.

    CALL FUNCTION 'RPY_DYNPRO_READ_NATIVE'
      EXPORTING
        progname         = iv_program
        dynnr            = <ls_dynpro_list>-dnum
      IMPORTING
        header           = ls_header
        dynprotext       = lv_dynprotext
      TABLES
        fieldlist        = lt_fieldlist
        params           = lt_params
        fieldtexts       = lt_fieldtexts
      EXCEPTIONS
        cancelled        = 1
        not_found        = 2
        permission_error = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Import texts
    READ TEXTPOOL iv_program INTO lt_text_pool LANGUAGE sy-langu.

* Screen description
    APPEND INITIAL LINE TO rt_screen ASSIGNING <ls_screen>.
    <ls_screen>-program_id = <ls_dynpro_list>-prog.
    <ls_screen>-screen_id = <ls_dynpro_list>-dnum.
*    <ls_screen>-element_id = .
    <ls_screen>-type = lco_screen_description.
    <ls_screen>-element_text = lv_dynprotext.

* Elements as field, selection option fields
    LOOP AT lt_fieldlist ASSIGNING <ls_fieldlist>.

** Selection screen
      IF ls_header-type = 'S'.

        CASE <ls_fieldlist>-grp3.

          WHEN 'PAR'.

            APPEND INITIAL LINE TO rt_screen ASSIGNING <ls_screen>.
            <ls_screen>-program_id = <ls_dynpro_list>-prog.
            <ls_screen>-screen_id = <ls_dynpro_list>-dnum.
            <ls_screen>-element_id = <ls_fieldlist>-fnam.
            <ls_screen>-type = lco_parameter.
            READ TABLE lt_text_pool ASSIGNING <ls_text_pool> WITH TABLE KEY id = 'S' key = <ls_screen>-element_id.
            IF sy-subrc IS INITIAL.
              <ls_screen>-element_text = <ls_text_pool>-entry.
              SHIFT <ls_screen>-element_text LEFT DELETING LEADING space.
            ENDIF.
            UNASSIGN <ls_text_pool>.

          WHEN 'LOW' OR 'HGH'.

            APPEND INITIAL LINE TO rt_screen ASSIGNING <ls_screen>.
            <ls_screen>-program_id = <ls_dynpro_list>-prog.
            <ls_screen>-screen_id = <ls_dynpro_list>-dnum.
            <ls_screen>-element_id = <ls_fieldlist>-fnam.
            REPLACE ALL OCCURRENCES OF '-LOW' IN <ls_screen>-element_id WITH ''.
            REPLACE ALL OCCURRENCES OF '-HIGH' IN <ls_screen>-element_id WITH ''.
            <ls_screen>-type = lco_selection_option.

            READ TABLE lt_text_pool ASSIGNING <ls_text_pool> WITH TABLE KEY id = 'S' key = <ls_screen>-element_id.
            IF sy-subrc IS INITIAL.
              <ls_screen>-element_text = <ls_text_pool>-entry.
              SHIFT <ls_screen>-element_text LEFT DELETING LEADING space.
            ENDIF.
            UNASSIGN <ls_text_pool>.

          WHEN 'BLK'.

            APPEND INITIAL LINE TO rt_screen ASSIGNING <ls_screen>.
            <ls_screen>-program_id = <ls_dynpro_list>-prog.
            <ls_screen>-screen_id = <ls_dynpro_list>-dnum.
            <ls_screen>-element_id = <ls_fieldlist>-fnam+2(3).
            <ls_screen>-type = lco_block.
            READ TABLE lt_text_pool ASSIGNING <ls_text_pool> WITH TABLE KEY id = 'I' key = <ls_screen>-element_id.
            IF sy-subrc IS INITIAL.
              <ls_screen>-element_text = <ls_text_pool>-entry.
            ENDIF.
            UNASSIGN <ls_text_pool>.

        ENDCASE.

** Program screen
      ELSE. "IF ls_header-type = 'S'.

        APPEND INITIAL LINE TO rt_screen ASSIGNING <ls_screen>.
        <ls_screen>-program_id = <ls_dynpro_list>-prog.
        <ls_screen>-screen_id = <ls_dynpro_list>-dnum.
        <ls_screen>-element_id = <ls_fieldlist>-fnam.
        <ls_screen>-type = <ls_fieldlist>-flg1.
        READ TABLE lt_fieldtexts ASSIGNING <ls_fieldtexts> WITH KEY fldn = <ls_screen>-element_id.
        IF sy-subrc IS INITIAL.
          <ls_screen>-element_text = <ls_fieldtexts>-dtxt.
        ELSE.
          <ls_screen>-element_text = <ls_fieldlist>-stxt.
        ENDIF.

      ENDIF.  "IF ls_header-type = 'S'.

    ENDLOOP. "LOOP AT lt_fieldlist ASSIGNING <ls_fieldlist>.

  ENDLOOP. "LOOP AT lt_dynpro_list ASSIGNING <ls_dynpro_list>.

  DELETE ADJACENT DUPLICATES FROM rt_screen COMPARING program_id screen_id element_id. "reduce SO LOW and HIGH

endmethod.