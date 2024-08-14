# OTel libary macros experience

## Why macros?

Otel library - is a framework allowing us to generate telemetry events from the code programmatically.

In the most simple way the code may look something like:

```abap
data(span) = zcl_otel_trace=>start_span( 'My new span' ).

" do something here
" ....

" in the end we always need to end span
span->end( ).
```

This code is supposed to be used in any place which you would like to cover with custom traces. 
If you write a new code - that's fine , if you just want to add some lines into existing code then of course it would be cool to have something trully minimalistic.
That's how we came with this idea:
```abap
method my_method.
trace_start 'My new span'.
"... do something
trace_end.
endmethod.
```

### Dealing with check statement

If we look at the code - we may think that trace_end is never reachable in this case. But it is.

```abap
method my_method.
trace_start 'My new span'.
check do_something( ) eq abap_true.
trace_end.
endmethod.
```

The solution is hidden is the script definition:
```abap
define trace_start.  
  data(trace) = zcl_otel_trace_api=>start_span( name = &1 ).
  do 1 times.
end-of-definition.
```

So this `do 1 times` makes a trick.

### What if exception is raised

So in real if we look what this code is doing:
```abap
trace_start 'My new span'.
"... do something
trace_end.
endmethod.
```

It's generating the code like:
```abap
" using zcl_otel_api is imortant because in badi we activate plugins
  data(trace) = zcl_otel_trace_api=>start_span( name = &1 ).
  do 1 times.
    try.

" here is your code

 " we should catch any exception and fail span, then we can raise it further
  catch cx_root into zcx_otel=>dummy.
    if trace is bound.
       trace->fail( zcx_otel=>dummy->get_text( ) ).
    endif.
    raise exception zcx_otel=>dummy.
  endtry.
  enddo.
" supposed to be called with trace_span macro prior to it
if trace is bound.
  trace->end( ).
endif.
```

AS you can see we are always intercepting the appeared exception and also ending the span as failed with logged event ( fail reason ).

It is very tricky to ask every developer to insert such a complicated contruction in every method, but with macros this experience becomes easier to use.
