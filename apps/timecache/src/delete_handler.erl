-module(delete_handler).
-export([init/2]).

init(Req, Opts) ->

  Method = cowboy_req:method(Req),
  Req2 =  case Method of
            <<"GET">> ->

              QsVals = cowboy_req:parse_qs(Req),

              try
                binary_to_atom(proplists:get_value(<<"key">>, QsVals), latin1) of
                KEY -> KEY,
                  timecache:delete_key(KEY),
                  io:format("Key=~p ~n",[KEY]),
                  cowboy_req:reply(200, [], <<"{\"OK\"}">>, Req)
              catch
                _:_  ->
                  cowboy_req:reply(400, [], <<"{\"Bad Key value\"}">>, Req)
              end;

            _ ->
                  cowboy_req:reply(400, [], <<"{\"result\":\"failure\", \"error_text\":\"bad query\"}">>, Req)
          end,
  {ok, Req2, Opts}.
