METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs the navigation, BSP pages, method includes, attributes etc.
*&
*&  Uses no flags in is_output_options
*& -----------------------------------------------------------------



  DATA: lv_name TYPE o2applname, "string,
        lv_text TYPE string,
        lt_text TYPE stringtab.

  DATA: lr_application TYPE REF TO cl_o2_api_application,
        lt_page TYPE o2pagelist,
        ls_attribute TYPE o2applattr,
        ls_page_key TYPE o2pagkey,
        lr_page_api TYPE REF TO cl_o2_api_pages,
        ls_page_attr TYPE o2pagattr,
        lt_event_handler TYPE o2pagevh_tabletype,
        lt_navigation TYPE o2applgrap_table,
        lt_page_parameter TYPE o2pagpar_tabletype,
        lt_type_definition_source TYPE rswsourcet.

  DATA: classdescr        TYPE REF TO cl_abap_classdescr,
        typedescr         TYPE REF TO cl_abap_typedescr,
        superclass        TYPE REF TO cl_abap_typedescr,
        oref              TYPE REF TO cx_root ,
        methoddescr       TYPE abap_methdescr ,
        lt_method_include TYPE seop_methods_w_include,
        ls_method_include LIKE LINE OF lt_method_include ,
        lv_clskey TYPE seoclskey .
  DATA: lv_textid         TYPE sotr_conc  .

  FIELD-SYMBOLS: <ls_page> LIKE LINE OF lt_page,
                 <ls_event_handler> LIKE LINE OF lt_event_handler,
                 <ls_page_parameter> LIKE LINE OF lt_page_parameter,
                 <ls_navigation> LIKE LINE OF lt_navigation ,
                 <ls_src_row> TYPE LINE OF rswsourcet . "=o2pagevh_tabletype-source.

* Initialization
  lv_name = gv_obj_name.

* Get detail
  CALL METHOD cl_o2_api_application=>load
    EXPORTING
      p_application_name  = lv_name
    IMPORTING
      p_application       = lr_application
    EXCEPTIONS
      object_not_existing = 1
      permission_failure  = 2
      error_occured       = 3.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>not_found.
      WHEN 2. "TODO
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>not_found.
      WHEN 3. "TODO
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>not_found.
    ENDCASE.
  ENDIF.

  CALL METHOD lr_application->get_attributes
    EXPORTING
      p_version    = 'A'
    IMPORTING
      p_attributes = ls_attribute.

* Heading
  CONCATENATE is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text SEPARATED BY space.
  io_render->add_object_title( lv_text ).

* Description
  CLEAR lt_text.
  CONCATENATE 'Description:'(001) ls_attribute-text INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

* Navigation
  CALL METHOD lr_application->get_navgraph
    EXPORTING
      p_version      = 'A'
    IMPORTING
      p_navgraph     = lt_navigation
    EXCEPTIONS
      object_invalid = 1
      object_deleted = 2
      error_occured  = 3
      OTHERS         = 4.

  "Heading
  CLEAR lt_text.
  lv_text = 'Navigation'(031).
  IF LINES( lt_navigation ) = 0.
    add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
  ENDIF.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  IF LINES( lt_navigation ) > 0.
    "Header
    io_render->start_table( ).
    CLEAR lt_text.
    lv_text = 'Start'(032).
    APPEND lv_text TO lt_text.
    lv_text = 'Navigation request'(033).
    APPEND lv_text TO lt_text.
    lv_text = 'Target'(034).
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).

    " Item
    LOOP AT lt_navigation ASSIGNING <ls_navigation>.

      CLEAR: lt_text.

      lv_text = <ls_navigation>-currname.
      APPEND lv_text TO lt_text.

      lv_text = <ls_navigation>-nodeexit.
      APPEND lv_text TO lt_text.

      lv_text = <ls_navigation>-fupname.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).

    ENDLOOP.
    io_render->end_table( ).
  ENDIF.

* BSP pages *********************************************************************
  CALL METHOD cl_o2_api_pages=>get_all_pages
    EXPORTING
      p_applname = lv_name
      p_version  = 'A'
    IMPORTING
      p_pages    = lt_page.

  LOOP AT lt_page ASSIGNING <ls_page>.

    "page header data
    ls_page_key-applname = lv_name.
    ls_page_key-pagekey = <ls_page>-pagekey.
    CLEAR lr_page_api.
    CALL METHOD cl_o2_api_pages=>load
      EXPORTING
        p_pagekey = ls_page_key
      IMPORTING
        p_page    = lr_page_api.

** Page property
    CALL METHOD lr_page_api->get_attrs
      IMPORTING
        p_attrs      = ls_page_attr
      EXCEPTIONS
        page_deleted = 1
        OTHERS       = 2.

    CLEAR lt_text.
    IF ls_page_attr-pagetype = 'C'. "Controller
      CONCATENATE 'Page - Controller'(038) ls_page_attr-pagekey INTO lv_text SEPARATED BY space.
    ELSEIF ls_page_attr-pagetype = 'V' . "View
      CONCATENATE 'Page - View'(037) ls_page_attr-pagekey INTO lv_text SEPARATED BY space.
    ELSEIF ls_page_attr-pagetype = 'X' . "Page Fragment
      CONCATENATE 'Page Fragment'(036) ls_page_attr-pagekey INTO lv_text SEPARATED BY space.
    ELSE . "Page with Flow Logic
      CONCATENATE 'Page with Flow Logic'(035) ls_page_attr-pagekey INTO lv_text SEPARATED BY space.
    ENDIF .
    io_render->add_object_subtitle( lv_text ).

    CLEAR lt_text.
    CONCATENATE 'Description:'(001) ls_page_attr-descript INTO lv_text SEPARATED BY space.
    APPEND lv_text TO lt_text.
    io_render->add_description( lt_text ).

    CLEAR lt_text.
    lv_text = ls_page_attr-pagetype.
    lv_text = me->get_domain_text( iv_domain_name  = 'O2PAGTYP' iv_domain_value = lv_text ).
    CONCATENATE 'Page type:'(012) lv_text INTO lv_text.
    APPEND lv_text TO lt_text.

    IF ls_page_attr-pagetype = 'C' OR ls_page_attr-pagetype = 'V' .
      SELECT SINGLE controllerurl FROM o2pagdir INTO lv_text WHERE applname = lv_name AND pagekey = <ls_page>-pagekey.
      IF sy-subrc IS INITIAL AND lv_text IS NOT INITIAL .
*     view's controller class
        CONCATENATE 'Controller class:'(013) lv_text INTO lv_text.
        APPEND lv_text TO lt_text.
      ELSEIF NOT ls_page_attr-implclass IS INITIAL .
*     xxx.do object's (controller) class
        CONCATENATE 'Controller class:'(013) ls_page_attr-implclass INTO lv_text.
        APPEND lv_text TO lt_text.
      ENDIF .
    ENDIF .

    io_render->add_text( lt_text ).

    IF ls_page_attr-pagetype = 'C'.  "controller pages

      lv_clskey = ls_page_attr-implclass .
      CALL FUNCTION 'SEO_CLASS_GET_METHOD_INCLUDES'
        EXPORTING
          clskey                       = lv_clskey
        IMPORTING
          includes                     = lt_method_include
        EXCEPTIONS
          _internal_class_not_existing = 1
          OTHERS                       = 2.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE e450(y00camsg_abpdoc) WITH gv_obj_name INTO lv_text.
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>error_message
            msg = lv_text.
      ENDIF.

      "Heading
      CLEAR lt_text.
      lv_text = 'Event handler list'(020).
      IF LINES( lt_method_include ) = 0.
        add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
      ENDIF.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

      "Header
      IF LINES( lt_method_include ) > 0.
        io_render->start_table( ).
        CLEAR lt_text.
        lv_text = 'Event handler'(021).
        APPEND lv_text TO lt_text.
        lv_text = 'Description'(022).
        APPEND lv_text TO lt_text.

        io_render->add_table_header_row( lt_text ).

        LOOP AT lt_method_include INTO ls_method_include
                                  WHERE cpdkey-cpdname = 'DO_HANDLE_EVENT'
                                    OR  cpdkey-cpdname = 'DO_HANDLE_DATA'
                                    OR  cpdkey-cpdname = 'DO_REQUEST'
                                        .


          DATA: lv_string TYPE string  ,
                lt_text2 TYPE stringtab ,
                lv_text2 TYPE string .

          CLEAR: lt_text, lv_text, lt_text2, lv_text2 .

          lv_text = ls_method_include-cpdkey-cpdname .
          APPEND lv_text TO lt_text.


          lv_string = ls_method_include-incname.
*        lt_text = get_code_comment(  lv_string  ).

          CALL METHOD get_code_comment
            EXPORTING
              iv_obj_name  = lv_string
              it_key_words = is_output_options-keyw_bsp
            RECEIVING
              rt_text      = lt_text2.

          CLEAR lv_text .
          LOOP AT lt_text2 INTO lv_text2.
            CONCATENATE lv_text lv_text2 cl_abap_char_utilities=>cr_lf  INTO lv_text SEPARATED BY space .
          ENDLOOP.
*        io_render->add_comment_code( lt_text ).
          APPEND lv_text TO lt_text.
          io_render->add_table_row( lt_text ).


        ENDLOOP . "  AT lt_method_include INTO ls_method_include.

        io_render->end_table( ).
      ENDIF.

    ELSE.                              "non-controller pages
* (Page with flow logic, View (=V) nebo Fragment ( =X))

* Page attributes
      CLEAR lt_page_parameter.
      CALL METHOD lr_page_api->get_parameters
        IMPORTING
          p_parameters = lt_page_parameter
        EXCEPTIONS
          page_deleted = 1
          invalid_call = 2
          OTHERS       = 3.

      "Heading
*      IF NOT lt_page_parameter[] IS INITIAL .
* 27.5.2014, Pavel Jelínek: changing to standard behaviour based on method add_na_to_title
      CLEAR lt_text.
      lv_text = 'Attributes'(023).
      IF LINES( lt_page_parameter ) = 0.
        add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
      ENDIF.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

      IF LINES( lt_page_parameter ) > 0.
        "Header
        io_render->start_table( ).
        CLEAR lt_text.
        lv_text = 'Attribute'(024).
        APPEND lv_text TO lt_text.
        lv_text = 'Description'(022).
        APPEND lv_text TO lt_text.
        lv_text = 'Type'(025).
        APPEND lv_text TO lt_text.
        lv_text = 'Alias name'(026).
        APPEND lv_text TO lt_text.

        io_render->add_table_header_row( lt_text ).


        " Item
        LOOP AT lt_page_parameter ASSIGNING <ls_page_parameter>.

          CLEAR: lt_text.

          lv_text = <ls_page_parameter>-compname.
          APPEND lv_text TO lt_text.

          lv_text = <ls_page_parameter>-text.
          APPEND lv_text TO lt_text.

          lv_text = <ls_page_parameter>-type.
          APPEND lv_text TO lt_text.

          lv_text = <ls_page_parameter>-aliasname.
          APPEND lv_text TO lt_text.

          io_render->add_table_row( lt_text ).

        ENDLOOP.
        io_render->end_table( ).
      ENDIF .

** Event handlers
      CALL METHOD lr_page_api->get_event_handlers
        IMPORTING
          p_ev_handler = lt_event_handler.

*      IF NOT lt_event_handler[] IS INITIAL .
* 27.5.2014, Pavel Jelínek: changing to standard behaviour based on method add_na_to_title
      CLEAR: lt_text.
      if LINES( lt_page_parameter ) > 0. "Jelínek: This indent has sense only of the _previous_ list m (lt_page_parameter) is non-empty
        io_render->add_text( lt_text ).
      endif.

      "Heading
      CLEAR lt_text.
      lv_text = 'Event handler list'(020).
      IF LINES( lt_event_handler ) = 0.
        add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
      ENDIF.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

      IF LINES( lt_event_handler ) > 0.
        "Header
        io_render->start_table( ).
        CLEAR lt_text.
        lv_text = 'Event handler'(021).
        APPEND lv_text TO lt_text.
        lv_text = 'Description'(022).
        APPEND lv_text TO lt_text.

        io_render->add_table_header_row( lt_text ).

        " Item
        LOOP AT lt_event_handler ASSIGNING <ls_event_handler>.

          CLEAR: lt_text.

          lv_text = <ls_event_handler>-evhandler.
          APPEND lv_text TO lt_text.

          lv_text = <ls_event_handler>-evhname.


          LOOP AT <ls_event_handler>-source ASSIGNING <ls_src_row> .

            IF <ls_src_row> IN is_output_options-keyw_bsp
               AND NOT is_output_options-keyw_bsp IS INITIAL .
              CONCATENATE lv_text cl_abap_char_utilities=>cr_lf <ls_src_row>  INTO lv_text.
*            APPEND lv_text TO lt_text.
            ENDIF.
          ENDLOOP.

          APPEND lv_text TO lt_text.

          io_render->add_table_row( lt_text ).

        ENDLOOP. "AT lt_event_handler ASSIGNING <ls_event_handler>.

        io_render->end_table( ).
      ENDIF .


****     type definitions
***      CALL METHOD lr_page_api->get_type_source
***        IMPORTING
***          p_source     = lt_type_definition_source
***        EXCEPTIONS
***          page_deleted = 1
***          invalid_call = 2
***          OTHERS       = 3.

    ENDIF.    "controller/non-controller pages

  ENDLOOP.

* Finalization ********************************************************************
  ef_result = abap_true.

ENDMETHOD.