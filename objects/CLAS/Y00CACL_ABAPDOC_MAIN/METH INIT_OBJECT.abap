METHOD INIT_OBJECT.

  DATA: lo_classobject TYPE REF TO y00cacl_abapdoc,
        lv_obj_name    TYPE string.

  FIELD-SYMBOLS: <fs_plugin>      LIKE LINE OF gt_plugin,
                 <fs_object_alv>  LIKE LINE OF gt_object_alv.

  CLEAR:  gt_object_alv.

  rf_result = abap_true.

  IF iv_obj_type IS NOT INITIAL AND iv_object IS NOT INITIAL.
    SELECT object AS obj_type obj_name srcsystem
      FROM tadir
      INTO CORRESPONDING FIELDS OF TABLE gt_object_alv
      WHERE object = iv_obj_type AND obj_name = iv_object AND pgmid = 'R3TR' AND delflag <> 'X'.
    IF sy-subrc <> 0.
      rf_result = abap_false.
    ENDIF.
  ELSEIF iv_package IS NOT INITIAL.
    SELECT object AS obj_type obj_name srcsystem
      FROM tadir
      INTO CORRESPONDING FIELDS OF TABLE gt_object_alv
      WHERE devclass = iv_package AND pgmid = 'R3TR' AND delflag <> 'X'.
    IF sy-subrc <> 0.
      rf_result = abap_false.
    ENDIF.
  ELSEIF iv_transport IS NOT INITIAL.
    DATA: lv_reqname    TYPE string,
          lv_trkorr     TYPE e07t-trkorr,
          lv_as4text    TYPE e07t-as4text,

          lt_trkorr     TYPE TABLE OF e070-trkorr,

          lt_req_tran   TYPE RANGE OF e070-trkorr,
          ls_req_tran   LIKE LINE OF lt_req_tran.

    ls_req_tran-sign = 'I'.
    ls_req_tran-option = 'EQ'.
    ls_req_tran-low = iv_transport.
    APPEND ls_req_tran TO lt_req_tran.
    SELECT SINGLE trkorr FROM e070 INTO lv_trkorr WHERE trkorr IN lt_req_tran.
    IF sy-subrc = 0.
* Subordinate transports
      SELECT trkorr FROM e070 INTO TABLE lt_trkorr WHERE strkorr IN lt_req_tran.

      LOOP AT lt_trkorr INTO lv_trkorr.
        ls_req_tran-sign = 'I'.
        ls_req_tran-option = 'EQ'.
        ls_req_tran-low = lv_trkorr.
        APPEND ls_req_tran TO lt_req_tran.
      ENDLOOP.
*     <--ewH

      SELECT object AS obj_type obj_name FROM e071 INTO CORRESPONDING FIELDS OF TABLE gt_object_alv
        WHERE trkorr IN lt_req_tran AND pgmid = 'R3TR'. "ewH: don't need subobjects
      IF sy-subrc <> 0.
        rf_result = abap_false.
      ENDIF.
    ELSE.
      rf_result = abap_false.
    ENDIF.

* Add also a line containing description of tr. request
    DATA ls_alv LIKE LINE OF gt_object_alv .
    CLEAR ls_alv .
    ls_alv-obj_type = co_ntt_transport_req.
    ls_alv-obj_name = iv_transport.
    MESSAGE  i016(y00camsg_abpdoc) INTO ls_alv-obj_type_txt.
    APPEND ls_alv TO gt_object_alv .
  ENDIF.

  IF LINES( gt_object_alv ) > 0.

    LOOP AT gt_object_alv ASSIGNING <fs_object_alv>.
* Check up whether particular plugin exists for object type
      READ TABLE gt_plugin ASSIGNING <fs_plugin> WITH KEY obj_type = <fs_object_alv>-obj_type.
      IF sy-subrc = 0.
* Plug-in exists
* support document type
        lv_obj_name = <fs_object_alv>-obj_name.
        CREATE OBJECT lo_classobject
          TYPE
            (<fs_plugin>-class_name)
          EXPORTING
            name                     = lv_obj_name.
        IF lo_classobject->is_support_output_type( iv_output_type = iv_output_type ) = abap_true.
          <fs_object_alv>-down_flag = abap_true.
          <fs_object_alv>-select = abap_true.
          <fs_object_alv>-status = icon_light_out.
        ELSE.
          MESSAGE i016(y00camsg_abpdoc) WITH <fs_object_alv>-obj_type INTO <fs_object_alv>-msg.
          <fs_object_alv>-down_flag = abap_false.
          <fs_object_alv>-select = abap_false.
          <fs_object_alv>-status = icon_red_light.
        ENDIF.
      ELSE.
        MESSAGE i009(y00camsg_abpdoc) WITH <fs_object_alv>-obj_type INTO <fs_object_alv>-msg.
        <fs_object_alv>-down_flag = abap_false.
        <fs_object_alv>-select = abap_false.
        <fs_object_alv>-status = icon_red_light.
      ENDIF.

*     get text
      get_text_for_obj_type( EXPORTING iv_obj_type = <fs_object_alv>-obj_type
                             IMPORTING ev_obj_type_text = <fs_object_alv>-obj_type_txt ).

    ENDLOOP.

    SORT gt_object_alv BY down_flag DESCENDING order DESCENDING obj_type ASCENDING obj_name ASCENDING.
  ENDIF.

ENDMETHOD.