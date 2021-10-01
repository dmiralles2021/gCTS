METHOD GET_DATA_TYPE_DESCR.

  DATA: lv_tabname    TYPE ddobjname,
        lv_fieldname  TYPE string,
        lv_typename   TYPE dfies-fieldname,
        lt_string     TYPE stringtab,
        lv_dummy      TYPE string,
        lt_dfies      TYPE dfies_tab,
        ls_dfies      LIKE LINE OF lt_dfies.

  DATA: lr_type_descr TYPE REF TO cl_abap_typedescr,
        lr_elem_descr TYPE REF TO cl_abap_elemdescr,
        lo_cast_error TYPE REF TO cx_sy_move_cast_error.


  FIND '-' IN iv_data_type.
  IF sy-subrc EQ 0.   " dealing with structure component
    SPLIT iv_data_type AT '-' INTO: lv_tabname lv_fieldname,
                                    TABLE lt_string.
    CHECK lt_string IS NOT INITIAL. " ...

    lv_typename = lv_fieldname.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname              = lv_tabname
        fieldname            = lv_typename
*       LANGU                = SY-LANGU
      TABLES
        dfies_tab            = lt_dfies
      EXCEPTIONS
        not_found            = 1
        internal_error       = 2
        OTHERS               = 3
              .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
      RETURN.
    ENDIF.

    READ TABLE lt_dfies INTO ls_dfies INDEX 1.
    rv_descr = ls_dfies-scrtext_l.


  ELSE.
    lv_typename = iv_data_type.

*   type description
    cl_abap_typedescr=>describe_by_name( EXPORTING p_name           = lv_typename
                                         RECEIVING p_descr_ref      = lr_type_descr
                                         EXCEPTIONS type_not_found  = 1
                                                    OTHERS          = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
      RETURN.
    ENDIF.

    TRY .
        lr_elem_descr ?= lr_type_descr.
      CATCH cx_sy_move_cast_error INTO lo_cast_error.
    ENDTRY.
    CHECK lr_elem_descr IS BOUND.

*   getting type info
    lr_elem_descr->get_ddic_field( RECEIVING  p_flddescr   = ls_dfies
                                   EXCEPTIONS not_found    = 1
                                              no_ddic_type = 2
                                              OTHERS       = 3 ).
    IF sy-subrc <> 0.
      CLEAR ls_dfies .
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
*      RETURN.
    ENDIF.

*   text description to output param.
    rv_descr = ls_dfies-scrtext_l.
  ENDIF.



**   structure description
*   data lr_stru_descr TYPE REF TO cl_abap_structdescr,
*        lr_data_descr TYPE REF TO cl_abap_datadescr,
*    cl_abap_typedescr=>describe_by_name(  EXPORTING p_name          = lv_tabname
*                                          RECEIVING p_descr_ref     = lr_type_descr
*                                          EXCEPTIONS type_not_found = 1
*                                                     OTHERS         = 2 ).
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
*      RETURN.
*    ENDIF.
*
*    lr_stru_descr ?= lr_type_descr.
*    CHECK lr_stru_descr IS BOUND.
*
**   component of a structure description
*    lr_stru_descr->get_component_type(  EXPORTING   p_name                 = lv_fieldname
*                                        RECEIVING   p_descr_ref            = lr_data_descr
*                                        EXCEPTIONS  component_not_found    = 1
*                                                    unsupported_input_type = 2
*                                                    OTHERS                 = 3 ).
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4  INTO lv_dummy.
*      RETURN.
*    ENDIF.
*
**   type of the component of the structure
*    lv_typename = lr_data_descr->get_relative_name( ).
ENDMETHOD.