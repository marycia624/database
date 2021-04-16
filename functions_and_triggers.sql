create or replace function never_delete()
    returns trigger as $$
begin
    RAISE EXCEPTION 'Removing passengers is not allowed';
    return NULL;
end;
$$ LANGUAGE plpgsql;

create or replace function create_incident()
    returns trigger as $$
begin
    insert into Black_list (Passenger_id) values (NEW.Passenger_id);
    insert into Incidents (Action_id, Time_police_officer_id)
    values (NEW.id, (select id from Time_police_officers where Priority = 1));
    delete from Tickets where Passenger_id = NEW.Passenger_id;
    return NEW;
end;
$$ LANGUAGE plpgsql;

create trigger incident_happened
    after insert on Actions
    for each row
    when (NEW.Is_legal = false)
execute procedure create_incident();

create or replace function change_priority()
    returns trigger as $$
begin
    update time_police_officers set Priority = Priority - 1;
    update time_police_officers set Priority = (select max(priority) from time_police_officers) + 1 where Priority = 0;
    return NEW;
end;
$$ LANGUAGE plpgsql;

create trigger change_priority_police
    after insert on incidents
    for each row
execute procedure change_priority();



create or replace function i_want_die()
returns table (my_col timestamp)
as $$
declare
        my_max_time timestamp;
        channel_free timestamp;
        g text;
begin
        select max(taken_to) into channel_free from Channels_queue where Channel_id = 41;
        raise notice  '%', channel_free;
        select max(taken_from) into my_max_time from doors_queue where Door_id = 6;
        if channel_free < current_timestamp + interval '30 min'
        then channel_free = current_timestamp + interval '30 min';
        end if;

        if my_max_time < channel_free
        then my_max_time := channel_free;
        end if;
        return query
            SELECT date_trunc('min', x)
            FROM generate_series( (channel_free)::timestamp,  (my_max_time + interval '1 min')::timestamp, interval  '1 min') t(x)
            WHERE date_trunc('min', x) not in (select taken_from from Doors_queue where door_id = 6);


end $$ language plpgsql;


create or replace function inserting_to_queue()
    returns trigger as $$
declare
    my_channel_id integer;
    channel_free timestamp;
    my_door_id integer;
    add_time timestamp;
    min integer;
    max_time timestamp;
begin

    if DATE_PART('year', CURRENT_TIMESTAMP) - NEW.Arrival_year  >= 5
    then UPDATE  Tickets SET Min_on_the_way = (DATE_PART('year', CURRENT_TIMESTAMP) - NEW.Arrival_year) where Passenger_id = NEW.Passenger_id;
            min := DATE_PART('year', CURRENT_TIMESTAMP) - NEW.Arrival_year;
    else UPDATE Tickets set Arrival_year = (DATE_PART('year', CURRENT_TIMESTAMP)) where id = NEW.id;
            min:= NEW.Min_on_the_way;
    end if;


    SELECT c.id into my_channel_id from Channels c join tickets t on c.Starting_station_id = t.Departure_station and c.End_station_id = t.Arrival_station where t.id = NEW.id;

    select max(taken_to) into channel_free from Channels_queue where Channel_id = my_channel_id;

    select id into my_door_id from Doors where Door_type = 'In' and Station_id = NEW.Departure_station;

    select max(taken_from) into max_time from doors_queue where Door_id = my_door_id;
    max_time:= max_time + interval '1 min';

    if channel_free < current_timestamp + interval '30 min' or channel_free IS NULL
    then channel_free = current_timestamp + interval '30 min';
    end if;

    if max_time < channel_free or max_time IS NULL
    then max_time := channel_free;
    end if;

    SELECT date_trunc('min', x) into add_time
    FROM generate_series( (channel_free)::timestamp,  (max_time + interval '1 min')::timestamp, interval  '1 min') t(x)
    WHERE date_trunc('min', x) not in (select taken_from from Doors_queue where door_id = my_door_id);

    insert into Doors_queue (Door_id, taken_from, Ticket_id)
    values (my_door_id, add_time, NEW.id);

    insert into Channels_queue (Channel_id, Taken_from, Taken_to, Ticket_id)
    values (my_channel_id, add_time + interval '1 min', add_time + min * interval '1 min', NEW.id);

    raise info 'You are in the queue. Waiting for you at %', add_time;

    return NEW;
    end;
$$ language plpgsql;


create trigger insert_to_queue
    after update of Ticket_is_in_queue on Tickets
    for each row
execute procedure inserting_to_queue();



create or replace function check_for_reserve()
returns trigger as $$
    begin
        if old.Ticket_is_in_queue = true
            then
                raise exception 'Ticket has been reserved already!';
            else
                return NEW;
        end if;
    end;
    $$ language plpgsql;

create trigger can_go_to_queue
    before update of Ticket_is_in_queue on Tickets
    for each row
execute procedure check_for_reserve();



create or replace function check_black_list()
    returns trigger as $$
begin
    if NEW.Passenger_id not in (select * from Black_list)
    then return NEW;
    else return NULL;
    end if;
end;
$$ language plpgsql;

create trigger buy_ticket
    before insert on Tickets
    for each row
execute procedure check_black_list();



UPDATE Tickets SET Ticket_is_in_queue = TRUE where id = 2;


insert into channels_queue (channel_id, taken_from, taken_to, ticket_id) (select id, date_trunc('min',current_timestamp), date_trunc('min',current_timestamp) + interval '1 min', 1 from channels);

create or replace function creat_back_ticket()
    returns trigger as $$
begin
    INSERT INTO Tickets (Passenger_id,Departure_station,Arrival_station,Purchase_datetime,Arrival_year,Ticket_is_in_queue)
    VALUES (NEW.Passenger_id,NEW.Arrival_station,NEW.Departure_station,CURRENT_TIMESTAMP,DATE_PART('year', CURRENT_TIMESTAMP),false);
    return NULL;
end;
$$ language plpgsql;

drop trigger create_back_ticket on Tickets;

create trigger create_back_ticket
    after insert on Tickets
    for each row
    when (NEW.Arrival_year != DATE_PART('year', CURRENT_TIMESTAMP))
execute procedure creat_back_ticket();

create or replace function set_police_priority()
returns trigger as $$
    declare max_pr integer;
    begin
        select max(priority) into max_pr from time_police_officers;
        NEW.priority = max_pr + 1;
        return NEW;
    end;
    $$ language plpgsql;

create trigger set_police_priority
    before insert on time_police_officers
    for each row
    execute procedure set_police_priority();