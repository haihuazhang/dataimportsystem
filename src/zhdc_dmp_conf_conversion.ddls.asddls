@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-Conversion配置CDS Projection View'
define view entity ZHDC_DMP_CONF_CONVERSION
//  provider contract transactional_query
  as projection on ZHDR_DMP_CONF_CONVERSION
{
  key UUID,
  UUIDDataType,
  Name,
  Class,
  Sequence,
  RegExpression,
  LocalLastChangedAt,
  _DataType : redirected to parent ZHDC_DMP_CONF_DT
  
}
