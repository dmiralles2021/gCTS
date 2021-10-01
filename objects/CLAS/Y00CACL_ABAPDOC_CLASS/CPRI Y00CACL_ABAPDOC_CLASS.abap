private section.
*"* private components of class Y00CACL_ABAPDOC_CLASS
*"* do not include other source files here!!!

  methods GET_DESCRIPTION_OF_METHOD
    importing
      !IO_CLASS_DESCR type ref to CL_ABAP_CLASSDESCR
      !IV_METHOD_NAME type C
    returning
      value(RV_DESCRIPTION) type SEODESCR .