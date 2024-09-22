INTERFACE zhdif_dmp_src_data
  PUBLIC .
  METHODS: get_data IMPORTING iv_where_condition TYPE zhdewhereconditions
                    EXPORTING ev_status          TYPE bapi_mtype
                              et_list            TYPE zhdtt_dmp_data_list
                              et_message         TYPE bapirettab.

ENDINTERFACE.
