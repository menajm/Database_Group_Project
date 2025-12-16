use cs_2025_fall_3430_101_t8;

drop table if exists Artist;
drop table if exists ArtPiece;
drop table if exists Location;
drop table if exists Event;
drop table if exists Staff;
drop table if exists Visitor_Feedback;
drop table if exists Event_Pieces;

CREATE TABLE Artist (
    Artist_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    DOB DATE
);
INSERT INTO Artist (Artist_ID, Name, DOB) VALUES
(1, 'Clara Mendel', '1975-04-12'),
(2, 'Jamal Ortiz', '1982-11-03'),
(3, 'Sophie Zhang', '1990-06-21');
CREATE TABLE ArtPiece (
    Art_ID INT PRIMARY KEY,
    Title VARCHAR(150) NOT NULL,
    Media VARCHAR(50),
    Genre VARCHAR(50),
    Time_Period VARCHAR(50),
    Artist_ID INT NOT NULL,
    FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
INSERT INTO ArtPiece (Art_ID, Title, Media, Genre, Time_Period, Artist_ID) VALUES
(101, 'Echoes of Silence', 'Oil on Canvas', 'Abstract', 'Contemporary', 1),
(102, 'Urban Pulse', 'Mixed Media', 'Modern', '21st Century', 2),
(103, 'Lotus Dreams', 'Ink on Rice Paper', 'Minimalist', 'Modern', 3);
CREATE TABLE Location (
    Location_ID INT PRIMARY KEY,
    Location_Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200)
);
INSERT INTO Location (Location_ID, Location_Name, Address) VALUES
(10, 'North Gallery', '123 Museum Ave'),
(11, 'East Wing', '456 Culture Blvd'),
(12, 'Sculpture Hall', '789 Art Street');
CREATE TABLE Event (
    Event_ID INT PRIMARY KEY,
    Theme VARCHAR(100),
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Details TEXT,
    Location_ID INT NOT NULL,
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
INSERT INTO Event (Event_ID, Theme, Start_Date, End_Date, Details, Location_ID) VALUES
(201, 'Reflections of Time', '2025-11-01', '2025-11-30', 'Exploring temporal themes in modern art.', 10),
(202, 'Voices in Color', '2025-12-05', '2026-01-10', 'Celebrating diversity through vibrant palettes.', 11);
CREATE TABLE Staff (
    Staff_ID INT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Department VARCHAR(50),
    Contact_Info VARCHAR(100),
    Location_ID INT,
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
INSERT INTO Staff (Staff_ID, First_Name, Last_Name, Department, Contact_Info, Location_ID) VALUES
(301, 'Ava', 'Nguyen', 'Curatorial', 'ava.nguyen@museum.org', 10),
(302, 'Leo', 'Martinez', 'Education', 'leo.martinez@museum.org', 11),
(303, 'Nina', 'Patel', 'Security', 'nina.patel@museum.org', 12);
CREATE TABLE Visitor_Feedback (
    VisitorID INT,
    Event_ID INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments TEXT,
    Feedback_Date DATE NOT NULL,
    PRIMARY KEY (VisitorID, Event_ID),
    FOREIGN KEY (VisitorID) REFERENCES Visitor(VisitorID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO Visitor_Feedback (VisitorID, Event_ID, Rating, Comments, Feedback_Date) VALUES
(401, 201, 5, 'Incredible curation and flow.', '2025-11-15'),
(402, 202, 4, 'Loved the color themes!', '2025-12-20'),
(403, 201, 3, 'Interesting pieces but layout was confusing.', '2025-11-22');
CREATE TABLE Event_Pieces (
    Event_ID INT,
    Art_ID INT,
    PRIMARY KEY (Event_ID, Art_ID),
    FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Art_ID) REFERENCES ArtPiece(Art_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
INSERT INTO Event_Pieces (Event_ID, Art_ID) VALUES
(201, 101),
(201, 103),
(202, 102);
CREATE TABLE Visitor (
    VisitorID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Registered_Date DATE
);
INSERT INTO Visitor (VisitorID, Name, Email, Registered_Date) VALUES
(401, 'Emily Carter', 'emily.carter@example.com', '2025-10-01'),
(402, 'Raj Mehta', 'raj.mehta@example.com', '2025-11-05'),
(403, 'Lena Brooks', 'lena.brooks@example.com', '2025-11-10');

DELIMITER //
CREATE TRIGGER prevent_location_delete
BEFORE DELETE ON Location
FOR EACH ROW
BEGIN
    DECLARE event_count INT;
    SELECT COUNT(*) INTO event_count
    FROM Event
    WHERE Location_ID = OLD.Location_ID;

    IF event_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete location: active';
    END IF;
END//

DELIMITER ;

DELIMITER //
CREATE TRIGGER cleanup_feedback_after_event_delete
AFTER DELETE ON Event
FOR EACH ROW
BEGIN
    DELETE FROM Visitor_Feedback
    WHERE Event_ID = OLD.Event_ID;
END//

DELIMITER ;


DELIMITER //
CREATE TRIGGER validate_staff_location
BEFORE INSERT ON Staff
FOR EACH ROW
BEGIN
    DECLARE loc_exists INT;
    SELECT COUNT(*) INTO loc_exists
    FROM Location
    WHERE Location_ID = NEW.Location_ID;

    IF loc_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Assigned location does not exist.';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER auto_feedback_date
BEFORE INSERT ON Visitor_Feedback
FOR EACH ROW
BEGIN
    IF NEW.Feedback_Date IS NULL THEN
        SET NEW.Feedback_Date = CURDATE();
    END IF;
END//

DELIMITER ;

-- Procedure to get the average rating and count of feedback for a specific event
DROP PROCEDURE IF EXISTS GetEventFeedbackSummary;
DELIMITER //
CREATE PROCEDURE GetEventFeedbackSummary(
    IN p_Event_ID INT
)
BEGIN
	START TRANSACTION;
    -- This query joins the feedback with the event name and calculates the average rating and total count.
    SELECT
        T2.Theme AS Event_Theme,
        COUNT(T1.Rating) AS Total_Feedback_Count,
        IFNULL(AVG(T1.Rating), 0) AS Average_Rating
    FROM Visitor_Feedback T1
    JOIN Event T2 ON T1.Event_ID = T2.Event_ID
    WHERE T1.Event_ID = p_Event_ID
    GROUP BY T2.Theme;
    
    COMMIT;
END //
DELIMITER ;

CALL GetEventFeedbackSummary(201);

