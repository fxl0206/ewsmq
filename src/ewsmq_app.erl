-module(ewsmq_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-define(TAB,ws_socket_conn).
%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	Routes    = route_helper:get_routes(),
	Dispatch  = cowboy_router:compile(Routes),
	Port      = 8080,
	TransOpts = [{port, Port}],
	ProtoOpts = [{env, [{dispatch, Dispatch}]}],
	cowboy:start_http(http, 100, TransOpts, ProtoOpts),
    
    ets:new(?TAB, [set,bag, public, named_table]),

	ewsmq_sup:start_link().

stop(_State) ->
    ok.
