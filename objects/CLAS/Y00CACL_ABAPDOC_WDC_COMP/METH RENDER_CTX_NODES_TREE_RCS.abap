method RENDER_CTX_NODES_TREE_RCS.

  DATA: lv_text     TYPE string,
        lt_text     TYPE stringtab,
        lv_tree_lev LIKE iv_tree_level.

  DATA: lt_ctx_nodes_sort LIKE it_ctx_nodes,
        wa_ctx_node       LIKE LINE OF lt_ctx_nodes_sort.

* tree level
  lv_tree_lev = iv_tree_level.
  ADD 1 TO lv_tree_lev.   " increasing tree level (must be outside the loop)

* table sorting to get the context nodes and attrs in the same order as they appear in webdynpro
  lt_ctx_nodes_sort[] = it_ctx_nodes[].
  SORT lt_ctx_nodes_sort BY node_position ASCENDING.


* getting node
  LOOP AT lt_ctx_nodes_sort INTO wa_ctx_node WHERE parent_node_name EQ iv_parent_nd_name.
    CLEAR lv_text.
*   writting down the node name
    lv_text = wa_ctx_node-node_name.
    APPEND lv_text TO lt_text.

    io_render->add_wd_ctx_node( EXPORTING it_text = lt_text
                                          iv_tree_level = iv_tree_level ).
    CLEAR lt_text.

*   getting subnodes
    me->render_ctx_nodes_tree_rcs( EXPORTING io_render         = io_render
                                             iv_parent_nd_name = wa_ctx_node-node_name
                                             iv_tree_level     = lv_tree_lev
                                             it_ctx_nodes      = it_ctx_nodes
                                             it_ctx_attrs      = it_ctx_attrs ).

*   getting list of node's attributes
    me->render_ctx_attrs( EXPORTING io_render     = io_render
                                    iv_node_name  = wa_ctx_node-node_name
                                    iv_tree_level = lv_tree_lev
                                    it_ctx_attrs  = it_ctx_attrs ).
  ENDLOOP.

endmethod.