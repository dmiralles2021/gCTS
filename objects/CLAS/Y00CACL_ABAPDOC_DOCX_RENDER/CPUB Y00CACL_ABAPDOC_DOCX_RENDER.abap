class Y00CACL_ABAPDOC_DOCX_RENDER definition
  public
  create public .

*"* public components of class Y00CACL_ABAPDOC_DOCX_RENDER
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  interfaces Y00CAIF_ABAPDOC_RENDER .

  constants STYLE_NORMAL_BOLD type STRING value 'NBold' ##NO_TEXT.
  constants STYLE_CHAPTER type STRING value 'Ctitle' ##NO_TEXT.
  constants STYLE_OBJECT type STRING value 'Otitle' ##NO_TEXT.
  constants STYLE_SUBOBJECT type STRING value 'Stitle' ##NO_TEXT.
  constants STYLE_SUBOBJECT2 type STRING value 'Stitle2' ##NO_TEXT.
  constants STYLE_DESCRIPTION type STRING value 'Descr' ##NO_TEXT.
  constants STYLE_DESCRIPTION_2 type STRING value 'Descr2' ##NO_TEXT.
  constants STYLE_COMMENT type STRING value 'Comnt' ##NO_TEXT.
  constants STYLE_TABLE type STRING value 'Table1' ##NO_TEXT.
  constants STYLE_TABLE_HEADER type STRING value 'TabHdr' ##NO_TEXT.
  constants STYLE_WD_CTX_ATTR type STRING value 'WdCtAt' ##NO_TEXT.
  constants STYLE_WD_CTX_NODE type STRING value 'WdCtNd' ##NO_TEXT.
  constants STYLE_WD_LAYOUT_ITEM type STRING value 'WdLayIt' ##NO_TEXT.

  methods CONSTRUCTOR
    raising
      Y00CACX_ABAPDOC_RENDER .