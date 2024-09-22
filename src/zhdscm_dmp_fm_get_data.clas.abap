CLASS zhdscm_dmp_fm_get_data DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_aco_proxy .

    TYPES:
      char100                        TYPE c LENGTH 000100 ##TYPSHADOW .
    TYPES:
      uuid TYPE x LENGTH 000016 ##TYPSHADOW .
    TYPES:
      BEGIN OF /zhd/s_dmp_data_list          ,
        line      TYPE int4,
        data_json TYPE string,
        uuid      TYPE uuid,
      END OF /zhd/s_dmp_data_list           ##TYPSHADOW .
    TYPES:
      /zhd/tt_dmp_data_list          TYPE STANDARD TABLE OF /zhd/s_dmp_data_list           WITH DEFAULT KEY ##TYPSHADOW .
    TYPES:
      bapi_mtype TYPE c LENGTH 000001 ##TYPSHADOW .
    TYPES:
      symsgid TYPE c LENGTH 000020 ##TYPSHADOW .
    TYPES:
      symsgno TYPE n LENGTH 000003 ##TYPSHADOW .
    TYPES:
      bapi_msg TYPE c LENGTH 000220 ##TYPSHADOW .
    TYPES:
      balognr TYPE c LENGTH 000020 ##TYPSHADOW .
    TYPES:
      balmnr TYPE n LENGTH 000006 ##TYPSHADOW .
    TYPES:
      symsgv TYPE c LENGTH 000050 ##TYPSHADOW .
    TYPES:
      bapi_param TYPE c LENGTH 000032 ##TYPSHADOW .
    TYPES:
      bapi_line TYPE int4 ##TYPSHADOW .
    TYPES:
      bapi_fld TYPE c LENGTH 000030 ##TYPSHADOW .
    TYPES:
      bapilogsys TYPE c LENGTH 000010 ##TYPSHADOW .
    TYPES:
      BEGIN OF bapiret2                      ,
        type       TYPE bapi_mtype,
        id         TYPE symsgid,
        number     TYPE symsgno,
        message    TYPE bapi_msg,
        log_no     TYPE balognr,
        log_msg_no TYPE balmnr,
        message_v1 TYPE symsgv,
        message_v2 TYPE symsgv,
        message_v3 TYPE symsgv,
        message_v4 TYPE symsgv,
        parameter  TYPE bapi_param,
        row        TYPE bapi_line,
        field      TYPE bapi_fld,
        system     TYPE bapilogsys,
      END OF bapiret2                       ##TYPSHADOW .
    TYPES:
      bapiret2_tab                   TYPE STANDARD TABLE OF bapiret2                       WITH DEFAULT KEY ##TYPSHADOW .
    TYPES:
      char1                          TYPE c LENGTH 000001 ##TYPSHADOW .

    METHODS /zhd/fm_dmp_get_data
      IMPORTING
        !iv_class_name      TYPE char100
        !iv_where_condition TYPE string
      EXPORTING
        !et_list            TYPE /zhd/tt_dmp_data_list
        !et_message         TYPE bapiret2_tab
        !ev_status          TYPE char1
      RAISING
        cx_aco_application_exception
        cx_aco_communication_failure
        cx_aco_system_failure .
    METHODS constructor
      IMPORTING
        !destination TYPE REF TO if_rfc_dest
      RAISING
        cx_rfc_dest_provider_error .
  PROTECTED SECTION.

    DATA destination TYPE rfcdest .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZHDSCM_DMP_FM_GET_DATA IMPLEMENTATION.


  METHOD /zhd/fm_dmp_get_data.
    DATA: _rfc_message_ TYPE aco_proxy_msg_type.
    CALL FUNCTION '/ZHD/FM_DMP_GET_DATA' DESTINATION me->destination
      EXPORTING
        iv_class_name         = iv_class_name
        iv_where_condition    = iv_where_condition
      IMPORTING
        et_list               = et_list
        et_message            = et_message
        ev_status             = ev_status
      EXCEPTIONS
        communication_failure = 1 MESSAGE _rfc_message_
        system_failure        = 2 MESSAGE _rfc_message_
        OTHERS                = 3.
    IF sy-subrc NE 0.
      DATA __sysubrc TYPE sy-subrc.
      DATA __textid TYPE aco_proxy_textid_type.
      __sysubrc = sy-subrc.
      __textid-msgid = sy-msgid.
      __textid-msgno = sy-msgno.
      __textid-attr1 = sy-msgv1.
      __textid-attr2 = sy-msgv2.
      __textid-attr3 = sy-msgv3.
      __textid-attr4 = sy-msgv4.
      CASE __sysubrc.
        WHEN 1 .
          RAISE EXCEPTION TYPE cx_aco_communication_failure
            EXPORTING
              rfc_msg = _rfc_message_.
        WHEN 2 .
          RAISE EXCEPTION TYPE cx_aco_system_failure
            EXPORTING
              rfc_msg = _rfc_message_.
        WHEN 3 .
          RAISE EXCEPTION TYPE cx_aco_application_exception
            EXPORTING
              exception_id = 'OTHERS'
              textid       = __textid.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    me->destination = destination->get_destination_name( ).
  ENDMETHOD.
ENDCLASS.
