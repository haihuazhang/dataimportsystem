CLASS zhdcl_dmp_import_process DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES : BEGIN OF ts_sheet_content,
              SheetName  TYPE string,
              sheet      TYPE REF TO if_xco_xlsx_ra_worksheet,
              data_table TYPE REF TO data,
            END OF ts_sheet_content,
            tt_sheet_content TYPE TABLE OF ts_sheet_content,
            BEGIN OF ts_excel_data_parsed,
              line      TYPE i,
              data_line TYPE REF TO data,
            END OF ts_excel_data_parsed,
            tt_excel_data_parsed TYPE ts_excel_data_parsed.


    DATA: ms_conf_datatype TYPE STRUCTURE FOR READ RESULT zhdr_dmp_conf_dt\\DataType.
    DATA: ms_conf_src     TYPE STRUCTURE FOR READ RESULT zhdr_dmp_conf_dt\\SourceSystem,
          ms_conf_excel   TYPE STRUCTURE FOR READ RESULT zhdr_dmp_conf_dt\\Excel,
          mt_conf_excel_s TYPE TABLE FOR READ RESULT zhdr_dmp_conf_dt\\ExcelStructure.

    DATA: mt_import_item TYPE TABLE FOR CREATE zhdr_dmp_t_import\\Import\_ImportItem.

    DATA: ms_import TYPE STRUCTURE FOR READ RESULT zhdr_dmp_t_import\\Import.

    DATA: uuid TYPE sysuuid_x16.
    DATA: out TYPE REF TO if_oo_adt_classrun_out.
    DATA: application_log TYPE REF TO if_bali_log.
    DATA: mt_sheet_content TYPE tt_sheet_content.



    METHODS init_application_log.
*    METHODS get_batch_import_configuration IMPORTING p_uuid TYPE sysuuid_x16.
    METHODS get_uuid IMPORTING it_parameters TYPE if_apj_dt_exec_object=>tt_templ_val .
    METHODS get_data_from_xlsx.
    METHODS add_text_to_app_log_or_console IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                                     i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                                           RAISING   cx_bali_runtime.
*    METHODS process_logic.
    METHODS save_job_info.
    METHODS get_config_from_src_config.
    METHODS get_config_from_excel_config.
    METHODS get_import_record.
    METHODS get_data_type_config.
    METHODS build_import_item.
    METHODS take_child_item IMPORTING po_parent_line         TYPE any
                                      ps_parent_sheet_config TYPE zhdr_dmp_conf_excelstructure
                            CHANGING  cs_excel_data_parsed   TYPE ts_excel_data_parsed.
    METHODS save_import_item.
    METHODS get_data_from_source_system.
    METHODS get_data_using_rfc
      EXPORTING et_list    TYPE zhdtt_dmp_data_list
                et_message TYPE bapirettab
                ev_status  TYPE bapi_mtype.
    METHODS check_source_system_config.
ENDCLASS.



CLASS ZHDCL_DMP_IMPORT_PROCESS IMPLEMENTATION.


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


  METHOD build_import_item.
    DATA : ls_root_sheet_config TYPE STRUCTURE FOR READ RESULT zhdr_dmp_conf_excelstructure,
           ls_root_content      TYPE ts_sheet_content,
           lv_lines             TYPE i.

*    FIELD-SYMBOLS: <fs_json_root_table> TYPE STANDARD TABLE.
    DATA: lt_component TYPE abap_component_tab,
          ls_component TYPE abap_componentdescr.

    "Create Dynamic data type
    "   --- Structure  -  A
    "   --- StructName - Table Type
    "             MARA - []
    "             MAKT - []
    "             MARC - []
    "             MARD - []



    "Get Root data
    ls_root_sheet_config = mt_conf_excel_s[ RootNode = abap_true ].
    ls_root_content = mt_sheet_content[ sheetname = ls_root_sheet_config-SheetName ].



    LOOP AT mt_conf_excel_s ASSIGNING FIELD-SYMBOL(<fs_conf_excel_structure>).
      CLEAR : ls_component.
      FREE : ls_component-type.
      DATA(lo_table_type) = cl_abap_tabledescr=>get(
          p_line_type = CAST cl_abap_structdescr(
              cl_abap_tabledescr=>describe_by_name( <fs_conf_excel_structure>-Structname )
          )
          p_table_kind = cl_abap_tabledescr=>tablekind_std
       ).
      ls_component-name = <fs_conf_excel_structure>-Structname.
      ls_component-type = lo_table_type.
      APPEND ls_component TO lt_component.
    ENDLOOP.
    DATA(lo_json_struc) = cl_abap_structdescr=>get( lt_component ).



    "获取数据行数
    DATA : ls_excel_data_parsed TYPE ts_excel_data_parsed,
           ls_import_item       TYPE STRUCTURE FOR CREATE zhdr_dmp_t_import\\Import\_ImportItem,
           lv_line_json         TYPE string.

*           ls_import TYPE STRUCTURE FOR CREATE zhdr_dmp_t_import.
    LOOP AT ls_root_content-data_table->* ASSIGNING FIELD-SYMBOL(<fs_parent_line>).

      CLEAR :ls_excel_data_parsed,ls_import_item.

      FREE: ls_excel_data_parsed-data_line.
      " build

      ls_excel_data_parsed-line = sy-tabix.

      CREATE DATA ls_excel_data_parsed-data_line TYPE HANDLE lo_json_struc.

      take_child_item(
         EXPORTING
             po_parent_line = <fs_parent_line>
             ps_parent_sheet_config = ls_root_sheet_config-%data
         CHANGING
             cs_excel_data_parsed = ls_excel_data_parsed
       ).

      lv_line_json =  /ui2/cl_json=>serialize( data = ls_excel_data_parsed-data_line ).

      ls_import_item = VALUE #(
*      %cid_ref = ms_import-uuid
                                 uuid = ms_import-uuid
                                 %target = VALUE #( (
                                     DataJson = lv_line_json
                                     Line = ls_excel_data_parsed-line
                                     %cid = ls_excel_data_parsed-line
                                     %control = VALUE #(
                                        Line = if_abap_behv=>mk-on
                                        DataJson = if_abap_behv=>mk-on
                                      )
                                  ) )

                                 ).
      APPEND ls_import_item TO mt_import_item.
*       append ls_excel_data_parsed to

    ENDLOOP.

  ENDMETHOD.


  METHOD check_source_system_config.
    IF ms_conf_src-Destination IS INITIAL OR ms_conf_src-SystemID IS INITIAL.
      TRY.
          add_text_to_app_log_or_console( i_text = | No Communication Scenario / Communication System maintained.|
                                i_type = if_bali_constants=>c_severity_error ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.

    IF ms_conf_src-Class IS INITIAL.
      TRY.
          add_text_to_app_log_or_console( i_text = | No Class maintained.|
                                i_type = if_bali_constants=>c_severity_error ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD get_config_from_excel_config.
    READ ENTITIES OF zhdr_dmp_conf_dt
        ENTITY Excel ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDCommExcel ) )
        RESULT FINAL(lt_excel)

        ENTITY Excel BY \_ExcelStructure ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDCommExcel ) )
        RESULT mt_conf_excel_s.

    ms_conf_excel = lt_excel[ 1 ].
  ENDMETHOD.


  METHOD get_config_from_src_config.
    READ ENTITY zhdr_dmp_conf_src ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDCommExcel ) )
        RESULT FINAL(lt_src).
    ms_conf_src = lt_src[ 1 ].
  ENDMETHOD.


  METHOD get_data_from_source_system.
    DATA : lt_list    TYPE zhdtt_dmp_data_list,
           lt_message TYPE bapirettab,
           lv_status  TYPE bapi_mtype.


    IF ms_conf_src-DestinationType = 'SM59'.
      get_data_using_rfc(
        IMPORTING
            et_list = lt_list
            et_message = lt_message
            ev_status = lv_status
       ).
    ELSEIF ms_conf_src-DestinationType = 'ODATA'.

    ENDIF.


    LOOP AT lt_message ASSIGNING FIELD-SYMBOL(<fs_message>).
      TRY.
          add_text_to_app_log_or_console( i_text = CONV text200( <fs_message>-message  )
                                          i_type = <fs_message>-type ).
        CATCH cx_bali_runtime.
      ENDTRY.

    ENDLOOP.

    IF lt_list IS NOT INITIAL.
      DATA : ls_import_item TYPE STRUCTURE FOR CREATE zhdr_dmp_t_import\\Import\_ImportItem.
      LOOP AT lt_list ASSIGNING FIELD-SYMBOL(<fs_list>).

        ls_import_item = VALUE #(
                          uuid = ms_import-uuid
                          %target = VALUE #( (
                              DataJson = <fs_list>-data_json
                              Line = <fs_list>-line
                              %cid = <fs_list>-line
                              %control = VALUE #(
                                 Line = if_abap_behv=>mk-on
                                 DataJson = if_abap_behv=>mk-on
                               )
                           ) )

                          ).
        APPEND ls_import_item TO mt_import_item.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_data_from_xlsx.


*    TRY.
    "create internal table for corresponding table type
*        CREATE DATA mo_table TYPE TABLE OF (ms_configuration-structname).

    " read xlsx object
    DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ms_import-Content ).

    DATA ls_sheet_content TYPE ts_sheet_content.

    LOOP AT mt_conf_excel_s ASSIGNING FIELD-SYMBOL(<fs_conf_excel_s>).
      ls_sheet_content-sheetname = <fs_conf_excel_s>-SheetName.
      ls_sheet_content-sheet = lo_document->read_access(  )->get_workbook(  )->worksheet->for_name( ls_sheet_content-sheetname ).
      DATA(lv_sheet_exists) = ls_sheet_content-sheet->exists(  ).
      IF lv_sheet_exists = abap_false.
        TRY.
            add_text_to_app_log_or_console( i_text = |Excel sheet { ls_sheet_content-sheetname } does not exist in the data file|
                                             i_type = if_bali_constants=>c_severity_warning ).
          CATCH cx_bali_runtime.
            "handle exception
        ENDTRY.
        CONTINUE.
      ENDIF.

      "Get Data from Excel
      "create internal table for corresponding table type
      CREATE DATA ls_sheet_content-data_table TYPE TABLE OF (<fs_conf_excel_s>-Structname).

      DATA(lo_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
      )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
      )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
      )->get_pattern(  ).

      ls_sheet_content-sheet->select( lo_pattern )->row_stream(  )->operation->write_to( ls_sheet_content-data_table )->execute(  ).
      APPEND ls_sheet_content TO mt_sheet_content.

    ENDLOOP.


*        DATA(lo_worksheet) = lo_document->read_access(  )->get_workbook(  )->worksheet->for_name( CONV string( ms_configuration-sheetname ) ).
*        DATA(lv_sheet_exists) = lo_worksheet->exists(  ).
*        IF lv_sheet_exists = abap_false.
*          TRY.
*              add_text_to_app_log_or_console( i_text = |Excel sheet ms_configuration-Sheetname does not exist in the data file|
*                                              i_type = if_bali_constants=>c_severity_error ).
*            CATCH cx_bali_runtime.
*              "handle exception
*          ENDTRY.
*          RETURN.
*        ENDIF.

*        DATA(lo_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
*        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( ms_configuration-startline )
*        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( ms_configuration-startcolumn )
*        )->get_pattern(  ).
*
*        lo_worksheet->select( lo_pattern )->row_stream(  )->operation->write_to( mo_table )->execute(  ).
*      CATCH cx_sy_create_data_error INTO DATA(lx_sy_create_data_error).
*        TRY.
*            add_text_to_app_log_or_console( i_text = |Data structure of Import Object not found, please contact Administrator|
*                                            i_type = if_bali_constants=>c_severity_error ).
*          CATCH cx_bali_runtime.
*            "handle exception
*        ENDTRY.
**        return.
**        RAISE EXCEPTION TYPE cx_bali_runtime.
*    ENDTRY.





  ENDMETHOD.


  METHOD get_data_type_config.
    READ ENTITY zhdr_dmp_conf_dt ALL FIELDS WITH VALUE #( ( %key-uuid = ms_import-UUIDDatatype ) )
      RESULT FINAL(lt_dt).
    ms_conf_datatype = lt_dt[ 1 ].
  ENDMETHOD.


  METHOD get_data_using_rfc.
    DATA dest TYPE REF TO if_rfc_dest.
    DATA myobj  TYPE REF TO zhdscm_dmp_fm_get_data.

    DATA iv_class_name TYPE zhdscm_dmp_fm_get_data=>char100.
    DATA iv_where_condition TYPE string.
*    DATA lt_list TYPE zhdscm_dmp_fm_get_data=>/zhd/tt_dmp_data_list.
*    DATA lt_message TYPE zhdscm_dmp_fm_get_data=>bapiret2_tab.
*    DATA lv_status TYPE zhdscm_dmp_fm_get_data=>char1.


    DATA: lr_cscn  TYPE if_com_scenario_factory=>ty_query-cscn_id_range,
          lr_cs_id TYPE if_com_system_factory=>ty_query-cs_id_range.

    TRY.
        add_text_to_app_log_or_console( |Creating destination.| ).
      CATCH cx_bali_runtime.
    ENDTRY.

    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = ms_conf_src-Destination ) ).
    lr_cs_id = VALUE #( ( sign = 'I' option = 'EQ' low = ms_conf_src-SystemID ) ).

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
    IF sy-subrc = 0.

      TRY.
          dest = cl_rfc_destination_provider=>create_by_comm_arrangement(
              comm_scenario = lo_ca->get_comm_scenario_id( )
              comm_system_id = lo_ca->get_comm_system_id( )
         ).

          CREATE OBJECT myobj
            EXPORTING
              destination = dest.

          iv_class_name = ms_conf_src-Class.
          iv_where_condition = ms_import-WhereConditions.

          myobj->/zhd/fm_dmp_get_data(
             EXPORTING
               iv_class_name = iv_class_name
               iv_where_condition = iv_where_condition
             IMPORTING
               et_list = et_list
               et_message = et_message
               ev_status = ev_status
           ).
        CATCH  cx_aco_communication_failure INTO DATA(lcx_comm).
          TRY.
              add_text_to_app_log_or_console( i_text = CONV text200( lcx_comm->get_longtext(  ) )
                                            i_type = if_bali_constants=>c_severity_error ).
            CATCH cx_bali_runtime.
          ENDTRY.
          " handle CX_ACO_COMMUNICATION_FAILURE (sy-msg* in lcx_comm->IF_T100_MESSAGE~T100KEY)
        CATCH cx_aco_system_failure INTO DATA(lcx_sys).
          TRY.
              add_text_to_app_log_or_console( i_text = CONV text200( lcx_sys->get_longtext(  ) )
                                            i_type = if_bali_constants=>c_severity_error ).
            CATCH cx_bali_runtime.
          ENDTRY.
          " handle CX_ACO_SYSTEM_FAILURE (sy-msg* in lcx_sys->IF_T100_MESSAGE~T100KEY)
        CATCH cx_aco_application_exception INTO DATA(lcx_appl).
          TRY.
              add_text_to_app_log_or_console( i_text = CONV text200( lcx_appl->get_longtext(  ) )
                                            i_type = if_bali_constants=>c_severity_error ).
            CATCH cx_bali_runtime.
          ENDTRY.
          " handle APPLICATION_EXCEPTIONS (sy-msg* in lcx_appl->IF_T100_MESSAGE~T100KEY)
        CATCH cx_rfc_dest_provider_error INTO DATA(lcx_dest_err).
          TRY.
              add_text_to_app_log_or_console( i_text = CONV text200( lcx_dest_err->get_longtext(  ) )
                                            i_type = if_bali_constants=>c_severity_error ).
            CATCH cx_bali_runtime.
          ENDTRY.
          " handle CX_RFC_DEST_PROVIDER_ERROR
      ENDTRY.
    ELSE.
      TRY.
          add_text_to_app_log_or_console( i_text = | Could not create Destination by Communication Scenario { ms_conf_src-Destination } / Communication System { ms_conf_src-SystemID } (No Communication Arrangment).|
                                        i_type = if_bali_constants=>c_severity_error ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD get_import_record.
    READ ENTITY zhdr_dmp_t_import ALL FIELDS WITH VALUE #( (  %key-uuid = uuid ) )
      RESULT FINAL(lt_import).
    ms_import = lt_import[ 1 ].
  ENDMETHOD.


  METHOD get_uuid.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_ID'.
          uuid = ls_parameter-low.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_ID'    kind = if_apj_dt_exec_object=>parameter datatype = 'X' length = 16 param_text = 'UUID of Import Record' changeable_ind = abap_true )
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
        add_text_to_app_log_or_console( |get batch import with uuid { uuid }.| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    get_import_record(  ).

    "get data type configuration
    TRY.
        add_text_to_app_log_or_console( |get data type configuration of this batch import record.| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    get_data_type_config(  ).

    "Process Data Import or read from Excel
    CASE ms_import-ImportType1.
      WHEN 'IMP'.

      WHEN 'SRC'.
        " get source system configuration
        TRY.
            add_text_to_app_log_or_console( |get source system configuration of this batch import record.| ).
          CATCH cx_bali_runtime.
            "handle exception
        ENDTRY.
        get_config_from_src_config(  ).

        check_source_system_config(  ).

        get_data_from_source_system(  ).
      WHEN 'EXL'.
        " get excel configuration
        TRY.
            add_text_to_app_log_or_console( |get excel configuration of this batch import record.| ).
          CATCH cx_bali_runtime.
            "handle exception
        ENDTRY.
        get_config_from_excel_config(  ).
        TRY.
            add_text_to_app_log_or_console( |import Type: { ms_import-ImportType1 }.| ).
            add_text_to_app_log_or_console( |file name: { ms_import-FileName }.| ).
          CATCH cx_bali_runtime.
            "handle exception
        ENDTRY.
        " read data from excel
        TRY.
            add_text_to_app_log_or_console( |read excel sheet content one by one.| ).
          CATCH cx_bali_runtime.
            "handle exception
        ENDTRY.
        get_data_from_xlsx(  ).
        " build import item CDS structure
        " read data from excel
        TRY.
            add_text_to_app_log_or_console( |parse excel sheet content to data line in json format.| ).
          CATCH cx_bali_runtime.
            "handle exception
        ENDTRY.
        build_import_item(  ).


    ENDCASE.

    "保存
    TRY.

        add_text_to_app_log_or_console( |saving data to database .| ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    save_import_item(  ).


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




*    " get file content
*    get_file_content( uuid ).
*    TRY.
*        add_text_to_app_log_or_console( |file name: { ms_file-filename }| ).
*      CATCH cx_bali_runtime.
*        "handle exception
*    ENDTRY.
*
*    IF ms_file IS INITIAL.
*      TRY.
*          add_text_to_app_log_or_console( i_text = |record not found for uuid { lv_uuid_c36 }|
*                                          i_type = if_bali_constants=>c_severity_error ).
*        CATCH cx_bali_runtime.
*          "handle exception
*      ENDTRY.
*      RETURN.
*    ENDIF.
*
*    IF ms_file-attachment IS INITIAL.
*      TRY.
*          add_text_to_app_log_or_console( i_text = |File not found|
*                                          i_type = if_bali_constants=>c_severity_error ).
*        CATCH cx_bali_runtime.
*          "handle exception
*      ENDTRY.
*      RETURN.
*    ENDIF.
*
*    " get configuration
*    get_batch_import_configuration( uuid ).
*    TRY.
*        add_text_to_app_log_or_console( |import object: { ms_configuration-objectname }| ).
*      CATCH cx_bali_runtime.
*        "handle exception
*    ENDTRY.
*
*    " read excel
*    IF ms_configuration IS INITIAL.
*      TRY.
*          add_text_to_app_log_or_console( i_text = |configuration not found for this batch import record |
*                                          i_type = if_bali_constants=>c_severity_error ).
*        CATCH cx_bali_runtime.
*          "handle exception
*      ENDTRY.
*      RETURN.
*    ENDIF.
*    get_data_from_xlsx(  ).
*
*    " call function module
*    IF mo_table IS  INITIAL.
*      RETURN.
*    ENDIF.
*    process_logic(  ).



  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    me->out = out.

    DATA  et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val  .

    et_parameters = VALUE #(
        ( selname = 'P_ID'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = '650334E8687B1EDF948E6DD7442A1AAC' )
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


  METHOD save_import_item.
    IF mt_import_item IS NOT INITIAL.
      MODIFY ENTITIES OF zhdr_dmp_t_import
          ENTITY Import
          UPDATE FIELDS ( Status )
          WITH VALUE #( ( Status = 'S'
                          %control-Status = if_abap_behv=>mk-on
                          %key-uuid = uuid
                           ) )
          CREATE BY \_ImportItem
          FROM mt_import_item
          MAPPED DATA(ls_mapped)
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported).
      IF ls_failed-importitem IS NOT INITIAL.
        TRY.
            add_text_to_app_log_or_console( i_text = CONV text200(  ls_reported-importitem[ 1 ]-%msg->if_message~get_longtext(  ) )
                                     i_type = if_bali_constants=>c_severity_warning ).
          CATCH cx_bali_runtime.
        ENDTRY.
      ELSE.
        COMMIT ENTITIES.
      ENDIF.
    ENDIF.
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

      MODIFY ENTITY zhdr_dmp_t_import UPDATE FIELDS ( jobcount jobname loghandle ) WITH VALUE #( ( jobcount = jobcount jobname = jobname loghandle = log_handle uuid = uuid ) ).
      COMMIT ENTITIES.
    ENDIF.
  ENDMETHOD.


  METHOD take_child_item.
    FIELD-SYMBOLS: <fs_json_root_table> TYPE STANDARD TABLE.
    DATA : ls_sheet_content TYPE ts_sheet_content.


    " append parent line to the internal table
    ASSIGN COMPONENT ps_parent_sheet_config-Structname OF STRUCTURE cs_excel_data_parsed-data_line->* TO <fs_json_root_table>.
    IF sy-subrc = 0.
      APPEND po_parent_line TO <fs_json_root_table>.
    ENDIF.

    "Get Child sheet config
    LOOP AT mt_conf_excel_s ASSIGNING FIELD-SYMBOL(<fs_conf_excel_structure>) WHERE SheetNameUp = ps_parent_sheet_config-SheetName.
      " Get Key field from parent line
      ASSIGN COMPONENT <fs_conf_excel_structure>-FieldNameUp OF STRUCTURE po_parent_line TO FIELD-SYMBOL(<fs_parent_key>).
      IF sy-subrc = 0.

        CLEAR ls_sheet_content.
        ls_sheet_content = mt_sheet_content[ sheetname = <fs_conf_excel_structure>-SheetName ].
        IF sy-subrc = 0.
          DATA(cond_loop) = |{ <fs_conf_excel_structure>-FieldName } = '{ <fs_parent_key> }' |.
          LOOP AT ls_sheet_content-data_table->* ASSIGNING FIELD-SYMBOL(<fs_child_line>) WHERE (cond_loop).
            take_child_item(
                EXPORTING
                    po_parent_line = <fs_child_line>
                    ps_parent_sheet_config = <fs_conf_excel_structure>-%data
                CHANGING
                    cs_excel_data_parsed = cs_excel_data_parsed
             ).
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
