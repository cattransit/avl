-module(cat_avl).
-compile(export_all).
-include("gtfsrt_pb.hrl").
-define(USERNAME, "admin").
-define(PASSWORD, "").

start(IPsFileName) ->
  start(IPsFileName, "cat_avl.pb").
start(IPsFileName, OutputFileName) ->
  {ok, [IPs]} = file:consult(IPsFileName),
  PID = spawn(?MODULE, protocol_buffers, [undefined, OutputFileName]),
  SpawnConnection = fun(IP) -> spawn(?MODULE, connect, [IP, PID]) end,
  lists:foreach(SpawnConnection, IPs).

connect(IP, PID) ->
  PORT = 8016,
  case gen_tcp:connect(IP, PORT, [binary, {active,false}, {packet,raw}], infinity) of
    {ok, Socket} ->
      idis:send_init(Socket),
      recv_loop(Socket, IP, PID, undefined);
    {error, etimedout} -> connect(IP, PID);
    {error, econnrefused} -> connect(IP, PID)
  end.

recv_loop(Socket, IP, PID, VID) ->
  case idis:get_message(Socket) of
    {error, closed} -> connect(IP, PID);
    {Type, Content} ->
      case handle_message(Socket, PID, Type, Content, VID) of
        {vid, NewVID} -> io:fwrite("Connected to ~p (Bus ~p)~n", [IP, NewVID]), recv_loop(Socket, IP, PID, NewVID);
        _ -> recv_loop(Socket, IP, PID, VID)
      end
  end.

handle_message(Socket, _PID, 20, _Content, _VID) ->
  idis:send_login(Socket, ?USERNAME, ?PASSWORD);
handle_message(_Socket, _PID, 3, <<255, 255, 255, 255>>, _VID) ->
  ok;
handle_message(_Socket, _PID, 18, _Content, _VID) ->
  ok;
handle_message(_Socket, _PID, 15, Content, _VID) ->
  {_, [BusID]} = re:run(Content, "Bus (\\d*)", [{capture, all_but_first, list}]),
  {vid, BusID};
handle_message(_Socket, PID, 98, Content, VID) ->
  case re:run(Content, "\\$(?:GPRMC).*?\\*.{2}", [{capture, first, list}]) of
    {_, [NMEA_sentence]} ->
      NMEA = string:tokens(NMEA_sentence,","),
      [GPSLock, LatN, LatCompass, LonN, LonCompass, Knots] = lists:sublist(NMEA, 3, 6),
      case GPSLock of
        "A" ->
          Lat = nmea_to_wgs84(LatN, LatCompass),
          Lon = nmea_to_wgs84(LonN, LonCompass),
          Speed = (Knots * 1852) / 3600,
          PID ! {VID, Lat, Lon, Speed};
        "V" ->
          ok
      end;
    _ -> ok
  end.

protocol_buffers(undefined, OutputFileName) ->
  Feed = #feedmessage{header=#feedheader{gtfs_realtime_version="1.0"},entity=[]},
  protocol_buffers(Feed, OutputFileName);
protocol_buffers(Feed, OutputFileName) ->
  receive
    {VID, Lat, Lon, Speed} ->
      NewEntities = lists:keystore(VID, #feedentity.id, Feed#feedmessage.entity, #feedentity{id=VID, vehicle=#vehicleposition{vehicle=#vehicledescriptor{id=VID},position=#position{latitude=Lat,longitude=Lon,speed=Speed}}}),
      NewFeed = Feed#feedmessage{entity=NewEntities},
      PB = gtfsrt_pb:encode_feedmessage(NewFeed),
      file:write_file(OutputFileName, PB),
      protocol_buffers(NewFeed, OutputFileName);
    terminate ->
      ok
  end.

nmea_to_wgs84(NMEA) ->
  {Float, _} = string:to_float(NMEA),
  Deg = trunc(Float/100),
  Deg + (Float-100*Deg)/60.
nmea_to_wgs84(NMEA, Compass) when Compass == "S"; Compass == "W" ->
  Deg = nmea_to_wgs84(NMEA),
  Deg * -1;
nmea_to_wgs84(NMEA, _Compass) ->
  nmea_to_wgs84(NMEA).