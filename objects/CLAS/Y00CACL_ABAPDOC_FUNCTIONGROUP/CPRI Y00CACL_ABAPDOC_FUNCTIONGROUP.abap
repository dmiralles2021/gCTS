private section.
*"* private components of class Y00CACL_ABAPDOC_FUNCTIONGROUP
*"* do not include other source files here!!!

  types:
    begin of Ts_include,
            name type TRDIR-name,
         end of ts_include .
  types:
    tt_include type STANDARD TABLE OF ts_include with DEFAULT KEY .

  methods GET_INCLUDES
    importing
      !IV_FUNCTION_GROUP type TLIBT-AREA
    returning
      value(RT_INCLUDE) type TT_INCLUDE .