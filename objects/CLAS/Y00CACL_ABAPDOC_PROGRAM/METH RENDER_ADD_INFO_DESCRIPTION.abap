METHOD RENDER_ADD_INFO_DESCRIPTION.

  DATA: ls_trdirt TYPE trdirt,
        lt_trdirt TYPE TABLE OF trdirt,
        lv_text TYPE string,
        lt_text TYPE stringtab.

  SELECT  *
    FROM trdirt
    INTO TABLE lt_trdirt
    WHERE name = gv_obj_name.

* Choose the line with the right language
  choose_by_preferred_langu(  EXPORTING  it_lang_dep        = lt_trdirt
                                         iv_langu_field     = 'SPRSL'
                              IMPORTING  es_lang_dep        = ls_trdirt ).

* Heading
  CONCATENATE is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text SEPARATED BY space.
  io_render->add_object_title( lv_text ).

* Description
  CLEAR lt_text.
  CONCATENATE 'Description:'(001) ls_trdirt-text INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.
  io_render->add_description2( lt_text ).

ENDMETHOD.