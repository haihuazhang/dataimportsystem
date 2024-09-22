@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-推送接收/导入记录OData-Projection View'
define root view entity ZHDC_DMP_T_IMPORT
  provider contract transactional_query
  as projection on ZHDR_DMP_T_IMPORT
{
           @ObjectModel.text.element: ['Name']
  key      UUID,
           @ObjectModel.text.element: ['DataTypeName']
           UUIDDatatype,
           @ObjectModel.text.element: ['SourceOrExcelName']
           UUIDCommExcel,
           DataType,
           ImportSystem,
           Name,
           @ObjectModel.text.element: ['ImportType1Text']
           ImportType1,
           WhereConditions,
           TimestampDmpStart,
           TimestampDmpEnd,
           TimestampSrc,
           Status,
           Jobcount,
           Jobname,
           LogHandle,
           MimeType,
           FileName,
           Content,
           CreatedAt,
           LocalLastChangedAt,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_GET_JOB_STATUS'
  virtual  JobStatus            : abap.char( 1 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_GET_JOB_STATUS'
  virtual  JobStatusText        : abap.char( 20 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_GET_JOB_STATUS'
  virtual  JobStatusCriticality : abap.int1,

           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_GET_JOB_STATUS'
  virtual  LogStatus            : abap.char( 1 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_GET_JOB_STATUS'
  virtual  LogStatusText        : abap.char( 20 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_GET_JOB_STATUS'
  virtual  LogStatusCriticality : abap.int1,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_GET_JOB_STATUS'
  virtual  ApplicationLogUrl    : abap.string( 256 ),
           //           StatusText,
           //           StatusCriticality,
           //           cast( case Status when 'S' then 'Success'
           //           when 'E' then 'Error'
           //           else 'None' end as abap.char( 10 ) ) as StatusText,
           StatusText,
           StatusCriticality,

           _ImportItem    : redirected to composition child ZHDC_DMP_T_IMP_I,
           _Version       : redirected to ZHDC_DMP_T_VERSION,
           _DataType      : redirected to ZHDC_DMP_CONF_DT,
           _VImportTypeT,
           _SourceOrExcel : redirected to ZHDC_DMP_CONF_SRCOREXCEL,
           _DataType.Name      as DataTypeName,
           _VImportTypeT.text  as ImportType1Text : localized,
           _SourceOrExcel.Name as SourceOrExcelName


}
