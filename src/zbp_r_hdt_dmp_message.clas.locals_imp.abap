*CLASS LHC_ZHDR_DMP_T_MESSAGE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
**  PRIVATE SECTION.
**    METHODS:
**      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
**        IMPORTING
**           REQUEST requested_authorizations FOR Message
**        RESULT result.
*ENDCLASS.
*
*CLASS LHC_ZHDR_DMP_T_MESSAGE IMPLEMENTATION.
**  METHOD GET_GLOBAL_AUTHORIZATIONS.
**  ENDMETHOD.
*ENDCLASS.


*CLASS lsc_zhdr_dmp_t_message DEFINITION INHERITING FROM cl_abap_behavior_saver.
*
*  PROTECTED SECTION.
*
*    METHODS save_modified REDEFINITION.
*
*ENDCLASS.
*
*CLASS lsc_zhdr_dmp_t_message IMPLEMENTATION.
*
*  METHOD save_modified.
*    DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZHD_JT_VERSION'.
*    DATA job_start_info TYPE cl_apj_rt_api=>ty_start_info.
*    DATA job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
*    DATA job_parameter TYPE cl_apj_rt_api=>ty_job_parameter_value.
*    DATA range_value TYPE cl_apj_rt_api=>ty_value_range.
*    DATA job_name TYPE cl_apj_rt_api=>ty_jobname.
*    DATA job_count TYPE cl_apj_rt_api=>ty_jobcount.
*
*    IF create-version IS NOT INITIAL.
*      LOOP AT create-version ASSIGNING FIELD-SYMBOL(<version>).
*        TRY.
*            "trigger a job
**            GET TIME STAMP FIELD DATA(start_time_of_job).
**          job_start_info-timestamp = start_time_of_job.
*            job_start_info-start_immediately = abap_true.
*            job_parameter-name = 'P_ID' . "'INVENT'.
*            range_value-sign = 'I'.
*            range_value-option = 'EQ'.
*            range_value-low = <version>-uuid.
*            APPEND range_value TO job_parameter-t_value.
*            APPEND job_parameter TO job_parameters.
*            cl_apj_rt_api=>schedule_job(
*                  EXPORTING
*                  iv_job_template_name = job_template_name
*                  iv_job_text = |数据管理系统-版本处理{ <version>-uuid }|
*                  is_start_info = job_start_info
*                  it_job_parameter_value = job_parameters
*                  IMPORTING
*                  ev_jobname  = job_name
*                  ev_jobcount = job_count
*                  ).
**             <import>-JobName = job_name.
**             <import>-JobCount = job_count.
*
*          CATCH cx_apj_rt INTO DATA(job_scheduling_error).
*
*            "reported-<entity name>
*            APPEND VALUE #(  uuid = <version>-uuid
*
*                             %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = job_scheduling_error->get_longtext(  ) )
*                            )
*              TO reported-version.
**            DATA(error_message) = job_scheduling_error->get_text( ).
*
*          CATCH cx_root INTO DATA(root_exception).
*
*            "reported-<entity name>
*            APPEND VALUE #(  uuid = <version>-uuid
*                             %msg = new_message(
*                             id       = '00'
*                             number   = 000
*                             severity = if_abap_behv_message=>severity-error
*                             v1       = |Root Exc: { root_exception->get_text(  ) }|
*                             )
*                           )
*              TO reported-version.
*
*        ENDTRY.
*
*      ENDLOOP.
*    ENDIF.
*
*  ENDMETHOD.
*
*ENDCLASS.
