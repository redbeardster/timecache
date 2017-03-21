-module(get_handler).
-export([init/2]).

init(Req, Opts) ->

  Method = cowboy_req:method(Req),
  Req2 =  case Method of
            <<"GET">> ->
              QsVals = cowboy_req:parse_qs(Req),
              Key = binary_to_atom(proplists:get_value(<<"key">>, QsVals), latin1),

              Value = case timecache:get_key(Key) of
                       []   -> <<"[]">>;
                       [{Key, Val}] -> list_to_binary(Val)
              end,

              cowboy_req:reply(200, [], Value, Req);

%%    bad or not permitted  query type
            _ ->
              cowboy_req:reply(400, [], <<"{\"result\":\"failure\", \"error_text\":\"bad POST query\"}">>, Req)
          end,
  {ok, Req2, Opts}.