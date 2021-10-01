method GET_DOCUMENTATION.

  DATA: ls_dokil TYPE dokil,
        lv_title TYPE dsyst-doktitle,
        lv_head TYPE thead,
        lv_object_type TYPE string,
        lv_document_class TYPE dokil-id,
        lv_object_name TYPE string.

* Initialization
  lv_object_name = iv_obj_name.

* Object type => Document class
  IF iv_document_class IS INITIAL.

    lv_object_type = get_object_type( ).
    CASE lv_object_type.
      WHEN 'CLAS'.
        lv_document_class = 'CL'.
      WHEN 'DOMA'.
        lv_document_class = 'DO'.
      WHEN 'DTEL'.
        lv_document_class = 'DE'.
      WHEN 'FUGR'.
        lv_document_class = 'RE'. " FG documentation = FG main program
        CONCATENATE 'SAPL' lv_object_name INTO lv_object_name.
      WHEN 'PROG'.
        lv_document_class = 'RE'.
      WHEN 'TABL'.
        lv_document_class = 'TB'.
      WHEN 'TTYP'.
        lv_document_class = 'TT'.
      WHEN 'WAPA'. "BPS, it looks that it is not able to create doc. for this object
*        lv_document_class = 'TT'.
        EXIT.
      WHEN 'WDYN'. "Web dynpro, it looks that it is not able to create doc. for this object
*        lv_document_class = 'TT'.
        EXIT.
* --> ZOLDOSP (08.01.2014 14:04:29): doplnění SH ************
      WHEN 'SHLP'.
        lv_document_class = 'DH'.
      WHEN 'NROB'.
        lv_document_class = 'NR'.
* <-- konec úpravy ******************************************
    ENDCASE.

  ELSE.
    lv_document_class = iv_document_class.

  ENDIF.

* Get documentation for entered SAP object
  SELECT SINGLE *
    FROM dokil
    INTO ls_dokil
    WHERE id = lv_document_class  " e.g.'CL' = class
      AND object = lv_object_name
      AND langu = sy-langu.
  IF sy-subrc IS INITIAL.

* Return documentation for SAP object
    CALL FUNCTION 'DOCU_READ'
      EXPORTING
        id       = ls_dokil-id
        langu    = ls_dokil-langu
        object   = ls_dokil-object
        typ      = ls_dokil-typ
        version  = ls_dokil-version
      IMPORTING
        doktitle = lv_title
        head     = lv_head
      TABLES
        line     = rt_documentation. "lines

  ENDIF.

endmethod.