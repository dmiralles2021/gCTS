method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = Y00cacx_ABAPDOC_RENDER .
 ENDIF.
me->MESSAGES = MESSAGES .
endmethod.