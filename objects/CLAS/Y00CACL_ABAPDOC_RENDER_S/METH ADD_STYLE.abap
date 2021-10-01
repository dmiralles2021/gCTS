method ADD_STYLE.
*----------------------------------------------------------------------*
* Method: ADD_STYLE
*----------------------------------------------------------------------*
* Description:
* Add new style to document.
*----------------------------------------------------------------------*

  DATA:
    ls_style TYPE lts_docx_style,
    lx_ex    TYPE REF TO cx_ood_exception.

* Transfer style data
  ls_style-id                         = iv_id.
  ls_style-type                       = iv_type.
  ls_style-name                       = iv_name.
  ls_style-based                      = iv_based_on.
  ls_style-next                       = iv_next.
  ls_style-qformat                    = iv_primary.
  ls_style-rpr-bold                   = iv_bold.
  ls_style-rpr-italic                 = iv_italic.
  ls_style-rpr-underlined             = iv_underlined.
  ls_style-rpr-color                  = iv_color.
  ls_style-rpr-font                   = iv_font.
  ls_style-rpr-size                   = iv_size.
  ls_style-ppr-keep_next              = iv_keep_next.
  ls_style-ppr-keep_lines             = iv_keep_lines.
  ls_style-ppr-numbering_id           = iv_numbering_id.
  ls_style-ppr-numbering_level        = iv_numbering_level.
  ls_style-ppr-outline_level          = iv_outline_level.
  ls_style-ppr-spacing_before         = iv_spacing_before.
  ls_style-ppr-spacing_after          = iv_spacing_after.
  ls_style-tblpr-indent               = iv_table_indent.
  IF iv_table_indent IS SUPPLIED.
    ls_style-tblpr-indent_tp            = iv_table_indent_unit.
  ENDIF.
  ls_style-tblpr-border_size          = iv_table_border_size.
  ls_style-tblpr-margin_l             = iv_table_margin_left.
  ls_style-tblpr-margin_r             = iv_table_margin_right.
  ls_style-tblpr-margin_t             = iv_table_margin_top.
  ls_style-tblpr-margin_b             = iv_table_margin_bottom.
  IF NOT ls_style-tblpr-margin_l IS INITIAL OR NOT ls_style-tblpr-margin_r IS INITIAL OR
     NOT ls_style-tblpr-margin_t IS INITIAL OR NOT ls_style-tblpr-margin_b IS INITIAL.
    ls_style-tblpr-margin_tp            = iv_table_margin_unit.
  ENDIF.

  TRY.

*   Add style to file
    me->styles->style_add( ls_style ).

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.
endmethod.