@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-Excel配置CDS Projection View'
define view entity ZHDC_DMP_CONF_EXCELCONFIG
  //  provider contract transactional_query
  as projection on ZHDR_DMP_CONF_EXCELCONFIG
{
  key UUID,
      UUIDDataType,
      Name,
      MimeType,
      FileName,
      Template,
      LocalLastChangedAt,
      _DataType       : redirected to parent ZHDC_DMP_CONF_DT,
      _ExcelStructure : redirected to composition child ZHDC_DMP_CONF_EXCELSTRUCTURE
}
