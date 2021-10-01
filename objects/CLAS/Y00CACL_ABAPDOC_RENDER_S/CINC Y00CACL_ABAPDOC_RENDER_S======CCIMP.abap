*&---------------------------------------------------------------------*
*& Description: Local classes implementation
*&---------------------------------------------------------------------*

* ----------------------------------------------------------------------
* Implementation of class lcl_element
* ----------------------------------------------------------------------

  CLASS lcl_element IMPLEMENTATION.

    METHOD lif_docx_element~subelement_add.

*     Append subelement
      APPEND io_element TO me->subelements.
    ENDMETHOD.                    "lif_docx_element~subelement_add

    METHOD subelements_get.

*     Return subelements
      REFRESH et_subelements.
      APPEND LINES OF me->subelements TO et_subelements.
    ENDMETHOD.                    "SUBELEMENTS_GET

    METHOD render_subelements.

      DATA:
        lo_element     TYPE REF TO if_ixml_element,
        lo_subelement  TYPE REF TO lif_docx_element.

*     Render subelements
      LOOP AT me->subelements INTO lo_subelement.

        lo_subelement->render( io_render ).
      ENDLOOP.
    ENDMETHOD.                    "render_subelements
  ENDCLASS.                    "lcl_element IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_simple_element
* ----------------------------------------------------------------------

  CLASS lcl_simple_element IMPLEMENTATION.

    METHOD constructor.

*     Call super
      super->constructor( ).

*     Save input
      me->name    = iv_name.
      me->prefix  = iv_prefix.
      me->value   = iv_value.
      APPEND LINES OF it_attributes TO me->attributes.
    ENDMETHOD.                    "constructor

    METHOD lif_docx_element~render.

      DATA:
        lx_ex TYPE REF TO cx_ood_exception.

      TRY.

*       Start element
          io_render->xml_element_start(
            iv_name       = me->name
            iv_prefix     = me->prefix
            it_attributes = me->attributes
          ).

*       Render value or subelements
          IF NOT me->value IS INITIAL.

*         Set value to element
            io_render->xml_element_value_set( me->value ).
          ELSE.

*         Call render before subelements
            me->render_before_subelements( io_render ).

*         Render subelements
            me->render_subelements( io_render ).

*         Call render after subelements
            me->render_after_subelements( io_render ).
          ENDIF.

*       End element
          io_render->xml_element_end( ).

*     Handle exceptions
        CATCH cx_ood_exception INTO lx_ex.
          RAISE EXCEPTION TYPE cx_ood_element_exception
            EXPORTING previous = lx_ex
                      msgno    = '003'.
          IF 1 = 0. MESSAGE e003. ENDIF.
*       Element render failed. See previous exception for more details.
      ENDTRY.
    ENDMETHOD.                    "lif_docx_element~render

    METHOD render_before_subelements.
*     For redefinition.
    ENDMETHOD.                    "render_before_subelements

    METHOD render_after_subelements.
*     For redefinition.
    ENDMETHOD.                    "render_after_subelements

  ENDCLASS.                    "lcl_simple_element IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_val_element
* ----------------------------------------------------------------------

  CLASS lcl_val_element IMPLEMENTATION.

    METHOD constructor.

      DATA:
        lt_attributes  TYPE ltt_xml_attribute,
        ls_attribute   TYPE lts_xml_attribute.

*     Create val attribute
      lmc_attributes_clear.
      lmc_attribute: 'val' lcl_ood_render=>ns_prefix_main iv_val.
      APPEND LINES OF it_attributes TO lt_attributes.

*     Call super
      super->constructor(
        iv_name       = iv_name
        iv_prefix     = iv_prefix
        it_attributes = lt_attributes
      ).
    ENDMETHOD.                    "constructor

  ENDCLASS.                    "lcl_val_element IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_style_element
* ----------------------------------------------------------------------

  CLASS lcl_style_element IMPLEMENTATION.

    METHOD constructor.

      DATA:
        lv_type        TYPE string,
        lt_attributes  TYPE ltt_xml_attribute,
        ls_attribute   TYPE lts_xml_attribute.

*     Style attributes
      lmc_attributes_clear.
      CASE is_style-type.
        WHEN y00cacl_abapdoc_render_s=>style_type_paragraph.
          lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main 'paragraph'.
        WHEN y00cacl_abapdoc_render_s=>style_type_table.
          lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main 'table'.
        WHEN y00cacl_abapdoc_render_s=>style_type_character.
          lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main 'character'.
      ENDCASE.
      lmc_attribute: 'styleId' lcl_ood_render=>ns_prefix_main is_style-id.
      IF iv_default EQ abap_true.
        lmc_attribute: 'default' lcl_ood_render=>ns_prefix_main '1'.
      ENDIF.

*     Call super
      super->constructor(
        iv_name       = 'style'
        iv_prefix     = lcl_ood_render=>ns_prefix_main
        it_attributes = lt_attributes
      ).

*     Save input
      me->style    = is_style.
    ENDMETHOD.                    "constructor

    METHOD render_before_subelements.

      DATA:
        lo_subelement  TYPE REF TO lcl_simple_element,
        lo_subelement2 TYPE REF TO lcl_simple_element,
        lo_subelement3 TYPE REF TO lcl_simple_element,
        lo_valelement  TYPE REF TO lcl_val_element,
        lt_attributes  TYPE ltt_xml_attribute,
        ls_attribute   TYPE lts_xml_attribute,
        lv_type        TYPE string,
        lv_str         TYPE string.

* ----------------------------------------------------------------------
* Base attributes
* ----------------------------------------------------------------------

*     Name
      IF me->style-name IS INITIAL.
        me->style-name = me->style-id.
      ENDIF.
      CREATE OBJECT lo_valelement
        EXPORTING
          iv_name   = 'name'
          iv_prefix = lcl_ood_render=>ns_prefix_main
          iv_val    = me->style-name.
      me->lif_docx_element~subelement_add( lo_valelement ).

*     Based on
      IF NOT me->style-based IS INITIAL.
        CREATE OBJECT lo_valelement
          EXPORTING
            iv_name   = 'basedOn'
            iv_prefix = lcl_ood_render=>ns_prefix_main
            iv_val    = me->style-based.
        me->lif_docx_element~subelement_add( lo_valelement ).
      ENDIF.

*     Next
      IF NOT me->style-next IS INITIAL.
        CREATE OBJECT lo_valelement
          EXPORTING
            iv_name   = 'next'
            iv_prefix = lcl_ood_render=>ns_prefix_main
            iv_val    = me->style-next.
        me->lif_docx_element~subelement_add( lo_valelement ).
      ENDIF.

*     Primary style
      IF me->style-qformat EQ abap_true.
        CREATE OBJECT lo_subelement
          EXPORTING
            iv_name   = 'qFormat'
            iv_prefix = lcl_ood_render=>ns_prefix_main.
        me->lif_docx_element~subelement_add( lo_subelement ).
      ENDIF.

* ----------------------------------------------------------------------
* Paragraph properties
* ----------------------------------------------------------------------

      IF me->ppr_initial_check( ) NE abap_true.

        CREATE OBJECT lo_subelement
          EXPORTING
            iv_name   = 'pPr'
            iv_prefix = lcl_ood_render=>ns_prefix_main.

*       Primary style
        IF me->style-ppr-keep_next EQ abap_true.
          CREATE OBJECT lo_subelement2
            EXPORTING
              iv_name   = 'keepNext'
              iv_prefix = lcl_ood_render=>ns_prefix_main.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

*       Keep lines
        IF me->style-ppr-keep_lines EQ abap_true.
          CREATE OBJECT lo_subelement2
            EXPORTING
              iv_name   = 'keepLines'
              iv_prefix = lcl_ood_render=>ns_prefix_main.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

*       Spacing
        IF me->style-ppr-spacing_before GE 0 OR
           me->style-ppr-spacing_after GE 0.

          lmc_attributes_clear.
          lmc_attribute 'lineRule' lcl_ood_render=>ns_prefix_main 'auto'.
          IF me->style-ppr-spacing_before GE 0.
            lmc_num2str me->style-ppr-spacing_before.
            lmc_attribute 'before' lcl_ood_render=>ns_prefix_main lv_str.
          ENDIF.
          IF me->style-ppr-spacing_after GE 0.
            lmc_num2str me->style-ppr-spacing_after.
            lmc_attribute 'after' lcl_ood_render=>ns_prefix_main lv_str.
          ENDIF.
          lmc_element lo_subelement2 'spacing' lcl_ood_render=>ns_prefix_main.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

*       Numberings
        IF NOT me->style-ppr-numbering_id IS INITIAL.

          CREATE OBJECT lo_subelement2
            EXPORTING
              iv_name   = 'numPr'
              iv_prefix = lcl_ood_render=>ns_prefix_main.

          lmc_num2str me->style-ppr-numbering_id.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'numId'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = lv_str.
          lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).

          IF NOT me->style-ppr-numbering_level IS INITIAL.
            lmc_num2str me->style-ppr-numbering_level.
            CREATE OBJECT lo_valelement
              EXPORTING
                iv_name   = 'ilvl'
                iv_prefix = lcl_ood_render=>ns_prefix_main
                iv_val    = lv_str.
            lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
          ENDIF.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).

*         Outline (for TOC)
          lmc_num2str me->style-ppr-outline_level.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'outlineLvl'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = lv_str.
          lo_subelement->lif_docx_element~subelement_add( lo_valelement ).
        ENDIF.

*       Add subelement
        me->lif_docx_element~subelement_add( lo_subelement ).
      ENDIF.

* ----------------------------------------------------------------------
* Table properties
* ----------------------------------------------------------------------
      IF NOT me->style-tblpr IS INITIAL.

        CREATE OBJECT lo_subelement
          EXPORTING
            iv_name   = 'tblPr'
            iv_prefix = lcl_ood_render=>ns_prefix_main.

*       Indent
        lv_type = me->tp_get( me->style-tblpr-indent_tp ).
        lmc_attributes_clear.
        lmc_attribute: 'w' lcl_ood_render=>ns_prefix_main me->style-tblpr-indent.
        lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main lv_type.
        lmc_element lo_subelement2 'tblInd' lcl_ood_render=>ns_prefix_main.
        lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).

*       Border
        IF me->style-tblpr-border_size GT 0.

          CREATE OBJECT lo_subelement2
            EXPORTING
              iv_name   = 'tblBorders'
              iv_prefix = lcl_ood_render=>ns_prefix_main.
          lmc_num2str me->style-tblpr-border_size.
          lmc_attributes_clear.
          lmc_attribute: 'sz' lcl_ood_render=>ns_prefix_main lv_str.
          lmc_attribute: 'space' lcl_ood_render=>ns_prefix_main '0'.
          lmc_attribute: 'color' lcl_ood_render=>ns_prefix_main 'auto'.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name       = 'top'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              iv_val        = 'single'
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name       = 'left'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              iv_val        = 'single'
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name       = 'bottom'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              iv_val        = 'single'
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name       = 'right'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              iv_val        = 'single'
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name       = 'insideH'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              iv_val        = 'single'
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name       = 'insideV'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              iv_val        = 'single'
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

*       Margin
        CREATE OBJECT lo_subelement2
          EXPORTING
            iv_name   = 'tblCellMar'
            iv_prefix = lcl_ood_render=>ns_prefix_main.
        lv_type = me->tp_get( me->style-tblpr-margin_tp ).
        lmc_num2str me->style-tblpr-margin_t.
        lmc_attributes_clear.
        lmc_attribute: 'w' lcl_ood_render=>ns_prefix_main lv_str.
        lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main lv_type.
        lmc_element lo_subelement3 'top' lcl_ood_render=>ns_prefix_main.
        lo_subelement2->lif_docx_element~subelement_add( lo_subelement3 ).
        lmc_num2str me->style-tblpr-margin_l.
        lmc_attributes_clear.
        lmc_attribute: 'w' lcl_ood_render=>ns_prefix_main lv_str.
        lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main lv_type.
        lmc_element lo_subelement3 'left' lcl_ood_render=>ns_prefix_main.
        lo_subelement2->lif_docx_element~subelement_add( lo_subelement3 ).
        lmc_num2str me->style-tblpr-margin_b.
        lmc_attributes_clear.
        lmc_attribute: 'w' lcl_ood_render=>ns_prefix_main lv_str.
        lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main lv_type.
        lmc_element lo_subelement3 'bottom' lcl_ood_render=>ns_prefix_main.
        lo_subelement2->lif_docx_element~subelement_add( lo_subelement3 ).
        lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        lmc_num2str me->style-tblpr-margin_r.
        lmc_attributes_clear.
        lmc_attribute: 'w' lcl_ood_render=>ns_prefix_main lv_str.
        lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main lv_type.
        lmc_element lo_subelement3 'right' lcl_ood_render=>ns_prefix_main.
        lo_subelement2->lif_docx_element~subelement_add( lo_subelement3 ).

*       Add subelement
        me->lif_docx_element~subelement_add( lo_subelement ).

      ENDIF.

* ----------------------------------------------------------------------
* Run properties
* ----------------------------------------------------------------------

      IF NOT me->style-rpr IS INITIAL.

        lmc_attributes_clear.
        lmc_element lo_subelement 'rPr' lcl_ood_render=>ns_prefix_main.

*       Bold
        IF me->style-rpr-bold EQ abap_true.
          lmc_attributes_clear.
          lmc_element lo_subelement2 'b' lcl_ood_render=>ns_prefix_main.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

*       Italic
        IF me->style-rpr-italic EQ abap_true.
          lmc_attributes_clear.
          lmc_element lo_subelement2 'i' lcl_ood_render=>ns_prefix_main.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

*       Underlined
        IF me->style-rpr-underlined EQ abap_true.
* ---> RK 18.2.2014
*          lmc_attributes_clear.
*          lmc_element lo_subelement2 'u' lcl_ood_render=>ns_prefix_main.
*          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
          lv_str = me->style-rpr-color.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'u'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = 'single'.
          lo_subelement->lif_docx_element~subelement_add( lo_valelement ).

* <--- RK 18.2.2014
        ENDIF.

*       Color
        IF NOT me->style-rpr-color IS INITIAL.
          lv_str = me->style-rpr-color.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'color'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = lv_str.
          lo_subelement->lif_docx_element~subelement_add( lo_valelement ).
        ENDIF.

*       Font
        IF NOT me->style-rpr-font IS INITIAL.
          lmc_attributes_clear.
          lmc_attribute: 'cs' lcl_ood_render=>ns_prefix_main me->style-rpr-font.
          lmc_attribute: 'hAnsi' lcl_ood_render=>ns_prefix_main me->style-rpr-font.
          lmc_attribute: 'ascii' lcl_ood_render=>ns_prefix_main me->style-rpr-font.
          lmc_element lo_subelement2 'rFonts' lcl_ood_render=>ns_prefix_main.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

*       Size
        IF NOT me->style-rpr-size IS INITIAL.
          lmc_num2str me->style-rpr-size.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'sz'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = lv_str.
          lo_subelement->lif_docx_element~subelement_add( lo_valelement ).
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'szCs'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = lv_str.
          lo_subelement->lif_docx_element~subelement_add( lo_valelement ).
        ENDIF.


*       Add subelement
        me->lif_docx_element~subelement_add( lo_subelement ).
      ENDIF.

    ENDMETHOD.                    "render_before_subelements

    METHOD tp_get.
      CASE iv_tp.
        WHEN y00cacl_abapdoc_render_s=>unit_point.
          rv_type = 'cpt'.
        WHEN y00cacl_abapdoc_render_s=>unit_pixel.
          rv_type = 'dxa'.
        WHEN OTHERS.
          rv_type = 'auto'.
      ENDCASE.
    ENDMETHOD.                    "tp_get

    METHOD ppr_initial_check.
      IF me->style-ppr-keep_next EQ abap_true OR
         me->style-ppr-keep_lines EQ abap_true OR
         NOT me->style-ppr-numbering_id IS INITIAL OR
         me->style-ppr-spacing_before GE 0 OR
         me->style-ppr-spacing_after GE 0.
        CLEAR rv_is_initial.
      ELSE.
        rv_is_initial = abap_true.
      ENDIF.
    ENDMETHOD.                    "ppr_initial_check

  ENDCLASS.                    "lcl_style_element IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_par_st_element
* ----------------------------------------------------------------------

  CLASS lcl_par_st_element IMPLEMENTATION.

    METHOD constructor.

*     Call super
      super->constructor(
        iv_name       = 'p'
        iv_prefix     = lcl_ood_render=>ns_prefix_main
      ).

*     Save input
      me->style       = iv_style.
      me->text        = iv_text.
      me->align       = iv_align.
      me->indent_left = iv_indent_left.

    ENDMETHOD.                    "constructor

    METHOD render_before_subelements.

      DATA:
        lo_subelement  TYPE REF TO lcl_simple_element,
        lo_subelement2 TYPE REF TO lcl_simple_element,
        lo_valelement  TYPE REF TO lcl_val_element,
        lt_attributes  TYPE ltt_xml_attribute,
        ls_attribute   TYPE lts_xml_attribute,
        lt_text        TYPE stringtab,
        lv_text        TYPE string.

**      Style is not obligatory!
***     Check style
**      IF me->style IS INITIAL.
**        RAISE EXCEPTION TYPE cx_ood_file_exception
**          EXPORTING msgno = '026'.
**        IF 1 = 0. MESSAGE E026. ENDIF.
***       Style is obligatory for style paragraph.
**      ENDIF.

*     Style or Alignment
      IF NOT me->style IS INITIAL OR
         NOT me->align IS INITIAL OR
         NOT me->indent_left IS INITIAL.
        lmc_attributes_clear.
        lmc_element lo_subelement 'pPr' lcl_ood_render=>ns_prefix_main.

        IF NOT me->style IS INITIAL.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'pStyle'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = me->style.

          lo_subelement->lif_docx_element~subelement_add( lo_valelement ).
        ENDIF.

        IF NOT me->align IS INITIAL.
          CREATE OBJECT lo_valelement
            EXPORTING
              iv_name   = 'jc'
              iv_prefix = lcl_ood_render=>ns_prefix_main
              iv_val    = me->align.

          lo_subelement->lif_docx_element~subelement_add( lo_valelement ).
        ENDIF.

        IF NOT me->indent_left IS INITIAL.
          lmc_attributes_clear.
          ls_attribute-name   = 'left'.
          ls_attribute-prefix = lcl_ood_render=>ns_prefix_main.
          ls_attribute-value  = me->indent_left.
          CONDENSE ls_attribute-value.
          APPEND ls_attribute TO lt_attributes.
          lmc_element lo_subelement2 'ind' lcl_ood_render=>ns_prefix_main.
          lmc_attributes_clear.

          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDIF.

        me->lif_docx_element~subelement_add( lo_subelement ).
      ENDIF.

*     Text
      IF NOT me->text IS INITIAL.
*       Split text to lines
        SPLIT me->text AT cl_abap_char_utilities=>cr_lf
             INTO TABLE lt_text.

*       Add run
        lmc_attributes_clear.
        lmc_element lo_subelement 'r' lcl_ood_render=>ns_prefix_main.
        LOOP AT lt_text INTO lv_text.

*         Add linebreak
          IF sy-tabix GT 1.
            lmc_element lo_subelement2 'br' lcl_ood_render=>ns_prefix_main.
            lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
          ENDIF.

*         Add text
          lmc_attribute 'space' lcl_ood_render=>ns_prefix_main 'preserve'.
          CREATE OBJECT lo_subelement2
            EXPORTING
              iv_name       = 't'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              iv_value      = lv_text
              it_attributes = lt_attributes.
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
        ENDLOOP.
        me->lif_docx_element~subelement_add( lo_subelement ).
      ENDIF.

    ENDMETHOD.                    "render_before_subelements
  ENDCLASS.                    "lcl_par_st_element IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_table_element
* ----------------------------------------------------------------------

  CLASS lcl_table_element IMPLEMENTATION.

    METHOD constructor.

*     Call super
      super->constructor(
        iv_name       = 'tbl'
        iv_prefix     = lcl_ood_render=>ns_prefix_main
      ).

*     Save input
      me->style    = iv_style.
    ENDMETHOD.                    "constructor

    METHOD row_add.

      DATA:
        ls_row  TYPE lts_docx_table_row.

*     Check for tast row
      me->last_row_check( ).

*     Add new row
      ls_row-style = iv_style.
      APPEND ls_row TO me->rows.

    ENDMETHOD.                    "row_add

    METHOD cell_add.

      DATA:
        ls_row  TYPE lts_docx_table_row,
        ls_cell TYPE lts_docx_table_cell,
        lv_i    TYPE i,
        lv_str  TYPE string.

*     Check cells per row
      IF NOT me->cells_per_row IS INITIAL.

        DESCRIBE TABLE me->rows LINES ls_cell-row.
        LOOP AT me->cells INTO ls_cell
          WHERE row EQ ls_cell-row.

          ADD 1 TO lv_i.
        ENDLOOP.
        IF lv_i GE me->cells_per_row.
          lv_str = me->cells_per_row.
          RAISE EXCEPTION TYPE cx_ood_element_exception
            EXPORTING msgno = '030' msgv1 = lv_str.
          IF 1 = 0. MESSAGE e030 WITH me->cells_per_row. ENDIF.
*         Can't define new cell as table have only &1 cells per row.
        ENDIF.
      ELSE.

*       This is first row
        ls_cell-row = 1.
      ENDIF.

*     Add new cell
      ls_cell-style = iv_style.
      ls_cell-text  = iv_text.
      APPEND ls_cell TO me->cells.
    ENDMETHOD.                    "cell_add

    METHOD render_before_subelements.

      DATA:
        lo_subelement  TYPE REF TO lcl_simple_element,
        lo_subelement2 TYPE REF TO lcl_simple_element,
        lo_valelement  TYPE REF TO lcl_val_element,
        lo_paragraph   TYPE REF TO lcl_par_st_element,
        lt_attributes  TYPE ltt_xml_attribute,
        ls_attribute   TYPE lts_xml_attribute,
        ls_row         TYPE lts_docx_table_row,
        ls_cell        TYPE lts_docx_table_cell,
        lv_style       TYPE string,
        lv_row         TYPE i.

*     Check table have content
      IF me->rows IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_element_exception
          EXPORTING msgno = '031'.
        IF 1 = 0. MESSAGE e031. ENDIF.
*       Can't render an empty table.
      ENDIF.

*     Check last row added successfully
      me->last_row_check( ).

* ----------------------------------------------------------------------
* Table properties
* ----------------------------------------------------------------------

      lmc_attributes_clear.
      lmc_element lo_subelement 'tblPr' lcl_ood_render=>ns_prefix_main.

*     Table style
      IF NOT me->style IS INITIAL.

        CREATE OBJECT lo_valelement
          EXPORTING
            iv_name   = 'tblStyle'
            iv_prefix = lcl_ood_render=>ns_prefix_main
            iv_val    = me->style.
        lo_subelement->lif_docx_element~subelement_add( lo_valelement ).
      ENDIF.

*     Table width
      lmc_attributes_clear.
      lmc_attribute 'w' lcl_ood_render=>ns_prefix_main '0'.
      lmc_attribute 'type' lcl_ood_render=>ns_prefix_main 'auto'.
      lmc_element lo_subelement2 'tblW' lcl_ood_render=>ns_prefix_main.
      lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).

      me->lif_docx_element~subelement_add( lo_subelement ).

* ----------------------------------------------------------------------
* Table structure
* ----------------------------------------------------------------------

*     Loop trough rows
      LOOP AT me->rows INTO ls_row.

        lv_row = sy-tabix.

*       Row element
        lmc_attributes_clear.
        lmc_element lo_subelement 'tr' lcl_ood_render=>ns_prefix_main.

*       Loop row cells
        LOOP AT me->cells INTO ls_cell WHERE row EQ lv_row.

*         Cell element
          lmc_element lo_subelement2 'tc' lcl_ood_render=>ns_prefix_main.

*         Determine style
          IF NOT ls_cell-style IS INITIAL.
            lv_style = ls_cell-style.
          ELSE.
            lv_style = ls_row-style.
          ENDIF.

*         Cell paragraph
          CREATE OBJECT lo_paragraph
            EXPORTING
              iv_style = lv_style
              iv_text  = ls_cell-text.

          lo_subelement2->lif_docx_element~subelement_add( lo_paragraph ).
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).

        ENDLOOP.

        me->lif_docx_element~subelement_add( lo_subelement ).
      ENDLOOP.

    ENDMETHOD.                    "render_before_subelements

    METHOD last_row_check.

      DATA:
        ls_cell TYPE lts_docx_table_cell,
        lv_i    TYPE i,
        lv_str  TYPE string.

*     Check for tast row
      DESCRIBE TABLE me->rows LINES sy-tfill.
      IF sy-tfill EQ 1.

*       Set number of cells per row
        DESCRIBE TABLE me->cells LINES me->cells_per_row.
        IF me->cells_per_row IS INITIAL.
          RAISE EXCEPTION TYPE cx_ood_element_exception
              EXPORTING msgno = '032'.
          IF 1 = 0. MESSAGE e032. ENDIF.
*           Table row can't be empty.
        ENDIF.
      ELSEIF sy-tfill GT 1.

*       Check number of cells in last row
        LOOP AT me->cells INTO ls_cell
          WHERE row EQ sy-tfill.

          ADD 1 TO lv_i.
        ENDLOOP.
        IF lv_i NE me->cells_per_row.
          lv_str = me->cells_per_row.
          RAISE EXCEPTION TYPE cx_ood_element_exception
            EXPORTING msgno = '029' msgv1 = lv_str.
          IF 1 = 0. MESSAGE e029 WITH me->cells_per_row. ENDIF.
*         Can't start row before previous have not &1 cells defined.
        ENDIF.
      ENDIF.
    ENDMETHOD.                    "last_row_check
  ENDCLASS.                    "lcl_table_element IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_file
* ----------------------------------------------------------------------

  CLASS lcl_file IMPLEMENTATION.

    METHOD file_path_split.

      DATA:
        lv_str   TYPE string,
        lt_split TYPE stringtab.

*     Just get everything before last slash
      IF iv_file_path CS '/'.
        SPLIT iv_file_path AT '/' INTO TABLE lt_split.
        DESCRIBE TABLE lt_split LINES sy-tfill.
        LOOP AT lt_split INTO lv_str.
          IF sy-tabix NE sy-tfill.
            CONCATENATE ev_file_path lv_str '/' INTO ev_file_path.
          ELSE.
            ev_file_name = lv_str.
          ENDIF.
        ENDLOOP.
      ELSE.
        ev_file_name = iv_file_path.
      ENDIF.
    ENDMETHOD.                    "file_path_split

    METHOD lif_docx_file~global_namespace_get.
*     Default is empty
    ENDMETHOD.                    "lif_docx_file~global_namespace_get

    METHOD lif_docx_file~relation_id_set.
      me->relation_id = iv_relation_id.
    ENDMETHOD.                    "lif_docx_file~relation_id_set

    METHOD lif_docx_file~render.

      DATA:
        lo_root     TYPE REF TO lif_docx_element,
        lx_ex       TYPE REF TO cx_ood_exception.

*     Get root
      lo_root = me->root_get( ).
      IF lo_root IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_file_exception
          EXPORTING msgno = '001'.
        IF 1 = 0. MESSAGE e001. ENDIF.
*       Unable to render archive file because missing root element.
      ENDIF.

      TRY.

*       Start document
          io_render->xml_document_start( me ).

*       Render root
          lo_root->render( io_render ).

*       End document
          io_render->xml_document_end( ).

*     Process exceptions
        CATCH cx_ood_exception INTO lx_ex.

          RAISE EXCEPTION TYPE cx_ood_file_exception
            EXPORTING previous = lx_ex
                      msgno    = '002'.
          IF 1 = 0. MESSAGE e002. ENDIF.
*       Archive file render failed. See previous exception for more details.
      ENDTRY.
    ENDMETHOD.                    "lif_docx_file~render

    METHOD lif_docx_file~custom_extension_get.
*     Custom extension is emty by default
    ENDMETHOD. "lif_docx_file~custom_extension_get

    METHOD relation_id_get.
      rv_relation_id = me->relation_id.
    ENDMETHOD.                    "relation_id_get

    METHOD root_set.
      me->root = io_root.
    ENDMETHOD.                    "root_set

    METHOD root_get.
      ro_root = me->root.
    ENDMETHOD.                    "root_get
  ENDCLASS.                    "lcl_file IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_content_types_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_content_types_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.
      rv_file_name = '[Content_Types].xml'.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.
      rv_file_path = '[Content_Types].xml'.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~global_namespace_get.
      rv_global_namespace = 'http://schemas.openxmlformats.org/package/2006/content-types'.
    ENDMETHOD.                    "lif_docx_file~global_namespace_get

    METHOD lif_docx_file~content_type_get.
*     Content types does not have conten type.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
*     Content types does not need to register relation.
    ENDMETHOD.                    "lif_docx_file~relation_register

    METHOD lif_docx_file~render.

      DATA:
        lo_root         TYPE REF TO lcl_simple_element,
        lo_subelement   TYPE REF TO lcl_simple_element,
        lt_attributes   TYPE ltt_xml_attribute,
        ls_attribute    TYPE lts_xml_attribute,
        ls_content_type TYPE lts_content_type,
        lx_ex           TYPE REF TO cx_ood_exception.

      TRY.
*       Create root element
          CREATE OBJECT lo_root
            EXPORTING
              iv_name = 'Types'.
          me->root_set( lo_root ).

*       Create default subelements
          lmc_attributes_clear.
          lmc_attribute: 'ContentType' ''
          'application/vnd.openxmlformats-package.relationships+xml',
                         'Extension'  '' 'rels'.
          CREATE OBJECT lo_subelement
            EXPORTING
              iv_name       = 'Default'
              iv_prefix     = ''
              it_attributes = lt_attributes.
          lo_root->lif_docx_element~subelement_add( lo_subelement ).
          lmc_attributes_clear.
          lmc_attribute: 'ContentType' '' 'application/xml',
                         'Extension'  '' 'xml'.
          CREATE OBJECT lo_subelement
            EXPORTING
              iv_name       = 'Default'
              iv_prefix     = ''
              it_attributes = lt_attributes.
          lo_root->lif_docx_element~subelement_add( lo_subelement ).

*       Create subelements for each content type
          LOOP AT me->content_types INTO ls_content_type.
            lmc_attributes_clear.
            lmc_attribute: 'ContentType' ''
                           ls_content_type-content_type,
                           'PartName'    ''
                           ls_content_type-part_name.
            CREATE OBJECT lo_subelement
              EXPORTING
                iv_name       = 'Override'
                iv_prefix     = ''
                it_attributes = lt_attributes.
            lo_root->lif_docx_element~subelement_add( lo_subelement ).
          ENDLOOP.
*       Call super
          super->lif_docx_file~render( io_render ).

*     Handle exceptions
        CATCH cx_ood_exception INTO lx_ex.

          RAISE EXCEPTION TYPE cx_ood_file_exception
            EXPORTING previous = lx_ex
                      msgno    = '005'.
          IF 1 = 0. MESSAGE e005. ENDIF.
*       Content types render failed. See previous exception for more details.
      ENDTRY.

    ENDMETHOD.                    "lif_docx_file~render

    METHOD content_type_add.

      DATA:
        lv_part_name    TYPE string,
        ls_content_type TYPE lts_content_type.

*     Add leading slash
      CONCATENATE '/' iv_part_name INTO lv_part_name.

*     Check for existence
      READ TABLE me->content_types INTO ls_content_type
          WITH KEY part_name = lv_part_name.
      IF sy-subrc IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_file_exception
          EXPORTING msgno    = '004'
                    msgv1    = iv_part_name.
        IF 1 = 0. MESSAGE e004 WITH iv_part_name. ENDIF.
*       Content type with part name &1 already added.
      ENDIF.

*     Add content type
      ls_content_type-content_type = iv_content_type.
      ls_content_type-part_name    = lv_part_name.
      APPEND ls_content_type TO me->content_types.
    ENDMETHOD.                    "content_type_add

  ENDCLASS.                    "lcl_ood_content_types_file IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_relations_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_relations_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.

*     Relations file is named after relation file
      lcl_file=>file_path_split(
        EXPORTING
          iv_file_path = me->relations_file
        IMPORTING
          ev_file_name = rv_file_name
      ).
      CONCATENATE rv_file_name '.rels' INTO rv_file_name.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.

      DATA:
        lv_file_name TYPE string.

*     Relations path depends on relation file (same folder)
      lcl_file=>file_path_split(
        EXPORTING
          iv_file_path = me->relations_file
        IMPORTING
          ev_file_name = lv_file_name
          ev_file_path = rv_file_path
      ).
      CONCATENATE rv_file_path '_rels/' lv_file_name '.rels' INTO rv_file_path.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~global_namespace_get.
      rv_global_namespace = 'http://schemas.openxmlformats.org/package/2006/relationships'.
    ENDMETHOD.                    "lif_docx_file~global_namespace_get

    METHOD lif_docx_file~content_type_get.
*     Relations does not have conten type.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
*     Relations does not need to register relation.
    ENDMETHOD.                    "lif_docx_file~relation_register

    METHOD lif_docx_file~render.

      DATA:
        lo_root         TYPE REF TO lcl_simple_element,
        lo_subelement   TYPE REF TO lcl_simple_element,
        lt_attributes   TYPE ltt_xml_attribute,
        ls_attribute    TYPE lts_xml_attribute,
        ls_relation     TYPE lts_relation,
        lx_ex           TYPE REF TO cx_ood_exception.

      TRY.
*       Create root element
          CREATE OBJECT lo_root
            EXPORTING
              iv_name = 'Relationships'.
          me->root_set( lo_root ).

*       Create subelements for each relation
          LOOP AT me->relations INTO ls_relation.
            lmc_attributes_clear.
            lmc_attribute: 'Id'     '' ls_relation-id,
                           'Type'   '' ls_relation-type,
                           'Target' '' ls_relation-target.
            CREATE OBJECT lo_subelement
              EXPORTING
                iv_name       = 'Relationship'
                iv_prefix     = ''
                it_attributes = lt_attributes.
            lo_root->lif_docx_element~subelement_add( lo_subelement ).
          ENDLOOP.

*       Call super
          super->lif_docx_file~render( io_render ).

*     Handle exceptions
        CATCH cx_ood_exception INTO lx_ex.

          RAISE EXCEPTION TYPE cx_ood_file_exception
            EXPORTING previous = lx_ex
                      msgno    = '007'.
          IF 1 = 0. MESSAGE e007. ENDIF.
*       Relations render failed. See previous exception for more details.
      ENDTRY.

    ENDMETHOD.                    "lif_docx_file~render

    METHOD constructor.

*     Call super
      super->constructor( ).

*     Set my values
      me->relations_file = iv_relations_file.
    ENDMETHOD.                    "constructor

    METHOD relation_register.

      DATA:
        lv_target_name    TYPE string,
        lv_target_path    TYPE string,
        lv_ref_file_name  TYPE string,
        lv_ref_file_path  TYPE string,
        ls_relation     TYPE lts_relation.

*     Process target path
      lcl_file=>file_path_split(
        EXPORTING
          iv_file_path = iv_target
        IMPORTING
          ev_file_path = lv_target_path
          ev_file_name = lv_target_name
      ).
      lcl_file=>file_path_split(
        EXPORTING
          iv_file_path = me->relations_file
        IMPORTING
          ev_file_path = lv_ref_file_path
      ).

*     Check if target is in same directory
      IF lv_ref_file_path EQ lv_target_path.

*       Target to name only
        lv_target_path = lv_target_name.
      ELSE.

*       Target to path
        lv_target_path = iv_target.
      ENDIF.

*     Check for existence
      READ TABLE me->relations INTO ls_relation
          WITH KEY target = lv_target_path.
      IF sy-subrc IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_file_exception
          EXPORTING msgno    = '006'
                    msgv1    = iv_target
                    msgv2    = me->relations_file
                    msgv3    = ls_relation-id.
        IF 1 = 0. MESSAGE e006 WITH iv_target me->relations_file ls_relation-id. ENDIF.
*       Relation &1 for &2 already registered with id &3.
      ENDIF.

*     Add relation
      ls_relation-id = me->counter.
      CONCATENATE 'rId' ls_relation-id INTO ls_relation-id.
      CONDENSE ls_relation-id NO-GAPS.
      ls_relation-type   = iv_type.
      ls_relation-target = lv_target_path.
      APPEND ls_relation TO me->relations.

*     Increase counter and return ID
      ADD 1 TO me->counter.
      rv_id = ls_relation-id.
    ENDMETHOD.                    "relation_register

    METHOD relations_file_get.
      rv_relations_file = me->relations_file.
    ENDMETHOD.                    "relations_file_get

  ENDCLASS.                    "lcl_ood_relations_file IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_styles_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_styles_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.
      rv_file_name = 'styles.xml'.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.
      rv_file_path = 'word/styles.xml'.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~content_type_get.
      rv_content_type =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml'.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
      ev_relation_file = 'word/document.xml'.
      ev_relation_type = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles'.
    ENDMETHOD.                    "lif_docx_file~relation_register

    METHOD lif_docx_file~render.

      DATA:
        lo_root         TYPE REF TO lcl_simple_element,
        lo_subelement   TYPE REF TO lcl_simple_element,
        lo_subelement2  TYPE REF TO lcl_simple_element,
        lo_subelement3  TYPE REF TO lcl_simple_element,
        lo_style        TYPE REF TO lcl_style_element,
        ls_style        TYPE lts_docx_style,
        lt_attributes   TYPE ltt_xml_attribute,
        ls_attribute    TYPE lts_xml_attribute,
        lv_default      TYPE xfeld,
        lx_ex           TYPE REF TO cx_ood_exception.

*     Check styles consistency
      me->consistency_check( ).

      TRY.

*       Create root element
          CREATE OBJECT lo_root
            EXPORTING
              iv_name   = 'styles'
              iv_prefix = lcl_ood_render=>ns_prefix_main.
          me->root_set( lo_root ).

* ----------------------------------------------------------------------
* Document defaults
* ----------------------------------------------------------------------

*       Document defaults
          CREATE OBJECT lo_subelement
            EXPORTING
              iv_name   = 'docDefaults'
              iv_prefix = lcl_ood_render=>ns_prefix_main.

*       Run properties defaults
          CREATE OBJECT lo_subelement2
            EXPORTING
              iv_name   = 'rPrDefault'
              iv_prefix = lcl_ood_render=>ns_prefix_main.

*       Font
          lmc_attributes_clear.
          lmc_attribute: 'ascii' lcl_ood_render=>ns_prefix_main me->default_font,
                         'hAnsi' lcl_ood_render=>ns_prefix_main me->default_font,
                         'cs'    lcl_ood_render=>ns_prefix_main me->default_font.
          CREATE OBJECT lo_subelement3
            EXPORTING
              iv_name       = 'rFonts'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_subelement3 ).
*       Size
          lmc_attributes_clear.
          lmc_attribute: 'val' lcl_ood_render=>ns_prefix_main me->default_size.
          CREATE OBJECT lo_subelement3
            EXPORTING
              iv_name       = 'sz'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_subelement3 ).
          CREATE OBJECT lo_subelement3
            EXPORTING
              iv_name       = 'szCs'
              iv_prefix     = lcl_ood_render=>ns_prefix_main
              it_attributes = lt_attributes.
          lo_subelement2->lif_docx_element~subelement_add( lo_subelement3 ).
          lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
          lo_root->lif_docx_element~subelement_add( lo_subelement ).

*       Add styles
          LOOP AT me->styles INTO ls_style.

            IF sy-tabix = 1.
              lv_default = abap_true.
            ELSE.
              lv_default = abap_false.
            ENDIF.

            CREATE OBJECT lo_style
              EXPORTING
                is_style = ls_style.
            lo_root->lif_docx_element~subelement_add( lo_style ).
          ENDLOOP.

*       Call super
          super->lif_docx_file~render( io_render ).

*     Handle exceptions
        CATCH cx_ood_exception INTO lx_ex.

          RAISE EXCEPTION TYPE cx_ood_file_exception
            EXPORTING previous = lx_ex
                      msgno    = '017'.
          IF 1 = 0. MESSAGE e017. ENDIF.
*       Styles render failed. See previous exceptions for more details.
      ENDTRY.

    ENDMETHOD.                    "lif_docx_file~render

    METHOD constructor.

      DATA:
        ls_style TYPE lts_docx_style.

*     Call super
      super->constructor( ).

*     Set my values
      me->default_font = iv_default_font.
      me->default_size = iv_default_size.

*     Add root style
      ls_style-id                 = y00cacl_abapdoc_render_s=>style_id_default.
      ls_style-type               = y00cacl_abapdoc_render_s=>style_type_paragraph.
      ls_style-name               = 'Normal'.
      ls_style-qformat            = abap_true.
      ls_style-ppr-spacing_before = -1.
      ls_style-ppr-spacing_after  = -1.
      APPEND ls_style TO me->styles.
    ENDMETHOD.                    "constructor

    METHOD style_add.

*     Check for existence
      READ TABLE me->styles TRANSPORTING NO FIELDS
          WITH KEY id = is_style-id.
      IF sy-subrc IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_file_exception
          EXPORTING msgno    = '016'
                    msgv1    = is_style-id.
        IF 1 = 0. MESSAGE e016 WITH is_style-id. ENDIF.
*       Style &1 already defined.
      ENDIF.

*     Add style
      APPEND is_style TO me->styles.

    ENDMETHOD.                    "style_add

    METHOD consistency_check.

      DATA:
        ls_style TYPE lts_docx_style,
        lv_str   TYPE string.

*     Check default
      IF me->default_font IS INITIAL OR me->default_size IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_file_exception
          EXPORTING msgno    = '018'.
        IF 1 = 0. MESSAGE e018. ENDIF.
*       Default font is not correctly defined.
      ENDIF.

*     Check all styles
      LOOP AT me->styles INTO ls_style.

*       Don't check default
        IF sy-tabix EQ 1.
          CONTINUE.
        ENDIF.

*       Check based
        IF NOT ls_style-based IS INITIAL.

          READ TABLE me->styles TRANSPORTING NO FIELDS
              WITH KEY id = ls_style-based.
          IF NOT sy-subrc IS INITIAL.
            RAISE EXCEPTION TYPE cx_ood_file_exception
              EXPORTING msgno    = '019' msgv1 = ls_style-id
                        msgv2 = ls_style-based.
            IF 1 = 0. MESSAGE e019 WITH ls_style-id ls_style-based. ENDIF.
*           Style &1 is based on unknown style &2.
          ENDIF.
        ENDIF.

*       Check next
        IF NOT ls_style-next IS INITIAL.

          READ TABLE me->styles TRANSPORTING NO FIELDS
              WITH KEY id = ls_style-next.
          IF NOT sy-subrc IS INITIAL.
            RAISE EXCEPTION TYPE cx_ood_file_exception
              EXPORTING msgno    = '020' msgv1 = ls_style-id
                        msgv2 = ls_style-next.
            IF 1 = 0. MESSAGE e020 WITH ls_style-id ls_style-next. ENDIF.
*           Style &1 have set unknown next style &2.
          ENDIF.
        ENDIF.

*       Check type
        CASE ls_style-type.
          WHEN y00cacl_abapdoc_render_s=>style_type_paragraph
            OR y00cacl_abapdoc_render_s=>style_type_character.

*           Check not table properties defined
            IF NOT ls_style-tblpr IS INITIAL.
              lv_str = ls_style-type.
              RAISE EXCEPTION TYPE cx_ood_file_exception
              EXPORTING msgno    = '021' msgv1 = ls_style-id
                        msgv2 = lv_str.
              IF 1 = 0. MESSAGE e021 WITH ls_style-id ls_style-type. ENDIF.
*             Style &1 is type &2 which can't have table properties defined.
            ENDIF.

          WHEN y00cacl_abapdoc_render_s=>style_type_table.

*           Nothing to check

          WHEN OTHERS.

            lv_str = ls_style-type.
            RAISE EXCEPTION TYPE cx_ood_file_exception
              EXPORTING msgno    = '022' msgv1 = ls_style-id
                        msgv2 = lv_str.
            IF 1 = 0. MESSAGE e022 WITH ls_style-id ls_style-type. ENDIF.
*           Style &1 is type &2 which is unknown.
        ENDCASE.
      ENDLOOP.

    ENDMETHOD.                    "consistency_check

  ENDCLASS.                    "lcl_ood_styles_file IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_numberings_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_numberings_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.
      rv_file_name = 'numbering.xml'.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.
      rv_file_path = 'word/numbering.xml'.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~content_type_get.
      rv_content_type =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml'.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
      ev_relation_file = 'word/document.xml'.
      ev_relation_type = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering'.
    ENDMETHOD.                    "lif_docx_file~relation_register

    METHOD lif_docx_file~render.

      DATA:
        ls_numbering    TYPE lts_docx_numbering,
        ls_level        TYPE lts_docx_numbering_level,
        lo_root         TYPE REF TO lcl_simple_element,
        lo_subelement   TYPE REF TO lcl_simple_element,
        lo_subelement2  TYPE REF TO lcl_simple_element,
        lo_valelement   TYPE REF TO lcl_val_element,
        lt_attributes   TYPE ltt_xml_attribute,
        ls_attribute    TYPE lts_xml_attribute,
        lv_str          TYPE string,
        lv_str2         TYPE string,
        lx_ex           TYPE REF TO cx_ood_exception.

*     Check styles consistency
      me->consistency_check( ).

      TRY.

*       Create root element
          CREATE OBJECT lo_root
            EXPORTING
              iv_name   = 'numbering'
              iv_prefix = lcl_ood_render=>ns_prefix_main.
          me->root_set( lo_root ).

* ----------------------------------------------------------------------
* Abstract
* ----------------------------------------------------------------------

          LOOP AT me->numberings INTO ls_numbering
            WHERE NOT multi_type IS INITIAL.

*         Abstract element
            lmc_num2str ls_numbering-abstract_id.
            lmc_attributes_clear.
            lmc_attribute 'abstractNumId' lcl_ood_render=>ns_prefix_main lv_str.
            lmc_element lo_subelement 'abstractNum' lcl_ood_render=>ns_prefix_main.

*         Multitype
            CASE ls_numbering-multi_type.
              WHEN y00cacl_abapdoc_render_s=>numbering_single_level.
                lv_str = 'singleLevel'.
              WHEN y00cacl_abapdoc_render_s=>numbering_multi_level.
                lv_str = 'multilevel'.
              WHEN OTHERS.
                lmc_num2str ls_numbering-id.
                lv_str2 = ls_numbering-multi_type.
                RAISE EXCEPTION TYPE cx_ood_file_exception
                  EXPORTING msgno    = '045'
                            msgv1    = lv_str msgv2 = lv_str2.
                IF 1 = 0. MESSAGE e045 WITH ls_numbering-id ls_numbering-multi_type. ENDIF.
*             Numbering &1 multilevel type &2 is unknown.
            ENDCASE.
            lmc_attributes_clear.
            CREATE OBJECT lo_valelement
              EXPORTING
                iv_name   = 'multiLevelType'
                iv_prefix = lcl_ood_render=>ns_prefix_main
                iv_val    = lv_str.
            lo_subelement->lif_docx_element~subelement_add( lo_valelement ).

*         Levels
            LOOP AT me->levels INTO ls_level
                WHERE id EQ ls_numbering-id.

*           Level
              lmc_num2str ls_level-level.
              lmc_attributes_clear.
              lmc_attribute 'ilvl' lcl_ood_render=>ns_prefix_main lv_str.
              lmc_element lo_subelement2 'lvl' lcl_ood_render=>ns_prefix_main.

*           Start
              IF ls_level-format EQ y00cacl_abapdoc_render_s=>numbering_format_decimal.
                lmc_num2str ls_level-start.
                lmc_attributes_clear.
                CREATE OBJECT lo_valelement
                  EXPORTING
                    iv_name   = 'start'
                    iv_prefix = lcl_ood_render=>ns_prefix_main
                    iv_val    = lv_str.
                lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
              ENDIF.

*           Format
              CASE ls_level-format.
                WHEN y00cacl_abapdoc_render_s=>numbering_format_decimal.
                  lv_str = 'decimal'.
                WHEN OTHERS.
                  lmc_num2str ls_numbering-id.
                  lv_str2 = ls_level-format.
                  RAISE EXCEPTION TYPE cx_ood_file_exception
                    EXPORTING msgno    = '046'
                              msgv1    = lv_str msgv2 = lv_str2.
                  IF 1 = 0. MESSAGE e046 WITH ls_numbering-id ls_level-format. ENDIF.
*               Numbering &1 format &2 is unknown.
              ENDCASE.
              lmc_attributes_clear.
              CREATE OBJECT lo_valelement
                EXPORTING
                  iv_name   = 'numFmt'
                  iv_prefix = lcl_ood_render=>ns_prefix_main
                  iv_val    = lv_str.
              lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).

*           Style
              IF NOT ls_level-style IS INITIAL.
                lmc_attributes_clear.
                CREATE OBJECT lo_valelement
                  EXPORTING
                    iv_name   = 'pStyle'
                    iv_prefix = lcl_ood_render=>ns_prefix_main
                    iv_val    = ls_level-style.
                lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
              ENDIF.

*           Level text
              IF NOT ls_level-level_text IS INITIAL.
                lmc_attributes_clear.
                CREATE OBJECT lo_valelement
                  EXPORTING
                    iv_name   = 'lvlText'
                    iv_prefix = lcl_ood_render=>ns_prefix_main
                    iv_val    = ls_level-level_text.
                lo_subelement2->lif_docx_element~subelement_add( lo_valelement ).
              ENDIF.

              lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).
            ENDLOOP.

            lo_root->lif_docx_element~subelement_add( lo_subelement ).
          ENDLOOP.

* ----------------------------------------------------------------------
* Numberings
* ----------------------------------------------------------------------

          LOOP AT me->numberings INTO ls_numbering.

*         Numbering element
            lmc_num2str ls_numbering-id.
            lmc_attributes_clear.
            lmc_attribute 'numId' lcl_ood_render=>ns_prefix_main lv_str.
            lmc_element lo_subelement 'num' lcl_ood_render=>ns_prefix_main.

*         Abstract reference
            lmc_num2str ls_numbering-abstract_id.
            lmc_attributes_clear.
            CREATE OBJECT lo_valelement
              EXPORTING
                iv_name   = 'abstractNumId'
                iv_prefix = lcl_ood_render=>ns_prefix_main
                iv_val    = lv_str.
            lo_subelement->lif_docx_element~subelement_add( lo_valelement ).

            lo_root->lif_docx_element~subelement_add( lo_subelement ).
          ENDLOOP.

*       Call super
          super->lif_docx_file~render( io_render ).

*     Handle exceptions
        CATCH cx_ood_exception INTO lx_ex.

          RAISE EXCEPTION TYPE cx_ood_file_exception
            EXPORTING previous = lx_ex
                      msgno    = '041'.
          IF 1 = 0. MESSAGE e041. ENDIF.
*       Numberings render failed. See previous exceptions for more details.
      ENDTRY.

    ENDMETHOD.                    "lif_docx_file~render

    METHOD numbering_add.

      DATA:
        ls_numbering TYPE lts_docx_numbering.

      MOVE is_numbering TO ls_numbering.
*     Create ID
      ls_numbering-abstract_id = me->ids_counter.
      ADD 1 TO me->ids_counter.
      ls_numbering-id = me->ids_counter.

*     Add numbering
      APPEND ls_numbering TO me->numberings.

      rv_id = ls_numbering-id.

    ENDMETHOD.                    "numbering_add

    METHOD numbering_level_add.

      DATA:
        lv_str  TYPE string,
        lv_str2 TYPE string.

*     Check for existence
      READ TABLE me->levels TRANSPORTING NO FIELDS
          WITH KEY id    = is_numbering_level-id
                   level = is_numbering_level-level.
      IF sy-subrc IS INITIAL.
        lmc_num2str is_numbering_level-level.
        lv_str2 = lv_str.
        lmc_num2str is_numbering_level-id.
        RAISE EXCEPTION TYPE cx_ood_file_exception
          EXPORTING msgno    = '042'
                    msgv1    = lv_str msgv2 = lv_str2.
        IF 1 = 0. MESSAGE e042 WITH is_numbering_level-id is_numbering_level-level. ENDIF.
*       Level &1 for numbering &2 already defined.
      ENDIF.

*     Add style
      APPEND is_numbering_level TO me->levels.

    ENDMETHOD.                    "numbering_level_add

    METHOD consistency_check.

      DATA:
        ls_numbering TYPE lts_docx_numbering,
        ls_level     TYPE lts_docx_numbering_level,
        lv_level     TYPE i,
        lv_id        TYPE i,
        lv_str       TYPE string,
        lv_str2      TYPE string,
        lv_str3      TYPE string.

*     Check numbering levels
      SORT me->levels BY id level.
      LOOP AT me->numberings INTO ls_numbering
          WHERE NOT multi_type IS INITIAL.

        lv_level = 0.
        LOOP AT me->levels INTO ls_level WHERE id EQ ls_numbering-id.

*         Check numbering order
          IF ls_level-level NE lv_level.
            lmc_num2str ls_level-level.
            lv_str2 = lv_str.
            lmc_num2str ls_level-id.
            RAISE EXCEPTION TYPE cx_ood_file_exception
              EXPORTING msgno    = '043'
                        msgv1    = lv_str msgv2 = lv_str2.
            IF 1 = 0. MESSAGE e043 WITH ls_level-id ls_level-level. ENDIF.
*           Numbering &1 check levels order before &2.
          ENDIF.
          ADD 1 TO lv_level.
        ENDLOOP.

*       Check multilevel type
        CASE ls_numbering-multi_type.
          WHEN y00cacl_abapdoc_render_s=>numbering_single_level.

*           Only one level allowed
            IF lv_level NE 1.
              lmc_num2str lv_level.
              lv_str2 = lv_str.
              lmc_num2str ls_numbering-id.
              lv_str3 = ls_numbering-multi_type.
              RAISE EXCEPTION TYPE cx_ood_file_exception
                EXPORTING msgno    = '044'
                          msgv1    = lv_str msgv2 = lv_str2
                          msgv3    = lv_str3.
              IF 1 = 0. MESSAGE e044 WITH ls_numbering-id lv_level ls_numbering-multi_type. ENDIF.
*             Numbering &1 have &2 levels which do not correspond his type &3.
            ENDIF.
          WHEN y00cacl_abapdoc_render_s=>numbering_multi_level.

*           Two or more required
            IF lv_level LE 1.
              lmc_num2str lv_level.
              lv_str2 = lv_str.
              lmc_num2str ls_numbering-id.
              lv_str3 = ls_numbering-multi_type.
              RAISE EXCEPTION TYPE cx_ood_file_exception
                EXPORTING msgno    = '044'
                          msgv1    = lv_str msgv2 = lv_str2
                          msgv3    = lv_str3.
              IF 1 = 0. MESSAGE e044 WITH ls_numbering-id lv_level ls_numbering-multi_type. ENDIF.
*             Numbering &1 have &2 levels which do not correspond his type &3.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDMETHOD.                    "consistency_check

  ENDCLASS.                    "lcl_ood_numberings_file IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_document_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_document_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.
      rv_file_name = 'document.xml'.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.
      rv_file_path = 'word/document.xml'.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~content_type_get.
      rv_content_type =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
      ev_relation_file = ''.
      ev_relation_type = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument'.
    ENDMETHOD.                    "lif_docx_file~relation_register
*>>-> PaM 30.10.2013 17:13:03
    METHOD lif_docx_file~render.
      DATA: lo_sectpr_el    TYPE REF TO lcl_simple_element,
            lo_ref_el       TYPE REF TO lcl_simple_element,
            ls_attribute    TYPE lts_xml_attribute,
            lt_attributes   TYPE ltt_xml_attribute,
            lt_hdr_rel_id   TYPE stringtab,
            lt_ftr_rel_id   TYPE stringtab.

      FIELD-SYMBOLS: <fs_rel_id> TYPE ANY.


*     Add header/footer section to body before rendering document
      me->header_relation_ids_get( IMPORTING et_hdr_rel_id = lt_hdr_rel_id ).
      me->footer_relation_ids_get( IMPORTING et_ftr_rel_id = lt_ftr_rel_id ).

      IF LINES( lt_hdr_rel_id[] ) > 0 OR
         LINES( lt_ftr_rel_id[] ) > 0.
        lmc_element lo_sectpr_el 'sectPr' lcl_ood_render=>ns_prefix_main.

        LOOP AT lt_hdr_rel_id ASSIGNING <fs_rel_id>.
          lmc_attributes_clear.
          lmc_attribute: 'id'   lcl_ood_render=>ns_prefix_relationship <fs_rel_id>.
          lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main         'default'.
          lmc_element lo_ref_el 'headerReference' lcl_ood_render=>ns_prefix_main.

          lo_sectpr_el->lif_docx_element~subelement_add( lo_ref_el ).
        ENDLOOP.

        LOOP AT lt_ftr_rel_id ASSIGNING <fs_rel_id>.
          lmc_attributes_clear.
          lmc_attribute: 'id'   lcl_ood_render=>ns_prefix_relationship <fs_rel_id>.
          lmc_attribute: 'type' lcl_ood_render=>ns_prefix_main         'default'.
          lmc_element lo_ref_el 'footerReference' lcl_ood_render=>ns_prefix_main.

          lo_sectpr_el->lif_docx_element~subelement_add( lo_ref_el ).
        ENDLOOP.

        me->body_element_add( lo_sectpr_el ).
      ENDIF.

*       Call super
      super->lif_docx_file~render( io_render ).

    ENDMETHOD.                    "lif_docx_file~render

    METHOD header_relation_id_add.
      APPEND iv_hdr_rel_id TO me->header_relation_ids[].
    ENDMETHOD.                    "header_relation_id_add

    METHOD footer_relation_id_add.
      APPEND iv_ftr_rel_id TO me->footer_relation_ids[].
    ENDMETHOD.                    "footer_relation_id_add

    METHOD header_relation_ids_get.
      et_hdr_rel_id = me->header_relation_ids[].
    ENDMETHOD.                    "header_relation_ids_get

    METHOD footer_relation_ids_get.
      et_ftr_rel_id = me->footer_relation_ids[].
    ENDMETHOD.                    "footer_relation_ids_get
*<-<< PaM 30.10.2013 17:13:03

    METHOD constructor.

      DATA:
        lo_document   TYPE REF TO lcl_simple_element,
        lt_attributes TYPE ltt_xml_attribute.

      super->constructor( ).

*     Create document element
      lmc_element lo_document 'document' lcl_ood_render=>ns_prefix_main.

*     Create body element
      lmc_element me->body 'body' lcl_ood_render=>ns_prefix_main.

*     Set root
      lo_document->lif_docx_element~subelement_add( me->body ).
      me->root_set( lo_document ).

    ENDMETHOD.                    "constructor

    METHOD body_element_add.

*     Just add element to body
      me->body->lif_docx_element~subelement_add( io_element ).

    ENDMETHOD.                    "body_element_add
  ENDCLASS.                    "lcl_ood_document_file IMPLEMENTATION
*>>-> PaM 30.10.2013 15:21:19 - doplneni trid pro header a footer
* ----------------------------------------------------------------------
* Implementation of class lcl_ood_header_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_header_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.
      rv_file_name = 'header1.xml'.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.
      rv_file_path = 'word/header1.xml'.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~content_type_get.
      rv_content_type =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml'.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
      ev_relation_file = 'word/document.xml'.
      ev_relation_type = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/header'.
    ENDMETHOD.                    "lif_docx_file~relation_register

    METHOD constructor.

      DATA:
        lo_hdr        TYPE REF TO lcl_simple_element,
        lo_par        TYPE REF TO lcl_par_st_element,
        lt_attributes TYPE ltt_xml_attribute.

      super->constructor( ).

*     Create hdr element
      lmc_element lo_hdr 'hdr' lcl_ood_render=>ns_prefix_main.

      CREATE OBJECT lo_par
        EXPORTING
          iv_align  = 'right'
*          iv_style =
          iv_text   = 'Illumiti Inc.'.

      lo_hdr->lif_docx_element~subelement_add( lo_par ).

*     Set root
      me->root_set( lo_hdr ).

    ENDMETHOD.                    "constructor

  ENDCLASS.                    "lcl_ood_header_file IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_footer_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_footer_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.
      rv_file_name = 'footer1.xml'.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.
      rv_file_path = 'word/footer1.xml'.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~content_type_get.
      rv_content_type =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml'.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
      ev_relation_file = 'word/document.xml'.
      ev_relation_type = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer'.
    ENDMETHOD.                    "lif_docx_file~relation_register

    METHOD constructor.

      DATA:
        lo_ftr        TYPE REF TO lcl_simple_element,
        lo_par        TYPE REF TO lcl_par_st_element,
        lv_text       TYPE string,
        lt_attributes TYPE ltt_xml_attribute.

      super->constructor( ).

*     Create hdr element
      lmc_element lo_ftr 'ftr' lcl_ood_render=>ns_prefix_main.

* --> RK 18.2.2014
      CONCATENATE 'www.illumiti.com' '         Generated ' sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4) ' by ' sy-uname INTO lv_text RESPECTING BLANKS.
      CREATE OBJECT lo_par
        EXPORTING
*          iv_style =
          iv_text = lv_text.
* <-- RK 18.2.2014

      lo_ftr->lif_docx_element~subelement_add( lo_par ).

*     Set root
      me->root_set( lo_ftr ).

    ENDMETHOD.                    "constructor

  ENDCLASS.                    "lcl_ood_footer_file IMPLEMENTATION
*<-<< PaM 30.10.2013 15:21:19

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_fonts_file
* ----------------------------------------------------------------------

  CLASS lcl_ood_fonts_file IMPLEMENTATION.

    METHOD lif_docx_file~file_name_get.
      rv_file_name = 'fontTable.xml'.
    ENDMETHOD.                    "lif_docx_file~file_name_get

    METHOD lif_docx_file~file_path_get.
      rv_file_path = 'word/fontTable.xml'.
    ENDMETHOD.                    "lif_docx_file~file_path_get

    METHOD lif_docx_file~content_type_get.
      rv_content_type =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml'.
    ENDMETHOD.                    "lif_docx_file~content_type_get

    METHOD lif_docx_file~relation_register.
      ev_relation_file = 'word/document.xml'.
      ev_relation_type = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable'.
    ENDMETHOD.                    "lif_docx_file~relation_register

    METHOD lif_docx_file~render.

      DATA:
        lo_root         TYPE REF TO lcl_simple_element,
        lo_subelement   TYPE REF TO lcl_simple_element,
        lo_subelement2  TYPE REF TO lcl_simple_element,
        lo_valelement   TYPE REF TO lcl_val_element,
        ls_font         TYPE lts_docx_font,
        lt_attributes   TYPE ltt_xml_attribute,
        ls_attribute    TYPE lts_xml_attribute,
        lv_str          TYPE string,
        lx_ex           TYPE REF TO cx_ood_exception.

      TRY.
*       Create root element
          CREATE OBJECT lo_root
            EXPORTING
              iv_name   = 'fonts'
              iv_prefix = lcl_ood_render=>ns_prefix_main.
          me->root_set( lo_root ).

*       Create subelements for each relation
          LOOP AT me->fonts INTO ls_font.

*         font
            lmc_attributes_clear.
            lmc_attribute: 'name' lcl_ood_render=>ns_prefix_main ls_font-name.
            lmc_element lo_subelement 'font' lcl_ood_render=>ns_prefix_main.

*         panose1
            lv_str = ls_font-panose1.
            CREATE OBJECT lo_valelement
              EXPORTING
                iv_name   = 'panose1'
                iv_prefix = lcl_ood_render=>ns_prefix_main
                iv_val    = lv_str.
            lo_subelement->lif_docx_element~subelement_add( lo_valelement ).

*         charset
            lv_str = ls_font-charset.
            CREATE OBJECT lo_valelement
              EXPORTING
                iv_name   = 'charset'
                iv_prefix = lcl_ood_render=>ns_prefix_main
                iv_val    = lv_str.
            lo_subelement->lif_docx_element~subelement_add( lo_valelement ).

*         family
            CREATE OBJECT lo_valelement
              EXPORTING
                iv_name   = 'family'
                iv_prefix = lcl_ood_render=>ns_prefix_main
                iv_val    = ls_font-family.
            lo_subelement->lif_docx_element~subelement_add( lo_valelement ).

*         pitch
            CREATE OBJECT lo_valelement
              EXPORTING
                iv_name   = 'pitch'
                iv_prefix = lcl_ood_render=>ns_prefix_main
                iv_val    = ls_font-pitch.
            lo_subelement->lif_docx_element~subelement_add( lo_valelement ).

*         sig
            lmc_attributes_clear.
            lv_str = ls_font-csb0. lmc_attribute: 'csb0' lcl_ood_render=>ns_prefix_main lv_str.
            lv_str = ls_font-csb1. lmc_attribute: 'csb1' lcl_ood_render=>ns_prefix_main lv_str.
            lv_str = ls_font-usb0. lmc_attribute: 'usb0' lcl_ood_render=>ns_prefix_main lv_str.
            lv_str = ls_font-usb1. lmc_attribute: 'usb1' lcl_ood_render=>ns_prefix_main lv_str.
            lv_str = ls_font-usb2. lmc_attribute: 'usb2' lcl_ood_render=>ns_prefix_main lv_str.
            lv_str = ls_font-usb3. lmc_attribute: 'usb3' lcl_ood_render=>ns_prefix_main lv_str.
            lmc_element lo_subelement2 'sig' lcl_ood_render=>ns_prefix_main.
            lo_subelement->lif_docx_element~subelement_add( lo_subelement2 ).

            lo_root->lif_docx_element~subelement_add( lo_subelement ).

          ENDLOOP.

*       Call super
          super->lif_docx_file~render( io_render ).

*     Handle exceptions
        CATCH cx_ood_exception INTO lx_ex.

          RAISE EXCEPTION TYPE cx_ood_file_exception
            EXPORTING previous = lx_ex
                      msgno    = '023'.
          IF 1 = 0. MESSAGE e007. ENDIF.
*       Fonts render failed. See previous exceptions for more details.
      ENDTRY.
    ENDMETHOD.                    "lif_docx_file~render

    METHOD font_add.

*     Check for existence
      READ TABLE me->fonts TRANSPORTING NO FIELDS
          WITH KEY name = is_font-name.
      IF sy-subrc IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_file_exception
          EXPORTING msgno    = '024'
                    msgv1    = is_font-name.
        IF 1 = 0. MESSAGE e024 WITH is_font-name. ENDIF.
*       Font &1 already defined.
      ENDIF.

*     Add font
      APPEND is_font TO me->fonts.

    ENDMETHOD.                    "font_add

    METHOD default_font_add.

      CASE iv_name.
        WHEN font_times_nr-name.
          me->font_add( font_times_nr ).
        WHEN font_calibri-name.
          me->font_add( font_calibri ).
        WHEN font_cambria-name.
          me->font_add( font_cambria ).
        WHEN font_tahoma-name.
          me->font_add( font_tahoma ).
        WHEN font_courier-name.
          me->font_add( font_courier ).
        WHEN font_public_sans-name.
          me->font_add( font_public_sans ).
        WHEN OTHERS.
          RAISE EXCEPTION TYPE cx_ood_file_exception
            EXPORTING msgno    = '025'
                      msgv1    = iv_name.
          IF 1 = 0. MESSAGE e025 WITH iv_name. ENDIF.
*         Font &1 is not defined in default fonts.
      ENDCASE.

    ENDMETHOD.                    "default_font_add
  ENDCLASS.                    "lcl_ood_fonts_file IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class lcl_ood_render
* ----------------------------------------------------------------------

  CLASS lcl_ood_render IMPLEMENTATION.

    METHOD lif_xml_render~xml_document_start.

      DATA:
        ls_ns   TYPE lts_namespace,
        lv_name TYPE string,
        lv_cnt  TYPE string,
        lx_ex   TYPE REF TO cx_ood_exception.

*     Check for open document or element and finals
      IF NOT me->current_element IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'start' msgv2 = 'document'
                    msgv3 = 'element' msgv4 = 'finished'.
        IF 1 = 0. MESSAGE e008 WITH 'start' 'document' 'element' 'finished'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.
      IF NOT me->current_document IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'start' msgv2 = 'document'
                    msgv3 = 'document' msgv4 = 'finished'.
        IF 1 = 0. MESSAGE e008 WITH 'start' 'document' 'document' 'finished'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.

      TRY.

*       Get properties
          me->current_document-name = io_docx_file->file_name_get( ).
          me->current_document-path = io_docx_file->file_path_get( ).

*       Add content type
          lv_cnt = io_docx_file->content_type_get( ).
          IF NOT lv_cnt IS INITIAL.
            me->content_types->content_type_add(
              iv_content_type = lv_cnt
              iv_part_name    = me->current_document-path
            ).
          ENDIF.

*       register relation
          me->relation_register( io_docx_file ).

*       Create document
          me->current_document-xml_document = me->ixml->create_document( ).

*       Global namespace
          IF NOT io_docx_file->global_namespace_get( ) IS INITIAL.
            me->global_namespace-xmlns = io_docx_file->global_namespace_get( ).
          ENDIF.

*     Handle errors
        CATCH cx_ood_exception INTO lx_ex.
          CLEAR me->current_document.
          RAISE EXCEPTION TYPE cx_ood_render_exception
            EXPORTING previous = lx_ex
                      msgno    = '009'.
          IF 1 = 0. MESSAGE e009. ENDIF.
*       Render process failed. See previous exception for more details.
      ENDTRY.
    ENDMETHOD.                    "lif_xml_render~xml_document_start

    METHOD lif_xml_render~xml_document_end.

*     Check for open document and element
      IF NOT me->current_element IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'end' msgv2 = 'document'
                    msgv3 = 'element' msgv4 = 'finished'.
        IF 1 = 0. MESSAGE e008 WITH 'end' 'document' 'element' 'finished'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.
      IF me->current_document IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'end' msgv2 = 'document'
                    msgv3 = 'document' msgv4 = 'started'.
        IF 1 = 0. MESSAGE e008 WITH 'end' 'document' 'document' 'started'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.

*     Global namespace
      IF NOT me->global_namespace IS INITIAL.

*       Add namespace to document and currents
        me->namespace_add(
          iv_prefix = me->global_namespace-prefix
          iv_uri    = me->global_namespace-xmlns
        ).
      ENDIF.

*     Append document and clear current
      IF me->final EQ abap_true.

*       Closing render - rendering content types and relations
        APPEND me->current_document TO me->finals.
      ELSE.

*       Normal document
        APPEND me->current_document TO me->documents.
      ENDIF.

      CLEAR: me->current_document, me->current_namespaces,
             me->global_namespace.
    ENDMETHOD.                    "lif_xml_render~xml_document_end

    METHOD lif_xml_render~xml_element_start.

      DATA:
        lo_element   TYPE REF TO if_ixml_element,
        ls_attribute TYPE lts_xml_attribute.

*     Check for open document
      IF me->current_document IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'start' msgv2 = 'element'
                    msgv3 = 'document' msgv4 = 'started'.
        IF 1 = 0. MESSAGE e008 WITH 'start' 'element' 'document' 'started'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.

*     Create element
      lo_element = me->current_document-xml_document->create_element_ns(
                     name   = iv_name
                     prefix = iv_prefix
                   ).

*     Create and set new element
      IF NOT me->current_element IS BOUND.

*       Under document
        me->current_document-xml_document->if_ixml_node~append_child( lo_element ).
      ELSE.

        IF NOT me->current_element->if_ixml_node~get_value( ) IS INITIAL AND
           me->current_element->if_ixml_node~num_children( ) EQ 0.
          RAISE EXCEPTION TYPE cx_ood_render_exception
            EXPORTING msgno = '012'.
          IF 1 = 0. MESSAGE e012. ENDIF.
*         Can't create subelement under element with value.
        ENDIF.

*       Under parent element
        me->current_element->if_ixml_node~append_child( lo_element ).
      ENDIF.

      me->current_element = lo_element.

*     Check prefix
      me->prefix_check( iv_prefix ).

*     Add attributes
      LOOP AT it_attributes INTO ls_attribute.

        me->lif_xml_render~xml_element_attribute_add(
          iv_name   = ls_attribute-name
          iv_prefix = ls_attribute-prefix
          iv_value  = ls_attribute-value
        ).
      ENDLOOP.

    ENDMETHOD.                    "lif_xml_render~xml_element_start

    METHOD lif_xml_render~xml_element_attribute_add.

      DATA:
        lo_attribute TYPE REF TO if_ixml_attribute.

*     Check for open document and element
      IF me->current_document IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'start' msgv2 = 'attribute'
                    msgv3 = 'document' msgv4 = 'started'.
        IF 1 = 0. MESSAGE e008 WITH 'start' 'attribute' 'document' 'started'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.
      IF me->current_element IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'start' msgv2 = 'attribute'
                    msgv3 = 'element' msgv4 = 'started'.
        IF 1 = 0. MESSAGE e008 WITH 'start' 'attribute' 'element' 'started'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.

*     Check prefix
      me->prefix_check( iv_prefix ).

*     Add attribute to current element
      me->current_element->set_attribute_ns(
        name   = iv_name
        prefix = iv_prefix
        value  = iv_value
      ).
    ENDMETHOD.                    "lif_xml_render~xml_element_attribute_add

    METHOD lif_xml_render~xml_element_value_set.

*     Check not document and not element with childern
      IF NOT me->current_element IS BOUND.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '011'.
        IF 1 = 0. MESSAGE e011. ENDIF.
*       Can't render value under document.
      ELSEIF me->current_element->if_ixml_node~num_children( ) GT 0.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '013'.
        IF 1 = 0. MESSAGE e013. ENDIF.
*       Can't render value under element with subelements.
      ENDIF.

*     Set value
      me->current_element->if_ixml_node~set_value( iv_value ).
    ENDMETHOD.                    "lif_xml_render~xml_element_value_set

    METHOD lif_xml_render~xml_element_end.

      DATA:
        lo_node TYPE REF TO if_ixml_node.

*     Check for open document
      IF me->current_document IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'end' msgv2 = 'element'
                    msgv3 = 'document' msgv4 = 'started'.
        IF 1 = 0. MESSAGE e008 WITH 'end' 'element' 'document' 'started'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.
      IF me->current_element IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'end' msgv2 = 'element'
                    msgv3 = 'element' msgv4 = 'started'.
        IF 1 = 0. MESSAGE e008 WITH 'end' 'element' 'element' 'started'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.

*     Set element
      lo_node = me->current_element->if_ixml_node~get_parent( ).

*     Check if it is element
      TRY.

          me->current_element ?= lo_node.
        CATCH cx_root.
          CLEAR me->current_element.
      ENDTRY.
    ENDMETHOD.                    "lif_xml_render~xml_element_end

    METHOD constructor.

      DATA:
        lo_relations TYPE REF TO lcl_ood_relations_file.

*     Create content types
      CREATE OBJECT me->content_types.

*     Create root relations
      CREATE OBJECT lo_relations.
      APPEND lo_relations TO me->relations.

*     Create iXML instance
      me->ixml = cl_ixml=>create( ).
    ENDMETHOD.                    "constructor

    METHOD relation_register.

      DATA:
        lo_file            TYPE REF TO lif_docx_file,
        lo_relations       TYPE REF TO lcl_ood_relations_file,
        lv_relation_file   TYPE string,
        lv_relation_type   TYPE string,
        lv_file_path       TYPE string,
        lv_id              TYPE string,
        lx_ex              TYPE REF TO cx_ood_exception.

*     Get relation data
      io_docx_file->relation_register(
        IMPORTING
          ev_relation_file   = lv_relation_file
          ev_relation_type   = lv_relation_type
      ).

*     Check file have relation
      IF NOT lv_relation_type IS INITIAL.

*       Find corresponding relations
        LOOP AT me->relations INTO lo_file.

          lo_relations ?= lo_file.
          IF lo_relations->relations_file_get( ) EQ lv_relation_file.
            EXIT.
          ENDIF.
          CLEAR lo_relations.
        ENDLOOP.

*       Create new relations if not found
        IF NOT lo_relations IS BOUND.
          CREATE OBJECT lo_relations
            EXPORTING
              iv_relations_file = lv_relation_file.
          APPEND lo_relations TO me->relations.
        ENDIF.

*       Register relation
        TRY.
            lv_file_path = io_docx_file->file_path_get( ).
            lv_id = lo_relations->relation_register(
                      iv_type   = lv_relation_type
                      iv_target = lv_file_path ).

          CATCH cx_ood_exception INTO lx_ex.
            RAISE EXCEPTION TYPE cx_ood_render_exception
              EXPORTING previous = lx_ex
                        msgno    = '009'.
            IF 1 = 0. MESSAGE e009. ENDIF.
*         Render process failed. See previous exception for more details.
        ENDTRY.

*       Return relation ID
*>>-> PaM 31.10.2013 15:37:14
*        lo_file->relation_id_set( lv_id ).
        io_docx_file->relation_id_set( lv_id ).
*<-<< PaM 31.10.2013 15:37:14
      ENDIF.
    ENDMETHOD.                    "relation_register

    METHOD prefix_check.

      DATA:
        ls_namespace      TYPE lts_namespace.

*     Prefix must be defined
      CHECK NOT iv_prefix IS INITIAL.

*     Check for global namespace
      IF NOT me->global_namespace IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno    = '028'.
        IF 1 = 0. MESSAGE e028. ENDIF.
*       Element prefix can't be defined with document global namespace.
      ENDIF.

*     Check namespace is already in document
      LOOP AT me->current_namespaces INTO ls_namespace.
        IF ls_namespace-prefix EQ iv_prefix.
          RETURN.
        ENDIF.
      ENDLOOP.

*     Get xmlns
      ls_namespace-prefix = iv_prefix.
      CASE iv_prefix.
        WHEN ns_prefix_main.
          ls_namespace-xmlns = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'.
        WHEN ns_prefix_drawing06.
          ls_namespace-xmlns = 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing'.
        WHEN ns_prefix_drawing10.
          ls_namespace-xmlns = 'http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing'.
        WHEN ns_prefix_compatibility.
          ls_namespace-xmlns = 'http://schemas.openxmlformats.org/markup-compatibility/2006'.
        WHEN ns_prefix_relationship.
*>>-> PaM 31.10.2013 12:52:25
*        ls_namespace-xmlns = 'http://schemas.openxmlformats.org/package/2006/relationships'.
          ls_namespace-xmlns = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'.
*<-<< PaM 31.10.2013 12:52:25
        WHEN ns_prefix_content_types.
          ls_namespace-xmlns = 'http://schemas.openxmlformats.org/package/2006/content-types'.
        WHEN OTHERS.
          RAISE EXCEPTION TYPE cx_ood_render_exception
            EXPORTING msgno    = '010' msgv1 = iv_prefix.
          IF 1 = 0. MESSAGE e010 WITH iv_prefix. ENDIF.
*         Namespace prefix &1 is unknown.
      ENDCASE.

*     Add namespace to document and currents
      me->namespace_add(
        iv_prefix = ls_namespace-prefix
        iv_uri    = ls_namespace-xmlns
      ).

*     Add namespace to currents
      APPEND ls_namespace TO me->current_namespaces.
    ENDMETHOD.                    "prefix_check

    METHOD namespace_add.

      DATA:
        lo_ns_declaration TYPE REF TO if_ixml_namespace_decl,
        lo_root_node      TYPE REF TO if_ixml_node,
        lo_root_element   TYPE REF TO if_ixml_element.

*     Add namespace to document and currents
      IF NOT iv_prefix IS INITIAL.
        lo_ns_declaration = me->current_document-xml_document->create_namespace_decl(
                                name   = iv_prefix
                                prefix = 'xmlns'
                                uri    = iv_uri
                            ).
      ELSE.
        lo_ns_declaration = me->current_document-xml_document->create_namespace_decl(
                                name   = 'xmlns'
                                prefix = ''
                                uri    = iv_uri
                            ).
      ENDIF.
      lo_root_node = me->current_document-xml_document->if_ixml_node~get_first_child( ).
      lo_root_element ?= lo_root_node.
      lo_root_element->set_attribute_node( lo_ns_declaration ).
    ENDMETHOD.                    "namespace_add

    METHOD save_to_file.

      DATA:
        lo_archive   TYPE REF TO cl_abap_zip,
        ls_document  TYPE lts_archive_document.

*     Check for open document
      IF NOT me->current_document IS INITIAL.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno = '008' msgv1 = 'start' msgv2 = 'archive'
                    msgv3 = 'document' msgv4 = 'started'.
        IF 1 = 0. MESSAGE e008 WITH 'start' 'file' 'document' 'started'. ENDIF.
*       Unable to &1 render &2 when &3 is not &4.
      ENDIF.

*     Final render
      me->render_final( ).

*     Create archive
      CREATE OBJECT lo_archive.

*     Render each document to archive
      LOOP AT me->documents INTO ls_document.

        me->document_to_archive_render(
          io_archive  = lo_archive
          is_document = ls_document
          iv_encoding = iv_encoding
        ).
      ENDLOOP.

*     Render each final to archive
      LOOP AT me->finals INTO ls_document.

        me->document_to_archive_render(
          io_archive  = lo_archive
          is_document = ls_document
          iv_encoding = iv_encoding
        ).
      ENDLOOP.

      IF iv_location = 'P'.
*     Save archive to frontend
        me->archive_to_frontend(
          io_archive          = lo_archive
          iv_target_file_path = iv_target_file_path
        ).
      ELSE.
*     Save archive to application server
        me->archive_to_appl_srv(
          io_archive          = lo_archive
          iv_target_file_path = iv_target_file_path
        ).
      ENDIF.

    ENDMETHOD.                    "save_to_file

    METHOD render_final.

      DATA:
        lo_file TYPE REF TO lif_docx_file,
        lx_ex   TYPE REF TO cx_ood_exception.

*     Clear previous render final
      CLEAR: me->finals.

*     Start final. Setting flag will add rendered documents
*     to finals table instead of documents table.
      me->final = abap_true.
      TRY.

*       Render relations
          LOOP AT me->relations INTO lo_file.

            lo_file->render( me ).
          ENDLOOP.

*       Render content types
          me->content_types->lif_docx_file~render( me ).

        CATCH cx_ood_exception INTO lx_ex.

*       End final with exception
          me->final = abap_false.
          RAISE EXCEPTION TYPE cx_ood_render_exception
            EXPORTING previous = lx_ex
                      msgno    = '009'.
          IF 1 = 0. MESSAGE e009. ENDIF.
*       Render process failed. See previous exception for more details.
      ENDTRY.

*     End final
      me->final = abap_false.

    ENDMETHOD.                    "render_final

    METHOD document_to_archive_render.

      DATA:
        lo_stream_factory TYPE REF TO if_ixml_stream_factory,
        lo_stream         TYPE REF TO if_ixml_ostream,
        lo_encoding       TYPE REF TO if_ixml_encoding,
        lo_renderer       TYPE REF TO if_ixml_renderer,
        lv_content        TYPE xstring,
        lv_rc             TYPE i,
        lv_str            TYPE string.

*     Stream factory
      lo_stream_factory = me->ixml->create_stream_factory( ).

*     Stream
      lo_stream = lo_stream_factory->create_ostream_xstring( lv_content ).

*     Encoding
      IF NOT iv_encoding IS INITIAL.
        lo_encoding = me->ixml->create_encoding(
          character_set = iv_encoding
          byte_order    = if_ixml_encoding=>co_none
        ).
        lo_stream->if_ixml_stream~set_encoding( lo_encoding ).
      ENDIF.

*     Renderer
      lo_renderer = me->ixml->create_renderer(
        document = is_document-xml_document
        ostream  = lo_stream
      ).

*     Render
      lv_rc = lo_renderer->render( ).
      IF NOT lv_rc IS INITIAL.
        lv_str = lv_rc.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno    = '014' msgv1 = is_document-name msgv2 = lv_str.
        IF 1 = 0. MESSAGE e014 WITH is_document-name lv_rc. ENDIF.
*       Archive document &1 render error. RC = &2.
      ENDIF.

*     Add to archive
      io_archive->add(
        name    = is_document-path
        content = lv_content
      ).

    ENDMETHOD.                    "document_to_archive_render

    METHOD archive_to_frontend.

      DATA:
        lv_content TYPE xstring,
        lt_content TYPE TABLE OF solisti1,
        lv_length  TYPE i,
        lv_str     TYPE string.

*     Get archive content
      lv_content = io_archive->save( ).

      " Convert to binary
      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer        = lv_content
        IMPORTING
          output_length = lv_length
        TABLES
          binary_tab    = lt_content.

*     Save file
      CALL METHOD cl_gui_frontend_services=>gui_download
        EXPORTING
          bin_filesize              = lv_length
          filename                  = iv_target_file_path
          filetype                  = 'BIN'
*          append                    = SPACE
*          write_field_separator     = SPACE
*          header                    = '00'
*          trunc_trailing_blanks     = SPACE
*          write_lf                  = 'X'
*          col_select                = SPACE
*          col_select_mask           = SPACE
*          dat_mode                  = SPACE
*          confirm_overwrite         = SPACE
*          no_auth_check             = SPACE
*          codepage                  = '1142'
*          ignore_cerr               = ABAP_TRUE
*          replacement               = '#'
*          write_bom                 = SPACE
*          trunc_trailing_blanks_eol = 'X'
*          wk1_n_format              = SPACE
*          wk1_n_size                = SPACE
*          wk1_t_format              = SPACE
*          wk1_t_size                = SPACE
*          show_transfer_status      = 'X'
*        IMPORTING
*          filelength                =
        CHANGING
          data_tab                  = lt_content
        EXCEPTIONS
          file_write_error          = 1
          no_batch                  = 2
          gui_refuse_filetransfer   = 3
          invalid_type              = 4
          no_authority              = 5
          unknown_error             = 6
          header_not_allowed        = 7
          separator_not_allowed     = 8
          filesize_not_allowed      = 9
          header_too_long           = 10
          dp_error_create           = 11
          dp_error_send             = 12
          dp_error_write            = 13
          unknown_dp_error          = 14
          access_denied             = 15
          dp_out_of_memory          = 16
          disk_full                 = 17
          dp_timeout                = 18
          file_not_found            = 19
          dataprovider_exception    = 20
          control_flush_error       = 21
          not_supported_by_gui      = 22
          error_no_gui              = 23
          OTHERS                    = 24
              .
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               INTO lv_str.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno    = '015' msgv1 = lv_str.
        IF 1 = 0. MESSAGE e015 WITH lv_str. ENDIF.
*       Archive save: &1...
      ENDIF.
    ENDMETHOD.                    "archive_to_frontend

    METHOD archive_to_appl_srv.

      DATA:
        lv_content TYPE xstring,
        lt_content TYPE TABLE OF solisti1,
        ls_content LIKE LINE OF lt_content,
        lv_length  TYPE i,
        lv_str     TYPE string.

*     Get archive content
      lv_content = io_archive->save( ).

      " Convert to binary
      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer        = lv_content
        IMPORTING
          output_length = lv_length
        TABLES
          binary_tab    = lt_content.

*     Save file on application server
      OPEN DATASET iv_target_file_path FOR OUTPUT IN BINARY MODE. "TEXT MODE ENCODING DEFAULT.
      IF sy-subrc = 0.
        LOOP AT lt_content INTO ls_content.
          IF lv_length < 510.
            TRANSFER ls_content TO iv_target_file_path LENGTH lv_length.
          ELSE.
            lv_length = lv_length - 510.
            TRANSFER ls_content TO iv_target_file_path.
          ENDIF.
        ENDLOOP.
        CLOSE DATASET iv_target_file_path.
      ENDIF.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               INTO lv_str.
        RAISE EXCEPTION TYPE cx_ood_render_exception
          EXPORTING msgno    = '015' msgv1 = lv_str.
        IF 1 = 0. MESSAGE e015 WITH lv_str. ENDIF.
*       Archive save: &1...
      ENDIF.
    ENDMETHOD.                    "archive_to_appl_srv
  ENDCLASS.                    "lcl_ood_render IMPLEMENTATION

* ----------------------------------------------------------------------
* Implementation of class cx_ood_exception
* ----------------------------------------------------------------------

  CLASS cx_ood_exception IMPLEMENTATION.

    METHOD constructor.

*     Call super
      super->constructor(
        textid   = textid
        previous = previous
      ).

*     Add own attributes
      me->msgid = msgid.
      me->msgno = msgno.
      me->msgv1 = msgv1.
      me->msgv2 = msgv2.
      me->msgv3 = msgv3.
      me->msgv4 = msgv4.

    ENDMETHOD.                    "constructor

    METHOD if_message~get_text.

*     Check for message
      IF NOT me->msgid IS INITIAL.

*       Return message
        MESSAGE ID me->msgid TYPE 'E' NUMBER me->msgno
               WITH me->msgv1 me->msgv2 me->msgv3 me->msgv4
               INTO result.
      ELSE.

*       Return super
        result = super->if_message~get_text( ).
      ENDIF.
    ENDMETHOD.                    "if_message~get_text
  ENDCLASS.                    "cx_ood_exception IMPLEMENTATION