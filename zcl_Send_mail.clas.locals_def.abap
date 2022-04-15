*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
*----------------------------------------------------------------------*
*       CLASS lcl_main DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_mail_send DEFINITION INHERITING FROM zcl_send_mail.

  PUBLIC SECTION.

    METHODS:
      constructor                IMPORTING iv_subject   TYPE string
                                           iv_body_type TYPE so_obj_tp DEFAULT 'RAW'
                                           it_body_text TYPE soli_tab
                                 RAISING   zcx_mail_send,

      set_sender                 REDEFINITION,
      add_recipient              REDEFINITION,
      add_soli_attachment        REDEFINITION,
      add_solix_attachment       REDEFINITION,
      send                       REDEFINITION,
      send_with_commit           REDEFINITION,
      send_with_commit_and_wait  REDEFINITION
      .

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA:
      o_send_request TYPE REF TO cl_bcs,
      o_document     TYPE REF TO cl_document_bcs.

ENDCLASS.  "lcl_main
CLASS lcl_mail_send IMPLEMENTATION.
  METHOD constructor .

    super->constructor( ).
    TRY.
        me->o_send_request = cl_bcs=>create_persistent( ).

        me->o_send_request->set_message_subject( iv_subject ).

        me->o_document = cl_document_bcs=>create_document( i_type    = iv_body_type
                                                           i_text    = it_body_text
                                                           i_subject = CONV #( iv_subject ) ).
      CATCH cx_send_req_bcs
            cx_document_bcs INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).
    ENDTRY.

  ENDMETHOD.
  METHOD set_sender .
    DATA:
      lo_sender TYPE REF TO if_sender_bcs.

    TRY.
        IF iv_mail IS SUPPLIED.
          lo_sender = cl_cam_address_bcs=>create_internet_address( iv_mail ).
        ELSEIF iv_uname IS SUPPLIED.
          lo_sender = cl_sapuser_bcs=>create( iv_uname ).
        ELSE.
          lo_sender = cl_sapuser_bcs=>create( syst-uname ).
        ENDIF.

        me->o_send_request->set_sender( lo_sender ).

      CATCH cx_address_bcs
            cx_send_req_bcs INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).

    ENDTRY.
  ENDMETHOD.
  METHOD add_recipient .
    DATA:

      lo_recipient TYPE REF TO if_recipient_bcs.
    TRY.

        IF iv_mail IS SUPPLIED.
          lo_recipient = cl_cam_address_bcs=>create_internet_address( iv_mail ).
        ELSEIF iv_uname IS SUPPLIED.
          lo_recipient = cl_sapuser_bcs=>create( iv_uname ).
        ELSE.
          lo_recipient = cl_sapuser_bcs=>create( syst-uname ).
        ENDIF.

        me->o_send_request->add_recipient( lo_recipient ).
      CATCH cx_address_bcs
            cx_send_req_bcs INTO DATA(lo_error) .

        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).

    ENDTRY.
  ENDMETHOD.
  METHOD add_soli_attachment .
    TRY.
        me->o_document->add_attachment( i_attachment_type     = iv_ext    " Document Class for Attachment
                                        i_attachment_subject  = iv_title    " Attachment Title
                                        i_att_content_text    = it_content    " Content (Textual)
                                        i_attachment_header   = VALUE #( ( |{ me->c-filename_tag_prefix }{ iv_title }.{ iv_ext }| ) )    " Attachment Header Data
                                      ).

      CATCH cx_document_bcs INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).

    ENDTRY.
  ENDMETHOD.
  METHOD add_solix_attachment .
    TRY.
        me->o_document->add_attachment( i_attachment_type     = iv_ext    " Document Class for Attachment
                                        i_attachment_subject  = iv_title    " Attachment Title
                                        i_att_content_hex     = it_hexcontent    " Content (Textual)
                                        i_attachment_header   = VALUE #( ( |{ me->c-filename_tag_prefix }{ iv_title }.{ iv_ext }| ) )    " Attachment Header Data
                                      ).

      CATCH cx_document_bcs INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).

    ENDTRY.
  ENDMETHOD.
  METHOD send .
    TRY.
        o_send_request->set_document( me->o_document ).

        o_send_request->send( ).

      CATCH cx_send_req_bcs INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).
    ENDTRY.

  ENDMETHOD.
  METHOD send_with_commit .
    TRY.
        o_send_request->set_document( me->o_document ).

        o_send_request->send( ).
      CATCH cx_send_req_bcs INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
  METHOD send_with_commit_and_wait .
    TRY.

        o_send_request->set_document( me->o_document ).

        o_send_request->send( ).
        COMMIT WORK AND WAIT.
      CATCH cx_send_req_bcs INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
CLASS lcl_mail_send_in_update_task DEFINITION INHERITING FROM zcl_send_mail.
  PUBLIC SECTION.

    METHODS:
      constructor               IMPORTING iv_subject   TYPE string
                                          iv_body_type TYPE so_obj_tp DEFAULT 'RAW'
                                          it_body_text TYPE soli_tab
                                RAISING   zcx_mail_send,

      set_sender                REDEFINITION,
      add_recipient             REDEFINITION,
      add_soli_attachment       REDEFINITION,
      add_solix_attachment      REDEFINITION,
      send                      REDEFINITION,
      send_with_commit          REDEFINITION,
      send_with_commit_and_wait REDEFINITION
      .

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA:
      o_message  TYPE REF TO cl_bcs_message,
      o_document TYPE REF TO cl_document_bcs.

    METHODS ret_mail_by_uname   IMPORTING iv_uname       TYPE syuname
                                RETURNING VALUE(rv_mail) TYPE ad_smtpadr.
ENDCLASS.
CLASS lcl_mail_send_in_update_task IMPLEMENTATION.

  METHOD constructor .

    super->constructor( ).

    me->o_message = NEW cl_bcs_message( ).

    me->o_message->set_subject( iv_subject ).


    me->o_message->set_main_doc(  iv_contents_txt = cl_bcs_convert=>txt_to_string( it_body_text )   " Main Documet, First Body Part
                                  iv_doctype      = iv_body_type    " Document Category
                               ).

  ENDMETHOD.
  METHOD set_sender .

    IF iv_mail IS SUPPLIED.
      me->o_message->set_sender( CONV  #( iv_mail ) ).
    ELSEIF iv_uname IS SUPPLIED.
      me->o_message->set_sender( CONV  #( me->ret_mail_by_uname( iv_uname ) ) ).
    ELSE.
      me->o_message->set_sender( CONV  #( me->ret_mail_by_uname( syst-uname ) ) ).
    ENDIF.


  ENDMETHOD.
  METHOD add_recipient .

    IF iv_mail IS SUPPLIED.
      me->o_message->add_recipient( CONV  #( iv_mail ) ).
    ELSEIF iv_uname IS SUPPLIED.
      me->o_message->add_recipient( CONV  #( me->ret_mail_by_uname( iv_uname ) ) ).
    ELSE.
      me->o_message->add_recipient( CONV  #( me->ret_mail_by_uname( syst-uname ) ) ).
    ENDIF.


  ENDMETHOD.
  METHOD add_soli_attachment .
    me->o_message->add_attachment( iv_doctype      = iv_ext    " Document Type
                                   iv_description  = CONV  #( iv_title )   " Short Description of Contents
                                   iv_filename     = |{ me->c-filename_tag_prefix }{ iv_title }.{ iv_ext }|   " File Name (with Extension)
                                   iv_contents_txt = cl_bcs_convert=>txt_to_string( it_content )    " Textual Document Content
                                 ).

  ENDMETHOD.
  METHOD add_solix_attachment .

    me->o_message->add_attachment( iv_doctype      = iv_ext    " Document Type
                                   iv_description  = CONV  #( iv_title )    " Short Description of Contents
                                   iv_filename     = |{ me->c-filename_tag_prefix }{ iv_title }.{ iv_ext }|   " File Name (with Extension)
                                   iv_contents_bin = cl_bcs_convert=>solix_to_xstring( it_hexcontent )    " Textual Document Content
                                 ).

  ENDMETHOD.
  METHOD send .
    TRY.
        me->o_message->set_update_task( abap_true ).

        me->o_message->send( ).

      CATCH cx_bcs_send INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).

    ENDTRY.

  ENDMETHOD.
  METHOD send_with_commit .
    TRY.
        me->o_message->set_send_immediately( abap_true ).

        me->o_message->send( ).

      CATCH cx_bcs_send INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).

    ENDTRY.
  ENDMETHOD.
  METHOD send_with_commit_and_wait .

    TRY.
        me->o_message->set_send_immediately( abap_true ).

        me->o_message->send( ).

      CATCH cx_bcs_send INTO DATA(lo_error) .
        RAISE EXCEPTION TYPE zcx_mail_send
          EXPORTING
            v_text = lo_error->get_text( ).

    ENDTRY.
  ENDMETHOD.
  METHOD ret_mail_by_uname.


    SELECT SINGLE adr6~smtp_addr
             INTO rv_mail
             FROM usr21 INNER JOIN adr6
               ON adr6~persnumber = usr21~persnumber
              AND adr6~addrnumber = usr21~addrnumber
            WHERE usr21~bname = iv_uname
              AND adr6~date_from = '00010101'
              AND adr6~smtp_addr <> ''.

    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    SELECT SINGLE pernr
             INTO @DATA(lv_pernr)
             FROM pa0105
            WHERE usrid = @iv_uname
              AND subty = '0001'
              AND endda >= @sy-datum
              AND begda <= @sy-datum.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE usrid
             INTO rv_mail
             FROM pa0105
            WHERE pernr = lv_pernr
              AND subty = 'MAIL'
              AND endda >= sy-datum
              AND begda <= sy-datum.
    IF sy-subrc <> 0.
      CLEAR:
        rv_mail.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
