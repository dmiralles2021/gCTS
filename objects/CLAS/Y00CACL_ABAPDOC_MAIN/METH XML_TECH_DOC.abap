method XML_TECH_DOC.
*----------------------------------------------------------------------*
* Method: XML_TECH_DOC
*----------------------------------------------------------------------*
* Description:
* Generate technical documentation using xml.
*----------------------------------------------------------------------*

  DATA: lo_classobject    TYPE REF TO y00cacl_abapdoc,

        lo_xml_node_root  TYPE REF TO if_ixml_node,

        lv_text           TYPE string,
        lv_obj_name       TYPE string,
        lf_result         TYPE flag.

  FIELD-SYMBOLS: <fs_object_alv> LIKE LINE OF gt_object_alv,
                 <fs_plugin>     LIKE LINE OF gt_plugin.

  CLEAR ev_text_error.

  ef_result = abap_true.

* create node componentsList and compomentsTree
  lo_xml_node_root = io_xml_document->find_node( name = 'schemaModel' ).

  LOOP AT gt_plugin ASSIGNING <fs_plugin> WHERE count > 0.

*     Loop plugin objects
    LOOP AT gt_object_alv ASSIGNING <fs_object_alv>
        WHERE down_flag EQ abap_true
          AND select    EQ abap_true
          AND obj_type  EQ <fs_plugin>-obj_type.

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
        lo_classobject->xml_add_info(
          EXPORTING
            is_object_alv     = <fs_object_alv>
            is_output_options = me->output_options
            io_xml_document   = io_xml_document
          IMPORTING
            ef_result         = lf_result
            ev_text_error     = <fs_object_alv>-msg
        ).

*         Process result
        IF lf_result EQ abap_true.

          MESSAGE s012 INTO <fs_object_alv>-msg.
*           Documentation generated
          <fs_object_alv>-status = icon_green_light.
        ELSE.
          <fs_object_alv>-status = icon_red_light.
        ENDIF.
      ELSE.

        MESSAGE e008 WITH lv_obj_name <fs_plugin>-obj_type INTO <fs_object_alv>-msg.
*         Object &2 type &1 does not exist
        <fs_object_alv>-status = icon_red_light.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

endmethod.