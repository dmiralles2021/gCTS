METHOD RENDER_ADD_INFO_DOKU__PRINT.


  DATA lv_text TYPE string.

* =========================================================
* = Find the readable form of tr.req. type

  DATA lv_req_type TYPE string. "e070-trfunction.
  DATA lv_req_type__readable TYPE string.
  SELECT SINGLE trfunction INTO lv_req_type  FROM e070 WHERE trkorr = iv_trkorr.
  IF sy-subrc = 0.
    lv_req_type__readable = get_domain_text( iv_domain_name = 'TRFUNCTION'
                                             iv_domain_value = lv_req_type ).

    if strlen( lv_req_type__readable ) > 4 and lv_req_type__readable(3) CP '[+]'.
* If it is something like "[K] Workbench Request", then remove "[K] "
      lv_req_type__readable = lv_req_type__readable+4.
    endif.
  ENDIF.

* ===========================================================
* = Output the sub2 heading
  CLEAR lv_text .
  MESSAGE i042(y00camsg_abpdoc) WITH lv_req_type__readable iv_trkorr INTO lv_text . "&1 &2
  io_render->add_object_subtitle2( lv_text ).

* ===========================================================
* = Output the doku
  io_render->add_text( it_doku  ).



ENDMETHOD.