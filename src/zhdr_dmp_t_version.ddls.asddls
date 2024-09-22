@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-版本记录CDS'
define root view entity ZHDR_DMP_T_VERSION
  as select from zhdt_dmp_version as Version
  composition of many ZHDR_DMP_T_DATA          as _VersionData
  composition of many ZHDR_DMP_T_TGT           as _TargetRecord
  //  composition of many ZHDR_DMP_T_MESSAGE as _Message
  association of one to one ZHDR_DMP_T_IMPORT  as _Import        on $projection.UUIDImport = _Import.UUID
  association of one to one ZHDR_DMP_T_VERSION as _SourceVersion on $projection.UUIDSourceVersion = _SourceVersion.UUID
{
  key uuid                                 as UUID,
      uuid_source_version                  as UUIDSourceVersion,
      uuid_import                          as UUIDImport,
      version                              as Version,
      is_init_version                      as IsInitVersion,
      status                               as Status,
      jobcount                             as Jobcount,
      jobname                              as Jobname,
      loghandle                            as Loghandle,
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
      _VersionData,
      _TargetRecord,
      _Import,
      _SourceVersion
      //      _Message

}
