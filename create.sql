CREATE TABLE Passengers (
                            id SERIAL primary key,
                            FIO TEXT NOT NULL,
                            Passport_id BIGINT NOT NULL UNIQUE
);

CREATE TABLE Stations (
                          id SERIAL primary key,
                          City TEXT NOT NULL
);

CREATE TABLE Tickets (
                         id SERIAL primary key,
                         Passenger_id INT REFERENCES Passengers(id) ON DELETE CASCADE NOT NULL,
                         Purchase_datetime TIMESTAMP NOT NULL,
                         Arrival_year INT NOT NULL,
                         Min_on_the_way INT,
                         Ticket_is_in_queue BOOLEAN DEFAULT false,
                         Departure_station INT REFERENCES Stations(id) ON DELETE CASCADE NOT NULL,
                         Arrival_station INT REFERENCES Stations(id) ON DELETE CASCADE NOT NULL,
                         CONSTRAINT ck_min CHECK (Min_on_the_way >= 5)
);

CREATE TABLE Channels (
                          id SERIAL primary key,
                          Starting_station_id INT REFERENCES Stations(id) ON DELETE CASCADE NOT NULL,
                          End_station_id INT REFERENCES Stations(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE Channels_queue (
                                Channel_id INT REFERENCES Channels(id) ON DELETE CASCADE NOT NULL,
                                Taken_from TIMESTAMP NOT NULL,
                                Taken_to TIMESTAMP NOT NULL,
                                Ticket_id INT REFERENCES Tickets(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE Doors (
                       id SERIAL primary key,
                       Door_type TEXT NOT NULL CHECK (Door_type IN ('In', 'Out')),
                       Station_id INT REFERENCES Stations(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE Doors_queue (
                             Door_id INT REFERENCES Doors(id) ON DELETE CASCADE NOT NULL,
                             Taken_from TIMESTAMP NOT NULL
);

ALTER TABLE Doors_queue
    ADD Ticket_id INT REFERENCES Tickets(id) ON DELETE CASCADE NOT NULL;

CREATE TABLE Black_list (
    Passenger_id INT REFERENCES Passengers(id) NOT NULL
);

CREATE TABLE Time_police_officers (
                                      id SERIAL primary key,
                                      FIO TEXT NOT NULL,
                                      Priority INT NOT NULL
);

CREATE TABLE Actions (
                         id SERIAL primary key,
                         Passenger_id INT REFERENCES Passengers(id) NOT NULL,
                         Description TEXT NOT NULL,
                         Is_legal BOOlEAN,
                         Time TIMESTAMP NOT NULL
);

CREATE TABLE Incidents (
                           id SERIAL primary key,
                           Action_id INT REFERENCES Actions(id) NOT NULL,
                           Time_police_officer_id INT REFERENCES Time_police_officers(id) NOT NULL
);
