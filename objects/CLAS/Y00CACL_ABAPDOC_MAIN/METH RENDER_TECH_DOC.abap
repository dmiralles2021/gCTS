METHOD render_tech_doc.
*----------------------------------------------------------------------*
* Method: RENDER_TECH_DOC
*----------------------------------------------------------------------*
* Description:
* Generate technical documentation using render class.
*----------------------------------------------------------------------*

  DATA:
    lo_classobject TYPE REF TO y00cacl_abapdoc,
    lv_text        TYPE string,
    lv_obj_name    TYPE string,
    lf_result      TYPE flag,
    lx_ex          TYPE REF TO cx_root.

  FIELD-SYMBOLS: <fs_object_alv> LIKE LINE OF gt_object_alv,
                 <fs_plugin>     LIKE LINE OF gt_plugin.

  CLEAR ef_result.

* Loop trough plugins
  TRY.
      LOOP AT gt_plugin ASSIGNING <fs_plugin>
          WHERE count > 0.

*     Write chapter for each plugin
        MESSAGE i100 WITH <fs_plugin>-obj_type <fs_plugin>-text INTO lv_text.
*     List of objects of type &1 - &2
        io_render->add_chapter_title( lv_text ).

*     Loop plugin objects
        LOOP AT gt_object_alv ASSIGNING <fs_object_alv>
            WHERE down_flag EQ abap_true
              AND select    EQ abap_true
              AND obj_type  EQ <fs_plugin>-obj_type.
* Progress bar (+Jelínek 22.4.2014)
          DATA lv_progress_text TYPE string.
          CONCATENATE <fs_object_alv>-obj_type <fs_object_alv>-obj_name INTO lv_progress_text SEPARATED BY space.
          CALL FUNCTION 'PROGRESS_INDICATOR_APPL'
            EXPORTING
              i_text               = lv_progress_text
              i_output_immediately = 'X'.

*       Create object class
          lv_obj_name = <fs_object_alv>-obj_name.
          CREATE OBJECT lo_classobject
            TYPE
              (<fs_plugin>-class_name)
            EXPORTING
              name                     = lv_obj_name.

*       Check existence
          IF lo_classobject->check_exists( ) = abap_true.

*         Try to render
            lo_classobject->render_add_info(
              EXPORTING
                is_object_alv     = <fs_object_alv>
                is_output_options = me->output_options
                io_render         = io_render
              IMPORTING
                ef_result         = lf_result
                ev_text_error     = <fs_object_alv>-msg
            ).

*         Process result
            IF lf_result EQ abap_true.

              MESSAGE s012
                     INTO <fs_object_alv>-msg.
*           Documentation generated
              <fs_object_alv>-status = icon_green_light.
            ELSE.
              <fs_object_alv>-status = icon_red_light.
            ENDIF.
          ELSE.

            MESSAGE e008
                   WITH lv_obj_name <fs_plugin>-obj_type
                   INTO <fs_object_alv>-msg.
*         Object &2 type &1 does not exist
            <fs_object_alv>-status = icon_red_light.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

    CATCH y00cacx_abapdoc_render y00cacx_abapdoc INTO lx_ex.
*>>-> PaM 16.01.2014 12:28:55
*    ev_text_error = lx_ex->if_message~get_text( ).
      <fs_object_alv>-msg = ev_text_error = lx_ex->if_message~get_text( ).
*<-<< PaM 16.01.2014 12:28:55
  ENDTRY.
  ef_result = abap_true.
  MESSAGE i501(y00camsg_abpdoc) INTO lv_progress_text.
  CALL FUNCTION 'PROGRESS_INDICATOR_APPL'
    EXPORTING
      i_text               = lv_progress_text
      i_output_immediately = 'X'.


ENDMETHOD.