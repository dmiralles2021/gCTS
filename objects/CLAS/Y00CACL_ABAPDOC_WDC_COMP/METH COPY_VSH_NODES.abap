method COPY_VSH_NODES.

  DATA: lv_name_comp      TYPE string,

        lv_pholder_owner  TYPE string.

  FIELD-SYMBOLS: <fs_vsh_nodes>     LIKE LINE OF it_vsh_nodes,
                 <fs_vsh_nodes2>    LIKE LINE OF it_vsh_nodes,
                 <fs_my_vsh_nodes>  LIKE LINE OF gt_my_vsh_nodes.

  IF LINES( it_vsh_nodes ) > 0.

    LOOP AT it_vsh_nodes ASSIGNING <fs_vsh_nodes>.

      lv_name_comp = <fs_vsh_nodes>-used_view.
      lv_pholder_owner = <fs_vsh_nodes>-pholder_owner.
      WHILE lv_pholder_owner IS NOT INITIAL.
        READ TABLE it_vsh_nodes WITH key vsh_node_name = lv_pholder_owner ASSIGNING <fs_vsh_nodes2>.
        if sy-subrc = 0.
          lv_pholder_owner = <fs_vsh_nodes2>-pholder_owner.
          CONCATENATE <fs_vsh_nodes2>-used_view lv_name_comp INTO lv_name_comp SEPARATED BY '.'.
        else.
          clear lv_pholder_owner.
        endif.
      ENDWHILE.

      CONCATENATE <fs_vsh_nodes>-window_name lv_name_comp INTO lv_name_comp SEPARATED BY '.'.
      APPEND INITIAL LINE TO gt_my_vsh_nodes ASSIGNING <fs_my_vsh_nodes>.
      MOVE-CORRESPONDING <fs_vsh_nodes> to <fs_my_vsh_nodes>.
      <fs_my_vsh_nodes>-name_comp = lv_name_comp.

    ENDLOOP.

    SORT gt_my_vsh_nodes BY name_comp.

  ENDIF.

endmethod.