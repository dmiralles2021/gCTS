method RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs description, documentation, line type,
*&   access mode and key category.
*&
*&  Uses the following flag in is_output_options
*&  - tech_docu (output content of "goto/documentation")
*& -----------------------------------------------------------------



*  break pelcm.

  DATA: ls_dd40v TYPE dd40v,
        lt_dd42v TYPE STANDARD TABLE OF dd42v,
        lv_gotstate TYPE ddgotstate,
        lv_name TYPE ddobjname,
        lv_text TYPE string,
        lt_text TYPE stringtab.


* Initialization
  lv_name = gv_obj_name.

* Get detail
  CALL FUNCTION 'DDIF_TTYP_GET'
    EXPORTING
      name          = lv_name
      langu         = sy-langu
    IMPORTING
      gotstate      = lv_gotstate
      dd40v_wa      = ls_dd40v
    TABLES
      dd42v_tab     = lt_dd42v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc IS NOT INITIAL OR ls_dd40v-typename IS INITIAL.
    RAISE EXCEPTION TYPE y00cacx_abapdoc
      EXPORTING
        textid = y00cacx_abapdoc=>not_found.
  ENDIF.

* Heading
  CONCATENATE is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text SEPARATED BY space.
  io_render->add_object_title( lv_text ).

* Description
  CLEAR lt_text.
  CONCATENATE 'Description:'(001) ls_dd40v-ddtext INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

* Documentation *************************************************************
  IF is_output_options-tech_docu = abap_true.

    CLEAR: lt_text, lv_text.
    APPEND lv_text TO lt_text.
    io_render->add_text( lt_text ).

* Heading
    CLEAR lt_text.
    lv_text = 'Documentation'(002).
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    lt_text = get_documentation( gv_obj_name ).
    io_render->add_documentation( lt_text ).

  ENDIF.

* Line type
  CLEAR lt_text.
  lv_text = 'Line type'(011).
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  CLEAR lt_text.
  IF ls_dd40v-rowtype IS NOT INITIAL.
    CONCATENATE 'Name of row type:'(013) ls_dd40v-rowtype INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
  ENDIF.
  IF ls_dd40v-rowkind IS NOT INITIAL.
    lv_text = ls_dd40v-rowkind.
    lv_text = me->get_domain_text( iv_domain_name  = 'TYPEKIND' iv_domain_value = lv_text ).
    CONCATENATE 'Category of Dictionary Type:'(014) lv_text INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
  ENDIF.
  IF ls_dd40v-datatype IS NOT INITIAL.
    lv_text = ls_dd40v-datatype.
    lv_text = me->get_domain_text( iv_domain_name  = 'DATATYPE' iv_domain_value = lv_text ).
    IF lv_text is INITIAL.
      CONCATENATE '[' ls_dd40v-datatype ']' into lv_text.
    ENDIF.
    CONCATENATE 'Data Type in ABAP Dictionary:'(015) lv_text INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
  ENDIF.
  IF ls_dd40v-leng IS NOT INITIAL.
    CONCATENATE 'Length (No. of Characters):'(016) ls_dd40v-leng INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
  ENDIF.
  IF ls_dd40v-decimals IS NOT INITIAL.
    CONCATENATE 'Number of Decimal Places:'(017) ls_dd40v-decimals INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
  ENDIF.
  IF ls_dd40v-reftype IS NOT INITIAL.
    lv_text = ls_dd40v-reftype.
    lv_text = me->get_domain_text( iv_domain_name  = 'DDREFTYPE' iv_domain_value = lv_text ).
    CONCATENATE 'Type of Object Referenced:'(018) lv_text INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
  ENDIF.

  io_render->add_text( lt_text ).

* Initialization and access
  CLEAR lt_text.
  lv_text = 'Initialization and access'(019).
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  CLEAR lt_text.
  lv_text = ls_dd40v-accessmode.
  lv_text = me->get_domain_text( iv_domain_name  = 'ACCESSMODE' iv_domain_value = lv_text ).
  CONCATENATE 'Access modes:'(026) lv_text INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.
  io_render->add_text( lt_text ).

* Key
  CLEAR lt_text.
  lv_text = 'Key'(020).
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  CLEAR lt_text.
  lv_text = ls_dd40v-keydef.
  lv_text = me->get_domain_text( iv_domain_name  = 'TTYPKEYDEF' iv_domain_value = lv_text ).
  CONCATENATE 'Key definition:'(036) lv_text INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.

  lv_text = ls_dd40v-keykind.
  lv_text = me->get_domain_text( iv_domain_name  = 'KEYKIND' iv_domain_value = lv_text ).
  CONCATENATE 'Key category:'(037) lv_text INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.

  io_render->add_text( lt_text ).

* Finalization ********************************************************************
  ef_result = abap_true.

endmethod.