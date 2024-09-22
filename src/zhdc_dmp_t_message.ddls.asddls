@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-系统写入记录-消息记录CDS-Projection View'
@AccessControl.authorizationCheck: #CHECK
define view entity ZHDC_DMP_T_MESSAGE
//  provider contract transactional_query
  as projection on ZHDR_DMP_T_MESSAGE
{
  key UUID,
  UUIDItem,
  UUIDVesion,
  Line,
  Type,
  Id,
  MsgNumber,
  Message,
  MessageV1,
  MessageV2,
  MessageV3,
  MessageV4,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _TargetRecord : redirected to parent ZHDC_DMP_T_TGT,
  _Version : redirected to ZHDC_DMP_T_VERSION
}
