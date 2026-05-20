
USE ExamSystemDB;
GO

-- CLEANUP
DELETE FROM Assessment.Student_Exam_Result
    WHERE CourseID = 6001;
DELETE FROM Assessment.Student_Answer
    WHERE ExamID IN (SELECT ExamID FROM Assessment.Exam WHERE CourseID = 6001);
DELETE FROM Assessment.Student_Exam
    WHERE ExamID IN (SELECT ExamID FROM Assessment.Exam WHERE CourseID = 6001);
DELETE FROM Assessment.Exam_Questions
    WHERE ExamID IN (SELECT ExamID FROM Assessment.Exam WHERE CourseID = 6001);
DELETE FROM Assessment.Exam
    WHERE CourseID = 6001;
DELETE FROM Academic.Question_Choices
    WHERE QuestionID BETWEEN 6001 AND 6020;
DELETE FROM Academic.Question_Pool
    WHERE CourseID = 6001;
DELETE FROM Academic.Course_Instructor
    WHERE CourseID = 6001;
DELETE FROM Academic.Course
    WHERE CourseID = 6001;
DELETE FROM Org.Intake_Track  WHERE IntakeId    = 6001;
DELETE FROM Org.Intake        WHERE IntakeId    = 6001;
DELETE FROM Org.Track         WHERE TrackId     = 6001;
DELETE FROM Org.Department    WHERE DepartmentId= 6001;
DELETE FROM Org.Branch        WHERE BranchId    = 6001;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'prof60001')
    DROP USER [prof60001];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'stu_a_60001')
    DROP USER [stu_a_60001];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'stu_b_60001')
    DROP USER [stu_b_60001];

BEGIN TRY EXEC Users.usp_DeleteInstructor @Username = 'prof60001';   END TRY BEGIN CATCH END CATCH;
BEGIN TRY EXEC Users.usp_DeleteStudent    @Username = 'stu_a_60001'; END TRY BEGIN CATCH END CATCH;
BEGIN TRY EXEC Users.usp_DeleteStudent    @Username = 'stu_b_60001'; END TRY BEGIN CATCH END CATCH;
GO

---- ORG DATA---

SET IDENTITY_INSERT Org.Department ON;
INSERT INTO Org.Department (DepartmentId, DepartmentName)
    VALUES (6001, 'Dept_6001_CS');
SET IDENTITY_INSERT Org.Department OFF;

SET IDENTITY_INSERT Org.Branch ON;
INSERT INTO Org.Branch (BranchId, BranchName)
    VALUES (6001, 'Branch_6001_Alex');
SET IDENTITY_INSERT Org.Branch OFF;

SET IDENTITY_INSERT Org.Track ON;
INSERT INTO Org.Track (TrackId, TrackName, DepartmentId)
    VALUES (6001, 'Track_6001_Python', 6001);
SET IDENTITY_INSERT Org.Track OFF;

SET IDENTITY_INSERT Org.Intake ON;
INSERT INTO Org.Intake (IntakeId, IntakeYear, IntakeSemester)
    VALUES (6001, 2026, 'Spring');
SET IDENTITY_INSERT Org.Intake OFF;

INSERT INTO Org.Intake_Track (IntakeId, TrackId) VALUES (6001, 6001);

INSERT INTO Academic.Course (CourseID, CourseName, Description, Max_Degree, Min_Degree)
    VALUES (6001, 'Python_6001', 'Python Fundamentals', 100.00, 50.00);
GO

-------------REGISTER USERS----------

EXEC Users.usp_RegisterInstructor
    @Username='prof60001',   @Email='prof60001@test.com',  @PlainPassword='Prof@60001',
    @FirstName='Sam',      @LastName='Nour',             @SSN='60010000000901',
    @Phone='01060010081',   @Salary=55000,                @Office=N'Lab_60001',
    @Is_Manager=0;

EXEC Users.usp_RegisterStudent
    @Username='stu_a_60001', @Email='stu_a0@test.com',     @PlainPassword='StuA@60001',
    @FirstName='Laylaa',     @LastName='Nabil',            @SSN='60010000800002',
    @Phone='01060010502',   @TrackID=6001, @IntakeID=6001, @BranchID=6001;

EXEC Users.usp_RegisterStudent
    @Username='stu_b_60001', @Email='stu_b0@test.com',     @PlainPassword='StuB@60001',
    @FirstName='Karim',     @LastName='Samio',            @SSN='60010000700003',
    @Phone='01060010503',   @TrackID=6001, @IntakeID=6001, @BranchID=6001;
GO


-- COURSE + QUESTIONS + CHOICES
------------------------------------
DECLARE @ProfID INT;
SELECT @ProfID = P.PersonId
FROM Users.Person P
JOIN Users.Account A ON P.AccountId = A.AccountId
WHERE A.Username = 'prof60001';

INSERT INTO Academic.Course_Instructor (InstructorID, CourseID, Year, IsDeleted)
    VALUES (@ProfID, 6001, 2026, 0);

SET IDENTITY_INSERT Academic.Question_Pool ON;
INSERT INTO Academic.Question_Pool
    (QuestionID, CourseID, InstructorID, QuestionType, QuestionText, Best_Accepted_Answer)
VALUES
    (6001, 6001, @ProfID, 'MCQ',       'What is a Python list?',                         NULL),
    (6002, 6001, @ProfID, 'MCQ',       'Which keyword defines a function?',              NULL),
    (6003, 6001, @ProfID, 'TrueFalse', 'Python is case-sensitive',                       NULL),
    (6004, 6001, @ProfID, 'TrueFalse', 'A tuple can be modified after creation',         NULL),
    (6005, 6001, @ProfID, 'Text',      'Explain the difference between list and tuple',
        'A list is mutable while a tuple is immutable');
SET IDENTITY_INSERT Academic.Question_Pool OFF;

SET IDENTITY_INSERT Academic.Question_Choices ON;
INSERT INTO Academic.Question_Choices (ChoiceID, QuestionID, ChoiceText, IsCorrectChoice) VALUES
    (6001, 6001, 'An ordered mutable collection', 1),
    (6002, 6001, 'An unordered immutable set',    0),
    (6003, 6001, 'A key-value mapping',           0),
    (6004, 6001, 'A fixed-size array',            0),
    (6005, 6002, 'def',                           1),
    (6006, 6002, 'function',                      0),
    (6007, 6002, 'func',                          0),
    (6008, 6002, 'lambda',                        0),
    (6009, 6003, 'True',                          1),
    (6010, 6003, 'False',                         0),
    (6011, 6004, 'True',                          0),
    (6012, 6004, 'False',                         1);
SET IDENTITY_INSERT Academic.Question_Choices OFF;
GO

PRINT '  Instructor : prof60001   / Prof@60001';
PRINT '  Student A  : stu_a_60001 / StuA@60001';
PRINT '  Student B  : stu_b_60001 / StuB@60001';
GO
