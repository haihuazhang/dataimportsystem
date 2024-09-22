CLASS zhdcl_dmp_version_process DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: ms_conf_datatype TYPE STRUCTURE FOR READ RESULT zhdr_dmp_conf_dt\\DataType,
          mt_validate      TYPE TABLE FOR READ RESULT zhdr_dmp_conf_dt\\DataType\_Validate,
          mt_conversion    TYPE TABLE FOR READ RESULT zhdr_dmp_conf_dt\\DataType\_Conversion.
    DATA: mt_version_item        TYPE TABLE FOR CREATE zhdr_dmp_t_version\\Version\_VersionData,
          mt_source_version_item TYPE TABLE FOR READ RESULT zhdr_dmp_t_version\\Version\_VersionData.

    DATA: ms_version TYPE STRUCTURE FOR READ RESULT zhdr_dmp_t_version\\Version.
    DATA: ms_import TYPE STRUCTURE FOR READ RESULT zhdr_dmp_t_import\\Import.

    DATA: uuid TYPE sysuuid_x16.
    DATA: out TYPE REF TO if_oo_adt_classrun_out.
    DATA: application_log TYPE REF TO if_bali_log.



    METHODS init_application_log.

    METHODS get_uuid IMPORTING it_parameters TYPE if_apj_dt_exec_object=>tt_templ_val .

    METHODS add_text_to_app_log_or_console IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                                     i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                                           RAISING   cx_bali_runtime.

    METHODS save_job_info.

    METHODS get_version_record.
    METHODS get_data_type_config.
    METHODS get_import_data.


    METHODS process_conversion_validation.
    METHODS process_init_version.
    METHODS process_normal_version.
    METHODS get_source_version_data.
    METHODS process_conversions
      CHANGING cs_Data TYPE zhds_dmp_data_list.
    METHODS process_validations
      IMPORTING is_data TYPE zhds_dmp_data_list.
    METHODS process_version_data.
    METHODS save_version_item.
ENDCLASS.



CLASS ZHDCL_DMP_VERSION_PROCESS IMPLEMENTATION.


  METHOD add_text_to_app_log_or_console.
    TRY.
        IF sy-batch = abap_true.

          DATA(application_log_free_text) = cl_bali_free_text_setter=>create(
                                 severity = COND #( WHEN i_type IS NOT INITIAL
                                                    THEN i_type
                                                    ELSE if_bali_constants=>c_severity_status )
                                 text     = i_text ).

          application_log_free_text->set_detail_level( detail_level = '1' ).
          application_log->add_item( item = application_log_free_text ).
          cl_bali_log_db=>get_instance( )->save_log( log = application_log
                                                     assign_to_current_appl_job = abap_true ).

        ELSE.
*          out->write( |sy-batch = abap_false | ).
          out->write( i_text ).
        ENDIF.
      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime).
    ENDTRY.
  ENDMETHOD.


  METHOD get_data_type_config.
    READ ENTITIES OF zhdr_dmp_conf_dt
        ENTITY DataType ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDDatatype ) )
        RESULT FINAL(lt_dt)
        ENTITY DataType BY \_Validate ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDDatatype ) )
        RESULT mt_validate
        ENTITY DataType BY \_Conversion ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDDatatype ) )
        RESULT mt_conversion.
*    READ ENTITY zhdr_dmp_conf_dt ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDDatatype ) )
*        RESULT FINAL(lt_dt).
    ms_conf_datatype = lt_dt[ 1 ].

  ENDMETHOD.


  METHOD get_import_data.
    READ ENTITY zhdr_dmp_t_import ALL FIELDS WITH VALUE #( ( %key-uuid = ms_version-UUIDImport ) )
      RESULT FINAL(lt_import).
    ms_import = lt_import[ 1 ].



  ENDMETHOD.


  METHOD get_source_version_data.
    READ ENTITIES OF zhdr_dmp_t_version
        ENTITY Version  BY \_VersionData
        ALL FIELDS WITH VALUE #( ( %key-uuid = ms_version-UUIDSourceVersion ) )
        RESULT mt_source_version_item.
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
    READ ENTITY zhdr_dmp_t_version ALL FIELDS WITH VALUE #( (  %key-uuid = uuid ) )
      RESULT FINAL(lt_version).
    ms_version = lt_version[ 1 ].
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_ID'    kind = if_apj_dt_exec_object=>parameter datatype = 'X' length = 16 param_text = 'UUID of Version Record' changeable_ind = abap_true )
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
        add_text_to_app_log_or_console( |获取版本UUID: { uuid }.| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    get_version_record(  ).

    "get original import record
    TRY.
        add_text_to_app_log_or_console( |获取导入原始记录.| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    get_import_data(  ).

    "get data type configuration
    TRY.
        add_text_to_app_log_or_console( |获取导入配置记录| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    get_data_type_config(  ).


    "process conversion/validation

    process_conversion_validation(  ).





*    "Process Data Import or read from Excel
*    CASE ms_import-ImportType1.
*      WHEN 'IMP'.
*
*      WHEN 'SRC'.
*        " get source system configuration
*        TRY.
*            add_text_to_app_log_or_console( |get source system configuration of this batch import record.| ).
*          CATCH cx_bali_runtime.
*            "handle exception
*        ENDTRY.
**        get_config_from_src_config(  ).
*
**        check_source_system_config(  ).
*
**        get_data_from_source_system(  ).
*      WHEN 'EXL'.
*        " get excel configuration
*        TRY.
*            add_text_to_app_log_or_console( |get excel configuration of this batch import record.| ).
*          CATCH cx_bali_runtime.
*            "handle exception
*        ENDTRY.
**        get_config_from_excel_config(  ).
*        TRY.
*            add_text_to_app_log_or_console( |import Type: { ms_import-ImportType1 }.| ).
*            add_text_to_app_log_or_console( |file name: { ms_import-FileName }.| ).
*          CATCH cx_bali_runtime.
*            "handle exception
*        ENDTRY.
*        " read data from excel
*        TRY.
*            add_text_to_app_log_or_console( |read excel sheet content one by one.| ).
*          CATCH cx_bali_runtime.
*            "handle exception
*        ENDTRY.
**        get_data_from_xlsx(  ).
*        " build import item CDS structure
*        " read data from excel
*        TRY.
*            add_text_to_app_log_or_console( |parse excel sheet content to data line in json format.| ).
*          CATCH cx_bali_runtime.
*            "handle exception
*        ENDTRY.
**        build_import_item(  ).
*
*
*    ENDCASE.

    "保存
    TRY.

        add_text_to_app_log_or_console( |保存版本数据| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
*    save_import_item(  ).
    save_version_item(  ).


*
*    TRY.
*        cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = uuid IMPORTING uuid_c36 = DATA(lv_uuid_c36)  ).
*      CATCH cx_uuid_error.
*        "handle exception
*    ENDTRY.
*    TRY.
*        add_text_to_app_log_or_console( |process batch import uuid { lv_uuid_c36 }| ).
*      CATCH cx_bali_runtime.
*        "handle exception
*    ENDTRY.
*
*
*    IF uuid IS INITIAL.
*      TRY.
*          add_text_to_app_log_or_console( i_text = |record not found for uuid { lv_uuid_c36 }|
*                                          i_type = if_bali_constants=>c_severity_error ).
*        CATCH cx_bali_runtime.
*          "handle exception
*      ENDTRY.
*      RETURN.
*    ENDIF.



  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    me->out = out.

    DATA  et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val  .

    et_parameters = VALUE #(
        ( selname = 'P_ID'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'A1FBE4DBB99C1EDF9BD5E4214BD49AF2' )
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


  METHOD process_conversions.
    DATA: lt_message TYPE bapirettab,
          lv_status  TYPE bapi_mtype.

    DATA : lo_conversion TYPE REF TO zhdif_dmp_conversion.
    SORT mt_conversion BY Sequence.

    LOOP AT mt_conversion ASSIGNING FIELD-SYMBOL(<fs_conversion>).
      CLEAR : lt_message , lv_status.
      CREATE OBJECT lo_conversion TYPE (<fs_conversion>-Class).

      TRY.
          add_text_to_app_log_or_console( |处理转换{ <fs_conversion>-Class }| ).
        CATCH cx_bali_runtime.
          "handle exception
      ENDTRY.
      lo_conversion->conversion(
          IMPORTING
              et_message = lt_message
              ev_status = lv_status
          CHANGING
              cs_line_data = cs_Data

       ).

      LOOP AT lt_message ASSIGNING FIELD-SYMBOL(<fs_message>).
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200( <fs_message>-message  )
                                            i_type = <fs_message>-type ).
          CATCH cx_bali_runtime.
        ENDTRY.

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.


  METHOD process_conversion_validation.
    IF ms_version-IsInitVersion = abap_true.
      process_init_version( ).
    ELSE.
      process_normal_version( ).
    ENDIF.
  ENDMETHOD.


  METHOD process_init_version.
    DATA : ls_version_item TYPE STRUCTURE FOR CREATE zhdr_dmp_t_version\\Version\_VersionData.
    "处理初始版本
    TRY.
        add_text_to_app_log_or_console( |版本是初始版本.| ).

        "获取ImportItem
        READ ENTITIES OF zhdr_dmp_t_import
            ENTITY Import BY \_ImportItem
            ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-uuid ) )
            RESULT DATA(lt_import_item).

        LOOP AT lt_import_item ASSIGNING FIELD-SYMBOL(<fs_import_item>).
          CLEAR ls_version_item.
          ls_version_item = VALUE #(
             uuid = ms_version-uuid
             %target = VALUE #( (
                                   DataJson = <fs_import_item>-DataJson
                                   Line = <fs_import_item>-line
                                   %cid = <fs_import_item>-line
                                   %control = VALUE #(
                                      Line = if_abap_behv=>mk-on
                                      DataJson = if_abap_behv=>mk-on
                                    )
                                ) )
           ).
          APPEND ls_version_item TO mt_version_item.

        ENDLOOP.



      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD process_normal_version.
    get_source_version_data(  ).

    process_version_data(  ).
  ENDMETHOD.


  METHOD process_validations.
    DATA: lt_message TYPE bapirettab,
          lv_status  TYPE bapi_mtype.

    DATA : lo_validation TYPE REF TO zhdif_dmp_validation.
    SORT mt_validate BY Sequence.

    LOOP AT mt_validate ASSIGNING FIELD-SYMBOL(<fs_validation>).
      CLEAR : lt_message , lv_status.
      CREATE OBJECT lo_validation TYPE (<fs_validation>-Class).

      TRY.
          add_text_to_app_log_or_console( |处理检查{ <fs_validation>-Class }| ).
        CATCH cx_bali_runtime.
          "handle exception
      ENDTRY.
      lo_validation->validate(
          EXPORTING
            is_line_data = is_data
          IMPORTING
              et_message = lt_message
              ev_status = lv_status
       ).

      LOOP AT lt_message ASSIGNING FIELD-SYMBOL(<fs_message>).
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200( <fs_message>-message  )
                                            i_type = <fs_message>-type ).
          CATCH cx_bali_runtime.
        ENDTRY.

      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.


  METHOD process_version_data.
*    DATA : lv_json_data TYPE string.
    DATA : ls_data    TYPE zhds_dmp_data_list.

    DATA : ls_version_item TYPE STRUCTURE FOR CREATE zhdr_dmp_t_version\\Version\_VersionData.



    LOOP AT mt_source_version_item ASSIGNING FIELD-SYMBOL(<fs_s_v_item>).



      CLEAR : ls_data.
      ls_data-data_json = <fs_s_v_item>-DataJson.
      ls_data-line = <fs_s_v_item>-Line.

      TRY.
          add_text_to_app_log_or_console( |处理第{ <fs_s_v_item>-Line }行转换| ).
        CATCH cx_bali_runtime.
          "handle exception
      ENDTRY.
      process_conversions(
        CHANGING
            cs_data = ls_data
       ).


      TRY.
          add_text_to_app_log_or_console( |处理第{ <fs_s_v_item>-Line }行检查| ).
        CATCH cx_bali_runtime.
          "handle exception
      ENDTRY.
      process_validations(
        EXPORTING
            is_data = ls_data
       ).



      ls_version_item = VALUE #(
             uuid = ms_version-uuid
             %target = VALUE #( (
                                   DataJson = ls_data-data_json
                                   Line = ls_data-line
                                   %cid = ls_data-line
                                   %control = VALUE #(
                                      Line = if_abap_behv=>mk-on
                                      DataJson = if_abap_behv=>mk-on
                                    )
                                ) )
           ).
      APPEND ls_version_item TO mt_version_item.

    ENDLOOP.

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

      MODIFY ENTITY zhdr_dmp_t_version UPDATE FIELDS ( jobcount jobname loghandle ) WITH VALUE #( ( jobcount = jobcount jobname = jobname loghandle = log_handle uuid = uuid ) ).
      COMMIT ENTITIES.
    ENDIF.
  ENDMETHOD.


  METHOD save_version_item.
    IF mt_version_item IS NOT INITIAL.
      MODIFY ENTITIES OF zhdr_dmp_t_version
          ENTITY Version
          UPDATE FIELDS ( Status )
          WITH VALUE #( ( Status = 'S'
                          %control-Status = if_abap_behv=>mk-on
                          %key-uuid = uuid
                           ) )
          CREATE BY \_VersionData
          FROM mt_version_item
          MAPPED DATA(ls_mapped)
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).
      IF ls_failed-versiondata IS NOT INITIAL.
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200(  ls_reported-versiondata[ 1 ]-%msg->if_message~get_longtext(  ) )
                                     i_type = if_bali_constants=>c_severity_warning ).
          CATCH cx_bali_runtime.
        ENDTRY.
      ELSE.
        COMMIT ENTITIES.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
