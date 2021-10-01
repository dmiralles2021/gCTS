method APPEND_PARAGRAPH.
*----------------------------------------------------------------------*
* Method: APPEND_PARAGRAPH
*----------------------------------------------------------------------*
* Description:
* Append paragraph to document body
*----------------------------------------------------------------------*

  DATA:
    lo_paragraph TYPE REF TO lcl_par_st_element,
    lx_ex        TYPE REF TO cx_ood_exception.

  TRY.

*   Create paragraph
    CREATE OBJECT lo_paragraph
      EXPORTING
        iv_style        = iv_style
        iv_text         = iv_text
        iv_indent_left  = iv_indent_left.

*   Add paragraph to document
    me->document->body_element_add( lo_paragraph ).

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.
endmethod.