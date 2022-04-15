*----------------------------------------------------------------------*
*       CLASS ZCL_SEND_MAIL DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_SEND_MAIL definition
  public
  abstract
  create public .

public section.

  constants:
    BEGIN OF c,
        filename_tag_prefix TYPE char13 VALUE '&SO_FILENAME=',
      END OF c .

  class-methods INIT_SEND_REQUEST
    importing
      !IV_SUBJECT type STRING
      !IV_BODY_TYPE type SO_OBJ_TP default 'RAW'
      !IT_BODY_TEXT type SOLI_TAB
    returning
      value(RO_SENDER) type ref to ZCL_SEND_MAIL
    raising
      ZCX_MAIL_SEND .
  class-methods INIT_UPDATE_TASK_SEND_REQUEST
    importing
      !IV_SUBJECT type STRING
      !IV_BODY_TYPE type SO_OBJ_TP default 'RAW'
      !IT_BODY_TEXT type SOLI_TAB
    returning
      value(RO_SENDER) type ref to ZCL_SEND_MAIL
    raising
      ZCX_MAIL_SEND .
  methods SET_SENDER
  abstract
    importing
      !IV_UNAME type SYUNAME optional
      !IV_MAIL type AD_SMTPADR optional
    preferred parameter IV_MAIL
    raising
      ZCX_MAIL_SEND .
  methods ADD_RECIPIENT
  abstract
    importing
      !IV_UNAME type SYUNAME optional
      !IV_MAIL type AD_SMTPADR optional
    preferred parameter IV_MAIL
    raising
      ZCX_MAIL_SEND .
  methods ADD_SOLI_ATTACHMENT
  abstract
    importing
      !IV_EXT type SO_OBJ_TP
      !IV_TITLE type SO_OBJ_DES
      !IT_CONTENT type SOLI_TAB
    raising
      ZCX_MAIL_SEND .
  methods ADD_SOLIX_ATTACHMENT
  abstract
    importing
      !IV_EXT type SO_OBJ_TP
      !IV_TITLE type SO_OBJ_DES
      !IT_HEXCONTENT type SOLIX_TAB
    raising
      ZCX_MAIL_SEND .
  methods SEND
  abstract
    raising
      ZCX_MAIL_SEND .
  methods SEND_WITH_COMMIT
  abstract
    raising
      ZCX_MAIL_SEND .
  methods SEND_WITH_COMMIT_AND_WAIT
  abstract
    raising
      ZCX_MAIL_SEND .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SEND_MAIL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SEND_MAIL=>INIT_SEND_REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SUBJECT                     TYPE        STRING
* | [--->] IV_BODY_TYPE                   TYPE        SO_OBJ_TP (default ='RAW')
* | [--->] IT_BODY_TEXT                   TYPE        SOLI_TAB
* | [<-()] RO_SENDER                      TYPE REF TO ZCL_SEND_MAIL
* | [!CX!] ZCX_MAIL_SEND
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD INIT_SEND_REQUEST .


  ro_sender = new lcl_mail_send( iv_subject  = iv_subject
                                iv_body_type = iv_body_type
                                it_body_text = it_body_text
                               ).

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SEND_MAIL=>INIT_UPDATE_TASK_SEND_REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SUBJECT                     TYPE        STRING
* | [--->] IV_BODY_TYPE                   TYPE        SO_OBJ_TP (default ='RAW')
* | [--->] IT_BODY_TEXT                   TYPE        SOLI_TAB
* | [<-()] RO_SENDER                      TYPE REF TO ZCL_SEND_MAIL
* | [!CX!] ZCX_MAIL_SEND
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD INIT_UPDATE_TASK_SEND_REQUEST .
*  DATA:
*    lo_mail_sender_in_upd_task TYPE REF TO lcl_mail_send_in_update_task.
  ro_sender = new lcl_mail_send_in_update_task( iv_subject   = iv_subject
                                                iv_body_type = iv_body_type
                                                it_body_text = it_body_text
                                               ).

*  ro_sender = lo_mail_sender_in_upd_task.

ENDMETHOD.
ENDCLASS.
