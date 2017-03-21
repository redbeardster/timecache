-module(timecache).
-behaviour(gen_server).
-define(SERVER, ?MODULE).
-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([set_key/3, get_key/1, delete_key/1, timer/2]).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

get_key(Key) ->

  gen_server:call(?SERVER, {get_key, Key}).

delete_key(Key) ->

    gen_server:cast(?SERVER, {delete_key, Key}).

set_key(Key, Value, Timeout) ->
     gen_server:cast(?SERVER, {set_key, Key, Value, Timeout}).

timer(Key, Timeout) ->

        timer:sleep(Timeout),
        whereis(timecache) ! {timeout, Key}.

init(Args) ->

      dets:open_file("cache.db", [{auto_save,1000}]),

  {ok, Args}.

%%  ========================
%%    get key/value
%%  ========================

handle_call({get_key, Key}, _From, State) ->

      Value = dets:lookup("cache.db", Key),

  {reply, Value, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%  =========================
%%    add key & value
%%  =========================

handle_cast({set_key, Key, Value, Timeout}, State) ->

  dets:insert("cache.db", [{Key, Value}]),

  case whereis(Key) of
    undefined  -> ok;
    PID ->
          erlang:exit(PID, kill),
          erlang:unregister(Key)
  end,

   Pid = spawn(timecache, timer, [Key,Timeout]),
   register(Key, Pid),

  {noreply, State};

%%  ========================
%%    delete key
%%  ========================

handle_cast({delete_key, Key}, State) ->

  dets:delete("cache.db", Key),

  case whereis(Key) of
    undefined  -> ok;
    PID ->
      erlang:exit(PID, kill),
      erlang:unregister(Key)
  end,

  {noreply, State};


handle_cast(_Msg, State) ->
    {noreply, State}.

%%  ========================
%%    TTL expires
%%  ========================

handle_info({timeout, Key}, State) ->

    dets:delete("cache.db", Key),

  {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

