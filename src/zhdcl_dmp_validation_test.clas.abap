CLASS zhdcl_dmp_validation_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zhdif_dmp_validation .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZHDCL_DMP_VALIDATION_TEST IMPLEMENTATION.


  METHOD zhdif_dmp_validation~validate.
    et_message = VALUE #( (
        type = 'S'
        id = 'Z001'
        number = '000'
        message = '测试消息'
     ) ).

  ENDMETHOD.
ENDCLASS.
