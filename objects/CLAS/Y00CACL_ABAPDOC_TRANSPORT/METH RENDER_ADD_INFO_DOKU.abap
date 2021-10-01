METHOD RENDER_ADD_INFO_DOKU.


  DATA lv_x_sub1_printed TYPE xfeld. "Have we printed the sub1 style heading?
  DATA lv_req TYPE trkorr.

  LOOP AT it_requests INTO lv_req . "Output all requests/tasks in it_requests (in that order)

* Get the long text
    DATA lt_doku TYPE stringtab.
    render_add_info_doku__get( EXPORTING iv_trkorr = lv_req IMPORTING  et_doku   = lt_doku ).
    CHECK LINES( lt_doku ) > 0. "Don't output empty docu

* ========================================================
* == Do the output
    DATA lv_text TYPE string.

    IF lv_x_sub1_printed = space.
* Output this only before the first req in it_requests
      CLEAR lv_text .
      MESSAGE i041(y00camsg_abpdoc) INTO lv_text. "  'Long texts'
      io_render->add_object_subtitle( lv_text ).
      lv_x_sub1_printed = 'X'.
    ENDIF.

    render_add_info_doku__print(  io_render = io_render
                                  iv_trkorr = lv_req
                                  it_doku   = lt_doku ).
  ENDLOOP.

ENDMETHOD.