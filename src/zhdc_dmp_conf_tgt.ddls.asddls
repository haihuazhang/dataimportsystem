@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-目标系统配置表CDS-Projection View'
define view entity ZHDC_DMP_CONF_TGT
//  provider contract transactional_query
  as projection on ZHDR_DMP_CONF_TGT
{
  key UUID,
  UUIDDataType,
  Name,
  Destination,
  SystemID,
  Class,
  DestinationType,
  LocalLastChangedAt,
  _DataType : redirected to parent ZHDC_DMP_CONF_DT
  
}
