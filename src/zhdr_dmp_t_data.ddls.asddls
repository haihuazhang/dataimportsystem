@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-版本明细数据CDS'
define 
//root 
view entity ZHDR_DMP_T_DATA
  as select from zhdt_dmp_data as VersionData
   association to parent ZHDR_DMP_T_VERSION as _Version on $projection.UUIDVersion = _Version.UUID
{
  key uuid as UUID,
  uuid_version as UUIDVersion,
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
  _Version
  
}
