-module(timecache_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    sync:go(),

    Dispatch = cowboy_router:compile([
        {'_', [
                {"/add", add_handler, []},
                {"/delete", delete_handler, []},
                {"/get", get_handler, []}
        ]}
    ]),

    {ok, _} = cowboy:start_http(http, 100, [{port, 8181}, {max_connections, infinity}],
        [{env, [{dispatch, Dispatch}]}]),

    timecache_sup:start_link().

stop(_State) ->
    ok.
