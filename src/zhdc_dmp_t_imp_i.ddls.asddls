@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-推送接收/导入记录OData-明细数据-Projection View'
define view entity ZHDC_DMP_T_IMP_I
//  provider contract transactional_query
  as projection on ZHDR_DMP_T_IMP_I
{
  key UUID,
  UUIDImport,
  DataJson,
  Line,
  LocalLastChangedAt,
  _Import : redirected to parent ZHDC_DMP_T_IMPORT
  
}
