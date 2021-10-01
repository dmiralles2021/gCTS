method ADD_WD_CONTEXT.

  DATA: lv_text   TYPE string,
        lt_text   TYPE stringtab.
  DATA: wa_ctx_attr LIKE LINE OF it_ctx_attrs.


  CHECK io_render IS BOUND.

* note
  lv_text = 'Context'.
  APPEND lv_text TO lt_text.
  io_render->add_description( lt_text ).

  IF LINES( it_ctx_nodes ) GT 1 OR " at least 2 nodes needed because the first one is always 'CONTEXT'
     LINES( it_ctx_attrs ) GT 0.

*   getting nodes and it's attributes
    me->render_ctx_nodes_tree_rcs( EXPORTING io_render         = io_render
                                             iv_parent_nd_name = 'CONTEXT'
                                             iv_tree_level     = 1
                                             it_ctx_nodes      = it_ctx_nodes[]
                                             it_ctx_attrs      = it_ctx_attrs ).

*   getting list of attributes which has no parent node
    me->render_ctx_attrs( EXPORTING io_render     = io_render
                                    iv_node_name  = 'CONTEXT'
                                    iv_tree_level = 0
                                    it_ctx_attrs  = it_ctx_attrs ).

  ELSE.
    CLEAR lt_text.
    lv_text = '-'.
    APPEND lv_text TO lt_text.
    io_render->add_text( lt_text ).
  ENDIF.

* empty line
  me->render_empty_line( io_render ).

endmethod.