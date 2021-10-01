METHOD RENDER_ADD_INFO_CONTROLLER.
*Pozn.: PaM, 16.01.2014 13:08:37 -
* component controller
* window controller
* view controller
* ...
  DATA: lv_text           TYPE string,
        lt_text           TYPE stringtab,
        lv_dummy          TYPE string,
        lv_comp_descr     TYPE wdy_md_description,
        lv_ctrl_type      TYPE wdy_md_controller_type.
  DATA: ls_controller_key TYPE wdy_md_controller_key,
        lr_controller     TYPE REF TO cl_wdy_md_controller.

  DATA: ls_wdyc_object                  TYPE wdy_md_controller_meta_data,
        lt_controller_definition        TYPE STANDARD TABLE OF wdy_controller,
        lt_controller_descriptions      TYPE wdy_controllert_table,
        lt_controller_usages            TYPE wdy_ctlr_usage_table,
        lt_component_usages             TYPE wdy_compo_usage_table,
        lt_controller_components        TYPE STANDARD TABLE OF wdy_ctlr_compo_vrs,
        lt_controller_componentsources  TYPE STANDARD TABLE OF wdy_ctlr_compo_source_vrs,
        lt_controller_component_texts   TYPE wdy_ctlr_compot_table,
        lt_controller_parameters        TYPE wdy_ctlr_param_table,
        lt_controller_parameter_texts   TYPE wdy_ctlr_paramt_table,
        lt_context_nodes                TYPE wdy_ctx_node_table,
        lt_context_attributes           TYPE wdy_ctx_attrib_table,
        lt_context_mappings             TYPE wdy_ctx_mapping_table,
        lt_fieldgroups                  TYPE wdy_fieldgroup_table,
        lt_psmodisrc                    TYPE STANDARD TABLE OF smodisrc,
        lt_psmodilog                    TYPE STANDARD TABLE OF smodilog.

  DATA: wa_ctrl_usages      LIKE LINE OF lt_controller_usages,
        wa_ctrl_components  LIKE LINE OF lt_controller_components,
        wa_ctrl_comp_info   LIKE LINE OF lt_controller_components,
        wa_ctrl_comp_txts   LIKE LINE OF lt_controller_component_texts,
        wa_comp_usages      LIKE LINE OF lt_component_usages.

  CONSTANTS: lc_ctrl_type_cc TYPE wdy_md_controller_type VALUE 02,  " component controller
             lc_ctrl_type_v  TYPE wdy_md_controller_type VALUE 01,  " view
             lc_ctrl_type_w  TYPE wdy_md_controller_type VALUE 06.  " window


  CHECK ir_controller IS BOUND.
  lr_controller ?= ir_controller.

  ls_controller_key-component_name  = lr_controller->if_wdy_md_object~get_parent_name( ).
  ls_controller_key-controller_name = lr_controller->if_wdy_md_object~get_name( ).

  CALL FUNCTION 'WDYC_GET_OBJECT'
    EXPORTING
      controller_key               = ls_controller_key
      r3state                      = 'A'
      get_all_translations         = 'X'
    IMPORTING
      object                       = ls_wdyc_object
    TABLES
      definition                   = lt_controller_definition
      descriptions                 = lt_controller_descriptions
      controller_usages            = lt_controller_usages
      controller_components        = lt_controller_components
      controller_component_sources = lt_controller_componentsources
      controller_component_texts   = lt_controller_component_texts
      controller_parameters        = lt_controller_parameters
      controller_parameter_texts   = lt_controller_parameter_texts
      context_nodes                = lt_context_nodes
      context_attributes           = lt_context_attributes
      context_mappings             = lt_context_mappings
      fieldgroups                  = lt_fieldgroups
      psmodilog                    = lt_psmodilog
      psmodisrc                    = lt_psmodisrc
    EXCEPTIONS
      not_existing                 = 1
      OTHERS                       = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ev_text_error.
    RETURN.
  ENDIF.

  lv_ctrl_type  = ls_wdyc_object-definition-controller_type.


************************************************************************************************************
* - Component Usages
*************************************************************************************************************
* table se sloupci: nazev pouziti komponenty, pouzita komponenta, controller, popis
  IF LINES( lt_controller_usages ) GT 0.
*   getting comp usage info from different FM
    me->get_comp_usage_info( RECEIVING rt_comp_usage = lt_component_usages
                             EXCEPTIONS error        = 1
                                        OTHERS       = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
    ENDIF.

    CLEAR: lt_text, lv_text.
    lv_text = 'Component Usages'.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

*   Table definition
    io_render->start_table( ).
    CLEAR lt_text.

*   Header line
    lv_text = 'Component Use'.
    APPEND lv_text TO lt_text.
    lv_text = 'Component'.
    APPEND lv_text TO lt_text.
    lv_text = 'Controller'.
    APPEND lv_text TO lt_text.
    lv_text = 'Description'.
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).
    CLEAR lt_text.

*   Data lines
    LOOP AT lt_controller_usages INTO wa_ctrl_usages.
      lv_text = wa_ctrl_usages-component_usage.       " Component Use
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      READ TABLE lt_component_usages INTO wa_comp_usages WITH KEY component_name    = wa_ctrl_usages-component_name
                                                                  compo_usage_name  = wa_ctrl_usages-component_usage.
      IF sy-subrc EQ 0.
        lv_text = wa_comp_usages-used_component.       " ext. Component
      ELSE.
        lv_text = wa_ctrl_usages-component_name.       " comp. controller
      ENDIF.

      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = wa_ctrl_usages-used_controller.       " Controller ..?? Interfacecontroller?
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

*     getting description
      CLEAR lv_comp_descr.
      y00cacl_abapdoc_wdc_comp=>read_component_description( EXPORTING iv_name        = wa_ctrl_usages-component_usage
                                                             IMPORTING ev_description = lv_comp_descr ).
      lv_text = lv_comp_descr. "wa_ctrl_usages-used_controller.       " Description ..??
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).
      CLEAR lt_text.
    ENDLOOP.

    io_render->end_table( ).
*   empty line
    me->render_empty_line( io_render ).

*  ELSE.
*    CLEAR lt_text.
*    lv_text = '-'.
*    APPEND lv_text TO lt_text.
*    io_render->add_text( lt_text ).
  ENDIF.



************************************************************************************************************
* - Attributes
************************************************************************************************************
* tabulka se sloupci: nazev atributu, viditelnost, typ, popis
  READ TABLE lt_controller_components TRANSPORTING NO FIELDS WITH KEY cmptype = 'CL_WDY_MD_CONTROLLER_PROPERTY'.
  IF sy-subrc EQ 0.
    CLEAR: lt_text, lv_text.
    lv_text = 'Attributes'.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

*   Table definition
    io_render->start_table( ).
    CLEAR lt_text.

*   Header line
    lv_text = 'Attribute'.
    APPEND lv_text TO lt_text.
    lv_text = 'Public'.
    APPEND lv_text TO lt_text.
    lv_text = 'Associated Type'.
    APPEND lv_text TO lt_text.
    lv_text = 'Description'.
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).
    CLEAR lt_text.

*   Data lines
    LOOP AT lt_controller_components INTO wa_ctrl_components WHERE cmptype EQ 'CL_WDY_MD_CONTROLLER_PROPERTY'. " attributes
      lv_text = wa_ctrl_components-display_name.    " attribute
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = wa_ctrl_components-read_only.       " public
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = wa_ctrl_components-abap_type.       " type
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      CLEAR wa_ctrl_comp_txts.
      READ TABLE lt_controller_component_texts INTO wa_ctrl_comp_txts WITH KEY cmpname = wa_ctrl_components-cmpname.
      lv_text = wa_ctrl_comp_txts-description.
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).
      CLEAR lt_text.
    ENDLOOP.

    io_render->end_table( ).

*   empty line
    me->render_empty_line( io_render ).

*  ELSE.
*    CLEAR lt_text.
*    lv_text = '-'.
*    APPEND lv_text TO lt_text.
*    io_render->add_text( lt_text ).
  ENDIF.


************************************************************************************************************
* - Methods
************************************************************************************************************
* tabulka se sloupci: nazev metody, typ metody, popis, event, controller, component use
  LOOP AT lt_controller_components TRANSPORTING NO FIELDS WHERE cmptype EQ 'CL_WDY_MD_CONTROLLER_METHOD' OR  " methods
                                                                cmptype EQ 'CL_WDY_MD_CTLR_EVENT_HANDLER'.   " event handlers.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    CLEAR: lt_text, lv_text.
    lv_text = 'Methods'.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

*   Table definition
    io_render->start_table( ).
    CLEAR lt_text.

*   Header line
    lv_text = 'Method'.
    APPEND lv_text TO lt_text.
    lv_text = 'Method type'.
    APPEND lv_text TO lt_text.
    lv_text = 'Description'.
    APPEND lv_text TO lt_text.
    lv_text = 'Event'.
    APPEND lv_text TO lt_text.
    lv_text = 'Controller'.
    APPEND lv_text TO lt_text.
    lv_text = 'Component Use'.
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).
    CLEAR lt_text.

*   Data lines
    LOOP AT lt_controller_components INTO wa_ctrl_components WHERE cmptype EQ 'CL_WDY_MD_CONTROLLER_METHOD' OR  " methods
                                                                   cmptype EQ 'CL_WDY_MD_CTLR_EVENT_HANDLER'.   " event handlers
      lv_text = wa_ctrl_components-display_name.      " method
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = Y00CACL_ABAPDOC_WDC_COMP=>convert_method_type_descr( wa_ctrl_components-cmptype ). " method type
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      CLEAR wa_ctrl_comp_txts.
      READ TABLE lt_controller_component_texts INTO wa_ctrl_comp_txts WITH KEY cmpname = wa_ctrl_components-cmpname.
      lv_text = wa_ctrl_comp_txts-description.        " description
      SHIFT lv_text RIGHT DELETING TRAILING space.

      APPEND lv_text TO lt_text.

      lv_text = wa_ctrl_components-ref_cmpname.       " event
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = wa_ctrl_components-ref_ctlr_name.     " controller
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      lv_text = wa_ctrl_components-ref_component.     " comp. used
      SHIFT lv_text RIGHT DELETING TRAILING space.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).
      CLEAR lt_text.
    ENDLOOP.

    io_render->end_table( ).

*   empty line
    me->render_empty_line( io_render ).

*  ELSE.
*    CLEAR lt_text.
*    lv_text = '-'.
*    APPEND lv_text TO lt_text.
*    io_render->add_text( lt_text ).
  ENDIF.



************************************************************************************************************
* - Events
************************************************************************************************************
  IF lv_ctrl_type NE lc_ctrl_type_w.    " events not in Window controller
* tabulka se sloupci: nazev eventu, popis
    READ TABLE lt_controller_components TRANSPORTING NO FIELDS WITH KEY cmptype = 'CL_WDY_MD_CUSTOM_EVENT'. " events
    IF sy-subrc EQ 0.
      CLEAR: lt_text, lv_text.
      lv_text = 'Events'.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

*     Table definition
      io_render->start_table( ).
      CLEAR lt_text.

*     Header line
      lv_text = 'Event'.
      APPEND lv_text TO lt_text.
      lv_text = 'Description'.
      APPEND lv_text TO lt_text.

      io_render->add_table_header_row( lt_text ).
      CLEAR lt_text.

*     Data lines
      LOOP AT lt_controller_components INTO wa_ctrl_components WHERE cmptype EQ 'CL_WDY_MD_CUSTOM_EVENT'. " events
        lv_text = wa_ctrl_components-display_name.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        CLEAR wa_ctrl_comp_txts.
        READ TABLE lt_controller_component_texts INTO wa_ctrl_comp_txts WITH KEY cmpname = wa_ctrl_components-cmpname.
        lv_text = wa_ctrl_comp_txts-description.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).
        CLEAR lt_text.
      ENDLOOP.

      io_render->end_table( ).

*     empty line
      me->render_empty_line( io_render ).

*    ELSE.
*      CLEAR lt_text.
*      lv_text = '-'.
*      APPEND lv_text TO lt_text.
*      io_render->add_text( lt_text ).
    ENDIF.

  ENDIF.


************************************************************************************************************
* - Actions
************************************************************************************************************
* todo tabulka se sloupci: nazev action, popis, event_handler
  IF lv_ctrl_type EQ lc_ctrl_type_v.    " actions only in view
    READ TABLE lt_controller_components TRANSPORTING NO FIELDS WITH KEY cmptype = 'CL_WDY_MD_ACTION'. " actions
    IF sy-subrc EQ 0.
      CLEAR: lt_text, lv_text.
      lv_text = 'Actions'.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

*     Table definition
      io_render->start_table( ).
      CLEAR lt_text.

*     Header line
      lv_text = 'Action'.
      APPEND lv_text TO lt_text.
      lv_text = 'Description'.
      APPEND lv_text TO lt_text.
      lv_text = 'Event Handler'.
      APPEND lv_text TO lt_text.

      io_render->add_table_header_row( lt_text ).
      CLEAR lt_text.

*     Data lines
      LOOP AT lt_controller_components INTO wa_ctrl_components WHERE cmptype EQ 'CL_WDY_MD_ACTION'. " actions
        lv_text = wa_ctrl_components-display_name.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        CLEAR: wa_ctrl_comp_txts.
        READ TABLE lt_controller_component_texts INTO wa_ctrl_comp_txts WITH KEY cmpname = wa_ctrl_components-cmpname.
        lv_text = wa_ctrl_comp_txts-description.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        CLEAR wa_ctrl_comp_info.
        READ TABLE lt_controller_components INTO wa_ctrl_comp_info WITH KEY ref_cmpname = wa_ctrl_components-cmpname.
        lv_text = wa_ctrl_comp_info-display_name.
        SHIFT lv_text RIGHT DELETING TRAILING space.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).
        CLEAR lt_text.
      ENDLOOP.

      io_render->end_table( ).

*     empty line
      me->render_empty_line( io_render ).

*    ELSE.
*      CLEAR lt_text.
*      lv_text = '-'.
*      APPEND lv_text TO lt_text.
*      io_render->add_text( lt_text ).
    ENDIF.
  ENDIF.

************************************************************************************************************
* - Context
************************************************************************************************************
* todo
* udelat novou metodu y00caif_abapdoc_render->ADD_WD_CONTEXT
* v te vypsat hierarchicky jednotlive nody contextu a pod nimi prislusne atributy
* pr.:
* doc (node)
*   header (node)
*     docnr (atribut)
  me->add_wd_context( EXPORTING io_render       = io_render
                                it_ctx_nodes    = lt_context_nodes
                                it_ctx_attrs    = lt_context_attributes
                                it_ctx_mappings = lt_context_mappings ).


  ef_result = abap_true.

ENDMETHOD.