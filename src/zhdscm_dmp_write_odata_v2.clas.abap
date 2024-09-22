"! <p class="shorttext synchronized">Consumption model for client proxy - generated</p>
"! This class has been generated based on the metadata with namespace
"! <em>ZHD.DMP_0001_SRV</em>
CLASS zhdscm_dmp_write_odata_v2 DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_v4_abs_pm_model_prov
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! <p class="shorttext synchronized">Head</p>
      BEGIN OF tys_head,
        "! <em>Key property</em> Version
        version   TYPE string,
        "! <em>Key property</em> DataType
        data_type TYPE string,
        "! Class
        class     TYPE string,
      END OF tys_head,
      "! <p class="shorttext synchronized">List of Head</p>
      tyt_head TYPE STANDARD TABLE OF tys_head WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">Item</p>
      BEGIN OF tys_item,
        "! <em>Key property</em> Version
        version   TYPE string,
        "! <em>Key property</em> DataType
        data_type TYPE string,
        "! <em>Key property</em> Line
        line      TYPE int8,
        "! DataJson
        data_json TYPE string,
      END OF tys_item,
      "! <p class="shorttext synchronized">List of Item</p>
      tyt_item TYPE STANDARD TABLE OF tys_item WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">Message</p>
      BEGIN OF tys_message,
        "! <em>Key property</em> Version
        version        TYPE string,
        "! <em>Key property</em> DataType
        data_type      TYPE string,
        "! <em>Key property</em> Line
        line           TYPE int8,
        "! <em>Key property</em> ID
        id             TYPE string,
        "! <em>Key property</em> Number
        number         TYPE string,
        "! Type
        type           TYPE string,
        "! MessageString
        message_string TYPE string,
        "! MessageV1
        message_v_1    TYPE string,
        "! MessageV2
        message_v_2    TYPE string,
        "! MessageV3
        message_v_3    TYPE string,
        "! MessageV4
        message_v_4    TYPE string,
      END OF tys_message,
      "! <p class="shorttext synchronized">List of Message</p>
      tyt_message TYPE STANDARD TABLE OF tys_message WITH DEFAULT KEY.

    TYPES : BEGIN OF ts_deep_item.
              INCLUDE TYPE tys_item.
    TYPES :   to_messages TYPE tyt_message,
            END OF ts_deep_item,
            tt_deep_item TYPE STANDARD TABLE OF ts_deep_item WITH DEFAULT KEY,
            BEGIN OF ts_deep_head.
              INCLUDE TYPE tys_head.
    TYPES : to_items TYPE tt_deep_item,
            END OF ts_deep_head.



    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the entity sets</p>
      BEGIN OF gcs_entity_set,
        "! HeadSet
        "! <br/> Collection of type 'Head'
        head_set    TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'HEAD_SET',
        "! ItemSet
        "! <br/> Collection of type 'Item'
        item_set    TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'ITEM_SET',
        "! MessageSet
        "! <br/> Collection of type 'Message'
        message_set TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'MESSAGE_SET',
      END OF gcs_entity_set .

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for entity types</p>
      BEGIN OF gcs_entity_type,
        "! <p class="shorttext synchronized">Internal names for Head</p>
        "! See also structure type {@link ..tys_head}
        BEGIN OF head,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! to_Items
            to_items TYPE /iwbep/if_v4_pm_types=>ty_internal_name VALUE 'TO_ITEMS',
          END OF navigation,
        END OF head,
        "! <p class="shorttext synchronized">Internal names for Item</p>
        "! See also structure type {@link ..tys_item}
        BEGIN OF item,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! to_Messages
            to_messages TYPE /iwbep/if_v4_pm_types=>ty_internal_name VALUE 'TO_MESSAGES',
          END OF navigation,
        END OF item,
        "! <p class="shorttext synchronized">Internal names for Message</p>
        "! See also structure type {@link ..tys_message}
        BEGIN OF message,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF message,
      END OF gcs_entity_type.


    METHODS /iwbep/if_v4_mp_basic_pm~define REDEFINITION.


  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Model</p>
    DATA mo_model TYPE REF TO /iwbep/if_v4_pm_model.


    "! <p class="shorttext synchronized">Define Head</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_head RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define Item</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_item RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define Message</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_message RAISING /iwbep/cx_gateway.

ENDCLASS.



CLASS ZHDSCM_DMP_WRITE_ODATA_V2 IMPLEMENTATION.


  METHOD /iwbep/if_v4_mp_basic_pm~define.

    mo_model = io_model.
    mo_model->set_schema_namespace( 'ZHD.DMP_0001_SRV' ) ##NO_TEXT.

    def_head( ).
    def_item( ).
    def_message( ).

  ENDMETHOD.


  METHOD def_head.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'HEAD'
                                    is_structure              = VALUE tys_head( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'Head' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'HEAD_SET' ).
    lo_entity_set->set_edm_name( 'HeadSet' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'VERSION' ).
    lo_primitive_property->set_edm_name( 'Version' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DATA_TYPE' ).
    lo_primitive_property->set_edm_name( 'DataType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CLASS' ).
    lo_primitive_property->set_edm_name( 'Class' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_navigation_property = lo_entity_type->create_navigation_property( 'TO_ITEMS' ).
    lo_navigation_property->set_edm_name( 'to_Items' ) ##NO_TEXT.
    lo_navigation_property->set_target_entity_type_name( 'ITEM' ).
    lo_navigation_property->set_target_multiplicity( /iwbep/if_v4_pm_types=>gcs_nav_multiplicity-to_many_optional ).

  ENDMETHOD.


  METHOD def_item.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'ITEM'
                                    is_structure              = VALUE tys_item( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'Item' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'ITEM_SET' ).
    lo_entity_set->set_edm_name( 'ItemSet' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'VERSION' ).
    lo_primitive_property->set_edm_name( 'Version' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DATA_TYPE' ).
    lo_primitive_property->set_edm_name( 'DataType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'LINE' ).
    lo_primitive_property->set_edm_name( 'Line' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Int64' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DATA_JSON' ).
    lo_primitive_property->set_edm_name( 'DataJson' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_navigation_property = lo_entity_type->create_navigation_property( 'TO_MESSAGES' ).
    lo_navigation_property->set_edm_name( 'to_Messages' ) ##NO_TEXT.
    lo_navigation_property->set_target_entity_type_name( 'MESSAGE' ).
    lo_navigation_property->set_target_multiplicity( /iwbep/if_v4_pm_types=>gcs_nav_multiplicity-to_many_optional ).

  ENDMETHOD.


  METHOD def_message.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'MESSAGE'
                                    is_structure              = VALUE tys_message( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'Message' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'MESSAGE_SET' ).
    lo_entity_set->set_edm_name( 'MessageSet' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'VERSION' ).
    lo_primitive_property->set_edm_name( 'Version' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DATA_TYPE' ).
    lo_primitive_property->set_edm_name( 'DataType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'LINE' ).
    lo_primitive_property->set_edm_name( 'Line' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Int64' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ID' ).
    lo_primitive_property->set_edm_name( 'ID' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'NUMBER' ).
    lo_primitive_property->set_edm_name( 'Number' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'TYPE' ).
    lo_primitive_property->set_edm_name( 'Type' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MESSAGE_STRING' ).
    lo_primitive_property->set_edm_name( 'MessageString' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MESSAGE_V_1' ).
    lo_primitive_property->set_edm_name( 'MessageV1' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MESSAGE_V_2' ).
    lo_primitive_property->set_edm_name( 'MessageV2' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MESSAGE_V_3' ).
    lo_primitive_property->set_edm_name( 'MessageV3' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MESSAGE_V_4' ).
    lo_primitive_property->set_edm_name( 'MessageV4' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.
ENDCLASS.
