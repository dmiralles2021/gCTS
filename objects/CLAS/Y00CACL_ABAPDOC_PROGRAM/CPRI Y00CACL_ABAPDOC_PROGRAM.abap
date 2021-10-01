private section.
*"* private components of class Y00CACL_ABAPDOC_PROGRAM
*"* do not include other source files here!!!

  types:
    BEGIN OF ts_screen,
      program_id TYPE d020s-prog,
      screen_id TYPE d020s-dnum,
      element_id TYPE string,
      element_text TYPE string,
      type TYPE string,
    END OF ts_screen .
  types:
    tt_screen TYPE TABLE OF ts_screen WITH DEFAULT KEY .
  types:
    BEGIN OF ts_include,
          name LIKE sy-repid,
        END OF ts_include .
  types:
    tt_include TYPE TABLE OF ts_include .
  types:
    BEGIN OF ts_program_include,
          name LIKE sy-repid,
          text TYPE string,
        END OF ts_program_include .
  types:
    tt_program_include TYPE TABLE OF ts_program_include WITH DEFAULT KEY .

  constants LCO_SELECTION_OPTION type STRING value 'SO'. "#EC NOTEXT
  constants LCO_BLOCK type STRING value 'BLOCK'. "#EC NOTEXT
  constants LCO_SCREEN_DESCRIPTION type STRING value 'SCREEN_DESCR'. "#EC NOTEXT
  constants LCO_PARAMETER type STRING value 'PAR'. "#EC NOTEXT
  constants LCO_NOT_DEFINED type STRING value '-'. "#EC NOTEXT

  methods GET_PROGRAM_INCLUDES
    importing
      !IV_PROGRAM type STRING
    returning
      value(RT_PROGRAM_INCLUDE) type TT_PROGRAM_INCLUDE .
  methods GET_SCREEN
    importing
      !IV_PROGRAM type PROGNAME
    returning
      value(RT_SCREEN) type TT_SCREEN .