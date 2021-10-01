method CONSTRUCTOR.
*----------------------------------------------------------------------*
* Method: CONSTRUCTOR
*----------------------------------------------------------------------*
* Description:
* Instance constructor.
*----------------------------------------------------------------------*

* Create fonts file
  CREATE OBJECT me->fonts.

* Create styles file
  CREATE OBJECT me->styles
    EXPORTING
      iv_default_font = iv_default_font
      iv_default_size = iv_default_size.

* Create document file
  CREATE OBJECT me->document.

*>>-> PaM 30.10.2013 16:39:59
* Create header
  CREATE OBJECT me->header.

* Create footer
  CREATE OBJECT me->footer.
*<-<< PaM 30.10.2013 16:39:59
endmethod.