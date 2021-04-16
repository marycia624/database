INSERT INTO Passengers (FIO, Passport_id)
VALUES  (
            'Громов Константин Михайлович',
            2563789874
        );

INSERT INTO Passengers (FIO, Passport_id)
VALUES  (
            'Громова Наджеда Михалйовна',
            2563795486
        );
INSERT INTO Passengers (FIO, Passport_id)
VALUES  (
            'Герман Екатерина Леонидовна',
            28324569878
        );
INSERT INTO Passengers (FIO, Passport_id)
VALUES  (
            'Чайковский Петр Ильич',
            2987452163
        );

INSERT INTO Passengers (FIO, Passport_id)
VALUES  (
            'Бернард Матвей Иванович',
            2987458734
        );

INSERT INTO Time_police_officers(FIO, Priority)
VALUES
('Ворошилов Климент Ефремович', 1),
('Тухачевский Михаил Николаевич', 2),
('Будённый Семён Михайлович', 3),
('Егоров Александр Ильич', 4),
('Блюхер Василий Константинович', 5),
('Тимошенко Семён Константинович', 6),
('Жуков Георгий Константинович', 7);

INSERT INTO Stations(City) VALUES ('Либерти-сити'), ('Эглоу'), ('Зурбаган'), ('Чарн'), ('Спрингфилд'), ('Касл-Рок'), ('Лидерград');

INSERT INTO Doors(Door_type, Station_id) select 'In' as door_type, id from Stations;

INSERT INTO Doors(Door_type, Station_id) select 'Out' as door_type, id from Stations;

INSERT INTO Channels (Starting_station_id, End_station_id) (select start.id, endd.id from Stations as start CROSS JOIN Stations as endd);

INSERT INTO Actions (Passenger_id, Description, Is_legal, Time)
VALUES
(5, 'разговаривает с человеком', false , CURRENT_TIMESTAMP);
