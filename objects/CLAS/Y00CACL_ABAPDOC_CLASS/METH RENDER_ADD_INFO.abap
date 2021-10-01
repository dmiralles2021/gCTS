METHOD RENDER_ADD_INFO.
*& -----------------------------------------------------------------
*&   Method RENDER_ADD_INFO
*& -----------------------------------------------------------------
*&  Outputs the description, documentation,  superclass, attributes,
*&    method headers, method interfaces and code comments.
*&
*&  For inherited attribs and methods, we must climb
*&    to the superclass where they are defined.
*&
*&  Uses following flags in is_output_options:
*&  - tech_docu (output content of "goto/documentation")
*&  - module_interfaces (output list of method parameters)
*&  - print_empty_par (output empty paragraphs in docu and in code comments)
*& -----------------------------------------------------------------

  TYPE-POOLS: seop.

  DATA: classdescr        TYPE REF TO cl_abap_classdescr,
        typedescr         TYPE REF TO cl_abap_typedescr,
        superclass        TYPE REF TO cl_abap_typedescr,
        oref              TYPE REF TO cx_root.
  DATA: lv_classname      TYPE seoclsname,
        lv_objtype        TYPE string,
        classkey          TYPE seoclskey,
        classproperties   TYPE vseoclass,
        lv_text           TYPE string,
        lt_text           TYPE stringtab,
        lt_text2          TYPE stringtab,
        ls_ole_actdoc     TYPE ole2_object,
        lv_textid         TYPE sotr_conc,
        text              TYPE string,
        lv_string         TYPE string,
        superclassname    TYPE string,
        superclasskey     TYPE seorelkey,
        inheritanceprops  TYPE vseoextend,
        lv_classprop      TYPE string,
        attribkey         TYPE seocmpkey,
        attribdescr       TYPE abap_attrdescr,
        attribproperties  TYPE vseoattrib,
        methoddescr       TYPE abap_methdescr,
        lv_row            TYPE i,
        ls_seosubcotx     TYPE seosubcotx,
        ls_seosubcodf     TYPE seosubcodf,
        redefines         TYPE STANDARD TABLE OF seoredef
                          WITH KEY clsname refclsname version mtdname,
        lt_method_include TYPE seop_methods_w_include,
        lv_clskey TYPE seoclskey,
        lv_cpdkey TYPE seocpdkey.

  FIELD-SYMBOLS: <ls_parameter> LIKE LINE OF methoddescr-parameters,
                 <ls_method_include> LIKE LINE OF lt_method_include.

  lv_classname = gv_obj_name.
  classkey-clsname = gv_obj_name.

  lv_objtype = get_object_type( ).


* Class info reading
  CALL FUNCTION 'SEO_CLASS_GET'
    EXPORTING
      clskey       = classkey
      version      = '1'
    IMPORTING
      class        = classproperties
    EXCEPTIONS
      not_existing = 1
      deleted      = 2
      is_interface = 3
      model_only   = 4.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>not_found.
      WHEN 2.
        MESSAGE i102(y00camsg_abpdoc) INTO lv_text.
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>error_message
            msg    = 'class deleted'.
      WHEN 3.
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>error_message
            msg    = 'interfaces not supported'.
      WHEN 4.
        RAISE EXCEPTION TYPE y00cacx_abapdoc
          EXPORTING
            textid = y00cacx_abapdoc=>error_message
            msg    = 'class is modeled only'.
    ENDCASE.
  ELSE.

*   Object name
    MESSAGE i102(y00camsg_abpdoc) WITH is_object_alv-obj_type_txt is_object_alv-obj_name INTO lv_text.
    io_render->add_object_title( lv_text ).
  ENDIF.

  TRY.
      CALL METHOD cl_abap_classdescr=>describe_by_name
        EXPORTING
          p_name         = gv_obj_name
        RECEIVING
          p_descr_ref    = typedescr
        EXCEPTIONS
          type_not_found = 1.
      classdescr ?= typedescr.
    CATCH cx_root INTO oref.
      lv_textid = y00cacx_abapdoc=>error_message.
      text = oref->get_text( ).
      RAISE EXCEPTION TYPE y00cacx_abapdoc
        EXPORTING
          textid = lv_textid
          msg    = text.
  ENDTRY.

* Class description **********************************************************
  CLEAR lt_text.
  CONCATENATE 'Description'(006) classproperties-descript INTO lv_text SEPARATED BY space.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

* Documentation *************************************************************
  IF is_output_options-tech_docu = abap_true.

    lt_text2 = get_documentation( gv_obj_name ).

    IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .

      CLEAR: lt_text, lv_text.
      APPEND lv_text TO lt_text.
      io_render->add_text( lt_text ).
* Heading
      CLEAR lt_text.
      lv_text = 'Documentation'(021).
      APPEND lv_text TO lt_text.
      io_render->add_text( lt_text ).

      io_render->add_documentation( lt_text2 ).
    ENDIF .
  ENDIF.

* Superclass ********************************************************************
  classdescr->get_super_class_type( RECEIVING  p_descr_ref           = superclass
                                    EXCEPTIONS super_class_not_found = 1 ).

  IF sy-subrc = 0.
    superclassname = superclass->get_relative_name( ).
    IF NOT superclassname CS 'OBJECT'.
      superclasskey-clsname = gv_obj_name.
      superclasskey-refclsname = superclassname.

      CALL FUNCTION 'SEO_INHERITANC_GET'
        EXPORTING
          inhkey        = superclasskey
        IMPORTING
          inheritance   = inheritanceprops
          redefinitions = redefines.
    ENDIF.
  ENDIF.



  IF superclassname IS NOT INITIAL.
    MESSAGE i105(y00camsg_abpdoc) WITH superclassname INTO lv_text.
    CLEAR lt_text.
    APPEND lv_text TO lt_text.
    io_render->add_text( lt_text ).
  ENDIF.

* Class atributes ************************************************************
  CLEAR: lt_text, lv_text.
  APPEND lv_text TO lt_text.
  io_render->add_text( lt_text ).

** Description
  CLEAR lt_text.
  lv_text = 'Class attributes'(004).
  IF LINES( classdescr->attributes ) = 0.
    add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
  ENDIF.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).


  IF LINES( classdescr->attributes ) > 0.
*   Header
    io_render->start_table( ).

    CLEAR lt_text.

*   Attributes names
    MESSAGE i200(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

*   Atributes description
    MESSAGE i201(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

*   Visibility
    MESSAGE i202(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

*   Inherited
    MESSAGE i203(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

*   Type
    MESSAGE i221(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

*   Default value
    MESSAGE i222(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).

    LOOP AT classdescr->attributes INTO attribdescr.

      CLEAR lt_text.
*   Attributes name
      lv_text = attribdescr-name.
      APPEND lv_text TO lt_text.

*   Attributes description

*   If we do not CLIMB iteratively to superclasses, then the documentator
*    will display an empty description for INHERITED attribs - which we do not want.
*   [Iteration added by P. Jelínek, 2014-04-21]
      DATA lo_cldes_climb TYPE REF TO cl_abap_classdescr.
      lo_cldes_climb = classdescr. "First look in the current class and then in the superclasses
      CLEAR lv_text.
      DO.
        ASSERT sy-index < 999. "Infinite cycle?
        CLEAR attribkey.
        attribkey-clsname = lo_cldes_climb->get_relative_name( ).
        attribkey-cmpname = attribdescr-name.
        CLEAR attribproperties.
        CALL FUNCTION 'SEO_ATTRIBUTE_GET'
          EXPORTING
            attkey       = attribkey
          IMPORTING
            attribute    = attribproperties
          EXCEPTIONS
            not_existing = 1
            deleted      = 2
            is_method    = 3
            is_event     = 4
            is_type      = 5
            OTHERS       = 6.
        IF sy-subrc <> 0.
*   !! Do NOT exit. This also happens when the attrib is inherited
*     in class lo_cldes_climb from its superclass
        ENDIF.
        lv_text   = attribproperties-descript.
        IF lv_text IS NOT INITIAL.
          EXIT. "Success
        ENDIF.
        lo_cldes_climb = cldes_to_superclass( lo_cldes_climb ).
        IF lo_cldes_climb IS INITIAL.
          EXIT. "We have reached the highest superclass
        ENDIF.
      ENDDO.
      IF lv_text IS INITIAL.
        MESSAGE i204(y00camsg_abpdoc) INTO lv_text.
      ENDIF.
      APPEND lv_text TO lt_text.

* Default value:
*  Now lo_cldes_climb contains the superclass where the attrib. has been defined.
*  This is where we can find the default value:
      DATA lv_default_val TYPE string.
      CLEAR lv_default_val .
      IF lo_cldes_climb IS NOT INITIAL.
        DATA lv_climb_name TYPE string.
        lv_climb_name = lo_cldes_climb->get_relative_name( ).
        SELECT SINGLE attvalue FROM seocompodf INTO lv_default_val
          WHERE clsname = lv_climb_name
            AND cmpname = attribdescr-name
            AND version = '1'. "Aktivní verze
      ENDIF.

*   Visibility
      CASE attribdescr-visibility.

*   Public
        WHEN 'U'.
          MESSAGE i205(y00camsg_abpdoc) INTO lv_text.

*   Protected
        WHEN 'O'.
          MESSAGE i206(y00camsg_abpdoc) INTO lv_text.

*   Private
        WHEN 'I'.
          MESSAGE i207(y00camsg_abpdoc) INTO lv_text.
        WHEN OTHERS.
          CLEAR lv_text.
      ENDCASE.
      APPEND lv_text TO lt_text.

*   Inherited ?
      IF attribdescr-is_inherited = abap_true.
        MESSAGE i208(y00camsg_abpdoc) INTO lv_text.
      ELSE.
        MESSAGE i209(y00camsg_abpdoc) INTO lv_text.
      ENDIF.
      APPEND lv_text TO lt_text.

* Type
      lv_text  = attribdescr-length .
      CONCATENATE attribdescr-type_kind lv_text   INTO lv_text  SEPARATED BY space.
      APPEND lv_text TO lt_text.  "For example C 10
* Default value
      APPEND lv_default_val TO lt_text.

      io_render->add_table_row( lt_text ).

    ENDLOOP.

    io_render->end_table( ).
  ENDIF.

* Method header ************************************************************

* prepare all methods includes for use later:
  lv_clskey = classproperties-clsname.
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


* Add blank paragraph to separate tables
  CLEAR lt_text.
  io_render->add_text( lt_text ).
* Heading
  CLEAR lt_text.
  lv_text = 'Method headers'(003).
  IF LINES( classdescr->methods ) = 0.
    add_na_to_title( CHANGING cv_title = lv_text ). "Add the 'N/A' suffix because we will output no table
  ENDIF.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  IF LINES( classdescr->methods ) > 0.
    io_render->start_table( ).

* Method name
    CLEAR lt_text.
    lv_text = 'Method name'(001). " <== message i210(y00camsg_abpdoc) into lv_text.
    APPEND lv_text TO lt_text.

* Method description
    MESSAGE i201(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

* Visibility
    MESSAGE i202(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

* Inheritied
    MESSAGE i203(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

* Re-defined
    MESSAGE i211(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

* Abstract
    MESSAGE i212(y00camsg_abpdoc) INTO lv_text.
    APPEND lv_text TO lt_text.

    io_render->add_table_header_row( lt_text ).

* Methods header
    CLEAR lt_text.
    LOOP AT classdescr->methods INTO methoddescr.

      CLEAR lt_text.
* Method name
      lv_text = methoddescr-name.
      APPEND lv_text TO lt_text.

* Method description
      lv_text = me->get_description_of_method( io_class_descr = classdescr
                                               iv_method_name = methoddescr-name
                                              ).
      IF lv_text IS INITIAL.
        MESSAGE i204(y00camsg_abpdoc) INTO lv_text. "  'Missing'
      ENDIF.
      APPEND lv_text TO lt_text.
* <<< REPLACE Jelínek 22.4.2014


* Visibility
      CASE methoddescr-visibility.

* Public
        WHEN 'U'.
          MESSAGE i205(y00camsg_abpdoc) INTO lv_text.
* Protected
        WHEN 'O'.
          MESSAGE i206(y00camsg_abpdoc) INTO lv_text.
* Private
        WHEN 'I'.
          MESSAGE i207(y00camsg_abpdoc) INTO lv_text.
        WHEN OTHERS.
          CLEAR lv_text.
      ENDCASE.
      APPEND lv_text TO lt_text.

* Inherited methods
      IF methoddescr-is_inherited = abap_true.
*     lv_text = 'Ano'.
        lv_text = 'Yes'.
      ELSE.
*     lv_text = 'Ne'.
        lv_text = 'No'.
      ENDIF.
      APPEND lv_text TO lt_text.

* Re-defined method
      IF methoddescr-is_redefined = abap_true.
        lv_text = 'Yes'.
      ELSE.
        lv_text = 'No'.
      ENDIF.
      APPEND lv_text TO lt_text.

* Abstract methods
      IF methoddescr-is_abstract = abap_true.
        lv_text = 'Yes'.
      ELSE.
        lv_text = 'No'.
      ENDIF.
      APPEND lv_text TO lt_text.

      io_render->add_table_row( lt_text ).

    ENDLOOP.
    io_render->end_table( ).
  ENDIF. "IF LINES( classdescr->methods ) > 0.

* Method detail ***************************************************************

  LOOP AT classdescr->methods INTO methoddescr.

** method interface ***********************************************************
    IF is_output_options-module_interfaces = abap_true.

      CONCATENATE 'Method'(002) methoddescr-name INTO lv_text SEPARATED BY space.
      io_render->add_object_subtitle( lv_text ).

** Method description
      CLEAR lt_text.
      lv_text = me->get_description_of_method( io_class_descr = classdescr
                                     iv_method_name = methoddescr-name
                                            ).
      CONCATENATE 'Description:'(006) lv_text INTO lv_text SEPARATED BY space.
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

** Method interface
      CLEAR lt_text.
      lv_text = 'Method interface'(024).
      APPEND lv_text TO lt_text.
      io_render->add_description( lt_text ).

      io_render->start_table( ).
      CLEAR lt_text.
      lv_text = 'Parameter id'(005).
      APPEND lv_text TO lt_text.
      lv_text = 'Description'(031).
      APPEND lv_text TO lt_text.
      lv_text = 'Type'(007).
      APPEND lv_text TO lt_text.
      lv_text = 'Pass value'(008).
      APPEND lv_text TO lt_text.
      lv_text = 'Optional'(009).
      APPEND lv_text TO lt_text.
      io_render->add_table_header_row( lt_text ).

      LOOP AT methoddescr-parameters ASSIGNING <ls_parameter>.

        CLEAR lt_text.

        "Parameter id
        lv_text = <ls_parameter>-name.
        APPEND lv_text TO lt_text.
        "Description
        SELECT SINGLE * INTO ls_seosubcotx FROM seosubcotx
          WHERE clsname = lv_classname
            AND cmpname = methoddescr-name
            AND sconame = <ls_parameter>-name
            AND langu = sy-langu.
        IF sy-subrc IS INITIAL.
          lv_text = ls_seosubcotx-descript.
*          SELECT SINGLE * INTO ls_seosubcodf FROM seosubcodf
*            WHERE clsname = lv_classname
*              AND cmpname = methoddescr-name
*              AND sconame = <ls_parameter>-name.
        ENDIF.
        IF lv_text IS INITIAL.
*Jelínek, 24.4.2014: Dávám "Missing" místo space
          MESSAGE i204(y00camsg_abpdoc) INTO lv_text.
        ENDIF.
        APPEND lv_text TO lt_text.
        "Type
        CASE <ls_parameter>-parm_kind.
          WHEN 'I'.
            lv_text = 'Importing'(010).
          WHEN 'E'.
            lv_text = 'Exporting'(011).
          WHEN 'C'.
            lv_text = 'Changing'(012).
          WHEN 'R'.
            lv_text = 'Returning'(013).
          WHEN OTHERS.
            break pelcm.
        ENDCASE.
        APPEND lv_text TO lt_text.
        "Pass value
        IF <ls_parameter>-by_value = abap_true.
          lv_text = 'Yes'(014).
        ELSE.
          lv_text = 'No'(015).
        ENDIF.
        APPEND lv_text TO lt_text.
        "Optional
        IF <ls_parameter>-is_optional = abap_true.
          lv_text = 'Yes'(014).
        ELSE.
          lv_text = 'No'(015).
        ENDIF.
        APPEND lv_text TO lt_text.

        io_render->add_table_row( lt_text ).

      ENDLOOP. "LOOP AT methoddescr-parameters ASSIGNING <ls_parameter>.

      io_render->end_table( ).

    ENDIF. "IF is_output_options-module_interfaces = abap_true.

    IF    methoddescr-is_inherited = abap_false
       OR methoddescr-is_redefined = abap_true.  "Opravil Jelínek, 9.5.2014 (code comments chceme pro nové a redefinované metody)

* Code comment with string '*&' ************************************************
*      lv_clskey = classproperties-clsname.
*      CALL FUNCTION 'SEO_CLASS_GET_METHOD_INCLUDES'
*        EXPORTING
*          clskey                       = lv_clskey
*        IMPORTING
*          includes                     = lt_method_include
*        EXCEPTIONS
*          _internal_class_not_existing = 1
*          OTHERS                       = 2.
*      IF sy-subrc IS NOT INITIAL.
*        MESSAGE e450(y00camsg_abpdoc) WITH gv_obj_name INTO lv_text.
*        RAISE EXCEPTION TYPE y00cacx_abapdoc
*          EXPORTING
*            textid = y00cacx_abapdoc=>error_message
*            msg = lv_text.
*      ENDIF.
      CONCATENATE lv_clskey methoddescr-name INTO lv_cpdkey RESPECTING BLANKS.
      READ TABLE lt_method_include ASSIGNING <ls_method_include> WITH KEY cpdkey = lv_cpdkey.
      IF sy-subrc IS NOT INITIAL.
        "Method not implemented
      ENDIF.

      IF <ls_method_include> IS ASSIGNED. "Method is implemented
        lv_string = <ls_method_include>-incname.
*        lt_text = get_code_comment(  lv_string  ).
        CLEAR lt_text2 .
        CALL METHOD get_code_comment
          EXPORTING
            iv_obj_name  = lv_string
            it_key_words = is_output_options-keyw_report
          RECEIVING
            rt_text      = lt_text2.

        IF NOT lt_text2[] IS INITIAL OR NOT is_output_options-print_empty_par IS INITIAL .
          CLEAR: lt_text, lv_text.
          APPEND lv_text TO lt_text.
          io_render->add_text( lt_text ).

* Heading
          CLEAR lt_text.
          lv_text = 'Code comment'(025).
          APPEND lv_text TO lt_text.
          io_render->add_description( lt_text ).

          io_render->add_comment_code( lt_text2 ).

        ENDIF .

      ENDIF.

    ENDIF. "IF classproperties-is_redefined = abap_true.

  ENDLOOP. "  LOOP AT classdescr->methods INTO methoddescr.


* Finalization
  ef_result = abap_true.

ENDMETHOD.