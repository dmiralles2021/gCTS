class Y00CACL_ABAPDOC_RENDER_S definition
  public
  final
  create public .

*"* public components of class Y00CACL_ABAPDOC_RENDER_S
*"* do not include other source files here!!!
public section.

  constants STYLE_ID_DEFAULT type STRING value 'Normln' ##NO_TEXT.
  constants STYLE_TYPE_PARAGRAPH type CHAR1 value 'P' ##NO_TEXT.
  constants STYLE_TYPE_TABLE type CHAR1 value 'T' ##NO_TEXT.
  constants STYLE_TYPE_CHARACTER type CHAR1 value 'C' ##NO_TEXT.
  constants UNIT_AUTO type CHAR1 value 'A' ##NO_TEXT.
  constants UNIT_POINT type CHAR1 value 'P' ##NO_TEXT.
  constants UNIT_PIXEL type CHAR1 value 'X' ##NO_TEXT.
  constants NUMBERING_SINGLE_LEVEL type CHAR1 value 'S' ##NO_TEXT.
  constants NUMBERING_MULTI_LEVEL type CHAR1 value 'M' ##NO_TEXT.
  constants NUMBERING_FORMAT_DECIMAL type CHAR1 value 'D' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      value(IV_DEFAULT_FONT) type STRING default 'Tahoma'
      value(IV_DEFAULT_SIZE) type I default 10
    raising
      y00cacx_docx_render_s .
  methods ADD_STYLE
    importing
      value(IV_ID) type STRING
      value(IV_TYPE) type CHAR1 default 'P'
      value(IV_NAME) type STRING optional
      value(IV_BASED_ON) type STRING optional
      value(IV_NEXT) type STRING optional
      value(IV_BOLD) type XFELD optional
      value(IV_ITALIC) type XFELD optional
      value(IV_UNDERLINED) type XFELD optional
      value(IV_COLOR) type CHAR8 optional
      value(IV_FONT) type STRING optional
      value(IV_SIZE) type I default 0
      value(IV_PRIMARY) type XFELD default 'X'
      value(IV_KEEP_NEXT) type XFELD optional
      value(IV_KEEP_LINES) type XFELD optional
      value(IV_NUMBERING_ID) type I default 0
      value(IV_NUMBERING_LEVEL) type I default 0
      value(IV_OUTLINE_LEVEL) type I default 0
      value(IV_SPACING_BEFORE) type I default -1
      value(IV_SPACING_AFTER) type I default -1
      value(IV_TABLE_INDENT) type I default 0
      value(IV_TABLE_INDENT_UNIT) type CHAR1 default 'X'
      value(IV_TABLE_BORDER_SIZE) type I optional
      value(IV_TABLE_MARGIN_LEFT) type I optional
      value(IV_TABLE_MARGIN_RIGHT) type I optional
      value(IV_TABLE_MARGIN_TOP) type I optional
      value(IV_TABLE_MARGIN_BOTTOM) type I optional
      value(IV_TABLE_MARGIN_UNIT) type CHAR1 default 'X'
    raising
      y00cacx_docx_render_s .
  methods ADD_FONT
    importing
      value(IV_NAME) type STRING
      value(IV_PANOSE1) type CHAR20 optional
      value(IV_CHARSET) type CHAR2 optional
      value(IV_FAMILY) type STRING optional
      value(IV_PITCH) type STRING optional
      value(IV_CSB0) type CHAR8 optional
      value(IV_CSB1) type CHAR8 optional
      value(IV_USB0) type CHAR8 optional
      value(IV_USB1) type CHAR8 optional
      value(IV_USB2) type CHAR8 optional
      value(IV_USB3) type CHAR8 optional
    raising
      y00cacx_docx_render_s .
  methods ADD_NUMBERING
    importing
      value(IV_MULTI_TYPE) type CHAR1 optional
    preferred parameter IV_MULTI_TYPE
    returning
      value(RV_ID) type I
    raising
      y00cacx_docx_render_s .
  methods ADD_NUMBERING_LEVEL
    importing
      value(IV_ID) type I
      value(IV_LEVEL) type I
      value(IV_START) type I optional
      value(IV_FORMAT) type CHAR1 optional
      value(IV_STYLE) type STRING optional
      value(IV_LEVEL_TEXT) type STRING optional
    raising
      y00cacx_docx_render_s .
  methods APPEND_PARAGRAPH
    importing
      value(IV_STYLE) type STRING optional
      value(IV_TEXT) type STRING optional
      value(IV_INDENT_LEFT) type I optional
    raising
      y00cacx_docx_render_s .
  methods SAVE_TO_FILE
    importing
      value(IV_TARGET_FILE_PATH) type STRING
      value(IV_ENCODING) type STRING default ''
      value(IV_LOCATION) type DXLOCATION default 'P'
    raising
      y00cacx_docx_render_s .
  methods START_TABLE
    importing
      value(IV_STYLE) type STRING optional
    raising
      y00cacx_docx_render_s .
  methods END_TABLE
    raising
      y00cacx_docx_render_s .
  methods START_TABLE_ROW
    importing
      value(IV_STYLE) type STRING optional
    raising
      y00cacx_docx_render_s .
  methods END_TABLE_ROW
    raising
      y00cacx_docx_render_s .
  methods APPEND_TABLE_CELL
    importing
      value(IV_STYLE) type STRING optional
      value(IV_TEXT) type STRING optional
    raising
      y00cacx_docx_render_s .