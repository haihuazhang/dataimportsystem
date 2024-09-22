@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '数据管理系统-推送接收/导入记录OData-明细数据'
define view entity ZHDR_DMP_T_IMP_I
  as select from zhdt_dmp_imp_i
  association to parent ZHDR_DMP_T_IMPORT as _Import on $projection.UUIDImport = _Import.UUID
{
  key uuid as UUID,
  uuid_import as UUIDImport,
  data_json as DataJson,
  line as Line,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  _Import
  
}
