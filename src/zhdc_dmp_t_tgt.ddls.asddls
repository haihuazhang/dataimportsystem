@Metadata.allowExtensions: true
@EndUserText.label: '数据管理系统-系统写入记录-Projection View'
@AccessControl.authorizationCheck: #CHECK
define view entity ZHDC_DMP_T_TGT
  //  provider contract TRANSACTIONAL_QUERY
  as projection on ZHDR_DMP_T_TGT
{
  key      UUID,
           UUIDVersion,
           @ObjectModel.text.element: ['TargetSystemName']
           UUIDTgt,
           Name,
           Status,
           Jobcount,
           Jobname,
           Loghandle,
           TimestampTgt,
           TimestampDmpStart,
           TimestampDmpEnd,
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
           _TargetSystem.Name as TargetSystemName,
           _Version : redirected to parent ZHDC_DMP_T_VERSION,
           _Message : redirected to composition child ZHDC_DMP_T_MESSAGE,
           _TargetSystem : redirected to ZHDC_DMP_CONF_TGT

}
