CLASS zzcl_get_job_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_GET_JOB_STATUS IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA jobname  TYPE cl_apj_rt_api=>ty_jobname .
    DATA jobcount   TYPE cl_apj_rt_api=>ty_jobcount  .
    DATA jobstatus  TYPE cl_apj_rt_api=>ty_job_status  .
    DATA jobstatustext  TYPE cl_apj_rt_api=>ty_job_status_text .

    DATA lv_tabix TYPE sy-tabix.
*    DATA lt_original_data TYPE STANDARD TABLE OF zhdc_dmp_t_import WITH DEFAULT KEY.
*    lt_original_data = CORRESPONDING #( it_original_data ).
*    data : lt_calculate_data like ct_calculated_data.
*    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_field>).
**        <fs_calc_field>-
*    <fs_calc_field>-
*    ENDLOOP.
*    ASSIGN ct_calculated_data TO FIELD-SYMBOL(<ft_calculated_data>).
*    DATA : lo_calculate_line TYPE REF TO data.



    LOOP AT it_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        lv_tabix = sy-tabix.
*      CREATE DATA lo_calculate_line LIKE LINE OF ct_calculated_data.
*      ASSIGN lo_calculate_line->* TO FIELD-SYMBOL(<fs_calculated_data>).
      TRY.

          IF <fs_original_data>-('JOBNAME') IS NOT INITIAL AND <fs_original_data>-('JOBCOUNT') IS NOT INITIAL.

*            cl_apj_rt_api=>get_job_status(
*              EXPORTING
*                iv_jobname  = CONV zzejobname( <fs_original_data>-jobname )
*                iv_jobcount = CONV zzejobcount( <fs_original_data>-jobcount )
*              IMPORTING
*                ev_job_status = jobstatus
*                ev_job_status_text = jobstatustext
*              ).

            DATA(ls_job_info) = cl_apj_rt_api=>get_job_details( iv_jobname  = CONV #( <fs_original_data>-('JOBNAME') )
                                                                iv_jobcount = CONV #( <fs_original_data>-('JOBCOUNT') ) ).

*            <fs_calculated_data>-('JOBSTATUS') = ls_job_info-status.
*            <fs_calculated_data>-('JOBSTATUSTEXT') = ls_job_info-status_text.
            ct_calculated_data[ lv_tabix ]-('JOBSTATUSTEXT') = ls_job_info-status_text.

            CASE ls_job_info-status.
              WHEN 'F'. "Finished
*                <fs_calculated_data>-('JOBSTATUSCRITICALITY') = 3.
                ct_calculated_data[ lv_tabix ]-('JOBSTATUSCRITICALITY') = 3.
              WHEN 'A'. "Aborted
*                <fs_calculated_data>-('JOBSTATUSCRITICALITY') = 1.
                ct_calculated_data[ lv_tabix ]-('JOBSTATUSCRITICALITY') = 1.
              WHEN 'R'. "Running
*                <fs_calculated_data>-('JOBSTATUSCRITICALITY') = 2.
                ct_calculated_data[ lv_tabix ]-('JOBSTATUSCRITICALITY') = 2.
              WHEN OTHERS.
*                <fs_calculated_data>-('JOBSTATUSCRITICALITY') = 0.
                ct_calculated_data[ lv_tabix ]-('JOBSTATUSCRITICALITY') = 0.
            ENDCASE.

*            <fs_calculated_data>-('LOGSTATUS') = ls_job_info-logstatus.

            CASE ls_job_info-logstatus.
              WHEN 'S'. "Finished
*                <fs_calculated_data>-('LOGSTATUSTEXT') = 'Success'.
*                <fs_calculated_data>-('LOGSTATUSCRITICALITY') = 3.
                ct_calculated_data[ lv_tabix ]-('LOGSTATUSTEXT') = 'Success'.
                ct_calculated_data[ lv_tabix ]-('LOGSTATUSCRITICALITY') = 3.
              WHEN 'E'. "Aborted
*                <fs_calculated_data>-('LOGSTATUSTEXT') = 'Error'.
*                <fs_calculated_data>-('LOGSTATUSCRITICALITY') = 1.
                ct_calculated_data[ lv_tabix ]-('LOGSTATUSTEXT') = 'Error'.
                ct_calculated_data[ lv_tabix ]-('LOGSTATUSCRITICALITY') = 1.
              WHEN OTHERS.
*                <fs_calculated_data>-('LOGSTATUSTEXT') = 'None'.
*                <fs_calculated_data>-('LOGSTATUSCRITICALITY') = 0.
                ct_calculated_data[ lv_tabix ]-('LOGSTATUSTEXT') = 'None'.
                ct_calculated_data[ lv_tabix ]-('LOGSTATUSCRITICALITY') = 0.
            ENDCASE.

            DATA(lv_loghandle) = cl_web_http_utility=>escape_url( CONV #( <fs_original_data>-('LOGHANDLE') ) ).

            DATA(lv_url) = |#ApplicationJob-show?JobCatalogEntryName=&/v4_JobRunLog/%252F| &&
                           |ApplicationLogOverviewSet('{ lv_loghandle }')%20%252F| &&
                           |JobRunOverviewSet(JobName%253D'{ <fs_original_data>-('JOBNAME') }'%252C| &&
                           |JobRunCount='{ <fs_original_data>-('JOBCOUNT') }')%20default|.

*            <fs_calculated_data>-('APPLICATIONLOGURL') = lv_url.
            ct_calculated_data[ lv_tabix ]-('APPLICATIONLOGURL') = lv_url.
          ENDIF.

        CATCH cx_apj_rt INTO DATA(exception).

          DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

*          <fs_calculated_data>-('JOBSTATUS') = ''.
*          <fs_calculated_data>-('JOBSTATUSTEXT') = exception->get_text(  ).
*          <fs_calculated_data>-('JOBSTATUSCRITICALITY') = 0.
          ct_calculated_data[ lv_tabix ]-('JOBSTATUSTEXT') = exception->get_text(  ).
          ct_calculated_data[ lv_tabix ]-('JOBSTATUSCRITICALITY') = 0.

        CATCH cx_root INTO DATA(root_exception).

*          RAISE EXCEPTION TYPE zapp_cx_demo_01
*            EXPORTING
*              previous = root_exception.

      ENDTRY.
*      APPEND <fs_calculated_data> TO <ft_calculated_data>.
    ENDLOOP.

*    ct_calculated_data = CORRESPONDING #(   ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    CONSTANTS fieldname_jobcount TYPE string VALUE 'JOBCOUNT'.
    CONSTANTS fieldname_jobname TYPE string VALUE 'JOBNAME'.
    CONSTANTS fieldname_loghandle TYPE string VALUE 'LOGHANDLE'.

*    IF iv_entity <> 'ZZC_ZT_DTIMP_FILES'.
*      RAISE EXCEPTION TYPE
*        EXPORTING
*          textid        = zapp_cx_demo_01=>generic_error
*          error_value_1 = |{ iv_entity } has no virtual elements|.
*    ENDIF.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'JOBSTATUS' .
          COLLECT fieldname_jobcount INTO et_requested_orig_elements.
          COLLECT fieldname_jobname INTO et_requested_orig_elements.
*          APPEND 'JOBCOUNT' TO et_requested_orig_elements.
*          APPEND 'JOBNAME' TO et_requested_orig_elements.
        WHEN 'JOBSTATUSTEXT'.
          COLLECT fieldname_jobcount INTO et_requested_orig_elements.
          COLLECT fieldname_jobname INTO et_requested_orig_elements.
*          APPEND 'JOBCOUNT' TO et_requested_orig_elements.
*          APPEND 'JOBNAME' TO et_requested_orig_elements.
        WHEN 'JOBSTATUSCRITICALITY'.
          COLLECT fieldname_jobcount INTO et_requested_orig_elements.
          COLLECT fieldname_jobname INTO et_requested_orig_elements.

        WHEN 'APPLICATIONLOGURL'.
          COLLECT fieldname_jobcount INTO et_requested_orig_elements.
          COLLECT fieldname_jobname INTO et_requested_orig_elements.
          COLLECT fieldname_loghandle INTO et_requested_orig_elements.
        WHEN OTHERS.
*          RAISE EXCEPTION TYPE zapp_cx_demo_01
*            EXPORTING
*              textid        = zapp_cx_demo_01=>generic_error
*              error_value_1 = |Virtual element { <fs_calc_element> } not known|.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
