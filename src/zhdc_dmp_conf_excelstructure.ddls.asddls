@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-Excel结构配置CDS Projection View'
define view entity ZHDC_DMP_CONF_EXCELSTRUCTURE
  //  provider contract transactional_query
  as projection on ZHDR_DMP_CONF_EXCELSTRUCTURE
{
  key UUID,
      UUIDDataType,
      UUIDExcel,
      RootNode,
      SheetName,
      SheetNameUp,
      Structname,
      FieldName,
      FieldNameUp,
      LocalLastChangedAt,
      _Excel    : redirected to parent ZHDC_DMP_CONF_EXCELCONFIG,
      _DataType : redirected to ZHDC_DMP_CONF_DT
}
