-module(idis).
-compile(export_all).

send_init(Socket) ->
  gen_tcp:send(Socket, <<10,16,0,0,0,20,140,140,25,6,0,0,0,1,0,0,0,48,49,48,48>>).

send_login(Socket, Username, Password) ->
  Username_bin = format_username(Username),
  Password_bin = format_password(Password),
  Content = <<Username_bin/binary, Password_bin/binary>>,
  send_message (Socket, <<1>>, Content).

format_username(U) ->
  Username_string = string:left(U,16,0),
  list_to_binary(Username_string).

format_password(P) ->
  Password_bin = erlsha2:sha256(P),
  Password_list = binary_to_list(Password_bin),
  Password_string = string:to_upper(lists:flatten(list_to_hex(Password_list))),
  list_to_binary(Password_string).

list_to_hex(L) ->
  lists:map(fun(X) -> int_to_hex(X) end, L).

int_to_hex(N) when N < 256 ->
  [hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 ->
  $0+N;
hex(N) when N >= 10, N < 16 ->
  $a + (N-10).

send_message(Socket, Type) ->
  Message = [<<40,54>>, Type, <<1>>, <<0,0,0,0>>],
  gen_tcp:send(Socket, Message).

send_message(Socket, Type, Content) ->
  Size_bin = binary:encode_unsigned(byte_size(Content), little),
  Size_list = binary_to_list(Size_bin),
  Size = string:left(Size_list,4,0),
  Message = [<<40,54>>, Type, <<0>>, Size, Content],
  gen_tcp:send(Socket, Message).

get_message(Socket) ->
  case gen_tcp:recv(Socket, 8) of
    {_,<<_Header:16,Type,Short,Size:32/integer-little>>} ->
      case Short of
        0 ->
          {_,Content} = gen_tcp:recv(Socket, Size),
          {Type, Content};
        1 ->
          {Type}
      end;
    {error, closed} -> {error, closed}
  end.