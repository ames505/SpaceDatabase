CREATE DATABASE SpaceExploration; 

CREATE TABLE Missions (
    MissionID INT PRIMARY KEY,
    MissionName VARCHAR(255) NOT NULL,
    LaunchDate DATE,
    MissionType VARCHAR(50),
    Status VARCHAR(50)
);

CREATE TABLE Spacecraft (
    SpacecraftID INT PRIMARY KEY,
    SpacecraftName VARCHAR(255) NOT NULL,
    Manufacturer VARCHAR(255),
    LaunchVehicle VARCHAR(255),
    MissionID INT,
    FOREIGN KEY (MissionID) REFERENCES Missions(MissionID)
);

CREATE TABLE Astronauts (
    AstronautID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Nationality VARCHAR(50),
    BirthDate DATE,
    SpacecraftID INT,
    FOREIGN KEY (SpacecraftID) REFERENCES Spacecraft(SpacecraftID)
);

CREATE TABLE Planets (
    PlanetID INT PRIMARY KEY,
    PlanetName VARCHAR(255) NOT NULL,
    DistanceFromEarth FLOAT,
    OrbitalPeriod FLOAT
);

CREATE TABLE Discoveries (
    DiscoveryID INT PRIMARY KEY,
    MissionID INT,
    Description TEXT,
    Date DATE,
    FOREIGN KEY (MissionID) REFERENCES Missions(MissionID)
);

INSERT INTO Missions (MissionID, MissionName, LaunchDate, MissionType, Status)
VALUES
(1, 'Apollo 11', '1969-07-16', 'Manned Lunar Landing', 'Completed'),
(2, 'Voyager 1', '1977-09-05', 'Flyby', 'Ongoing'),
(3, 'Curiosity Rover', '2011-11-26', 'Rover', 'Ongoing'),
(4, 'Hubble Space Telescope', '1990-04-24', 'Orbiter', 'Ongoing'),
(5, 'Mars Pathfinder', '1996-12-04', 'Lander', 'Completed');

INSERT INTO Spacecraft (SpacecraftID, SpacecraftName, Manufacturer, LaunchVehicle, MissionID)
VALUES
(1, 'Apollo Lunar Module', 'Grumman', 'Saturn V', 1),
(2, 'Voyager 1 Spacecraft', 'Jet Propulsion Laboratory', 'Titan IIIE', 2),
(3, 'Curiosity Rover', 'Jet Propulsion Laboratory', 'Atlas V', 3),
(4, 'Hubble Space Telescope', 'Lockheed Martin', 'Space Shuttle Discovery', 4),
(5, 'Mars Pathfinder', 'Jet Propulsion Laboratory', 'Delta II', 5);

INSERT INTO Astronauts (AstronautID, Name, Nationality, BirthDate, SpacecraftID)
VALUES
(1, 'Neil Armstrong', 'American', '1930-08-05', 1),
(2, 'Buzz Aldrin', 'American', '1930-01-20', 1),
(3, 'Sally Ride', 'American', '1951-05-26', NULL), -- Not assigned to a mission
(4, 'Chris Hadfield', 'Canadian', '1959-08-29', NULL); -- Not  assigned to a mission

INSERT INTO Planets (PlanetID, PlanetName, DistanceFromEarth, OrbitalPeriod)
VALUES
(1, 'Mars', 225000000, 687),
(2, 'Venus', 41000000, 225),
(3, 'Jupiter', 778500000, 4332),
(4, 'Saturn', 1433500000, 10759),
(5, 'Neptune', 4495100000, 60190);

INSERT INTO Discoveries (DiscoveryID, MissionID, Description, Date)
VALUES
(1, 1, 'First human landing on the Moon', '1969-07-20'),
(2, 2, 'Discovered the edge of the solar system (Heliopause)', '2012-08-25'),
(3, 3, 'Discovered evidence of ancient water on Mars', '2012-08-06'),
(4, 4, 'Captured high-resolution images of distant galaxies', '1990-05-20'),
(5, 5, 'Analyzed the Martian atmosphere', '1997-07-04');

-- Retrieve the names of astronauts and the missions they were part of, including the mission status:
SELECT a.Name AS AstronautName, m.MissionName, m.Status
FROM Astronauts a
JOIN Spacecraft s ON a.SpacecraftID = s.SpacecraftID
JOIN Missions m ON s.MissionID = m.MissionID;

-- Retrieve the name and launch date of the mission with the earliest launch date:
SELECT MissionName, LaunchDate
FROM Missions
WHERE LaunchDate = (
    SELECT MIN(LaunchDate)
    FROM Missions
);

-- Retrieve the total number of missions for each type of mission:
SELECT MissionType, COUNT(*) AS MissionCount
FROM Missions
GROUP BY MissionType; 


-- trigger to log details when a new discovery is recorded for a mission
DELIMITER $$
CREATE TRIGGER log_discovery_trigger
AFTER INSERT ON Discoveries
FOR EACH ROW
BEGIN
   INSERT INTO Missions (MissionID, Description, Date)
   VALUES (NEW.MissionID, NEW.Description, NEW.Date);
END $$
DELIMITER ;


--events to delete completed mission
DELIMITER $$
CREATE EVENT delete_completed_missions
ON SCHEDULE EVERY 1 YEAR
DO
BEGIN
   DELETE 
   FROM Missions
   WHERE Status = 'completed';
END $$
DELIMITER $$


DELIMITER //
CREATE FUNCTION AVERAGE_PLANET_DISTANCE_FROM_EARTH()
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN (SELECT AVG(DISTANCEFROMEARTH) FROM PLANETS);
END //
DELIMITER ;

SELECT AVERAGE_PLANET_DISTANCE_FROM_EARTH() AS AvgDistanceFromEarth;

DELIMITER //
CREATE PROCEDURE SPACECRAFTS_CURRENTLY_ON_MISSION ()
BEGIN
SELECT SPACECRAFTNAME
FROM SPACECRAFT
WHERE MISSIONID IN (
SELECT MISSIONID
FROM MISSIONS
WHERE STATUS = 'ONGOING');
END //
DELIMITER ;


CALL SPACECRAFTS_CURRENTLY_ON_MISSION ();

CREATE VIEW MissionDetailsView AS
SELECT 
    m.MissionName,
    m.LaunchDate,
    m.MissionType,
    s.SpacecraftName,
    a.Name AS AstronautName,
    d.Description AS DiscoveryDescription,
    d.Date AS DiscoveryDate
FROM 
    Missions m
LEFT JOIN 
    Spacecraft s ON m.MissionID = s.MissionID
LEFT JOIN 
    Astronauts a ON s.SpacecraftID = a.SpacecraftID
LEFT JOIN 
    Discoveries d ON m.MissionID = d.MissionID;


SELECT * FROM MissionDetailsView;


