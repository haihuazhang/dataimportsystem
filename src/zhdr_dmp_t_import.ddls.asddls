@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '数据管理系统-推送接收/导入记录OData'
define root view entity ZHDR_DMP_T_IMPORT
  as select from zhdt_dmp_import as Import
  composition of many ZHDR_DMP_T_IMP_I               as _ImportItem
  association of one to many ZHDR_DMP_T_VERSION      as _Version       on $projection.UUID = _Version.UUIDImport
  association of one to one ZHDR_DMP_CONF_DT         as _DataType      on $projection.UUIDDatatype = _DataType.UUID
  association of one to many ZHDR_DMP_V_IMPORTTYPE_T as _VImportTypeT  on $projection.ImportType1 = _VImportTypeT.value_low
  association of one to one ZHDR_DMP_CONF_SRCOREXCEL as _SourceOrExcel on $projection.UUIDCommExcel = _SourceOrExcel.UUID
{
  key uuid                                       as UUID,
      //      @Consumption.valueHelpDefinition: [{
      //
      //                                                              useForValidation: true
      //
      //                                                                   }]
      @Consumption.valueHelpDefinition: [{
      //        association: '_DataType',
        entity: {
            name: 'ZHDR_DMP_CONF_DT' ,
            element: 'UUID'
        },
        additionalBinding: [{
            element: 'Name',
            usage: #RESULT

         }],
        useForValidation: true
       }]
      //      @ObjectModel.text.association: '_DataType'

      uuid_datatype                              as UUIDDatatype,

      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDR_DMP_CONF_SRCOREXCEL' ,
                                                        element: 'UUID'  },
                                                        additionalBinding: [{
                                                              element: 'UUIDDataType',
                                                              localElement: 'UUIDDatatype',
                                                              usage: #FILTER }],
                                                              useForValidation: true
                                                             }]
      uuid_comm_excel                            as UUIDCommExcel,
      data_type                                  as DataType,
      import_system                              as ImportSystem,
      @Semantics.text: true
      name                                       as Name,

      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDR_DMP_V_IMPORTTYPE' ,
                                                  element: 'value_low'  },
                                                        useForValidation: true
                                                       }]
      import_type                                as ImportType1,
      where_conditions                           as WhereConditions,
      //      @Semantics.systemDateTime.createdAt: true
      timestamp_src                              as TimestampSrc,
      timestamp_dmp_start                        as TimestampDmpStart,
      timestamp_dmp_end                          as TimestampDmpEnd,
      status                                     as Status,
      jobcount                                   as Jobcount,
      jobname                                    as Jobname,
      //      loghandle             as Loghandle,
      cast( loghandle as abap.char( 22 ) )       as LogHandle,
      @Semantics.mimeType: true
      mime_type                                  as MimeType,
      file_name                                  as FileName,
      @Semantics.largeObject:
      { mimeType: 'MimeType',
      fileName: 'FileName',
      contentDispositionPreference: #ATTACHMENT }
      content                                    as Content,
      @Semantics.user.createdBy: true
      created_by                                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                      as LocalLastChangedAt,
      cast( case status when 'S' then 'Success'
            when 'E' then 'Error'
            else 'None' end as abap.char( 10 ) ) as StatusText,
//
      cast( case status when 'S' then 3
            when 'E' then 1
            else 0 end as abap.int1 ) as StatusCriticality,
      _ImportItem,
      _Version,
      _DataType,
      _VImportTypeT,
      _SourceOrExcel
}
