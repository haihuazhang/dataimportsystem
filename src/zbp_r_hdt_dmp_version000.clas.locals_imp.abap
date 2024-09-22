CLASS lsc_zhdr_dmp_t_version DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zhdr_dmp_t_version IMPLEMENTATION.

  METHOD save_modified.
    DATA job_template_name_version TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZHD_JT_VERSION'.
    DATA job_template_name_export TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZHD_JT_EXPORT'.
    DATA job_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA job_parameter TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA range_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA job_name TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count TYPE cl_apj_rt_api=>ty_jobcount.

    IF create-version IS NOT INITIAL.
      LOOP AT create-version ASSIGNING FIELD-SYMBOL(<version>).
        TRY.
            "trigger a job
*            GET TIME STAMP FIELD DATA(start_time_of_job).
*          job_start_info-timestamp = start_time_of_job.
            job_start_info-start_immediately = abap_true.
            job_parameter-name = 'P_ID' . "'INVENT'.
            range_value-sign = 'I'.
            range_value-option = 'EQ'.
            range_value-low = <version>-uuid.
            APPEND range_value TO job_parameter-t_value.
            APPEND job_parameter TO job_parameters.
            cl_apj_rt_api=>schedule_job(
                  EXPORTING
                  iv_job_template_name = job_template_name_version
                  iv_job_text = |数据管理系统-版本处理{ <version>-uuid }|
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
            APPEND VALUE #(  uuid = <version>-uuid

                             %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = job_scheduling_error->get_longtext(  ) )
                            )
              TO reported-version.
*            DATA(error_message) = job_scheduling_error->get_text( ).

          CATCH cx_root INTO DATA(root_exception).

            "reported-<entity name>
            APPEND VALUE #(  uuid = <version>-uuid
                             %msg = new_message(
                             id       = '00'
                             number   = 000
                             severity = if_abap_behv_message=>severity-error
                             v1       = |Root Exc: { root_exception->get_text(  ) }|
                             )
                           )
              TO reported-version.

        ENDTRY.

      ENDLOOP.
    ENDIF.


    IF create-targetrecord IS NOT INITIAL.
      LOOP AT create-targetrecord ASSIGNING FIELD-SYMBOL(<targetrecord>).
        TRY.
            "trigger a job
*            GET TIME STAMP FIELD DATA(start_time_of_job).
*          job_start_info-timestamp = start_time_of_job.
            job_start_info-start_immediately = abap_true.
            job_parameter-name = 'P_ID' . "'INVENT'.
            range_value-sign = 'I'.
            range_value-option = 'EQ'.
            range_value-low = <targetrecord>-uuid.
            APPEND range_value TO job_parameter-t_value.
            APPEND job_parameter TO job_parameters.
            cl_apj_rt_api=>schedule_job(
                  EXPORTING
                  iv_job_template_name = job_template_name_export
                  iv_job_text = |数据管理系统-导入系统{ <targetrecord>-uuid }|
                  is_start_info = job_start_info
                  it_job_parameter_value = job_parameters
                  IMPORTING
                  ev_jobname  = job_name
                  ev_jobcount = job_count
                  ).
*             <import>-JobName = job_name.
*             <import>-JobCount = job_count.

          CATCH cx_apj_rt INTO job_scheduling_error.

            "reported-<entity name>
            APPEND VALUE #(  uuid = <targetrecord>-uuid

                             %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = job_scheduling_error->get_longtext(  ) )
                            )
              TO reported-targetrecord.
*            DATA(error_message) = job_scheduling_error->get_text( ).

          CATCH cx_root INTO root_exception.

            "reported-<entity name>
            APPEND VALUE #(  uuid = <targetrecord>-uuid
                             %msg = new_message(
                             id       = '00'
                             number   = 000
                             severity = if_abap_behv_message=>severity-error
                             v1       = |Root Exc: { root_exception->get_text(  ) }|
                             )
                           )
              TO reported-targetrecord.

        ENDTRY.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zhdr_dmp_t_version DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Version
        RESULT result,
      CreateVersionWithDialog FOR MODIFY
        IMPORTING keys FOR ACTION Version~CreateVersionWithDialog.
ENDCLASS.

CLASS lhc_zhdr_dmp_t_version IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD CreateVersionWithDialog.
    DATA : lt_version TYPE TABLE FOR CREATE zhdr_dmp_t_version\\Version,
           ls_version TYPE STRUCTURE FOR CREATE zhdr_dmp_t_version\\Version.



    IF lines( keys ) > 0.

      READ ENTITIES OF zhdr_dmp_t_version IN LOCAL MODE
          ENTITY Version
          FIELDS ( uuid Jobcount Jobname Status UUIDImport ) WITH CORRESPONDING #( keys )
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
              IsInitVersion = abap_false
              UUIDSourceVersion = <key>-uuid
              UUIDImport = results[ uuid = <key>-uuid ]-UUIDImport
              Version = <key>-%param-Version
              %cid = <key>-uuid
              %control = VALUE #(
                  IsInitVersion = if_abap_behv=>mk-on
                  UUIDSourceVersion = if_abap_behv=>mk-on
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
                v1       = '无法在失败的版本基础上生成后继版本'
                )
        ) TO reported-version.
          APPEND VALUE #( uuid = <key>-uuid ) TO failed-version.
        ENDIF.
      ENDLOOP.

      IF lines( lt_version ) > 0 AND lines( failed-version ) = 0.
        MODIFY ENTITIES OF zhdr_dmp_t_version
          IN LOCAL MODE
          ENTITY Version
          CREATE
          FROM lt_version
          MAPPED mapped
          FAILED failed
          REPORTED reported.
      ENDIF.

    ENDIF.


  ENDMETHOD.

ENDCLASS.
