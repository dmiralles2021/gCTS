method ADD_NA_TO_TITLE.

* This methods appends a suffix ' - N/A' to the title which we are going to output
* It indicates

  data lv_text type string.
  MESSAGE i111(y00camsg_abpdoc) INTO lv_text.  "  ' – N/A'
  CONCATENATE CV_TITLE  lv_text into cv_title SEPARATED BY space.
endmethod.