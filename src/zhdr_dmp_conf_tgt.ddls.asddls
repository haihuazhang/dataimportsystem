@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '数据管理系统-目标系统配置表CDS'
define view entity ZHDR_DMP_CONF_TGT
  as select from zhdt_dmp_com_tgt as TargetSystem
  association to parent ZHDR_DMP_CONF_DT as _DataType on $projection.UUIDDataType = _DataType.UUID
{
  key uuid                  as UUID,
      uuid_datatype         as UUIDDataType,
      @Semantics.text: true
      name                  as Name,
      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDR_DMP_V_COMM_SCENARIO' ,
                                                element: 'id'  },
                                                      useForValidation: true
                                                     }]
      destination           as Destination,
      class                 as Class,
      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDR_DMP_V_DESTYPE' ,
                                                element: 'value_low'  },
                                                      useForValidation: true
                                                     }]
      destination_type      as DestinationType,
      @Consumption.valueHelpDefinition: [{  entity: {   name: 'ZHDR_DMP_V_COMM_SYSTEM_ID' ,
                                    element: 'id'  },
                                          useForValidation: true
                                         }]
      system_id             as SystemID,
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
