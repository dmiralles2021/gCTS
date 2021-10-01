  method Y00CAIF_ABAPDOC_RENDER~ADD_DOCUMENTATION.
  DATA: current_text TYPE string,
        appending_text TYPE string,
        lines LIKE sy-tabix,
        tabix LIKE sy-tabix,
        lf_bold TYPE flag,
        lx_ex  TYPE REF TO y00cacx_docx_render_s.

  FIELD-SYMBOLS: <ls_text> LIKE LINE OF it_text.

*  DATA:
*    lt_result TYPE match_result_tab,
*    lv_str TYPE string,
*    lv_lines TYPE i,
*    lv_strlen TYPE i,
*    lv_first_occurrence TYPE i,
*    lv_last_occurrence TYPE i,
*    lv_offset TYPE i,
*    lx_ex  TYPE REF TO y00cacx_docx_render_s.
*  FIELD-SYMBOLS: <ls_text> LIKE LINE OF it_text,
*                 <ls_result> LIKE LINE OF lt_result.

*  TRY.
****      lv_str = 'Documentation'(001).
****      me->docx->append_paragraph(
****        iv_style = style_description
****        iv_text  = lv_str
****      ).
***      LOOP AT it_text ASSIGNING <ls_text>.
***        TRY.
***            lv_str = <ls_text>+2.
***          CATCH cX_SY_RANGE_OUT_OF_BOUNDS. "shorted string
***            me->docx->append_paragraph(
****              iv_style = style_description
***              iv_text  = lv_str
***            ).
***        ENDTRY.
***        FIND ALL OCCURRENCES OF '&' IN lv_str RESULTS lt_result. "reduce Tag column
***        DESCRIBE TABLE lt_result LINES lv_lines.
***        IF lv_lines = 2.
***          lv_strlen = STRLEN( lv_str ).
***          READ TABLE lt_result INDEX 1 ASSIGNING <ls_result>.
***          lv_first_occurrence = <ls_result>-offset.
***          READ TABLE lt_result INDEX 2 ASSIGNING <ls_result>.
***          lv_last_occurrence = <ls_result>-offset.
***        ENDIF.
***
***        lv_offset = lv_strlen - 1.
***        IF lv_lines = 2 AND lv_first_occurrence = 0 AND lv_last_occurrence = lv_offset. "e.g. &FUNCTIONALITY&
***          REPLACE ALL OCCURRENCES OF '&' IN lv_str WITH ''.
***          me->docx->append_paragraph(
****            iv_style = style_description
***            iv_text  = lv_str
***          ).
***
***        ELSE.
***
***          me->docx->append_paragraph(
****            iv_style = style_comment
***            iv_text  = lv_str
***            ).
***
***
***        ENDIF.

  TRY.

      DESCRIBE TABLE it_text LINES lines.
      LOOP AT it_text ASSIGNING <ls_text>.
        tabix = sy-tabix.

* Shorter line
        TRY.
            current_text = <ls_text>+2.
          CATCH cx_sy_range_out_of_bounds. "shorted string
            me->docx->append_paragraph(
              iv_text  = current_text
            ).
        ENDTRY.

* Found new paragraph
        DATA: paragraph_key TYPE c LENGTH 2.
*        paragraph_key = <ls_text>(2).
        clear paragraph_key.
        if <ls_text> ne space. " 'IF' added by Jelínek, 2014/05, because <ls_text> can be space (when ZKCT_ABAP_DOC is run for package ZCEVR_SIEMENS in German language)
          paragraph_key = <ls_text>(1).
        endif.
        IF paragraph_key IS NOT INITIAL. " */P1/P2 and first line
          IF lf_bold = abap_true.
            me->docx->append_paragraph(
              iv_style = style_normal_bold
              iv_text  = appending_text
            ).
          ELSE.
            me->docx->append_paragraph(
             iv_text  = appending_text
             ).
          ENDIF.
          appending_text = current_text.
*          IF paragraph_key = '* ' .
          IF paragraph_key = '*' OR
             ( NOT paragraph_key = 'U' AND NOT paragraph_key = 'K')  .
            lf_bold = abap_false.
          ELSE.
            lf_bold = abap_true.
          ENDIF.

* Same paragraph
        ELSE.
          CONCATENATE appending_text current_text INTO appending_text.

        ENDIF.

* Last line
        IF lines = tabix.
          IF lf_bold = abap_true.
            me->docx->append_paragraph(
              iv_style = style_normal_bold
              iv_text  = appending_text
            ).
          ELSE.
            me->docx->append_paragraph(
             iv_text  = appending_text
             ).
          ENDIF.
        ENDIF.


      ENDLOOP. "LOOP AT it_text ASSIGNING <ls_text>.

    CATCH y00cacx_docx_render_s INTO lx_ex.
      RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
        EXPORTING messages = lx_ex->messages.
  ENDTRY.
  endmethod.