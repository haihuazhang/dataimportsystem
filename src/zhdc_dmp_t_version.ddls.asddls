@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-版本记录CDS-Projection View'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZHDC_DMP_T_VERSION
  provider contract transactional_query
  as projection on ZHDR_DMP_T_VERSION
{
           @ObjectModel.text.element: ['Version']
  key      UUID,
           @ObjectModel.text.element: ['SourceVersion']
           UUIDSourceVersion,
           @ObjectModel.text.element: ['ImportName']
           UUIDImport,
           Version,
           IsInitVersion,
           Status,
           Jobcount,
           Jobname,
           Loghandle,
           CreatedBy,
           CreatedAt,
           LastChangedBy,
           LastChangedAt,
           LocalLastChangedAt,
           StatusText,
           StatusCriticality,
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
           _VersionData   : redirected to composition child ZHDC_DMP_T_DATA,
           _TargetRecord  : redirected to composition child ZHDC_DMP_T_TGT,
           _Import        : redirected to ZHDC_DMP_T_IMPORT,
           _SourceVersion : redirected to ZHDC_DMP_T_VERSION,
           _Import.Name           as ImportName,
           _SourceVersion.Version as SourceVersion
           //           _Message : redirected to composition child ZHDC_DMP_T_MESSAGE

}
