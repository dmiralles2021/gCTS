method GET_TAB_PREFERRED_LANGU.

* IV_MOST_PREFERRED_LANGU tells us which langu we should prefer.
* In various situations, if we can't find the desired thing in this most preferred langu,
*  then we'll use a different language.
* But not randomly (we prefer English to, for example, Vietnamiese).
* This method returns the list of languages we prefer;
*  the lower index (position) in table, the more preferred it is.

  clear rt_preferred_langu[].

  if iv_most_preferred_langu is not INITIAL.
    APPEND iv_most_preferred_langu TO rt_preferred_langu .
  endif.
  if sy-langu NE iv_most_preferred_langu.
    append sy-langu to rt_preferred_langu .
  ENDIF.
* And then the less preferred ones (sorted descending by preferrence):
  APPEND 'E' TO rt_preferred_langu. "English
  APPEND 'D' TO rt_preferred_langu. "German
  APPEND 'C' TO rt_preferred_langu. "Czech
  APPEND 'S' TO rt_preferred_langu. "Slovak


endmethod.