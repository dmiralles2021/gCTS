method OLE_WORD_ADD_INFO.

  data: classdescr        type ref to cl_abap_classdescr,
        typedescr         type ref to cl_abap_typedescr,
        superclass        type ref to cl_abap_typedescr,
        oref              type ref to cx_root.

  data: lv_classname      type seoclsname,
        lv_objtype        type string,
        classkey          type seoclskey,
        classproperties   type vseoclass,
        lv_text           type string,
        ls_ole_actdoc     type ole2_object,
        lv_textid         type sotr_conc,
        text              type string,
        superclassname    type string,
        superclasskey     type seorelkey,
        inheritanceprops  type vseoextend,
        lv_classprop      type string,
        attribkey         type seocmpkey,
        attribdescr       type abap_attrdescr,
        attribproperties  type vseoattrib,
        methoddescr       type abap_methdescr,
        methodkey         type seocpdkey,
        clsmethkey        type seocmpkey,
        methodproperties  type vseomethod,
        ls_ole_selection  type ole2_object,
        ls_ole_font       type ole2_object,
        ls_ole_paragraphs type ole2_object,
        ls_ole_tables     type ole2_object,
        ls_ole_table      type ole2_object,
        ls_ole_border     type ole2_object,
        ls_ole_range      type ole2_object.

  data: redefines         type standard table of seoredef
                          with key clsname refclsname version mtdname.

  lv_classname = gv_obj_name.
  classkey-clsname = gv_obj_name.

  lv_objtype = get_object_type( ).

* Class info reading
  call function 'SEO_CLASS_GET'
    exporting
      clskey       = classkey
      version      = '1'
    importing
      class        = classproperties
    exceptions
      not_existing = 1
      deleted      = 2
      is_interface = 3
      model_only   = 4.
  if sy-subrc <> 0.
    case sy-subrc.
      when 1.
        raise exception type y00cacx_abapdoc
          exporting
            textid = y00cacx_abapdoc=>not_found.
      when 2.
        message i102(y00camsg_abpdoc) into lv_text.
        raise exception type y00cacx_abapdoc
          exporting
            textid = y00cacx_abapdoc=>error_message
            msg    = 'class deleted'.
      when 3.
        raise exception type y00cacx_abapdoc
          exporting
            textid = y00cacx_abapdoc=>error_message
            msg    = 'interfaces not supported'.
      when 4.
        raise exception type y00cacx_abapdoc
          exporting
            textid = y00cacx_abapdoc=>error_message
            msg    = 'class is modeled only'.
    endcase.
  else.

    get property of is_ole_word 'Selection' = ls_ole_selection.
    get property of ls_ole_selection 'Font' = ls_ole_font .
    call method of
      ls_ole_selection
      'EndKey'
      exporting
        #1 = '6'.

* Font setup and headline writing
    message i102(y00camsg_abpdoc) with is_object_alv-obj_type_txt is_object_alv-obj_name into lv_text.
    set property of ls_ole_font 'Bold' = '1' . "Bold
    set property of ls_ole_font 'Size' = '14' .
    call method of
      ls_ole_selection
      'TypeText'
      exporting
        #1 = lv_text.
    set property of ls_ole_font 'Size' = '10' .
    set property of ls_ole_font 'Bold' = '0' . "Not bold
    call method of
      ls_ole_selection
      'TypeParagraph'.

* Intend to the left
    get property of ls_ole_selection 'Paragraphs' = ls_ole_paragraphs.
    call method of
      ls_ole_paragraphs
      'Indent'.
  endif.

  try.
      call method cl_abap_classdescr=>describe_by_name
        exporting
          p_name         = gv_obj_name
        receiving
          p_descr_ref    = typedescr
        exceptions
          type_not_found = 1.
      classdescr ?= typedescr.
    catch cx_root into oref.
      lv_textid = y00cacx_abapdoc=>error_message.
      text = oref->get_text( ).
      raise exception type y00cacx_abapdoc
        exporting
          textid = lv_textid
          msg    = text.
  endtry.

*----------------------------------
* Find out info about the superclass
*----------------------------------
  classdescr->get_super_class_type( receiving  p_descr_ref           = superclass
                                    exceptions super_class_not_found = 1 ).

  if sy-subrc = 0.
    superclassname = superclass->get_relative_name( ).
    if not superclassname cs 'OBJECT'.
      superclasskey-clsname = gv_obj_name.
      superclasskey-refclsname = superclassname.

      call function 'SEO_INHERITANC_GET'
        exporting
          inhkey        = superclasskey
        importing
          inheritance   = inheritanceprops
          redefinitions = redefines.
    endif.
  endif.

* -------------------------
* Class info creation
* -------------------------

* Create a table with Class information
  get property of is_ole_word 'ActiveDocument' = ls_ole_actdoc .
  get property of ls_ole_actdoc 'Tables' = ls_ole_tables .
  get property of ls_ole_selection 'Range' = ls_ole_range .

  call method of
    ls_ole_tables
    'Add' = ls_ole_table
    exporting
      #1 = ls_ole_range " Handle for range entity
      #2 = '2' "is_plugin-count "Number of rows
      #3 = '2' "Number of columns
      #4 = '1'  "wdWord9TableBehavior
      #5 = '1'. "wdAutoFitContent
*-- Setup without a frme
  get property of ls_ole_table 'Borders' = ls_ole_border .
  set property of ls_ole_border 'Enable' = '0' .

  lv_classprop = classproperties-descript.

  message i104(y00camsg_abpdoc) into lv_text.
  me->ole_word_add_info_row( is_ole_font      = ls_ole_font
                             is_ole_selection = ls_ole_selection
                             iv_header        = lv_text
                             iv_text          = lv_classprop ).

  if superclassname is not initial.
    message i105(y00camsg_abpdoc) into lv_text.
    me->ole_word_add_info_row( is_ole_font      = ls_ole_font
                               is_ole_selection = ls_ole_selection
                               iv_header        = lv_text
                               iv_text          = superclassname ).
  endif.

  get property of is_ole_word 'Selection' = ls_ole_selection.
  get property of ls_ole_selection 'Font' = ls_ole_font .
  call method of
    ls_ole_selection
    'EndKey'
    exporting
      #1 = '6'.

* Intend to the right
  call method of
    ls_ole_paragraphs
    'Outdent'.
  call method of
    ls_ole_selection
    'TypeParagraph'.

*---------------------------------------------
* Table creation with attributes information
*---------------------------------------------
  get property of is_ole_word 'ActiveDocument' = ls_ole_actdoc .
  get property of ls_ole_actdoc 'Tables' = ls_ole_tables .
  get property of ls_ole_selection 'Range' = ls_ole_range .

  data lv_row type i.

  describe table classdescr->attributes lines lv_row.

  lv_row = lv_row + 1.

  call method of
    ls_ole_tables
    'Add' = ls_ole_table
    exporting
      #1 = ls_ole_range " Handle for range entity
      #2 = lv_row "is_plugin-count "Number of rows
      #3 = '4' "Number of columns
      #4 = '1'  "wdWord9TableBehavior
      #5 = '1'. "wdAutoFitContent
*-- Setup with a frame
  get property of ls_ole_table 'Borders' = ls_ole_border .
  set property of ls_ole_border 'Enable' = '1' . "No border

* Attributes names
  message i200(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 =  lv_text.

* Move to the right by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Atributes description
  message i201(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the left by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Visibility
  message i202(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by the column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Inherited
  message i203(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by the column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

  attribkey-clsname = gv_obj_name.

  loop at classdescr->attributes into attribdescr.
    attribkey-cmpname = attribdescr-name.

* Attributes description
    call method of
      ls_ole_selection
      'TypeText'
      exporting
        #1 = attribdescr-name.

* Move to the right by one column
    call method of
      ls_ole_selection
      'MoveRight'
      exporting
        #1 = '1' "wdLine,
        #2 = '1'.

* Attributes description
    call function 'SEO_ATTRIBUTE_GET'
      exporting
        attkey    = attribkey
      importing
        attribute = attribproperties.
    if attribproperties-descript is not initial.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = attribproperties-descript.
    else.
      message i204(y00camsg_abpdoc) into lv_text.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = lv_text.
    endif.

* Move to the right by the column
    call method of
      ls_ole_selection
      'MoveRight'
      exporting
        #1 = '1' "wdLine,
        #2 = '1'.

* Visibility
    case attribdescr-visibility.

* Public
      when 'U'.
        message i205(y00camsg_abpdoc) into lv_text.
        call method of
          ls_ole_selection
          'TypeText'
          exporting
            #1 = lv_text.

* Move to the right by the column
        call method of
          ls_ole_selection
          'MoveRight'
          exporting
            #1 = '1' "wdLine,
            #2 = '1'.

* Protected
      when 'O'.
        message i206(y00camsg_abpdoc) into lv_text.
        call method of
          ls_ole_selection
          'TypeText'
          exporting
            #1 = lv_text.

* Move to the right by one column
        call method of
          ls_ole_selection
          'MoveRight'
          exporting
            #1 = '1' "wdLine,
            #2 = '1'.
      when 'I'.

* Private
        message i207(y00camsg_abpdoc) into lv_text.
        call method of
          ls_ole_selection
          'TypeText'
          exporting
            #1 = lv_text.

* Move to the right by one column
        call method of
          ls_ole_selection
          'MoveRight'
          exporting
            #1 = '1' "wdLine,
            #2 = '1'.
    endcase.

* Inherited ?
    if attribdescr-is_inherited = abap_true.
      message i208(y00camsg_abpdoc) into lv_text.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = lv_text.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    else.
      message i209(y00camsg_abpdoc) into lv_text.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = lv_text.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    endif.

  endloop.

  get property of is_ole_word 'Selection' = ls_ole_selection.
  get property of ls_ole_selection 'Font' = ls_ole_font .
  call method of
    ls_ole_selection
    'EndKey'
    exporting
      #1 = '6'.

  call method of
    ls_ole_selection
    'TypeParagraph'.

*-------------------------------------------
* Table creation with the information about methods
*-------------------------------------------
  get property of is_ole_word 'ActiveDocument' = ls_ole_actdoc .
  get property of ls_ole_actdoc 'Tables' = ls_ole_tables .
  get property of ls_ole_selection 'Range' = ls_ole_range .

  clear lv_row.
  describe table classdescr->methods lines lv_row.

  lv_row = lv_row + 1.

  call method of
    ls_ole_tables
    'Add' = ls_ole_table
    exporting
      #1 = ls_ole_range " Handle for range entity
      #2 = lv_row "is_plugin-count "Number of rows
      #3 = '6' "Number of columns
      #4 = '1'  "wdWord9TableBehavior
      #5 = '1'. "wdAutoFitContent

* Setup with a frame
  get property of ls_ole_table 'Borders' = ls_ole_border .
  set property of ls_ole_border 'Enable' = '1' . "No border

* Method name
  message i210(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Method description
  message i201(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Visibility
  message i202(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Inheritied
  message i203(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Re-defined
  message i211(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.

* Abstract
  message i212(y00camsg_abpdoc) into lv_text.
  set property of ls_ole_font 'Bold' = '1'.
  call method of
    ls_ole_selection
    'TypeText'
    exporting
      #1 = lv_text.

* Move to the right by one column
  call method of
    ls_ole_selection
    'MoveRight'
    exporting
      #1 = '1'
      #2 = '1'.


* Methods
  loop at classdescr->methods into methoddescr.
    methodkey-cpdname = methoddescr-name.


* Method name
    call method of
      ls_ole_selection
      'TypeText'
      exporting
        #1 = methoddescr-name.

* Move to the right by one column
    call method of
      ls_ole_selection
      'MoveRight'
      exporting
        #1 = '1' "wdLine,
        #2 = '1'.

* Method description
    clsmethkey-clsname = lv_classname.
    clsmethkey-cmpname = methoddescr-name.

    call function 'SEO_METHOD_GET'
      exporting
        mtdkey       = clsmethkey
      importing
        method       = methodproperties
      exceptions
        not_existing = 1.
    if sy-subrc = 0.

      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = methodproperties-descript.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    else.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = 'Missing'.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    endif.

* Visibility
    case methoddescr-visibility.

* Public
      when 'U'.
        message i205(y00camsg_abpdoc) into lv_text.
        call method of
          ls_ole_selection
          'TypeText'
          exporting
            #1 = lv_text.

* Move to the right by one column
        call method of
          ls_ole_selection
          'MoveRight'
          exporting
            #1 = '1' "wdLine,
            #2 = '1'.

* Protected
      when 'O'.
        message i206(y00camsg_abpdoc) into lv_text.
        call method of
          ls_ole_selection
          'TypeText'
          exporting
            #1 = lv_text.

* Move to the right by one column
        call method of
          ls_ole_selection
          'MoveRight'
          exporting
            #1 = '1' "wdLine,
            #2 = '1'.
      when 'I'.

* Private
        message i207(y00camsg_abpdoc) into lv_text.
        call method of
          ls_ole_selection
          'TypeText'
          exporting
            #1 = lv_text.

* Move to the right by one column
        call method of
          ls_ole_selection
          'MoveRight'
          exporting
            #1 = '1' "wdLine,
            #2 = '1'.
    endcase.

* Inherited methods
    if methoddescr-is_inherited = abap_true.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = 'Yes'.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    else.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = 'No'.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    endif.

* Re-defined method
    if methoddescr-is_redefined = abap_true.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = 'Yes'.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    else.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = 'No'.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    endif.

* Abstract methods
    if methoddescr-is_abstract = abap_true.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = 'Yes'.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    else.
      call method of
        ls_ole_selection
        'TypeText'
        exporting
          #1 = 'No'.

* Move to the right by one column
      call method of
        ls_ole_selection
        'MoveRight'
        exporting
          #1 = '1' "wdLine,
          #2 = '1'.
    endif.

  endloop.

  get property of is_ole_word 'Selection' = ls_ole_selection.
  get property of ls_ole_selection 'Font' = ls_ole_font .
  call method of
    ls_ole_selection
    'EndKey'
    exporting
      #1 = '6'.

  call method of
    ls_ole_selection
    'TypeParagraph'.

endmethod.