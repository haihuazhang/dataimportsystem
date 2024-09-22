@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '数据管理系统-导入数据配置CDS'
define root view entity ZHDR_DMP_CONF_DT
  as select from zhdt_dmp_dt as DataType
  composition of many ZHDR_DMP_CONF_SRC         as _SourceSystem
  composition of many ZHDR_DMP_CONF_EXCELCONFIG as _Excel
  composition of many ZHDR_DMP_CONF_VALIDATE    as _Validate
  composition of many ZHDR_DMP_CONF_CONVERSION  as _Conversion
  composition of many ZHDR_DMP_CONF_TGT         as _TargetSystem
{
  key uuid                  as UUID,
      zzmodule              as Zzmodule,
      @Semantics.text: true
      name                  as Name,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _SourceSystem,
      _Excel,
      _Validate,
      _Conversion,
      _TargetSystem
}
