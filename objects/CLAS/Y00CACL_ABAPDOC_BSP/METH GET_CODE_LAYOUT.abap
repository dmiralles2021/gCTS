METHOD GET_CODE_LAYOUT.

  DATA: lv_text       TYPE string.

  FIELD-SYMBOLS: <fs_pageline> LIKE LINE OF it_pageline.

  CLEAR rt_text.

* Processing
  LOOP AT it_pageline ASSIGNING <fs_pageline>.
    IF <fs_pageline> IN it_key_words AND NOT it_key_words IS INITIAL .
      lv_text = <fs_pageline>.
      APPEND lv_text TO rt_text.
    ENDIF.
  ENDLOOP.

ENDMETHOD.