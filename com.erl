-module(com).
-compile(export_all).


start() ->
	io:format("Hello! Welcome to the communicator!~n"),
	Pid = spawn(fun init_run/0),
	register(server, Pid).
	%add_user().

init_run() ->
	State = #{users=>[]},
	run(State).

add_user(Name) ->
	Pid = whereis(server), %%returns the pid of the process that's registered with the name
	Pid ! {add_user, Name},
	ok.

read_next_message(Name) ->
	Pid = whereis(server),
	Pid ! {read_next_meeesage, Name},
	ok.

send_message(To, From, Message) ->
	Pid = whereis(server),
	Pid ! {send_message, {To, From, Message}},
	ok.

%%===================================================================================
%%handling server
%%===================================================================================
run(#{users:=Names_list}=State) ->
	
	receive
		{add_user, Name} ->
			UserPid = spawn(fun init_user_loop/0),
			register(Name, UserPid),
			run(State#{users=>Names_list++[{Name, UserPid}]});
		{send_message, {To, From, Message}} ->
			%% resolve name of recipent (To) to find pid
		     Pid = whereis(To),
			 Pid ! {message, From, Message},
			run(State);
		{read_next_meeesage, Name} ->
			Name ! read_next_message,
			run(State);
		stop ->
			ok
	end.


%%===================================================================================
%%user
%%===================================================================================
init_user_loop() ->
  user_loop(#{inbox=>[]}).

%% #{inbox => {{from1, "msg1"}, {from2, "msg2"}}}
user_loop(#{inbox:=Inbox}=State) ->
	receive
		{message, From, Message} ->
			%% add message to inbox
		    %% [{from1, "msg1"}, {from2, "msg2"}]
            NewInbox = Inbox ++ [{From, Message}], %% update inbox list with NewInbox
			user_loop(State#{inbox=>NewInbox}); %% aktualizacja stanu 
		read_next_message ->
			[{From, Message} | T] = Inbox,
			io:format("From: ~p Message: ~p~n", [From, Message]),
			user_loop(State#{inbox=>T});
		stop ->
			ok
	end.


