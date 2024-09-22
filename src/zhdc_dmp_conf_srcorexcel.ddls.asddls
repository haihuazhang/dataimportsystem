@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '数据管理系统-Source System/Excel搜索帮助Projection视图'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZHDC_DMP_CONF_SRCOREXCEL
  provider contract transactional_query
  as projection on ZHDR_DMP_CONF_SRCOREXCEL
  
{
      @ObjectModel.text.element: ['Name']
  key UUID,
      UUIDDataType,
      Name
}
