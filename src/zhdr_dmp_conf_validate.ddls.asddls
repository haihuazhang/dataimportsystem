@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '数据管理系统-Validation配置CDS'
define view entity ZHDR_DMP_CONF_VALIDATE
  as select from zhdt_dmp_vad as Validate
  association to parent ZHDR_DMP_CONF_DT as _DataType on $projection.UUIDDataType = _DataType.UUID
{
  key uuid                  as UUID,
      uuid_datatype         as UUIDDataType,
      @Semantics.text: true
      name                  as Name,
      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDR_DMP_V_VALIDATION_CLASS' ,
                                        element: 'id'  },
                                              useForValidation: true
                                             }]
      class                 as Class,
      sequence              as Sequence,
      reg_expression        as RegExpression,
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
      _DataType

}
