@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '数据管理系统-源系统/Excel搜索帮助CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZHDR_DMP_CONF_SRCOREXCEL as select from ZHDR_DMP_CONF_SRC as _SourceSystem
{
    key _SourceSystem.UUID,
    _SourceSystem.UUIDDataType,
    @Semantics.text: true
    cast( _SourceSystem.Name as zhdename) as Name
//    _SourceSystem.Destination,
//    _SourceSystem.Class,
//    _SourceSystem.DestinationType
//    _SourceSystem.LocalLastChangedAt,
//    _SourceSystem._DataType
}

union select from ZHDR_DMP_CONF_EXCELCONFIG as _Excel {
    
    key _Excel.UUID,
    _Excel.UUIDDataType,
    _Excel.Name
//    _Excel.MimeType,
//    _Excel.FileName,
//    _Excel.Template,
//    _Excel.LocalLastChangedAt,
//    _Excel._DataType,
//    _Excel._ExcelStructure
}
