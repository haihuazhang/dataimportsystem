CLASS zhdcl_dmp_export_process DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: ms_conf_datatype     TYPE STRUCTURE FOR READ RESULT zhdr_dmp_conf_dt\\DataType,
          ms_conf_targetsystem TYPE STRUCTURE FOR READ RESULT zhdr_dmp_conf_dt\\DataType\_TargetSystem.
*    DATA: mt_version_item        TYPE TABLE FOR CREATE zhdr_dmp_t_version\\Version\_VersionData,
*          mt_source_version_item TYPE TABLE FOR READ RESULT zhdr_dmp_t_version\\Version\_VersionData.

    DATA: ms_version       TYPE STRUCTURE FOR READ RESULT zhdr_dmp_t_version\\Version,
          mt_version_item  TYPE TABLE FOR READ RESULT zhdr_dmp_t_version\\Version\_VersionData,
          ms_target_record TYPE STRUCTURE FOR READ RESULT zhdr_dmp_t_version\\Version\_TargetRecord.

    DATA : mt_message TYPE TABLE FOR CREATE zhdr_dmp_t_version\\TargetRecord\_Message.

    DATA: uuid TYPE sysuuid_x16.
    DATA: out TYPE REF TO if_oo_adt_classrun_out.
    DATA: application_log TYPE REF TO if_bali_log.



    METHODS init_application_log.

    METHODS get_uuid IMPORTING it_parameters TYPE if_apj_dt_exec_object=>tt_templ_val .

    METHODS add_text_to_app_log_or_console IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                                     i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                                           RAISING   cx_bali_runtime
                                                     cx_apj_rt_content.

    METHODS save_job_info.

    METHODS get_version_record.
    METHODS get_data_type_config.




    METHODS process_version_data.
    METHODS process_export.
    METHODS save_messages.
    METHODS process_export_with_odata_v2.
    METHODS save_process_status
      IMPORTING
        i_type TYPE symsgty.
ENDCLASS.



CLASS ZHDCL_DMP_EXPORT_PROCESS IMPLEMENTATION.


  METHOD add_text_to_app_log_or_console.
    TRY.
        IF sy-batch = abap_true.

          IF I_type = if_bali_constants=>c_severity_error.
            save_process_status(
               i_type = i_type
             ).



          ENDIF.


          DATA(application_log_free_text) = cl_bali_free_text_setter=>create(
                                 severity = COND #( WHEN i_type IS NOT INITIAL
                                                    THEN i_type
                                                    ELSE if_bali_constants=>c_severity_status )
                                 text     = i_text ).

          application_log_free_text->set_detail_level( detail_level = '1' ).
          application_log->add_item( item = application_log_free_text ).
          cl_bali_log_db=>get_instance( )->save_log( log = application_log
                                                     assign_to_current_appl_job = abap_true ).
          "Shutdown Job if error
          IF i_type = if_bali_constants=>c_severity_error.

            RAISE EXCEPTION NEW cx_apj_rt_content( textid = VALUE #(
                                                       msgid = '00'
                                                       msgno = '000'
                                                       attr1 = i_text
                                                    )
                                                   ).
          ENDIF.


        ELSE.
*          out->write( |sy-batch = abap_false | ).
          out->write( i_text ).
        ENDIF.
      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime).
    ENDTRY.
  ENDMETHOD.


  METHOD get_data_type_config.
    READ ENTITIES OF zhdr_dmp_conf_dt
        ENTITY TargetSystem ALL FIELDS WITH VALUE #( ( %key-uuid = ms_target_record-UUIDTgt ) )
        RESULT FINAL(lt_targetsystem)
        ENTITY TargetSystem BY \_DataType ALL FIELDS WITH VALUE #( ( %key-uuid = ms_target_record-UUIDTgt ) )
        RESULT FINAL(lt_dt).

    ms_conf_targetsystem = lt_targetsystem[ 1 ].
    ms_conf_datatype = lt_dt[ 1 ].

  ENDMETHOD.


  METHOD get_uuid.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_ID'.
          uuid = ls_parameter-low.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_version_record.
    READ ENTITIES OF zhdr_dmp_t_version
     ENTITY TargetRecord ALL FIELDS WITH VALUE #( (  %key-uuid = uuid ) )
         RESULT FINAL(lt_targetrecord)
     ENTITY TargetRecord BY \_Version ALL FIELDS WITH VALUE #( (  %key-uuid = uuid ) )
         RESULT FINAL(lt_version).
*    ENTITY Version by \_VersionData ALL FIELDS WITH VALUE #( (  %key-uuid = uuid ) )
    ms_target_record = lt_targetrecord[ 1 ].
    ms_version = lt_version[ 1 ].


    READ ENTITIES OF zhdr_dmp_t_version
        ENTITY Version BY \_VersionData ALL FIELDS WITH VALUE #( (  %key-uuid = ms_version-uuid ) )
        RESULT mt_version_item.

  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_ID'    kind = if_apj_dt_exec_object=>parameter datatype = 'X' length = 16 param_text = 'UUID of Target System Record' changeable_ind = abap_true )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.



    " get uuid
    get_uuid( it_parameters ).

    "create log handle
    init_application_log(  ).

    "save job info to ZZC_ZT_DTIMP_FILES
    save_job_info(  ).

    "get data import record.
    TRY.
        add_text_to_app_log_or_console( |获取数据写入记录UUID: { uuid }.| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    get_version_record(  ).

    "get data type configuration
    TRY.
        add_text_to_app_log_or_console( |获取导入配置记录| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    get_data_type_config(  ).


    "process export
    process_export(  ).



    "保存
    TRY.

        add_text_to_app_log_or_console( |保存版本数据| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
*    save_import_item(  ).
    save_messages(  ).






  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    me->out = out.

    DATA  et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val  .

    et_parameters = VALUE #(
        ( selname = 'P_ID'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'A1FBE4DBB99C1EDF9CD4596BC9033AFC' )
      ).

    TRY.

        if_apj_rt_exec_object~execute( it_parameters = et_parameters ).
        out->write( |Finished| ).

      CATCH cx_root INTO DATA(job_scheduling_exception).
        out->write( |Exception has occured: { job_scheduling_exception->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD init_application_log.
    DATA : external_id TYPE c LENGTH 100.

    external_id = uuid.
*    cl_bali_log=>
    TRY.
        application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object = 'ZHD_ALO_DATAIMPORT'
                                                                       subobject = 'ZHD_ALO_TEXT_SUB'
                                                                       external_id = external_id ) ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD process_export.
    CASE ms_conf_targetsystem-DestinationType.
      WHEN 'ODAT2'.
        process_export_with_odata_v2(  ).
      WHEN 'RFC'.

      WHEN 'ODAT4'.

    ENDCASE.



  ENDMETHOD.


  METHOD process_export_with_odata_v2.
    DATA:
*      ls_business_data        TYPE zhdscm_dmp_write_odata_v2=>tys_head,
      ls_business_data              TYPE zhdscm_dmp_write_odata_v2=>ts_deep_head,
      ls_response_data              TYPE zhdscm_dmp_write_odata_v2=>ts_deep_head,
*      ls_bus_data_d TYPE zhdscm_dmp_write_odata_v2=>
      lo_http_client                TYPE REF TO if_web_http_client,
      lo_client_proxy               TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request                    TYPE REF TO /iwbep/if_cp_request_create,
      lo_response                   TYPE REF TO /iwbep/if_cp_response_create,
      lo_data_desc_node_root        TYPE REF TO /iwbep/if_cp_data_desc_node,
      lo_data_desc_node_child       TYPE REF TO /iwbep/if_cp_data_desc_node,
      lo_data_desc_node_child_child TYPE REF TO /iwbep/if_cp_data_desc_node.


    DATA: lr_cscn  TYPE if_com_scenario_factory=>ty_query-cscn_id_range,
          lr_cs_id TYPE if_com_system_factory=>ty_query-cs_id_range.

    DATA : ls_message_for_create TYPE STRUCTURE FOR CREATE zhdr_dmp_t_version\\TargetRecord\_Message.

    TRY.


        TRY.
            add_text_to_app_log_or_console( |Creating destination.| ).
          CATCH cx_bali_runtime.
        ENDTRY.

        lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = ms_conf_targetsystem-Destination ) ).
        lr_cs_id = VALUE #( ( sign = 'I' option = 'EQ' low = ms_conf_targetsystem-SystemID ) ).

        DATA(lo_factory) = cl_com_arrangement_factory=>create_instance(  ).
        lo_factory->query_ca(
            EXPORTING
              is_query = VALUE #( cscn_id_range = lr_cscn
                                  cs_id_range = lr_cs_id )
*                              cs_business_system_id_range = lr_cs_id )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

        IF lt_ca IS INITIAL.
          EXIT.
        ENDIF.

        READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
*          READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
        IF sy-subrc = 0.
          " Create http client
          DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
              comm_scenario = lo_ca->get_comm_scenario_id( )
              comm_system_id = lo_ca->get_comm_system_id( )
              service_id     = 'ZHDOS_DMP_003_REST'
                                                        ).
          lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).



          lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
            EXPORTING
               is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                   proxy_model_id      = 'ZHDSCM_DMP_ODATA_WRITE'
                                                   proxy_model_version = '0001' )
              io_http_client             = lo_http_client
              iv_relative_service_root   = '/sap/opu/odata/ZHD/DMP_0001_SRV' ).

          ASSERT lo_http_client IS BOUND.


* Prepare business data
          ls_business_data = VALUE #(
                    version    = ms_version-Version
                    data_type  = ms_conf_datatype-Name
                    class      = ms_conf_targetsystem-Class
                    to_items = VALUE #(
                      FOR item IN mt_version_item (
                          version = ms_version-Version
                          data_type = ms_conf_datatype-Name
                          line =  item-Line
                          data_json = item-DataJson
                       )
                     )
                    ).

          " Navigate to the resource and create a request for the create operation
          lo_request = lo_client_proxy->create_resource_for_entity_set( 'HEAD_SET' )->create_request_for_create( ).

          lo_data_desc_node_root = lo_request->create_data_descripton_node( ).
          lo_data_desc_node_root->set_properties( VALUE #( ( |VERSION| ) ( |DATA_TYPE| ) ( |CLASS| ) ) ).

          lo_data_desc_node_child = lo_data_desc_node_root->add_child( 'TO_ITEMS' ).
          lo_data_desc_node_child->set_properties( VALUE #( ( |VERSION| ) ( |DATA_TYPE| ) ( |LINE| ) ( |DATA_JSON| )  ) ).

          lo_data_desc_node_child_child = lo_data_desc_node_child->add_child( 'TO_MESSAGES' ).
          lo_data_desc_node_child_child->set_properties( VALUE #( ( |VERSION| ) ( |DATA_TYPE| ) ( |LINE| ) ( |ID| )
            ( |NUMBER| ) ( |TYPE| ) ( |MESSAGE_STRING| ) ( |MESSAGE_V_1| ) ( |MESSAGE_V_2| ) ( |MESSAGE_V_3| ) ( |MESSAGE_V_4| )
           ) ).



          " Set the business data for the created entity
*        lo_request->set_business_data( ls_business_data ).
          lo_request->set_deep_business_data(
              is_business_data = ls_business_data
              io_data_description = lo_data_desc_node_root
           ).



          " Execute the request
          lo_response = lo_request->execute( ).

          " Get the after image
          lo_response->get_business_data( IMPORTING es_business_data = ls_response_data ).


          "循环Item/Message，
          LOOP AT ls_response_data-to_items ASSIGNING FIELD-SYMBOL(<fs_item>).
            LOOP AT <fs_item>-to_messages ASSIGNING FIELD-SYMBOL(<fs_message>).
              ls_message_for_create = VALUE #(
*                            uuid = mt_version_item[ Line = <fs_item>-line ]-uuid
                             uuid = uuid
            %target = VALUE #( (
*                                   DataJson = ls_data-data_json
                                  %cid = <fs_item>-line
                                  Line = <fs_item>-line
                                  Type = <fs_message>-type
                                  Id = <fs_message>-id
                                  MsgNumber = <fs_message>-number
                                  Message = <fs_message>-message_string
                                  MessageV1 = <fs_message>-message_v_1
                                  MessageV2 = <fs_message>-message_v_2
                                  MessageV3 = <fs_message>-message_v_3
                                  MessageV4 = <fs_message>-message_v_4

                                  %control = VALUE #(
                                     Line = if_abap_behv=>mk-on
                                     Type = if_abap_behv=>mk-on
                                     Id = if_abap_behv=>mk-on
                                     MsgNumber = if_abap_behv=>mk-on
                                     Message = if_abap_behv=>mk-on
                                     MessageV1 = if_abap_behv=>mk-on
                                     MessageV2 = if_abap_behv=>mk-on
                                     MessageV3 = if_abap_behv=>mk-on
                                     MessageV4 = if_abap_behv=>mk-on
                                   )
                               ) )
          ).
              APPEND ls_message_for_create TO mt_message.


            ENDLOOP.

          ENDLOOP.
        ELSE.
          TRY.
              add_text_to_app_log_or_console( i_text = | Could not create Destination by Communication Scenario { ms_conf_targetsystem-Destination } / Communication System { ms_conf_targetsystem-SystemID } (No Communication Arrangment).|
                                            i_type = if_bali_constants=>c_severity_error ).
            CATCH cx_bali_runtime.
          ENDTRY.
        ENDIF.





      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200( lx_remote->get_longtext(  ) )
                                          i_type = if_bali_constants=>c_severity_error ).
          CATCH cx_bali_runtime.
        ENDTRY.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200( lx_gateway->get_longtext(  ) )
                                          i_type = if_bali_constants=>c_severity_error ).
          CATCH cx_bali_runtime.
        ENDTRY.
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
*        RAISE SHORTDUMP lx_web_http_client_error.
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200( lx_web_http_client_error->get_longtext(  ) )
                                          i_type = if_bali_constants=>c_severity_error ).
          CATCH cx_bali_runtime.
        ENDTRY.
      CATCH cx_http_dest_provider_error INTO DATA(lx_dest_provider).
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200( lx_dest_provider->get_longtext(  ) )
                                          i_type = if_bali_constants=>c_severity_error ).
          CATCH cx_bali_runtime.
        ENDTRY.

    ENDTRY.

  ENDMETHOD.


  METHOD process_version_data.
*    DATA : lv_json_data TYPE string.
*    DATA : ls_data    TYPE zhds_dmp_data_list.
*
*    DATA : ls_version_item TYPE STRUCTURE FOR CREATE zhdr_dmp_t_version\\Version\_VersionData.
*
*
*
*    LOOP AT mt_source_version_item ASSIGNING FIELD-SYMBOL(<fs_s_v_item>).
*
*
*
*      CLEAR : ls_data.
*      ls_data-data_json = <fs_s_v_item>-DataJson.
*      ls_data-line = <fs_s_v_item>-Line.
*
*      TRY.
*          add_text_to_app_log_or_console( |处理第{ <fs_s_v_item>-Line }行转换| ).
*        CATCH cx_bali_runtime.
*          "handle exception
*      ENDTRY.
*      process_conversions(
*        CHANGING
*            cs_data = ls_data
*       ).
*
*
*      TRY.
*          add_text_to_app_log_or_console( |处理第{ <fs_s_v_item>-Line }行检查| ).
*        CATCH cx_bali_runtime.
*          "handle exception
*      ENDTRY.
*      process_validations(
*        EXPORTING
*            is_data = ls_data
*       ).
*
*
*
*      ls_version_item = VALUE #(
*             uuid = ms_version-uuid
*             %target = VALUE #( (
*                                   DataJson = ls_data-data_json
*                                   Line = ls_data-line
*                                   %cid = ls_data-line
*                                   %control = VALUE #(
*                                      Line = if_abap_behv=>mk-on
*                                      DataJson = if_abap_behv=>mk-on
*                                    )
*                                ) )
*           ).
*      APPEND ls_version_item TO mt_version_item.

*    ENDLOOP.

  ENDMETHOD.


  METHOD save_job_info.
    IF sy-batch = abap_true.
      DATA(log_handle) = application_log->get_handle( ).
      DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
      DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
      DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
      DATA: template  TYPE cl_apj_rt_api=>ty_template_name.
      TRY.
          cl_apj_rt_api=>get_job_runtime_info(
                              IMPORTING
                                ev_jobname        = jobname
                                ev_jobcount       = jobcount
                                ev_catalog_name   = catalog
                                ev_template_name  = template ).
        CATCH cx_apj_rt.
          "handle exception
      ENDTRY.

      MODIFY ENTITY zhdr_dmp_t_tgt UPDATE FIELDS ( jobcount jobname loghandle ) WITH VALUE #( ( jobcount = jobcount jobname = jobname loghandle = log_handle uuid = uuid ) ).
      COMMIT ENTITIES.
    ENDIF.
  ENDMETHOD.


  METHOD save_messages.
    IF mt_version_item IS NOT INITIAL.
      MODIFY ENTITIES OF zhdr_dmp_t_version
          ENTITY TargetRecord
          UPDATE FIELDS ( Status )
          WITH VALUE #( ( Status = 'S'
                          %control-Status = if_abap_behv=>mk-on
                          %key-uuid = uuid
                           ) )
          CREATE BY \_Message
          FROM mt_message
          MAPPED DATA(ls_mapped)
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).
      IF ls_failed-message IS NOT INITIAL.
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200(  ls_reported-message[ 1 ]-%msg->if_message~get_longtext(  ) )
                                     i_type = if_bali_constants=>c_severity_warning ).
          CATCH cx_bali_runtime.
        ENDTRY.
      ELSE.
        COMMIT ENTITIES.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD save_process_status.
*        IF mt_version_item IS NOT INITIAL.
    MODIFY ENTITIES OF zhdr_dmp_t_version
        ENTITY TargetRecord
        UPDATE FIELDS ( Status )
        WITH VALUE #( ( Status =  i_type
                        %control-Status = if_abap_behv=>mk-on
                        %key-uuid = uuid
                         ) )
        MAPPED DATA(ls_mapped)
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported).
    IF ls_failed-targetrecord IS NOT INITIAL.
      TRY.
          add_text_to_app_log_or_console( i_text = CONV text200(  ls_reported-targetrecord[ 1 ]-%msg->if_message~get_longtext(  ) )
                                   i_type = if_bali_constants=>c_severity_warning ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ELSE.
      COMMIT ENTITIES.
    ENDIF.
*    ENDIF
  ENDMETHOD.
ENDCLASS.
