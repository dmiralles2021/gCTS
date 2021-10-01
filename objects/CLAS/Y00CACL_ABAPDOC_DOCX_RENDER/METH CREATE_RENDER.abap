METHOD create_render.
*----------------------------------------------------------------------*
* Method: CREATE_RENDER
*----------------------------------------------------------------------*
* Description:
* Create and define docx render.
*----------------------------------------------------------------------*

  DATA:
    lv_nrid TYPE i,
    lv_str  TYPE string,
    lx_ex   TYPE REF TO y00cacx_docx_render_s.

  TRY.

      CREATE OBJECT ro_render
        EXPORTING
          iv_default_font = 'Calibri'
          iv_default_size = 10.


*   Add used fonts
      ro_render->add_font( 'Public Sans' ).
      ro_render->add_font( 'Tahoma' ).
      ro_render->add_font( 'Courier New' ).
      ro_render->add_font( 'Calibri' ).
*   Add numbering for chapters and objects
      lv_nrid = ro_render->add_numbering( y00cacl_abapdoc_render_s=>numbering_multi_level ).
      ro_render->add_numbering_level(
        iv_id         = lv_nrid
        iv_level      = 0
        iv_start      = 1
        iv_format     = y00cacl_abapdoc_render_s=>numbering_format_decimal
        iv_style      = style_chapter
        iv_level_text = '%1'
      ).
      ro_render->add_numbering_level(
        iv_id         = lv_nrid
        iv_level      = 1
        iv_start      = 1
        iv_format     = y00cacl_abapdoc_render_s=>numbering_format_decimal
        iv_style      = style_object
        iv_level_text = '%1.%2'
      ).
*>>-> PaM 27.01.2014 14:53:42
      ro_render->add_numbering_level(
        iv_id         = lv_nrid
        iv_level      = 2
        iv_start      = 1
        iv_format     = y00cacl_abapdoc_render_s=>numbering_format_decimal
        iv_style      = style_subobject
        iv_level_text = '%1.%2.%3'
      ).
*<-<< PaM 27.01.2014 14:53:42

*   Chapter style
      lv_str = 'Chapter'(s01).
      ro_render->add_style(
        iv_id               = style_chapter
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = y00cacl_abapdoc_render_s=>style_id_default
        iv_keep_next        = abap_true
        iv_keep_lines       = abap_true
        iv_spacing_before   = 300
        iv_numbering_id     = lv_nrid
        iv_numbering_level  = 0
        iv_outline_level    = 0
        iv_bold             = abap_true
        iv_size             = 30
      ).

*   Object style
      lv_str = 'Object'(s02).
      ro_render->add_style(
        iv_id               = style_object
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = y00cacl_abapdoc_render_s=>style_id_default
        iv_keep_next        = abap_true
        iv_keep_lines       = abap_true
        iv_spacing_before   = 300
        iv_numbering_id     = lv_nrid
        iv_numbering_level  = 1
        iv_outline_level    = 1
        iv_bold             = abap_true
        iv_size             = 26
      ).

*   Object subtitle style
      lv_str = 'Subtitle'(s07).
      ro_render->add_style(
        iv_id               = style_subobject
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = y00cacl_abapdoc_render_s=>style_id_default
        iv_keep_next        = abap_true
        iv_keep_lines       = abap_true
        iv_spacing_before   = 300
        iv_numbering_id     = lv_nrid
        iv_numbering_level  = 2
        iv_outline_level    = 2
        iv_italic           = abap_true
        iv_bold             = abap_true
        iv_size             = 24
      ).

*>>-> PaM 16.01.2014 16:59:51
*   Object subtitle style
      lv_str = 'Subtitle2'(s08).
      ro_render->add_style(
        iv_id               = style_subobject2
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = y00cacl_abapdoc_render_s=>style_id_default
        iv_keep_next        = abap_true
        iv_keep_lines       = abap_true
        iv_spacing_before   = 300
        iv_numbering_id     = lv_nrid
        iv_numbering_level  = 3
        iv_outline_level    = 3
        iv_italic           = abap_false
        iv_bold             = abap_true
        iv_size             = 22
      ).
*<-<< PaM 16.01.2014 16:59:51

* --> RK (18.02.2014 : *************************
*   Description style
      lv_str = 'Description'(s03).
      ro_render->add_style(
        iv_id               = style_description
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = style_description
        iv_color            = '595959'
        iv_italic           = abap_true
        iv_bold             = abap_true
        iv_size             = 22
      ).

*   Description style
      lv_str = 'Description 2'(s12).
      ro_render->add_style(
        iv_id               = style_description_2
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = style_description
        iv_color            = '595959'
        iv_italic           = abap_true
        iv_bold             = abap_true
        iv_underlined       = abap_true
        iv_size             = 24
      ).

*   Description style
      lv_str = 'Normal Bold'(s13).
      ro_render->add_style(
        iv_id               = style_normal_bold
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = style_normal_bold
        iv_bold             = abap_true
      ).

* <-- RK (18.02.2014 : *************************

*   Code comment style
      lv_str = 'Comment'(s04).
      ro_render->add_style(
        iv_id               = style_comment
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_next             = style_comment
        iv_italic           = abap_true
        iv_color            = '808080'
        iv_font             = 'Courier New'
        iv_size             = 20
      ).

*   Add table style
      lv_str = 'Table 1'(s05).
      ro_render->add_style(
        iv_id                 = style_table
        iv_type               = y00cacl_abapdoc_render_s=>style_type_table
        iv_name               = lv_str
        iv_primary            = space
        iv_spacing_before     = 0
        iv_spacing_after      = 0
        iv_table_indent       = 0
        iv_table_indent_unit  = y00cacl_abapdoc_render_s=>unit_pixel
        iv_table_border_size  = 4
        iv_table_margin_left  = 36
        iv_table_margin_right = 36
        iv_table_margin_unit  = y00cacl_abapdoc_render_s=>unit_pixel
      ).

*   Add table header style
      lv_str = 'Tab head'(s06).
      ro_render->add_style(
        iv_id               = style_table_header
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = style_table_header
        iv_bold             = abap_true
      ).

* --> ZOLDOSP (23.01.2014 16:30:13): *************************
*   WD Context node style
      lv_str = 'WD Context node'(s09).
      ro_render->add_style(
        iv_id               = style_wd_ctx_node
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = style_wd_ctx_node
        iv_italic           = abap_false
        iv_bold             = abap_true
        iv_spacing_before   = 0
        iv_spacing_after    = 0
        iv_size             = 16
      ).

*   WD Context ATTRIBUTE style
      lv_str = 'WD Context attr.'(s10).
      ro_render->add_style(
        iv_id               = style_wd_ctx_attr
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = style_wd_ctx_attr
        iv_italic           = abap_false
        iv_size             = 16
      ).
* <-- konec úpravy ******************************************
*>>-> PaM 27.01.2014 16:10:28
*   WD Layout item
      lv_str = 'WD Layout item.'(s11).
      ro_render->add_style(
        iv_id               = style_wd_layout_item
        iv_type             = y00cacl_abapdoc_render_s=>style_type_paragraph
        iv_name             = lv_str
        iv_based_on         = y00cacl_abapdoc_render_s=>style_id_default
        iv_next             = style_wd_layout_item
        iv_italic           = abap_false
        iv_spacing_before   = 0
        iv_spacing_after    = 0
        iv_size             = 16
      ).
*<-<< PaM 27.01.2014 16:10:28
    CATCH y00cacx_docx_render_s INTO lx_ex.

      RAISE EXCEPTION TYPE Y00CACX_ABAPDOC_RENDER
        EXPORTING
          messages = lx_ex->messages.
  ENDTRY.
ENDMETHOD.