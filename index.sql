explain analyze  select max(taken_from) from doors_queue where Door_id = 3;
create index queue_door_id on doors_queue(door_id);

create index queue_door_taken_from on doors_queue(taken_from);
drop index queue_door_id;

explain analyze select max(taken_to) from Channels_queue where Channel_id = 48;
create index queue_channel_id on channels_queue(channel_id);
create index queue_channel_taken_to on channels_queue(taken_to);


explain analyze SELECT c.id from Channels c join tickets t on c.Starting_station_id = t.Departure_station and c.End_station_id = t.Arrival_station where t.id = 252;
create  index ticket_passenger_id on tickets(passenger_id);
drop index ticket_passenger_id;

explain analyze select d.taken_from from Passengers p
    join Tickets t on t.Passenger_id = p.id
    join Doors_queue d on d.ticket_id = t.id
    where p.Passport_id = 13130689
        and EXTRACT(YEAR from CURRENT_TIMESTAMP)<>t.arrival_year
        and t.Departure_station = 6

create index ticket_passenger_id on tickets(passenger_id);
create index ticket_id in ticket(id)
create index passenger_id on passenger(id);
create index passenger_passport on passenger(passport);