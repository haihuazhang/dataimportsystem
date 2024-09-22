CLASS zhdcl_dmp_valuehelp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_comm_scenario IMPORTING io_request  TYPE REF TO if_rap_query_request
                                        io_response TYPE REF TO if_rap_query_response
                              RAISING   cx_rap_query_prov_not_impl
                                        cx_rap_query_provider.

    METHODS get_system_id IMPORTING io_request  TYPE REF TO if_rap_query_request
                                    io_response TYPE REF TO if_rap_query_response
                          RAISING   cx_rap_query_prov_not_impl
                                    cx_rap_query_provider.

    METHODS get_validation_class IMPORTING io_request  TYPE REF TO if_rap_query_request
                                           io_response TYPE REF TO if_rap_query_response
                                 RAISING   cx_rap_query_prov_not_impl
                                           cx_rap_query_provider.
    METHODS get_conversion_class
      IMPORTING
        io_request  TYPE REF TO if_rap_query_request
        io_response TYPE REF TO if_rap_query_response.
ENDCLASS.



CLASS ZHDCL_DMP_VALUEHELP IMPLEMENTATION.


  METHOD get_comm_scenario.
    DATA: lt_entity TYPE TABLE OF zhdr_dmp_v_comm_scenario.

*    SELECT * FROM zr_tsd008   "#EC CI_NOWHERE "#EC CI_ALL_FIELDS_NEEDED
*    WHERE language = @lv_curr_lang
*    INTO TABLE @DATA(lt_result).
    DATA(lo_scenario_factory) =  cl_com_scenario_factory=>create_instance(  ).
    lo_scenario_factory->query_cscn(
*            EXPORTING
*              is_query = VALUE #( cscn_id_range = lr_cscn
*                                  cs_id_range = lr_cs_id )
*                              cs_business_system_id_range = lr_cs_id )
    IMPORTING
      et_com_scenario = DATA(lt_scenario) ).


    lt_entity = VALUE #( FOR result IN lt_scenario ( id = result->get_id( ) name =  result->get_description(  ) ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).
  ENDMETHOD.


  METHOD get_conversion_class.
    DATA: lt_entity TYPE TABLE OF zhdr_dmp_v_conversion_class.

    DATA(lo_interface) = xco_cp_abap=>interface( 'ZHDIF_DMP_CONVERSION' ).
    DATA(lt_implementations) = lo_interface->implementations->all->get( ).



    lt_entity = VALUE #( FOR result IN lt_implementations ( id = result->name name = result->content(  )->get_short_description(  ) ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).
  ENDMETHOD.


  METHOD get_system_id.
    DATA: lt_entity TYPE TABLE OF zhdr_dmp_v_comm_system_id.

*    SELECT * FROM zr_tsd008   "#EC CI_NOWHERE "#EC CI_ALL_FIELDS_NEEDED
*    WHERE language = @lv_curr_lang
*    INTO TABLE @DATA(lt_result).
    DATA(lo_system_factory) =  cl_com_system_factory=>create_instance(  ).
    lo_system_factory->query_cs(
*            EXPORTING
*              is_query = VALUE #( cscn_id_range = lr_cscn
*                                  cs_id_range = lr_cs_id )
*                              cs_business_system_id_range = lr_cs_id )
    IMPORTING
      et_com_system = DATA(lt_system) ).


    lt_entity = VALUE #( FOR result IN lt_system ( id = result->get_id( ) name =  result->get_description(  ) ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).
  ENDMETHOD.


  METHOD get_validation_class.
    DATA: lt_entity TYPE TABLE OF zhdr_dmp_v_validation_class.

    DATA(lo_interface) = xco_cp_abap=>interface( 'ZHDIF_DMP_VALIDATION' ).
    DATA(lt_implementations) = lo_interface->implementations->all->get( ).



    lt_entity = VALUE #( FOR result IN lt_implementations ( id = result->name name = result->content(  )->get_short_description(  ) ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZHDR_DMP_V_COMM_SCENARIO'.
            get_comm_scenario( io_request = io_request io_response = io_response ).
          WHEN 'ZHDR_DMP_V_COMM_SYSTEM_ID'.
            get_system_id( io_request = io_request io_response = io_response ).

          WHEN 'ZHDR_DMP_V_VALIDATION_CLASS'.
            get_validation_class( io_request = io_request io_response = io_response ).

          WHEN 'ZHDR_DMP_V_CONVERSION_CLASS'.
            get_conversion_class( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
