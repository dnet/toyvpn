% depends: https://github.com/msantos/tunctl

-module(toyvpn).
-export([start/0]).

start() ->
	{ok, Ref} = tuncer:create("toyvpn", [tun, no_pi, {active, true}]),
	ok = tuncer:up(Ref, "192.168.32.1"),
	{ok, Sock} = gen_udp:open(4444, [binary, {active, true}]),
	handler(Ref, Sock).

handler(Ref, Sock) ->
	receive
		{tuntap, Ref, Payload} ->
			io:format("<- ~p~n", [Payload]),
			gen_udp:send(Sock, {88,151,101,208}, 4444, Payload);
		{udp, Sock, IP, Port, Payload} ->
			io:format("-> ~p~n", [Payload]),
			tuncer:send(Ref, Payload);
		Msg -> io:format("Unknown message: ~p~n", [Msg])
	end,
	handler(Ref, Sock).
