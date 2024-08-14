*&---------------------------------------------------------------------*
*&  Include  ZCA_OTEL_MACRO_TRACES
*&---------------------------------------------------------------------*

" it's supposed to be used like this.
" trace_start 'new span name'.
" ...
" check do_something( ) eq abap_true.
" ...
" trace_end.

" you can notice that if check is executed trace_end might never be reached
" that's why we have this do 1 times.
" additionally it's an extra guard that trace is always end =)
" the only condition trace might not be reached - is an exception or return.

define trace_start.
  " using zcl_otel_api is imortant because in badi we activate plugins
  data(trace) = zcl_otel_trace_api=>start_span( name = &1 ).
  do 1 times.
end-of-definition.

define trace_start_with_context.
  " using zcl_otel_api is imortant because in badi we activate plugins
  data(trace) = zcl_otel_trace_api=>start_span(
      name = &1
      context = &2 ).
  do 1 times.
end-of-definition.

define trace_start_external.
  " using zcl_otel_api is imortant because in badi we activate plugins
  data(trace) = zcl_otel_trace_api=>start_span(
      name = &1
      context = cond #(
        when trace_id is not initial and span_id is not initial
        then new zcl_otel_span_context( trace_id = &2 span_id = &3 ) ) ).
  do 1 times.
end-of-definition.

define trace_end.

  enddo.
" supposed to be called with trace_span macro prior to it
if trace is bound.
  trace->end( ).
endif.
end-of-definition.

define trace_fail.
  " supposed to be called with trace_span macro prior to it
  if trace is bound.
    trace->fail( ).
  endif.
end-of-definition.

define trace_fail_cx.
  " supposed to be called with trace_span macro prior to it
  if trace is bound.
    trace->fail( &1->get_text( ) ).
  endif.
end-of-definition.


define start_span.
  trace_start &1.
end-of-definition.

define end_span.
  trace_end.
end-of-definition.
