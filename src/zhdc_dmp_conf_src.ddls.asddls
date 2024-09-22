@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZHDR_DMP_CONF_SRC'
define view entity ZHDC_DMP_CONF_SRC
//  provider contract transactional_query
  as projection on ZHDR_DMP_CONF_SRC
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
