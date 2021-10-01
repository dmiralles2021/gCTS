*&---------------------------------------------------------------------*
*& Author's name             : Marek BENDA; KCT Data, s.r.o.
*& Creation Date             : 17.07.2013 11:55:57
*&
*& Version                   : 1.0
*&
*&---------------------------------------------------------------------*
*& Description: Local classes/types definitions
*&---------------------------------------------------------------------*


* ----------------------------------------------------------------------
* INTERFACE-DEFERRED
* ----------------------------------------------------------------------

  INTERFACE lif_docx_element DEFERRED.
  INTERFACE lif_docx_file    DEFERRED.

* ----------------------------------------------------------------------
* TYPES
* ----------------------------------------------------------------------

* Table types for element and file
  TYPES:
    ltt_element TYPE TABLE OF REF TO lif_docx_element,
    ltt_file    TYPE TABLE OF REF TO lif_docx_file.

* Archive document structure and table
  TYPES:
    BEGIN OF lts_archive_document,
      name            TYPE string,
      path            TYPE string,
      xml_document    TYPE REF TO if_ixml_document,
    END OF lts_archive_document,
    ltt_archive_document TYPE TABLE OF lts_archive_document.

* XML atribute structure and table
  TYPES:
    BEGIN OF lts_xml_attribute,
      name   TYPE string,
      prefix TYPE string,
      value  TYPE string,
    END OF lts_xml_attribute,
    ltt_xml_attribute TYPE TABLE OF lts_xml_attribute.

* Content type structure and table
  TYPES:
    BEGIN OF lts_content_type,
      content_type TYPE string,
      part_name    TYPE string,
    END OF lts_content_type,
    ltt_content_type TYPE TABLE OF lts_content_type.

* Extension type structure and table
  TYPES:
    BEGIN OF lts_extension,
      extension    TYPE string,
      content_type TYPE string,
    END OF lts_extension,
    ltt_extension TYPE TABLE OF lts_extension.

* Relations structure and table
  TYPES:
    BEGIN OF lts_relation,
      id      TYPE string,
      type    TYPE string,
      target  TYPE string,
    END OF lts_relation,
    ltt_relation TYPE TABLE OF lts_relation.

* Namespace structure and table
  TYPES:
    BEGIN OF lts_namespace,
      prefix TYPE string,
      xmlns  TYPE string,
    END OF lts_namespace,
    ltt_namespace TYPE TABLE OF lts_namespace.

* Style structures and table
  TYPES:

*   Paragraph properties
    BEGIN OF lts_docx_style_ppr,
      keep_next       TYPE xfeld,
      keep_lines      TYPE xfeld,
      numbering_id    TYPE i,
      numbering_level TYPE i,
      outline_level   TYPE i,
      spacing_before  TYPE i,
      spacing_after   TYPE i,
    END OF lts_docx_style_ppr,

*   Table properties
    BEGIN OF lts_docx_style_tblpr,
      indent      TYPE i,
      indent_tp   TYPE c LENGTH 1, "See constants lcl_ood_styles_file=>TP_*
      border_size TYPE i,
      margin_l    TYPE i,
      margin_r    TYPE i,
      margin_t    TYPE i,
      margin_b    TYPE i,
      margin_tp   TYPE c LENGTH 1, "See constants lcl_ood_styles_file=>TP_*
    END OF lts_docx_style_tblpr,

*   Run properties
    BEGIN OF lts_docx_style_rpr,
      bold  TYPE xfeld, italic TYPE xfeld, underlined TYPE xfeld,
      color TYPE char8,
      font  TYPE string,
      size  TYPE i,
    END OF lts_docx_style_rpr,

*   Style structure
    BEGIN OF lts_docx_style,
      id              TYPE string,
      type            TYPE c LENGTH 1, "See constants lcl_ood_styles_file=>TYPE_*
      name            TYPE string,
      based           TYPE string,
      next            TYPE string,
      qformat         TYPE xfeld,
      ppr             TYPE lts_docx_style_ppr,
      tblpr           TYPE lts_docx_style_tblpr,
      rpr             TYPE lts_docx_style_rpr,
    END OF lts_docx_style,
    ltt_docx_style TYPE TABLE OF lts_docx_style.

* Font structure and table
  TYPES:
    BEGIN OF lts_docx_font,
      name    TYPE string,
      panose1 TYPE char20,
      charset TYPE char2,
      family  TYPE string,
      pitch   TYPE string,
      csb0    TYPE char8,
      csb1    TYPE char8,
      usb0    TYPE char8,
      usb1    TYPE char8,
      usb2    TYPE char8,
      usb3    TYPE char8,
    END OF lts_docx_font,
    ltt_docx_font TYPE TABLE OF lts_docx_font.

* Tables
  TYPES:

*   Cell structure and table
    BEGIN OF lts_docx_table_cell,
      row   TYPE i,
      style TYPE string,
      text  TYPE string,
    END OF lts_docx_table_cell,
    ltt_docx_table_cell TYPE TABLE OF lts_docx_table_cell,

*   Row structure and table
    BEGIN OF lts_docx_table_row,
      style TYPE string,
    END OF lts_docx_table_row,
    ltt_docx_table_row TYPE TABLE OF lts_docx_table_row.

* Numberings
  TYPES:

*   Numbering level structure and table
    BEGIN OF lts_docx_numbering_level,
      id         TYPE i,
      level      TYPE i,
      start      TYPE i,
      format     TYPE char1,
      style      TYPE string,
      level_text TYPE string,
    END OF lts_docx_numbering_level,
    ltt_docx_numbering_level TYPE TABLE OF lts_docx_numbering_level,

*   Numbering structure and table
    BEGIN OF lts_docx_numbering,
      id          TYPE i,
      abstract_id TYPE i,
      multi_type  TYPE char1,
    END OF lts_docx_numbering,
    ltt_docx_numbering TYPE TABLE OF lts_docx_numbering.

* ----------------------------------------------------------------------
* EXCEPTIONS
* ----------------------------------------------------------------------

* Base exception class
  CLASS cx_ood_exception DEFINITION
    INHERITING FROM cx_static_check.

    PUBLIC SECTION.

      DATA:
        msgid TYPE msgid VALUE 'ZKCT_OOD',
        msgno TYPE msgno,
        msgv1 TYPE string,
        msgv2 TYPE string,
        msgv3 TYPE string,
        msgv4 TYPE string.

      METHODS:

*       Constructor
        constructor
          IMPORTING
            textid       LIKE textid    OPTIONAL
            previous     LIKE previous  OPTIONAL
            value(msgid) TYPE msgid     DEFAULT 'ZKCT_OOD'
            value(msgno) TYPE msgno     OPTIONAL
            value(msgv1) TYPE string    OPTIONAL
            value(msgv2) TYPE string    OPTIONAL
            value(msgv3) TYPE string    OPTIONAL
            value(msgv4) TYPE string    OPTIONAL,

        if_message~get_text REDEFINITION.

  ENDCLASS.                    "cx_ood_exception  DEFINITIO

* Docx file exception
  CLASS cx_ood_file_exception DEFINITION
    INHERITING FROM cx_ood_exception.
  ENDCLASS.                    "cx_ood_file_exception  DEFINITIO

* Docx element exception
  CLASS cx_ood_element_exception DEFINITION
    INHERITING FROM cx_ood_exception.
  ENDCLASS.                    "cx_ood_element_exception  DEFINITIO

* Docx archive exception
  CLASS cx_ood_archive_exception DEFINITION
    INHERITING FROM cx_ood_exception.
  ENDCLASS.                    "cx_ood_archive_exception  DEFINITIO

* Docx render exception
  CLASS cx_ood_render_exception DEFINITION
    INHERITING FROM cx_ood_exception.
  ENDCLASS.                    "cx_ood_render_exception  DEFINITIO

* ----------------------------------------------------------------------
* INTERFACE
* ----------------------------------------------------------------------

* XML render interface
  INTERFACE lif_xml_render.

    METHODS:

*     Start new xml document
      xml_document_start
        IMPORTING
          io_docx_file               TYPE REF TO lif_docx_file
        RAISING cx_ood_render_exception,

*     End of xml document
      xml_document_end
        RAISING cx_ood_render_exception,

*     Start new xml element.
      xml_element_start
        IMPORTING
          value(iv_name)       TYPE string
          value(iv_prefix)     TYPE string OPTIONAL "For prefixes use class constants NS_PREFIX_*
          value(it_attributes) TYPE ltt_xml_attribute OPTIONAL
        RAISING cx_ood_render_exception,

*     Add new attribute to xml element
      xml_element_attribute_add
        IMPORTING
          value(iv_name)   TYPE string
          value(iv_prefix) TYPE string OPTIONAL "For prefixes use class constants NS_PREFIX_*
          value(iv_value)  TYPE string OPTIONAL
        RAISING cx_ood_render_exception,

*     Set text to XML element.
      xml_element_value_set
        IMPORTING
          value(iv_value)  TYPE string OPTIONAL
        RAISING cx_ood_render_exception,

*     End XML element
      xml_element_end
        RAISING cx_ood_render_exception.
  ENDINTERFACE.                    "lif_xml_render  DEFINITIO

* Interface of file in docx.
  INTERFACE lif_docx_element.
    METHODS:

*     Add subelement.
      subelement_add
        IMPORTING
          io_element TYPE REF TO lif_docx_element
        RAISING cx_ood_element_exception,

*     Render element returning result as new xml document element
      render
        IMPORTING
          io_render TYPE REF TO lif_xml_render
        RAISING cx_ood_element_exception.

  ENDINTERFACE.                    "lif_docx_element  DEFINITIO

* Interface of file in docx.
  INTERFACE lif_docx_file.
    METHODS:

*     Return file name (f.e. fontTable.xml)
      file_name_get
        RETURNING value(rv_file_name) TYPE string,

*     Return full file path on archive (f.e. word/fontTable.xml)
      file_path_get
        RETURNING value(rv_file_path) TYPE string,

*     Return content type for [Content_Types].xml
*     (f.e. application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml)
      content_type_get
        RETURNING value(rv_content_type) TYPE string,

*     Return custom extension (different from rels and xml)
*     (f.e. extension = gif, content_type = image/gif)
      custom_extension_get
        EXPORTING
          VALUE(ev_extension) TYPE String
          VALUE(ev_content_type) TYPE String,

*     Return namespace for whole file (optional)
      global_namespace_get
        RETURNING value(rv_global_namespace) TYPE string,

*     Register file relation. File will register relation on some object
*     returning type and target. If this values are returned, method
*     RELATION_ID_SET is called with file relation ID assigned.
*     (f.e.
*     File = word/document.xml
*     Type = http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable
      relation_register
        EXPORTING
          ev_relation_file   TYPE string
          ev_relation_type   TYPE string,

*     After relation is registered, relation ID in archive is assigned and
*     using this method is returned to object
      relation_id_set
        IMPORTING
          iv_relation_id TYPE string,

*     File render itself to ixml document
      render
        IMPORTING
          io_render TYPE REF TO lif_xml_render
          RAISING cx_ood_file_exception.

  ENDINTERFACE.                    "lif_docx_file  DEFINITIO

* ----------------------------------------------------------------------
* CLASS
* ----------------------------------------------------------------------

* Base element class.
  CLASS lcl_element DEFINITION ABSTRACT.

    PUBLIC SECTION.

      INTERFACES: lif_docx_element
        ABSTRACT METHODS
          render.

    PROTECTED SECTION.

      METHODS:

*       Return subelements
        subelements_get
          EXPORTING
            et_subelements TYPE ltt_element,

*       Render subelements
        render_subelements
          IMPORTING
            io_render TYPE REF TO lif_xml_render
          RAISING cx_ood_element_exception.

    PRIVATE SECTION.

      DATA:
        subelements TYPE ltt_element.

  ENDCLASS.                    "lcl_element DEFINITION

* Simple element.
  CLASS lcl_simple_element DEFINITION
    INHERITING FROM lcl_element.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor
          IMPORTING
            value(iv_name)   TYPE string
            value(iv_prefix) TYPE string OPTIONAL
            value(iv_value)  TYPE string OPTIONAL
            it_attributes    TYPE ltt_xml_attribute OPTIONAL,

*       Redefinitions
        lif_docx_element~render REDEFINITION.

    PROTECTED SECTION.

      METHODS:

*       Method called before subelements are rendered.
*       For redefinition by inheriting classes.
        render_before_subelements
          IMPORTING
            io_render TYPE REF TO lif_xml_render
          RAISING cx_ood_element_exception,

        render_after_subelements
          IMPORTING
            io_render TYPE REF TO lif_xml_render
          RAISING cx_ood_element_exception.

    PRIVATE SECTION.

      DATA:
        name       TYPE string,
        prefix     TYPE string,
        value      TYPE string,
        attributes TYPE ltt_xml_attribute.

  ENDCLASS.                    "lcl_simple_element  DEFINITIO

* Simple element with val attribute
  CLASS lcl_val_element DEFINITION
    INHERITING FROM lcl_simple_element.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor
          IMPORTING
            value(iv_name)   TYPE string
            value(iv_prefix) TYPE string OPTIONAL
            value(iv_val)    TYPE string OPTIONAL
            it_attributes    TYPE ltt_xml_attribute OPTIONAL.

  ENDCLASS.                    "lcl_val_element  DEFINITIO

* Style element.
  CLASS lcl_style_element DEFINITION
    INHERITING FROM lcl_simple_element.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor
          IMPORTING
            is_style          TYPE lts_docx_style
            value(iv_default) TYPE xfeld DEFAULT space.

    PROTECTED SECTION.

      METHODS:

*       Redefinitions
        render_before_subelements REDEFINITION.

    PRIVATE SECTION.

      DATA:
        style   TYPE lts_docx_style.

      METHODS:

*       Return size measure unit text
        tp_get
          IMPORTING
            value(iv_tp) TYPE char1
          RETURNING value(rv_type) TYPE string,


*       Return true if paragraph properties are initial.
        ppr_initial_check
          RETURNING value(rv_is_initial) TYPE xfeld.

  ENDCLASS.                    "lcl_style_element  DEFINITIO

* Styled Paragraph Element.
  CLASS lcl_par_st_element DEFINITION
    INHERITING FROM lcl_simple_element.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor
          IMPORTING
*>>-> PaM 01.11.2013 15:35:10
            value(iv_align) TYPE string OPTIONAL
*<-<< PaM 01.11.2013 15:35:10
*>>-> PaM 22.01.2014 10:53:59
            value(iv_indent_left) TYPE i OPTIONAL
*<-<< PaM 22.01.2014 10:53:59
            value(iv_style) TYPE string OPTIONAL
            value(iv_text)  TYPE string OPTIONAL.

    PROTECTED SECTION.

      METHODS:

*       Redefinitions
        render_before_subelements REDEFINITION.

    PRIVATE SECTION.

      DATA:
*>>-> PaM 01.11.2013 15:35:10
        align TYPE string,
*<-<< PaM 01.11.2013 15:35:10
*>>-> PaM 22.01.2014 10:53:59
        indent_left TYPE i,
*<-<< PaM 22.01.2014 10:53:59
        style TYPE string,
        text  TYPE string.

  ENDCLASS.                    "lcl_par_st_element  DEFINITIO

* Table element
  CLASS lcl_table_element DEFINITION
    INHERITING FROM lcl_simple_element.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor
          IMPORTING
            value(iv_style) TYPE string OPTIONAL,

*       Start new table row
        row_add
          IMPORTING
            value(iv_style) TYPE string OPTIONAL
          RAISING cx_ood_element_exception,

*       Add cell to row
        cell_add
          IMPORTING
            value(iv_style) TYPE string OPTIONAL
            value(iv_text)  TYPE string OPTIONAL
          RAISING cx_ood_element_exception.

    PROTECTED SECTION.

      METHODS:

*       Redefinitions
        render_before_subelements REDEFINITION.

    PRIVATE SECTION.

      DATA:
        style         TYPE string,
        rows          TYPE ltt_docx_table_row,
        cells         TYPE ltt_docx_table_cell,
        cells_per_row TYPE i.

      METHODS:

*       Check last added row before new or render.
        last_row_check
        RAISING cx_ood_element_exception.


  ENDCLASS.                    "lcl_table_element  DEFINITION

* Base file class
  CLASS lcl_file DEFINITION ABSTRACT.

    PUBLIC SECTION.
      INTERFACES lif_docx_file
        ABSTRACT METHODS
          file_name_get file_path_get content_type_get relation_register.

      CLASS-METHODS:

*       Split full archive file path to file and path
        file_path_split
          IMPORTING
            value(iv_file_path) TYPE string
          EXPORTING
            value(ev_file_path) TYPE string
            value(ev_file_name) TYPE string.

*>>-> PaM 31.10.2013 15:55:45 - moved from protected section
      METHODS:
*       Return relation ID
        relation_id_get
          RETURNING value(rv_relation_id) TYPE string.
*<-<< PaM 31.10.2013 15:55:45

    PROTECTED SECTION.

      METHODS:

*>>-> PaM 31.10.2013 15:55:23 - moved to public section
**       Return relation ID
*        relation_id_get
*          RETURNING value(rv_relation_id) TYPE string,
*<-<< PaM 31.10.2013 15:55:23

*       Set root object
        root_set
          IMPORTING
            io_root TYPE REF TO lif_docx_element,

*       Get root object
        root_get
          RETURNING value(ro_root) TYPE REF TO lif_docx_element.

    PRIVATE SECTION.

      DATA:
        relation_id TYPE string,
        root        TYPE REF TO lif_docx_element.
  ENDCLASS.                    "lcl_file DEFINITION

* Open Office Document Content Types File
  CLASS lcl_ood_content_types_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      METHODS:

*       Add new content type
        content_type_add
          IMPORTING
            value(iv_content_type) TYPE string
            value(iv_part_name)    TYPE string
          RAISING cx_ood_file_exception,

*       Redefinitions
        lif_docx_file~file_name_get        REDEFINITION,
        lif_docx_file~file_path_get        REDEFINITION,
        lif_docx_file~global_namespace_get REDEFINITION,
        lif_docx_file~content_type_get     REDEFINITION,
        lif_docx_file~relation_register    REDEFINITION,
        lif_docx_file~render               REDEFINITION.

    PRIVATE SECTION.

      DATA:
        content_types TYPE ltt_content_type.

  ENDCLASS.                    "lcl_ood_content_types_file  DEFINITIO

* Open Office Document Relations File
  CLASS lcl_ood_relations_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      METHODS:

*       Instance contructor
        constructor
          IMPORTING
            iv_relations_file TYPE string OPTIONAL,

*       Register new relation
        relation_register
          IMPORTING
            value(iv_type)   TYPE string
            value(iv_target) TYPE string
          RETURNING value(rv_id) TYPE string
          RAISING cx_ood_file_exception,

*       Get relations file
        relations_file_get
          RETURNING value(rv_relations_file) TYPE string,

*       Redefinitions
        lif_docx_file~file_name_get        REDEFINITION,
        lif_docx_file~file_path_get        REDEFINITION,
        lif_docx_file~global_namespace_get REDEFINITION,
        lif_docx_file~content_type_get     REDEFINITION,
        lif_docx_file~relation_register    REDEFINITION,
        lif_docx_file~render               REDEFINITION.

    PRIVATE SECTION.

      DATA:
        relations_file TYPE string,
        relations      TYPE ltt_relation,
        counter        TYPE i VALUE 1.
  ENDCLASS.                    "lcl_ood_relations_file  DEFINITIO

* Open Office Document Styles File
  CLASS lcl_ood_styles_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      METHODS:

*       Instance contructor
        constructor
          IMPORTING
            value(iv_default_font) TYPE string
            value(iv_default_size) TYPE i,

*       Add style
        style_add
          IMPORTING
            value(is_style) TYPE lts_docx_style
          RAISING cx_ood_file_exception,

*       Redefinitions
        lif_docx_file~file_name_get       REDEFINITION,
        lif_docx_file~file_path_get       REDEFINITION,
        lif_docx_file~content_type_get    REDEFINITION,
        lif_docx_file~relation_register   REDEFINITION,
        lif_docx_file~render              REDEFINITION.

    PRIVATE SECTION.

      DATA:
        default_font TYPE string,
        default_size TYPE string,
        styles       TYPE ltt_docx_style.

      METHODS:

*       Check consistency before render
        consistency_check
          RAISING cx_ood_file_exception.

  ENDCLASS.                    "lcl_ood_styles_file  DEFINITIO

* Open Office Document Numberings File
  CLASS lcl_ood_numberings_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      METHODS:

*       Add numbering
        numbering_add
          IMPORTING
            value(is_numbering)  TYPE lts_docx_numbering
          RETURNING value(rv_id) TYPE i
          RAISING cx_ood_file_exception,

*       Add numbering level
        numbering_level_add
          IMPORTING
            value(is_numbering_level) TYPE lts_docx_numbering_level
          RAISING cx_ood_file_exception,

*       Redefinitions
        lif_docx_file~file_name_get       REDEFINITION,
        lif_docx_file~file_path_get       REDEFINITION,
        lif_docx_file~content_type_get    REDEFINITION,
        lif_docx_file~relation_register   REDEFINITION,
        lif_docx_file~render              REDEFINITION.

    PRIVATE SECTION.

      DATA:
        numberings  TYPE ltt_docx_numbering,
        levels      TYPE ltt_docx_numbering_level,
        ids_counter TYPE i.

      METHODS:

*       Check consistency before render
        consistency_check
          RAISING cx_ood_file_exception.

  ENDCLASS.                    "lcl_ood_numberings_file  DEFINITIO

* Open Office Document Fonts File
  CLASS lcl_ood_fonts_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      CONSTANTS:
        BEGIN OF font_times_nr,
          name TYPE string VALUE 'Times New Roman',
          panose1 TYPE char20 VALUE '02020603050405020304', charset TYPE char2 VALUE 'EE',
          family TYPE string VALUE 'roman', pitch TYPE string VALUE 'variable',
          csb0 TYPE char8 VALUE '000001FF', csb1 TYPE char8 VALUE '00000000',
          usb0 TYPE char8 VALUE 'E0002AFF', usb1 TYPE char8 VALUE 'C0007841',
          usb2 TYPE char8 VALUE '00000009', usb3 TYPE char8 VALUE '00000000',
        END OF font_times_nr,
        BEGIN OF font_calibri,
          name TYPE string VALUE 'Calibri',
          panose1 TYPE char20 VALUE '020F0502020204030204', charset TYPE char2 VALUE 'EE',
          family TYPE string VALUE 'swiss', pitch TYPE string VALUE 'variable',
          csb0 TYPE char8 VALUE '0000019F', csb1 TYPE char8 VALUE '00000000',
          usb0 TYPE char8 VALUE 'E00002FF', usb1 TYPE char8 VALUE '4000ACFF',
          usb2 TYPE char8 VALUE '00000001', usb3 TYPE char8 VALUE '00000000',
        END OF font_calibri,
        BEGIN OF font_cambria,
          name TYPE string VALUE 'Cambria',
          panose1 TYPE char20 VALUE '02040503050406030204', charset TYPE char2 VALUE 'EE',
          family TYPE string VALUE 'roman', pitch TYPE string VALUE 'variable',
          csb0 TYPE char8 VALUE '0000019F', csb1 TYPE char8 VALUE '00000000',
          usb0 TYPE char8 VALUE 'E00002FF', usb1 TYPE char8 VALUE '400004FF',
          usb2 TYPE char8 VALUE '00000000', usb3 TYPE char8 VALUE '00000000',
        END OF font_cambria,
        BEGIN OF font_tahoma,
          name TYPE string VALUE 'Tahoma',
          panose1 TYPE char20 VALUE '020B0604030504040204', charset TYPE char2 VALUE 'EE',
          family TYPE string VALUE 'swiss', pitch TYPE string VALUE 'variable',
          csb0 TYPE char8 VALUE '000101FF', csb1 TYPE char8 VALUE '00000000',
          usb0 TYPE char8 VALUE 'E1002EFF', usb1 TYPE char8 VALUE 'C000605B',
          usb2 TYPE char8 VALUE '00000029', usb3 TYPE char8 VALUE '00000000',
        END OF font_tahoma,
        BEGIN OF font_courier,
          name TYPE string VALUE 'Courier New',
          panose1 TYPE char20 VALUE '02070309020205020404', charset TYPE char2 VALUE 'EE',
          family TYPE string VALUE 'modern', pitch TYPE string VALUE 'fixed',
          csb0 TYPE char8 VALUE '000001FF', csb1 TYPE char8 VALUE '00000000',
          usb0 TYPE char8 VALUE 'E0002AFF', usb1 TYPE char8 VALUE 'C0007843',
          usb2 TYPE char8 VALUE '00000009', usb3 TYPE char8 VALUE '00000000',
        END OF font_courier,
        BEGIN OF font_public_sans,
          name TYPE string VALUE 'Public Sans',
          panose1 TYPE char20 VALUE '00000000000000000000', charset TYPE char2 VALUE 'EE',
          family TYPE string VALUE 'roman', pitch TYPE string VALUE 'default',
          csb0 TYPE char8 VALUE '000001FF', csb1 TYPE char8 VALUE '00000000',
          usb0 TYPE char8 VALUE 'E0002AFF', usb1 TYPE char8 VALUE 'C0007843',
          usb2 TYPE char8 VALUE '00000009', usb3 TYPE char8 VALUE '00000000',
        END OF font_public_sans.
      METHODS:

*       Add font
        font_add
          IMPORTING
            is_font TYPE lts_docx_font
          RAISING cx_ood_file_exception,

*       Add default font
        default_font_add
          IMPORTING
            value(iv_name) TYPE string
          RAISING cx_ood_file_exception,

*       Redefinitions
        lif_docx_file~file_name_get       REDEFINITION,
        lif_docx_file~file_path_get       REDEFINITION,
        lif_docx_file~content_type_get    REDEFINITION,
        lif_docx_file~relation_register   REDEFINITION,
        lif_docx_file~render              REDEFINITION.

    PRIVATE SECTION.

      DATA:
        fonts TYPE ltt_docx_font.

  ENDCLASS.                    "lcl_ood_fonts_file  DEFINITIO

* Open Office Document file
  CLASS lcl_ood_document_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor,

*       Add element to body
        body_element_add
          IMPORTING
            io_element TYPE REF TO lif_docx_element
          RAISING cx_ood_file_exception,

*>>-> PaM 31.10.2013 16:14:31
*       Add header relation id to document file object
        header_relation_id_add
          IMPORTING
            iv_hdr_rel_id TYPE string,

*       Add footer relation id to document file object
        footer_relation_id_add
          IMPORTING
            iv_ftr_rel_id TYPE string,

*       Get table of header relation ids
        header_relation_ids_get
          EXPORTING
            et_hdr_rel_id TYPE stringtab,

*       Get table of footer relation ids
        footer_relation_ids_get
          EXPORTING
            et_ftr_rel_id TYPE stringtab,
*<-<< PaM 31.10.2013 16:14:31

*       Redefinitions
      lif_docx_file~file_name_get       REDEFINITION,
      lif_docx_file~file_path_get       REDEFINITION,
      lif_docx_file~content_type_get    REDEFINITION,
      lif_docx_file~relation_register   REDEFINITION,
*>>-> PaM 30.10.2013 17:10:48
      lif_docx_file~render              REDEFINITION.
*<-<< PaM 30.10.2013 17:10:48

    PRIVATE SECTION.

      DATA:
        body TYPE REF TO lcl_simple_element.
*>>-> PaM 31.10.2013 16:12:41
      DATA:
        header_relation_ids TYPE TABLE OF string,
        footer_relation_ids TYPE TABLE OF string.
*<-<< PaM 31.10.2013 16:12:41

  ENDCLASS.                    "lcl_ood_document_file  DEFINITIO
*>>-> PaM 30.10.2013 10:54:56 - Doplneni trid pro header a footer
* Open Office Header file
  CLASS lcl_ood_header_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor,

*       Redefinitions
        lif_docx_file~file_name_get       REDEFINITION,
        lif_docx_file~file_path_get       REDEFINITION,
        lif_docx_file~content_type_get    REDEFINITION,
        lif_docx_file~relation_register   REDEFINITION.

    PRIVATE SECTION.

  ENDCLASS.                    "lcl_ood_header_file  DEFINITIO
* Open Office Footer file
  CLASS lcl_ood_footer_file DEFINITION
    INHERITING FROM lcl_file.

    PUBLIC SECTION.

      METHODS:

*       Instance constructor
        constructor,

*       Redefinitions
        lif_docx_file~file_name_get       REDEFINITION,
        lif_docx_file~file_path_get       REDEFINITION,
        lif_docx_file~content_type_get    REDEFINITION,
        lif_docx_file~relation_register   REDEFINITION.

    PRIVATE SECTION.

  ENDCLASS.                    "lcl_ood_header_file  DEFINITIO
*<-<< PaM 30.10.2013 10:54:56

* Office Open Document archive renderer
  CLASS lcl_ood_render DEFINITION.

    PUBLIC SECTION.

      INTERFACES: lif_xml_render.

*     Namespace prefixes
      CONSTANTS:
        ns_prefix_main          TYPE string VALUE 'w',
        ns_prefix_drawing06     TYPE string VALUE 'wp',
        ns_prefix_drawing10     TYPE string VALUE 'wp14',
        ns_prefix_compatibility TYPE string VALUE 'mc',
        ns_prefix_relationship  TYPE string VALUE 'r',
        ns_prefix_content_types TYPE string VALUE 'ct'.

      METHODS:

*       Instance constructor
        constructor,

*       Save rendered document to file
        save_to_file
          IMPORTING
            value(iv_target_file_path) TYPE string
            value(iv_encoding)         TYPE string OPTIONAL
            value(iv_location)         TYPE dxlocation DEFAULT 'P'
          RAISING cx_ood_render_exception.
      .

    PRIVATE SECTION.

      DATA:
        content_types      TYPE REF TO lcl_ood_content_types_file,
        relations          TYPE ltt_file,
        documents          TYPE ltt_archive_document,
        finals             TYPE ltt_archive_document,
        global_namespace   TYPE lts_namespace,
        current_namespaces TYPE ltt_namespace,
        current_document   TYPE lts_archive_document,
        current_element    TYPE REF TO if_ixml_element,
        ixml               TYPE REF TO if_ixml,
        final              TYPE flag.

      METHODS:

*       Register relation for file
        relation_register
          IMPORTING
            io_docx_file TYPE REF TO lif_docx_file
          RAISING cx_ood_render_exception,

*       Check prefix
        prefix_check
          IMPORTING
            value(iv_prefix) TYPE string
          RAISING cx_ood_render_exception,

*       Final render document
        render_final
        RAISING cx_ood_render_exception,

*       Render document to archive
        document_to_archive_render
          IMPORTING
            io_archive         TYPE REF TO cl_abap_zip
            is_document        TYPE lts_archive_document
            value(iv_encoding) TYPE string OPTIONAL
          RAISING cx_ood_render_exception,

*       Save archive to frontend
        archive_to_frontend
          IMPORTING
            io_archive                 TYPE REF TO cl_abap_zip
            value(iv_target_file_path) TYPE string
          RAISING cx_ood_render_exception,

*       Save archive to application server
        archive_to_appl_srv
          IMPORTING
            io_archive                 TYPE REF TO cl_abap_zip
            value(iv_target_file_path) TYPE string
          RAISING cx_ood_render_exception,

        namespace_add
          IMPORTING
            value(iv_prefix) TYPE string
            value(iv_uri)    TYPE string.
  ENDCLASS.                    "lcl_ood_render DEFINITION

* ----------------------------------------------------------------------
* DEFINITION
* ----------------------------------------------------------------------

* Simple macro for adding attributes to local table
  DEFINE lmc_attribute.
    ls_attribute-name   = &1.
    ls_attribute-prefix = &2.
    ls_attribute-value  = &3.
    append ls_attribute to lt_attributes.
  END-OF-DEFINITION.

* Simple macro for attributes refresh
  DEFINE lmc_attributes_clear.
    clear lt_attributes.
  END-OF-DEFINITION.

* Simple macro for new element
  DEFINE lmc_element.
    create object &1
      exporting
        iv_name       = &2
        iv_prefix     = &3
        it_attributes = lt_attributes.
  END-OF-DEFINITION.
* Simple for number to string conversion
  DEFINE lmc_num2str.
    lv_str = &1.
    condense lv_str no-gaps.
  END-OF-DEFINITION.