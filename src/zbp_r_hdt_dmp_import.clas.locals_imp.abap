CLASS lsc_zhdr_dmp_t_import DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zhdr_dmp_t_import IMPLEMENTATION.

  METHOD save_modified.


    DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZHD_JT_IMPORT'.
    DATA job_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA job_parameter TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA range_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA job_name TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count TYPE cl_apj_rt_api=>ty_jobcount.

    IF create-import IS NOT INITIAL.
      LOOP AT create-import ASSIGNING FIELD-SYMBOL(<import>).
        TRY.
            "trigger a job
*            GET TIME STAMP FIELD DATA(start_time_of_job).
*          job_start_info-timestamp = start_time_of_job.
            job_start_info-start_immediately = abap_true.
            job_parameter-name = 'P_ID' . "'INVENT'.
            range_value-sign = 'I'.
            range_value-option = 'EQ'.
            range_value-low = <import>-uuid.
            APPEND range_value TO job_parameter-t_value.
            APPEND job_parameter TO job_parameters.
            cl_apj_rt_api=>schedule_job(
                  EXPORTING
                  iv_job_template_name = job_template_name
                  iv_job_text = |数据管理系统-数据抽取{ <import>-uuid }|
                  is_start_info = job_start_info
                  it_job_parameter_value = job_parameters
                  IMPORTING
                  ev_jobname  = job_name
                  ev_jobcount = job_count
                  ).
*             <import>-JobName = job_name.
*             <import>-JobCount = job_count.

          CATCH cx_apj_rt INTO DATA(job_scheduling_error).

            "reported-<entity name>
            APPEND VALUE #(  uuid = <import>-uuid

                             %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = job_scheduling_error->get_longtext(  ) )
                            )
              TO reported-import.
*            DATA(error_message) = job_scheduling_error->get_text( ).

          CATCH cx_root INTO DATA(root_exception).

            "reported-<entity name>
            APPEND VALUE #(  uuid = <import>-uuid
                             %msg = new_message(
                             id       = '00'
                             number   = 000
                             severity = if_abap_behv_message=>severity-error
                             v1       = |Root Exc: { root_exception->get_text(  ) }|
                             )
                           )
              TO reported-import.

*            DATA(error_message_root) = root_exception->get_text( ).
        ENDTRY.

      ENDLOOP.
    ENDIF.



  ENDMETHOD.

ENDCLASS.

CLASS lhc_import DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Import
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Import RESULT result,
      checkFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR Import~checkFields,
      determinateFields FOR DETERMINE ON SAVE
        IMPORTING keys FOR Import~determinateFields,
      determinateImportSystemUUID FOR DETERMINE ON MODIFY
        IMPORTING keys FOR Import~determinateImportSystemUUID.

    METHODS determinateImportTypeUUID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Import~determinateImportTypeUUID.
    METHODS createInitVersion FOR MODIFY
      IMPORTING keys FOR ACTION Import~createInitVersion.
ENDCLASS.

CLASS lhc_import IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD get_instance_features.
    READ ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
        ENTITY Import
        FIELDS ( ImportType1 )
        WITH CORRESPONDING #( keys )
        RESULT DATA(imports)
        FAILED failed.

    result = VALUE #( FOR import IN imports
               ( %tky                           = import-%tky
*                 %delete = COND #( WHEN file-JobName IS NOT INITIAL
*                                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
*                 %update = COND #( WHEN file-JobName IS NOT INITIAL
*                                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
*                 %action-Edit = COND #( WHEN file-JobName IS NOT INITIAL
*                                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                  %field-TimestampSrc = COND #( WHEN import-ImportType1 = 'IMP' THEN  if_abap_behv=>fc-f-mandatory ELSE if_abap_behv=>fc-f-unrestricted )
                  %field-DataType = COND #( WHEN import-ImportType1 = 'IMP' THEN  if_abap_behv=>fc-f-mandatory ELSE if_abap_behv=>fc-f-unrestricted )
                  %field-ImportSystem = COND #( WHEN import-ImportType1 = 'IMP' THEN  if_abap_behv=>fc-f-mandatory ELSE if_abap_behv=>fc-f-unrestricted )

                  %field-Content = COND #( WHEN import-ImportType1 = 'EXL' THEN  if_abap_behv=>fc-f-mandatory ELSE if_abap_behv=>fc-f-unrestricted )

                  %field-UUIDCommExcel = COND #( WHEN import-ImportType1 <> 'IMP' THEN  if_abap_behv=>fc-f-mandatory ELSE if_abap_behv=>fc-f-unrestricted )

              ) ).

  ENDMETHOD.

  METHOD checkFields.
    " Check Mandatory Fields
    DATA permission_request TYPE STRUCTURE FOR PERMISSIONS REQUEST zhdr_dmp_t_import.
    DATA(description_permission_request) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( permission_request-%field ) ) ).
    DATA(components_permission_request) = description_permission_request->get_components(  ).

    DATA reported_field LIKE LINE OF reported-import.



    LOOP AT components_permission_request INTO DATA(component_permission_request).
      permission_request-%field-(component_permission_request-name) = if_abap_behv=>mk-on.
    ENDLOOP.

*    GET PERMISSIONS ONLY GLOBAL FEATURES ENTITY zhdr_dmp_t_import REQUEST permission_request
*        RESULT DATA(permission_result).

    " Get current field values
    READ ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
    ENTITY Import
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(imports).
    LOOP AT imports ASSIGNING FIELD-SYMBOL(<data>).
*      LOOP AT components_permission_request INTO component_permission_request.
*        IF permission_result-global-%field-(component_permission_request-name) = if_abap_behv=>fc-f-mandatory
*          AND <data>-(component_permission_request-name) IS INITIAL.
*          APPEND VALUE #( %tky = <data>-%tky  ) TO failed-import.
**          failed-zr_tcs016[ 1 ]-%fail-cause-unspecific
*
*          CLEAR reported_field.
*          reported_field-%tky = <data>-%tky.
*          reported_field-%element-(component_permission_request-name) = if_abap_behv=>mk-on.
**          reported_field-%path = VALUE #( imports-%is_draft = <data>-%is_draft
**                                          imports-%key-uuid = <data>-uuid
**                                          ).
*          reported_field-%state_area = component_permission_request-name.
*
*          reported_field-%msg = new_message( id       = '00'
*                                                         number   = 000
*                                                         severity = if_abap_behv_message=>severity-error
*                                                         v1       = |{ component_permission_request-name }|
**                                                         v2       = | with key: { <data>-uuid } is required | ).
*                                                         v2       = | is required | ).
*
*          APPEND reported_field TO reported-import .
*        ENDIF.
*      ENDLOOP.



      GET PERMISSIONS ONLY FEATURES ENTITY zhdr_dmp_t_import
                FROM VALUE #( ( %tky = <data>-%tky ) )
                REQUEST permission_request
                RESULT DATA(permission_result_instance)
                FAILED DATA(failed_permission_result)
                REPORTED DATA(reported_permission_result).

      LOOP AT components_permission_request INTO component_permission_request.

        "permission result for instances (field ( features : instance ) MandFieldInstfeat;) is stored in an internal table.
        "So we have to retrieve the information for the current entity
        "whereas the global information (field ( mandatory ) MandFieldBdef;) is stored in a structure
        IF ( permission_result_instance-instances[ uuid = <data>-uuid ]-%field-(component_permission_request-name) = if_abap_behv=>fc-f-mandatory OR
             permission_result_instance-global-%field-(component_permission_request-name) = if_abap_behv=>fc-f-mandatory ) AND
             <data>-(component_permission_request-name) IS INITIAL.

          APPEND VALUE #( %tky = <data>-%tky ) TO failed-import.

          "since %element-(component_permission_request-name) = if_abap_behv=>mk-on could not be added using a VALUE statement
          "add the value via assigning value to the field of a structure

          CLEAR reported_field.
          reported_field-%tky = <data>-%tky.
          reported_field-%element-(component_permission_request-name) = if_abap_behv=>mk-on.
          reported_field-%msg = new_message( id       = '00'
                                                         number   = 000
                                                         severity = if_abap_behv_message=>severity-error
                                                         v1       = |{ component_permission_request-name }|
*                                                         v2       = | with key: { <data>-uuid } is required | ).
                                                         v2       = | is required | ).
          APPEND reported_field  TO reported-import.

        ENDIF.
      ENDLOOP.


      " 检查接口字段正确性
      " DATA_TYPE
      " IMPORT_SYSTEM
      IF <data>-ImportType1 = 'IMP'.
*        READ ENTITIES OF zhdr_dmp_conf_dt
*            ENTITY DataType
*            FIELDS ( UUID Name )
*            WITH
        SELECT SINGLE uuid,Name FROM zhdr_dmp_conf_dt
            WHERE Name = @<data>-DataType INTO @DATA(ls_conf_dt).
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <data>-%tky ) TO failed-import.
          CLEAR reported_field.
          reported_field-%tky = <data>-%tky.
          reported_field-%element-(component_permission_request-name) = if_abap_behv=>mk-on.
          reported_field-%msg = new_message( id       = '00'
                                                         number   = 000
                                                         severity = if_abap_behv_message=>severity-error
                                                         v1       = 'Invalid Data Type' ).
          APPEND reported_field  TO reported-import.
        ENDIF.


        SELECT SINGLE uuid FROM zhdr_dmp_conf_src
            WHERE Name = @<data>-ImportSystem INTO @DATA(ls_conf_src).
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <data>-%tky ) TO failed-import.
          CLEAR reported_field.
          reported_field-%tky = <data>-%tky.
          reported_field-%element-(component_permission_request-name) = if_abap_behv=>mk-on.
          reported_field-%msg = new_message( id       = '00'
                                                         number   = 000
                                                         severity = if_abap_behv_message=>severity-error
                                                         v1       = 'Invalid Import System' ).
          APPEND reported_field  TO reported-import.
        ENDIF.
      ENDIF.



    ENDLOOP.

  ENDMETHOD.

  METHOD determinateFields.


    READ ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
        ENTITY Import FIELDS ( ImportType1 ImportSystem DataType TimestampSrc )
            WITH CORRESPONDING #( keys ) RESULT DATA(lt_data).


    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<data>).
      IF <data>-ImportType1 = 'IMP'.
        <data>-TimestampDmpStart = <data>-TimestampSrc.
        <data>-TimestampDmpEnd = <data>-TimestampSrc.

*        SELECT SINGLE uuid,Name FROM zhdr_dmp_conf_dt
*           WHERE Name = @<data>-DataType INTO @DATA(ls_conf_dt).
*        IF sy-subrc = 0.
*          <data>-UUIDDatatype = ls_conf_dt-uuid.
*        ENDIF.
*        SELECT SINGLE uuid FROM zhdr_dmp_conf_src
*            WHERE Name = @<data>-ImportSystem INTO @DATA(lv_conf_src_uuid).
*        IF sy-subrc = 0.
*          <data>-UUIDCommExcel = lv_conf_src_uuid.
*        ENDIF.

        <data>-Status = 'S'.

      ENDIF.
*      <data>-SubmitDate = cl_abap_context_info=>get_system_date( ).
    ENDLOOP.

    MODIFY ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
        ENTITY Import UPDATE FIELDS ( TimestampDmpStart TimestampDmpEnd  Status )
            WITH CORRESPONDING #( lt_data  ).

  ENDMETHOD.

  METHOD determinateImportSystemUUID.

    READ ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
          ENTITY Import FIELDS ( ImportType1 ImportSystem   )
              WITH CORRESPONDING #( keys ) RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<data>).
      IF <data>-ImportType1 = 'IMP'.


        SELECT SINGLE uuid FROM zhdr_dmp_conf_src
            WHERE Name = @<data>-ImportSystem INTO @DATA(lv_conf_src_uuid).
        IF sy-subrc = 0.
          <data>-UUIDCommExcel = lv_conf_src_uuid.
        ENDIF.

      ENDIF.
*      <data>-SubmitDate = cl_abap_context_info=>get_system_date( ).
    ENDLOOP.

    MODIFY ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
        ENTITY Import UPDATE FIELDS ( UUIDCommExcel )
            WITH CORRESPONDING #( lt_data  ).

  ENDMETHOD.

  METHOD determinateImportTypeUUID.

    READ ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
          ENTITY Import FIELDS ( ImportType1 DataType   )
              WITH CORRESPONDING #( keys ) RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<data>).
      IF <data>-ImportType1 = 'IMP'.


        SELECT SINGLE uuid,Name FROM zhdr_dmp_conf_dt
                   WHERE Name = @<data>-DataType INTO @DATA(ls_conf_dt).
        IF sy-subrc = 0.
          <data>-UUIDDatatype = ls_conf_dt-uuid.
        ENDIF.

      ENDIF.
*      <data>-SubmitDate = cl_abap_context_info=>get_system_date( ).
    ENDLOOP.

    MODIFY ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
        ENTITY Import UPDATE FIELDS ( UUIDDatatype )
            WITH CORRESPONDING #( lt_data  ).


  ENDMETHOD.

  METHOD createInitVersion.
    DATA : lt_version TYPE TABLE FOR CREATE zhdr_dmp_t_version\\Version,
           ls_version TYPE STRUCTURE FOR CREATE zhdr_dmp_t_version\\Version.



    IF lines( keys ) > 0.

      READ ENTITIES OF zhdr_dmp_t_import IN LOCAL MODE
          ENTITY Import
          FIELDS ( uuid Jobcount Jobname Status ) WITH CORRESPONDING #( keys )
          RESULT DATA(results).

      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*        <key>-
*        TRY.
*
*            DATA(ls_job_info) = cl_apj_rt_api=>get_job_details( iv_jobname  = CONV #( results[ uuid = <key>-uuid ]-jobname )
*                                                                iv_jobcount = CONV #( results[ uuid = <key>-uuid ]-jobcount ) ).
**            if ( ls_job_info- )
*
*          CATCH cx_apj_rt INTO DATA(exception).
*        ENDTRY.
        "Create Init Version
        IF results[ uuid = <key>-uuid ]-Status = 'S'.
          ls_version = VALUE #(
              IsInitVersion = abap_true
              UUIDImport = <key>-uuid
              Version = <key>-%param-Version
              %cid = <key>-uuid
              %control = VALUE #(
                  IsInitVersion = if_abap_behv=>mk-on
                  UUIDImport = if_abap_behv=>mk-on
                  Version = if_abap_behv=>mk-on

               )
           ).
          APPEND ls_version TO lt_version.
        ELSE.
          APPEND VALUE #(  uuid = <key>-uuid
            %msg = new_message(
                id       = '00'
                number   = 000
                severity = if_abap_behv_message=>severity-error
                v1       = '数据抽取失败的情况下无法创建后继初始版本'
                )
        ) TO reported-import.
          APPEND VALUE #( uuid = <key>-uuid ) TO failed-import.
        ENDIF.
      ENDLOOP.

      IF lines( lt_version ) > 0 AND lines( failed-import ) = 0.
        MODIFY ENTITIES OF zhdr_dmp_t_version
          ENTITY Version
          CREATE
          FROM lt_version
          MAPPED DATA(ls_mapped)
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).

        IF ls_failed-version IS NOT INITIAL.
*        LOOP AT ls_failed-version ASSIGNING FIELD-SYMBOL(<fs_failedversion>).
*            <fs_failedversion>-
*        ENDLOOP.
          APPEND VALUE #( uuid = keys[ 1 ]-uuid ) TO failed-import.

          LOOP AT ls_reported-version ASSIGNING FIELD-SYMBOL(<fs_reported_version>).
            APPEND VALUE #(  uuid = keys[ 1 ]-uuid
              %msg = <fs_reported_version>-%msg
          ) TO reported-import.

          ENDLOOP.
        ENDIF.
      ENDIF.


    ENDIF.

  ENDMETHOD.

ENDCLASS.
