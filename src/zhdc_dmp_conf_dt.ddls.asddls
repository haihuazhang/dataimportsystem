@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-导入数据配置CDS Projection View'
define root view entity ZHDC_DMP_CONF_DT
  provider contract transactional_query
  as projection on ZHDR_DMP_CONF_DT
{
      @ObjectModel.text.element: ['Name']
  key UUID,
      Zzmodule,
      Name,
      LocalLastChangedAt,
      _SourceSystem : redirected to composition child ZHDC_DMP_CONF_SRC,
      _Excel        : redirected to composition child ZHDC_DMP_CONF_EXCELCONFIG,
      _Validate     : redirected to composition child ZHDC_DMP_CONF_VALIDATE,
      _Conversion   : redirected to composition child ZHDC_DMP_CONF_CONVERSION,
      _TargetSystem : redirected to composition child ZHDC_DMP_CONF_TGT

}
