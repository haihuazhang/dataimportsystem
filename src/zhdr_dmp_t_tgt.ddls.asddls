@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-系统写入记录'
define view entity ZHDR_DMP_T_TGT
  as select from zhdt_dmp_tgt_r as TargetRecord
  association to parent ZHDR_DMP_T_VERSION as _Version on $projection.UUIDVersion = _Version.UUID
  composition of many ZHDR_DMP_T_MESSAGE   as _Message
  //  association to one ZHDR_DMP_T_IMPORT as _Import on _Version.UUIDImport = _Import.UUID
  association to one ZHDR_DMP_CONF_TGT as _TargetSystem on $projection.UUIDTgt = _TargetSystem.UUID
{
  key uuid                                 as UUID,
      uuid_version                         as UUIDVersion,
      //      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDC_DMP_CONF_TGT' ,
      //                                                        element: 'UUID'  },
      //                                                        useForValidation: true
      //                                                             }]
      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDR_DMP_S_TGT_CONF' ,
                                                        element: 'UUID'  },
                                                        additionalBinding: [{
                                                              element: 'UUIDVersion',
                                                              localElement: 'UUIDVersion',
                                                              usage: #FILTER }],
                                                        useForValidation: true
                                                             }]
      uuid_tgt                             as UUIDTgt,
      name                                 as Name,
      status                               as Status,
      jobcount                             as Jobcount,
      jobname                              as Jobname,
      loghandle                            as Loghandle,

      timestamp_tgt                        as TimestampTgt,

      timestamp_dmp_start                  as TimestampDmpStart,

      timestamp_dmp_end                    as TimestampDmpEnd,
      @Semantics.user.createdBy: true
      created_by                           as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                           as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                      as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                      as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                as LocalLastChangedAt,
      cast( case status when 'S' then 'Success'
      when 'E' then 'Error'
      else 'None' end as abap.char( 10 ) ) as StatusText,
      //
      cast( case status when 'S' then 3
            when 'E' then 1
            else 0 end as abap.int1 )      as StatusCriticality,
      _Version,
      _Message,
      _TargetSystem

}
