-module(add_handler).
-export([init/2]).

init(Req, Opts) ->

    Method = cowboy_req:method(Req),
    Req2 =  case Method of
            <<"GET">> ->
              QsVals = cowboy_req:parse_qs(Req),
              Key = binary_to_atom(proplists:get_value(<<"key">>, QsVals), latin1),
              Value = binary_to_list(proplists:get_value(<<"value">>, QsVals)),

                try
                  binary_to_integer(proplists:get_value(<<"ttl">>, QsVals)) of
                  TTL -> TTL,
                    timecache:set_key(Key, Value, TTL),
                    io:format("Key=~p Value=~p TTL=~p~n",[Key, Value, TTL]),
                    cowboy_req:reply(200, [], <<"{\"OK\"}">>, Req)
                catch
                    _:_  ->
                      cowboy_req:reply(400, [], <<"{\"Bad TTL value\"}">>, Req)
                end;

%%    bad or not permitted  query type
            _ ->
              cowboy_req:reply(400, [], <<"{\"result\":\"failure\", \"error_text\":\"bad POST query\"}">>, Req)
          end,
  {ok, Req2, Opts}.
