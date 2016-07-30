-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

-define(TAB,ws_socket_conn).

init({tcp, http}, _Req, _Opts) ->
    io:format("init ~n"),
    {upgrade, protocol, cowboy_websocket}.

%% websocket handshake
websocket_init(_TransportName, Req, _Opts) ->
    io:format("websocket_init ~n"),
    %%erlang:start_timer(1000, self(), <<"Hello!">>),
    {ok, Req, undefined_state}.


%%producer handshake
websocket_handle({text, <<"0xFF0x00">>}, Req, State) ->
    io:format("one produce online ~p~n",[self()]),
    {reply, {text, << "ok">>}, Req, State};

%%consumer handshake
websocket_handle({text, <<"0xFE0x00",Topic/binary>>}, Req, State) ->
    ets:insert(?TAB,{{type,xfe,Topic},self()}),
    io:format("one consumer online topic:~p,pid:~p,state:~p~n",[Topic,self(),State]),

    {reply, {text, << "[]" >>}, Req, {topic,Topic}};

%%on message
websocket_handle({text, <<"0xFF0x01",_Topic:30/binary,Msg/binary>>}, Req, State) ->
    %%io:format("~p~n",[_Topic]),
    [Topic|_]=binary:split(_Topic,[<<0>>]),
    %%io:format("~p~n",[Topic]),
    Cms=ets:lookup(?TAB,{type,xfe,Topic}),
    %%io:format("push  ~p~n",[Cms]),
    push_msg(Cms,Msg),
    {reply, {text, << "ok">>}, Req, State};

%%other mesage    
websocket_handle(_Data, Req, State) ->
     io:format("~p~n",[_Data]),
%%     io:format("websocket_handle ~p,~p,~p~n",[_Data,Req,State]),
    {ok, Req, State}.

%%on erlang message and send msg to client
websocket_info({timeout, _Ref, Msg}, Req, State) ->
    %%erlang:start_timer(1000, self(), <<"How' you doin'?">>),
    {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
    io:format("websocket_info ~p,~p,~p~n",[_Info,Req,State]),
    {ok, Req, State}.

%%on close
websocket_terminate(_Reason, _Req, {topic,Topic}) ->
    ets:delete_object(?TAB, {{type,xfe,Topic},self()}),
    ok;

websocket_terminate(_Reason, _Req, _State) ->
    io:format("terminate ~n"),
    ok.

%%push message to consumer
push_msg(Cms,Msg)->
    case Cms of
        []->
            ok;
        [{_,Pid}|Last] ->
            Pid!{timeout,ok,Msg},
            push_msg(Last,Msg)
    end. 