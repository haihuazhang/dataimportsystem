@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '数据管理系统-Excel配置CDS'
define view entity ZHDR_DMP_CONF_EXCELCONFIG
  as select from zhdt_dmp_excel as Excel
  association to parent ZHDR_DMP_CONF_DT           as _DataType on $projection.UUIDDataType = _DataType.UUID
  composition of many ZHDR_DMP_CONF_EXCELSTRUCTURE as _ExcelStructure
{
  key uuid                  as UUID,
      uuid_datatype         as UUIDDataType,
      @Semantics.text: true
      name                  as Name,
      @Semantics.mimeType: true
      mime_type             as MimeType,
      file_name             as FileName,
      @Semantics.largeObject:
      { mimeType: 'MimeType',
      fileName: 'FileName',
      contentDispositionPreference: #ATTACHMENT }
      template              as Template,
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
      _DataType,
      _ExcelStructure

}
