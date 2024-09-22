INTERFACE zhdif_dmp_conversion
  PUBLIC .
  METHODS conversion
    EXPORTING ev_status    TYPE bapi_mtype
              et_message   TYPE bapirettab
    CHANGING  cs_line_data TYPE zhds_dmp_data_list.
ENDINTERFACE.
