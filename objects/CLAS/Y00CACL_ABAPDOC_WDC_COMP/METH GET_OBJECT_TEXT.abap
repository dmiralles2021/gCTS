method GET_OBJECT_TEXT.

  DATA: lv_description TYPE wdy_md_description,
        lv_name TYPE wdy_component_name.


  lv_name = gv_obj_name.

  y00cacl_abapdoc_wdc_comp=>read_component_description(
    EXPORTING
      iv_name        = lv_name
    IMPORTING
      ev_description = lv_description
         ).

  ev_object_text_singl = ev_object_text_multi = lv_description.

endmethod.