method GENERATE_TECH_DOC.

    data: lo_classobject type ref to y00cacl_abapdoc.
    data: lv_count       type i,
          lv_perc        type i,
          lv_text_error  type string,
          lv_obj_name    type string,
          lf_result      type flag.

    field-symbols: <fs_object_alv> like line of gt_object_alv,
                   <fs_plugin>     like line of gt_plugin.

    clear: ev_text_error, lv_count.

    ef_result = abap_true.

    SORT gt_plugin BY order ASCENDING obj_type ASCENDING.
    sort gt_object_alv by down_flag descending order descending obj_type ascending obj_name ascending.

* Resets number of generated object to zero and sets up number of new
    loop at gt_plugin assigning <fs_plugin>.
      <fs_plugin>-count = 0.
      loop at gt_object_alv assigning <fs_object_alv> where down_flag = 'X' and select = 'X' and obj_type = <fs_plugin>-obj_type.
        <fs_plugin>-count = <fs_plugin>-count + 1.
        lv_count = lv_count + 1.
      endloop.
    endloop.

    if lv_count > 0.

*     Check renderer. If provided, use renderer object otherwise continue
*     rendering using OLE method.
      IF io_render IS BOUND.
        me->render_tech_doc(
          EXPORTING
            io_render       = io_render
          IMPORTING
            ef_result       = ef_result
            ev_text_error   = ev_text_error
        ).
        RETURN.
      ENDIF.

      IF io_xml_document IS BOUND.
        me->xml_tech_doc(
          EXPORTING
            io_xml_document = io_xml_document
          IMPORTING
            ef_result       = ef_result
            ev_text_error   = ev_text_error
        ).
        RETURN.
      ENDIF.


      me->ole_word_initialize( importing ef_result     = ef_result
                                         ev_text_error = ev_text_error ).

      loop at gt_plugin assigning <fs_plugin> where count > 0.
        if ef_result = abap_true.
          me->ole_word_add_text_obj_type( exporting is_plugin     = <fs_plugin>
                                          importing ef_result     = lf_result
                                                    ev_text_error = lv_text_error ).
          if lf_result = abap_true.
            me->ole_word_add_table_obj_type( exporting is_plugin     = <fs_plugin>
                                             importing ef_result     = lf_result
                                                       ev_text_error = lv_text_error ).
          endif.
        endif.

        loop at gt_object_alv assigning <fs_object_alv> where down_flag = 'X' and select = 'X' and obj_type = <fs_plugin>-obj_type.
          if ef_result = abap_true.
            lv_obj_name = <fs_object_alv>-obj_name.
            create object lo_classobject type (<fs_plugin>-class_name)
              exporting
                name = lv_obj_name.
            if lo_classobject->check_exists( ) = abap_true.
              lo_classobject->ole_word_add_info( exporting is_object_alv     = <fs_object_alv>
                                                           is_output_options = me->output_options
                                                           is_ole_word       = gs_ole_word
                                                 importing ef_result         = lf_result
                                                           ev_text_error     = lv_text_error ).
              if lf_result = abap_true.
                message e012(y00camsg_abpdoc) into lv_text_error.
                <fs_object_alv>-msg = lv_text_error.
                <fs_object_alv>-status = icon_green_light.
              else.
                <fs_object_alv>-msg = lv_text_error.
                <fs_object_alv>-status = icon_red_light.
              endif.
            else.
              message e008(y00camsg_abpdoc) with lv_obj_name <fs_plugin>-obj_type into lv_text_error.
              <fs_object_alv>-msg = lv_text_error.
              <fs_object_alv>-status = icon_red_light.
            endif.
          else.
            <fs_object_alv>-msg = ev_text_error.
            <fs_object_alv>-status = icon_red_light.
          endif.
        endloop.

      endloop.

      me->ole_word_free( importing ef_result     = lf_result
                                   ev_text_error = lv_text_error ).

    endif.

endmethod.