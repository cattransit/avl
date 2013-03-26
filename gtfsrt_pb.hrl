-ifndef(FEEDMESSAGE_PB_H).
-define(FEEDMESSAGE_PB_H, true).
-record(feedmessage, {
    header = erlang:error({required, header}),
    entity = []
}).
-endif.

-ifndef(FEEDHEADER_PB_H).
-define(FEEDHEADER_PB_H, true).
-record(feedheader, {
    gtfs_realtime_version = erlang:error({required, gtfs_realtime_version}),
    incrementality = 'FULL_DATASET',
    timestamp,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(FEEDENTITY_PB_H).
-define(FEEDENTITY_PB_H, true).
-record(feedentity, {
    id = erlang:error({required, id}),
    is_deleted = false,
    trip_update,
    vehicle,
    alert
}).
-endif.

-ifndef(TRIPUPDATE_PB_H).
-define(TRIPUPDATE_PB_H, true).
-record(tripupdate, {
    trip = erlang:error({required, trip}),
    stop_time_update = [],
    vehicle,
    timestamp,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(VEHICLEPOSITION_PB_H).
-define(VEHICLEPOSITION_PB_H, true).
-record(vehicleposition, {
    trip,
    position,
    current_stop_sequence,
    current_status = 'IN_TRANSIT_TO',
    timestamp,
    congestion_level,
    stop_id,
    vehicle,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(ALERT_PB_H).
-define(ALERT_PB_H, true).
-record(alert, {
    active_period = [],
    informed_entity = [],
    cause = 'UNKNOWN_CAUSE',
    effect = 'UNKNOWN_EFFECT',
    url,
    header_text,
    description_text,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(TIMERANGE_PB_H).
-define(TIMERANGE_PB_H, true).
-record(timerange, {
    start,
    pb_end
}).
-endif.

-ifndef(POSITION_PB_H).
-define(POSITION_PB_H, true).
-record(position, {
    latitude = erlang:error({required, latitude}),
    longitude = erlang:error({required, longitude}),
    bearing,
    odometer,
    speed,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(TRIPDESCRIPTOR_PB_H).
-define(TRIPDESCRIPTOR_PB_H, true).
-record(tripdescriptor, {
    trip_id,
    start_time,
    start_date,
    schedule_relationship,
    route_id,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(VEHICLEDESCRIPTOR_PB_H).
-define(VEHICLEDESCRIPTOR_PB_H, true).
-record(vehicledescriptor, {
    id,
    label,
    license_plate,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(ENTITYSELECTOR_PB_H).
-define(ENTITYSELECTOR_PB_H, true).
-record(entityselector, {
    agency_id,
    route_id,
    route_type,
    trip,
    stop_id,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(TRANSLATEDSTRING_PB_H).
-define(TRANSLATEDSTRING_PB_H, true).
-record(translatedstring, {
    translation = []
}).
-endif.

-ifndef(TRIPUPDATE_STOPTIMEUPDATE_PB_H).
-define(TRIPUPDATE_STOPTIMEUPDATE_PB_H, true).
-record(tripupdate_stoptimeupdate, {
    stop_sequence,
    arrival,
    departure,
    stop_id,
    schedule_relationship = 'SCHEDULED',
    '$extensions' = dict:new()
}).
-endif.

-ifndef(TRIPUPDATE_STOPTIMEEVENT_PB_H).
-define(TRIPUPDATE_STOPTIMEEVENT_PB_H, true).
-record(tripupdate_stoptimeevent, {
    delay,
    time,
    uncertainty,
    '$extensions' = dict:new()
}).
-endif.

-ifndef(TRANSLATEDSTRING_TRANSLATION_PB_H).
-define(TRANSLATEDSTRING_TRANSLATION_PB_H, true).
-record(translatedstring_translation, {
    text = erlang:error({required, text}),
    language
}).
-endif.

