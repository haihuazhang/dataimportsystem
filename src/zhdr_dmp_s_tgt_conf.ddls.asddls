@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '数据管理系统-目标系统配置CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZHDR_DMP_S_TGT_CONF
  as select from    ZHDR_DMP_CONF_TGT  as TargetConf
    left outer join ZHDR_DMP_T_IMPORT  as _Import  on _Import.UUIDDatatype = TargetConf.UUIDDataType
    left outer join ZHDR_DMP_T_VERSION as _Version on _Version.UUIDImport = _Import.UUID
  //  association to many ZHDR_DMP_T_IMPORT as _Import on _Import.UUIDDatatype = $projection.UUIDDataType
  //  _Import.
{
  key TargetConf.UUID,
  key _Version.UUID as UUIDVersion,
      //      TargfeUUIDDataType,
      @Semantics.text: true
      TargetConf.Name,
      TargetConf.DestinationType,
      TargetConf.Class
}
