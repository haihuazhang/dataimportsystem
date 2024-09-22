@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '数据管理系统-Excel结构配置CDS'
define view entity ZHDR_DMP_CONF_EXCELSTRUCTURE
  as select from zhdt_dmp_excel_s as ExcelStructure
  association to parent ZHDR_DMP_CONF_EXCELCONFIG as _Excel on $projection.UUIDExcel = _Excel.UUID
  association [1..1] to ZHDR_DMP_CONF_DT as _DataType on $projection.UUIDDataType = _DataType.UUID
{
  key uuid as UUID,
  uuid_datatype as UUIDDataType,
  uuid_excel as UUIDExcel,
  root_node as RootNode,
  sheet_name as SheetName,
  sheet_name_up as SheetNameUp,
  structname as Structname,
  field_name as FieldName,
  field_name_up as FieldNameUp,
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
  _Excel,
  _DataType
}
