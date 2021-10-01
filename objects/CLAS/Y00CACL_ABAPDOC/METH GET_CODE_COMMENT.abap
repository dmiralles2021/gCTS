method GET_CODE_COMMENT.

  DATA: lt_src_table TYPE STANDARD TABLE OF string,
        lv_name TYPE trdir-name,
        lv_text TYPE string,
        lv_from TYPE i,
        lv_to TYPE i.
  FIELD-SYMBOLS: <ls_src_table> LIKE LINE OF lt_src_table.

* Initialization
** Source
  lv_name = iv_obj_name.
  READ REPORT lv_name INTO lt_src_table.
** From
  IF iv_from_line IS NOT INITIAL.
    lv_from = iv_from_line.
  ELSE.
    lv_from = 1.
  ENDIF.
** To
  IF iv_up_to_line IS NOT INITIAL.
    lv_to = iv_up_to_line.
  ELSE.
    DESCRIBE TABLE lt_src_table LINES lv_to.
  ENDIF.

* Processing
  LOOP AT lt_src_table ASSIGNING <ls_src_table> FROM lv_from TO lv_to.
    IF <ls_src_table> IN it_key_words
       AND NOT it_key_words IS INITIAL .
      lv_text = <ls_src_table>.
      APPEND lv_text TO rt_text.
*    ELSEIF <ls_src_table> CP '#*&*'.
**     just for compatibility reason
*      lv_text = <ls_src_table>.
*      APPEND lv_text TO rt_text.
    ENDIF.
  ENDLOOP.

endmethod.