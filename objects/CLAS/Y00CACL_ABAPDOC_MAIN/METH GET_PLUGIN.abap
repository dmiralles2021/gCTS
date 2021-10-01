method GET_PLUGIN.

* zjisti typ pluginu na zaklade dedeni z tridy y00cacl_abapdoc
    DATA: lo_classobject      TYPE REF TO y00cacl_abapdoc.
    DATA: lt_class            TYPE seo_inheritances,
*          ls_tabletypeline    TYPE ko105,
*          lt_tabletypesout    TYPE tr_object_texts,
*          ls_tabletypeoutline TYPE ko100,
          lv_clsname          TYPE string,
          lv_order            TYPE int4.
*    DATA: lt_tabletypesin     TYPE TABLE OF ko105.
    data lv_obj_type_text type string.

    FIELD-SYMBOLS: <fs_class>   LIKE LINE OF lt_class,
                   <fs_plugin>  LIKE LINE OF rt_plugin.

    IF gt_plugin IS INITIAL.

      SELECT * FROM vseoextend INTO TABLE lt_class WHERE refclsname = y00cacl_abapdoc_const=>name_class_root AND version = '1'.

      LOOP AT lt_class ASSIGNING <fs_class>.
        lv_clsname = <fs_class>-clsname.
        CREATE OBJECT lo_classobject TYPE (lv_clsname)
          EXPORTING
            name = 'foo'.

        lv_order = lo_classobject->get_object_order( ).

*        CLEAR ls_tabletypeline.
*        REFRESH lt_tabletypesin.

*        ls_tabletypeline-object = lo_classobject->get_object_type( ).
*        APPEND ls_tabletypeline TO lt_tabletypesin.
*
*        CALL FUNCTION 'TRINT_OBJECT_TABLE'
*          TABLES
*            tt_types_in  = lt_tabletypesin
*            tt_types_out = lt_tabletypesout.


          APPEND INITIAL LINE TO gt_plugin ASSIGNING <fs_plugin>.
          <fs_plugin>-class_name = lv_clsname.
          <fs_plugin>-obj_type = lo_classobject->get_object_type( ). "=ls_tabletypeoutline-object.
*          <fs_plugin>-text = ls_tabletypeoutline-text.
          <fs_plugin>-order = lv_order.
          <fs_plugin>-count = 0.
           GET_TEXT_FOR_OBJ_TYPE( EXPORTING iv_obj_type      = <fs_plugin>-obj_type
                                 IMPORTING ev_obj_type_text = lv_obj_type_text    ).
          <fs_plugin>-text = lv_obj_type_text.

      ENDLOOP.
    ENDIF.

    rt_plugin = gt_plugin.

endmethod.