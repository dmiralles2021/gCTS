method GET_DESCRIPTION_OF_METHOD.
* Jelínek, 2014-04-23
* This method returns the description of a specified object method
    clear rv_description.

    CONSTANTS co_tilde_in_ifc_meth TYPE char1 VALUE '~'. "Separator in a name of a method inherited from interface
    data lo_cldes_climb type REF TO cl_abap_classdescr.

*    data methodkey         TYPE seocpdkey.
    data clsmethkey        type seocmpkey.
    data methodproperties  TYPE vseomethod.
*    data methoddescr       TYPE abap_methdescr.
    data lv_text type string.

    lo_cldes_climb = io_class_descr. "First look in the current class and then in the superclasses
    CLEAR lv_text.
    DO.
      ASSERT sy-index < 999. "Infinite cycle?
      CLEAR clsmethkey.
      IF iv_method_name CS co_tilde_in_ifc_meth. "Interface method (we'll pass the DO cycle only once)
        SPLIT iv_method_name AT co_tilde_in_ifc_meth INTO clsmethkey-clsname clsmethkey-cmpname.
      ELSE. "All other cases
        clsmethkey-clsname = lo_cldes_climb->get_relative_name( ).
        clsmethkey-cmpname = iv_method_name.
      ENDIF.
      CLEAR methodproperties.
      CALL FUNCTION 'SEO_METHOD_GET'
        EXPORTING
          mtdkey       = clsmethkey
        IMPORTING
          method       = methodproperties
        EXCEPTIONS
          not_existing = 1
          deleted      = 2
          is_event     = 3
          is_type      = 4
          is_attribute = 5
          OTHERS       = 6.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF sy-subrc <> 0.
* No need to exit
      ENDIF.
      lv_text   = methodproperties-descript.
      IF lv_text IS NOT INITIAL.
        EXIT. "Success
      elseif iv_method_name CS co_tilde_in_ifc_meth.
        exit. "We've looked directly at the interface definition - there's nothing more we can try
      ENDIF.
* Climb to the superclass
      lo_cldes_climb = cldes_to_superclass( lo_cldes_climb ).
      IF lo_cldes_climb IS INITIAL.
        EXIT. "We have reached the highest superclass
      ENDIF.
    ENDDO.

    rv_description = lv_text.

endmethod.