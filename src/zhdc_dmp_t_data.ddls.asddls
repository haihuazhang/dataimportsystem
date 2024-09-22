@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-版本明细数据CDS-Projection View'
@AccessControl.authorizationCheck: #CHECK
define 

//root 
view entity ZHDC_DMP_T_DATA
//  provider contract TRANSACTIONAL_QUERY
  as projection on ZHDR_DMP_T_DATA
{
  key UUID,
  UUIDVersion,
  DataJson,
  Line,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _Version : redirected to parent ZHDC_DMP_T_VERSION
  
}
