INTERFACE zhdif_dmp_validation
  PUBLIC .
  METHODS Validate IMPORTING is_line_data TYPE zhds_dmp_data_list
                   EXPORTING ev_status    TYPE bapi_mtype
                             et_message   TYPE bapirettab.
ENDINTERFACE.
