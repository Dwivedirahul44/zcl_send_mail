# zcl_mail_send
ABAP mail send utility to handle most day to mail sending tasks

# Usage Examples

# Send mail in update task
```ABAP
"Initiate Send request

  " Provide Subject and EMail body text.
  DATA(lo_send_request) = zcl_send_mail=>init_update_task_send_request( iv_subject   = `my test email`
                                                                        it_body_text = cl_bcs_convert=>string_to_soli(`My Email body`)
                                                                      ).
  "SEt sender(optional) by providing username/No input(Current username)/email address
  lo_send_request->set_sender( ).
  "add recipient by providing username/No input(Current username)/email address
  lo_send_request->add_recipient( 'USER@domain.com' )."Call multiple times to add multiple recipients.

  "Add Text or Binary attachment.. call as many times as the number of attachments.
  lo_send_request->add_soli_attachment( iv_ext     = 'TXT'
                                        iv_title   = 'My Text File'
                                        it_content = cl_bcs_convert=>string_to_soli(`My text file contents`)
                                      ).
  lo_send_request->send( ). "the email is sent in update task which is triggered on next commit work
  ```
# send Regular Email
```ABAP
  "Initiate Send request
  " Provide Subject and EMail body text.
  DATA(lo_send_request) = zcl_send_mail=>init_send_request( iv_subject   = `my test email`
                                                            it_body_text = cl_bcs_convert=>string_to_soli(`My Email body`)
                                                          ).
  "SEt sender(optional) by providing username/No input(Current username)/email address
  lo_send_request->set_sender( ).
  "add recipient by providing username/No input(Current username)/email address
  lo_send_request->add_recipient( 'USER@domain.com' )."Call multiple times to add multiple recipients.

  "Add Text or Binary attachment.. call as many times as the number of attachments.
  lo_send_request->add_soli_attachment( iv_ext     = 'TXT'
                                        iv_title   = 'My Text File'
                                        it_content = cl_bcs_convert=>string_to_soli(`My text file contents`)
                                      ).

  lo_send_request->send_with_commit( )."Auto commit post send.
  ```
