@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-系统写入记录-消息记录CDS'
define view entity ZHDR_DMP_T_MESSAGE
  as select from zhdt_dmp_message as Message
  association to parent ZHDR_DMP_T_TGT  as _TargetRecord on $projection.UUIDItem = _TargetRecord.UUID
  association to ZHDR_DMP_T_VERSION as _Version on $projection.UUIDVesion = _Version.UUID
{
  key uuid                  as UUID,
      uuid_vesion           as UUIDVesion,
      uuid_item             as UUIDItem,
      line                  as Line,
      type                  as Type,
      id                    as Id,
      msg_number            as MsgNumber,
      message               as Message,
      message_v1            as MessageV1,
      message_v2            as MessageV2,
      message_v3            as MessageV3,
      message_v4            as MessageV4,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Version,
      _TargetRecord

}
