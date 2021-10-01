*&---------------------------------------------------------------------*
*&  Include           ZKCT_ABAP_DOC_DTA
*&---------------------------------------------------------------------*
*/------------------------DATA----------------------------\

TABLES: sscrfields, e071, e07t.

TYPE-POOLS: icon, slis, sabc, stms, trwbo.

************************************************************************
TYPES: BEGIN OF t_plugin,
         object TYPE ko100-object,
         text   TYPE ko100-text,
       END OF t_plugin.

DATA: gv_file_name         TYPE string,

      go_main_obj          TYPE REF TO y00cacl_abapdoc_main,
      go_render            TYPE REF TO y00caif_abapdoc_render,
      go_xml_document      TYPE REF TO cl_xml_document,
      gt_fieldcat          TYPE slis_t_fieldcat_alv,
      gs_layout            TYPE slis_layout_alv,

      g_text               TYPE stextt,

* --> ZOLDOSP (10.01.2014 10:54:08): *************************
      go_picture_control_1 TYPE REF TO  cl_gui_picture,
      gv_alv_mode          TYPE c LENGTH 7.

CONSTANTS: cv_alv_init   LIKE gv_alv_mode VALUE 'alv_ini',
           cv_alv_result LIKE gv_alv_mode VALUE 'alv_res'.
* <-- konec úpravy ******************************************

CONSTANTS:
  cv_logo_ss_top    TYPE i VALUE 8,
  cv_logo_ss_height TYPE i VALUE  38, " 40,
* --> ZOLDOSP (18.07.2014 09:58:39): Úprava loga na výběrové obrazovce i v ALV top of page: *
* obrázek nahrán přes transakci SMW0! :
  cv_logo_ss_name   TYPE w3_qvalue  VALUE 'Y00CAIMG_ILLUMIT_LOGO',"'ZKCT_ABAP_DOC_PAPERWORK_GIF' , "'ZKCT_ABAP_DOC__PAPERWORK3_EN_JPG',
  cv_logo_ss_width  TYPE i VALUE 397, "418, "255 "(pro Z_PERF_BY_KCTDATA_LOGO)
  cv_logo_ss_left   TYPE i VALUE 550, "690 "(pro Z_PERF_BY_KCTDATA_LOGO)
  " obrázek nahrán přes transakci OAER! :
  cv_logo_alv_name  TYPE w3_qvalue  VALUE 'Y00CAIMG_ILLUMIT_LOGO'." . "'ZKCT_ABAPDOC_PPWORK_OAER'.
* <-- konec úpravy ******************************************


*\--------------------------------------------------------------------/