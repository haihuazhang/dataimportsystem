@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '数据管理系统-导入方式Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_ASSOCIATION_TARGET, #CDS_MODELING_DATA_SOURCE ]
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel : { resultSet.sizeCategory: #XS }
define view entity ZHDR_DMP_V_DESTYPE

  as select from DDCDS_CUSTOMER_DOMAIN_VALUE( p_domain_name: 'ZHDDDESTINATIONTYPE')
  association [0..*] to ZHDR_DMP_V_DESTYPE_T as _Text on  $projection.domain_name    = _Text.domain_name
                                                      and $projection.value_position = _Text.value_position
{
       //    key ,
       @UI.lineItem: [{
         importance: #HIGH
        }]
       @ObjectModel.text.association: '_Text'
  key  value_low,
       //       @UI.hidden: true
       @UI.lineItem: [{
         importance: #LOW
        }]
       domain_name,
       //       @UI.hidden: true
       @UI.lineItem: [{
         importance: #LOW
        }]
       value_position,
       //    value_high,
       _Text
}
