method ADD_FONT.
*----------------------------------------------------------------------*
* Method: ADD_FONT
*----------------------------------------------------------------------*
* Description:
* Add font to document.
*----------------------------------------------------------------------*

  DATA:
    ls_font TYPE lts_docx_font,
    lx_ex   TYPE REF TO cx_ood_exception.

* Transfer font data
  ls_font-name      = iv_name.
  ls_font-panose1   = iv_panose1.
  ls_font-charset   = iv_charset.
  ls_font-family    = iv_family.
  ls_font-pitch     = iv_pitch.
  ls_font-csb0      = iv_csb0.
  ls_font-csb1      = iv_csb1.
  ls_font-usb0      = iv_usb0.
  ls_font-usb1      = iv_usb1.
  ls_font-usb2      = iv_usb2.
  ls_font-usb3      = iv_usb3.

  TRY.

*   Check predefined or custom
    IF ls_font-panose1 IS INITIAL.

*     Add predefined font
      me->fonts->default_font_add( ls_font-name ).
    ELSE.

*     Add custom font
      me->fonts->font_add( ls_font ).
    ENDIF.

  CATCH cx_ood_exception INTO lx_ex.

    me->raise_exception( lx_ex ).
  ENDTRY.
endmethod.