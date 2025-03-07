*"* use this source file for your ABAP unit test classes
class ltcl_main definition final for testing
  duration short
  risk level harmless.

  private section.
    methods:
      simple for testing raising cx_static_check,
      fail for testing raising cx_static_check.

endclass.


class ltcl_main implementation.

  method simple.
    trace_start 'Simple trace'.
    " do something here
    trace->log( 'Some event' ).
    trace_end.
  endmethod.

  method fail.

    trace_start 'This trace should fail'.
    trace->fail( ).
    trace_end.

  endmethod.

endclass.
