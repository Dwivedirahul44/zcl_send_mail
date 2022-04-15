class ZCX_MAIL_SEND definition
  public
  inheriting from CX_STATIC_CHECK
  final.

public section.

  data V_TEXT type STRING read-only .
  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !V_TEXT type STRING optional .
 protected section.
*"* protected components of class ZCX_CRT
*"* do not include other source files here!!!
private section.
*"* private components of class ZCX_CRT
*"* do not include other source files here!!!
ENDCLASS.

CLASS ZCX_MAIL_SEND IMPLEMENTATION.
* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCX_CRT->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] V_TEXT                        TYPE        STRING(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        textid   = textid
        previous = previous.
    me->v_text = v_text .
  ENDMETHOD.
ENDCLASS.     
