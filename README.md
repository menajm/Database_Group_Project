# Art Museum Database Group Project

This project implements a relational database for managing museum events, artwork, staff assignments, visitor registrations, and feedback. It demonstrates SQL schema design, data modeling, triggers, and stored procedures.

For this project, our team acted as database consultants for a fictional art museum seeking an improved system to manage its art pieces, exhibition schedules, staff coordination, and visitor engagement.

# Features
  - List the technical highlights:

  - Normalized relational schema

  - Cascading foreign keys

  - Composite primary keys

  - Data validation with CHECK constraints

  - Multiple SQL triggers

  - Stored procedure for event analytics

  - Sample dataset for testing

# Team Contributions

  Jenna Mena - Focused on the Museum Curator applications
  Liam Curiel - Focused on the Event Coordinator applications
  Emiliano Pecina-Tristan - Focused on the Customer Relations Analyst applications

# Conceptual Model

[Group Project Conceptual Model.drawio.pdf](https://github.com/user-attachments/files/24199947/Group.Project.Conceptual.Model.drawio.pdf)

Our conceptual model was designed to support the museum’s core operations: managing artists, their artwork, scheduled exhibitions, staff assignments, and visitor feedback. We ensured that each art piece is linked to its artist for accurate attribution and future filtering, and that every artwork can be associated with one or more events where visitors can view it and leave feedback.

During development, our team initially struggled with how to properly represent the relationship between events and art pieces. After reviewing the requirements, we revised the model to include an associative entity that accurately captures the many‑to‑many relationship between exhibitions and the artworks they feature.

# Relational Model

[Relational Model.drawio.pdf](https://github.com/user-attachments/files/24200098/Relational.Model.drawio.pdf)

The relational model formalizes the structure of the database and defines how each entity interacts with others. To accurately represent the many‑to‑many relationship between exhibitions and the artworks they feature, we introduced an associative table, Event_Pieces, which links each art piece to the events in which it appears.

The model incorporates primary and foreign keys, cascading actions, and validation rules to maintain data integrity across all tables. Triggers further reinforce this reliability by preventing invalid deletions, automating updates, and ensuring consistent relationships between events, artwork, staff, and visitor feedback.

# Triggeres & Stored Procedures

- updateArtCount: Increments an artist’s total artwork count when a new art piece is added for an artist already in the system.

- decrementArtCount: Decreases the artwork count when an art piece is removed from the museum’s collection.

- prevent_location_delete: Blocks deletion of any location that still has active events assigned to it.

- cleanup_feedback_after_event_delete: Automatically removes visitor feedback associated with an event when that event is deleted.

- validate_staff_location: Ensures staff cannot be assigned to locations that do not exist in the database.

- auto_feedback_date: Automatically sets the feedback date on insert if the user does not provide one.

- GetEventFeedbackSummary (Stored Procedure): Generates an event‑level analytics summary, returning the event’s theme, total number of feedback entries, and average visitor rating. This supports the museum’s need for reporting and data‑driven exhibit planning.
