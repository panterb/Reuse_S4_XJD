CLASS zad_cl_apj_online_shop DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces if_oo_adt_classrun.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZAD_CL_APJ_ONLINE_SHOP IMPLEMENTATION.


 METHOD if_apj_dt_exec_object~get_parameters.
    " Parameter Description for Application Jobs Template:
    et_parameter_def = VALUE #(
        ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Description'   lowercase_ind = abap_true changeable_ind = abap_true )
      ).

    " Parameter Table for Application Jobs Template:
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Job Template for Online Shop' )
    ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    TRY.

        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

        lo_mail->set_sender( 'noreply@sap.com' ).
        lo_mail->add_recipient( 'alda.dollani@sap.com' ).
        lo_mail->set_subject( 'Notification: Job complete' ).

        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
          iv_content      = '<h1>Confirmation</h1><p>The job to process the items uploaded via XLSX is finished successfully.</p>'
          iv_content_type = 'text/html'
        ) ).

      lo_mail->send( IMPORTING et_status = DATA(lt_status) ).

      CATCH cx_bcs_mail INTO DATA(lx_mail).
        out->write( EXPORTING data = |Exception: { lx_mail->get_longtext( ) }| ).
    ENDTRY.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    TRY.
        DATA(lo_log) = cl_bali_log=>create( ).

        lo_log->set_header( header = cl_bali_header_setter=>create( object = zad_if_online_shop_constants=>cs_apl-object-online_shop
                                                                    subobject = zad_if_online_shop_constants=>cs_apl-subobject-online_shops
                                                                    external_id = 'demo' ) ).

        " Business Logic
        DATA lt_online_shop TYPE STANDARD TABLE OF zad_i_online_shop WITH DEFAULT KEY.
        SELECT zad_i_online_shop~order_uuid FROM zad_i_online_shop
        WITH PRIVILEGED ACCESS

        WHERE zad_i_online_shop~deliverydate < @sy-datum "@sy-datlo
        AND zad_i_online_shop~ordereditem = 'Laptop'
        INTO TABLE @lt_online_shop.

        MESSAGE ID 'ZAD_ONLINE_SHOP' TYPE 'S' NUMBER '032' WITH sy-dbcnt  INTO DATA(lv_message).
        lo_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).

      CATCH cx_bali_runtime INTO DATA(l_runtime_exception).
*        out->write( l_runtime_exception->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
