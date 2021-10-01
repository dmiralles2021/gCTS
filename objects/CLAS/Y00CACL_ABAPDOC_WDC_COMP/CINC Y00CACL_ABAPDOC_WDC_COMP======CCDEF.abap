*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature

TYPE-POOLS: wdywb.

TYPES:  BEGIN OF ts_my_wdy_vsh_node,
          component_name    TYPE wdy_component_name,
          window_name	      TYPE wdy_window_name,
          vsh_node_name	    TYPE wdy_vsh_node_name,
          version	          TYPE r3state,
          vsh_node_type	    TYPE wdy_md_object_type,
          pholder_owner	    TYPE wdy_vsh_node_name,
          pholder_name      TYPE wdy_vsh_placeholder_name,
          used_component    TYPE wdy_component_name,
          used_view	        TYPE wdy_view_name,
          display_name      TYPE wdy_md_object_name,
          vset_definition	  TYPE wdy_viewset_definition_name,
          component_usage	  TYPE wdy_component_usage_name,
          def_inbound_plug  TYPE wdy_event_name,

          name_comp         TYPE string,
        END OF ts_my_wdy_vsh_node.

TYPES: tt_my_wdy_vsh_node_table TYPE TABLE OF ts_my_wdy_vsh_node.