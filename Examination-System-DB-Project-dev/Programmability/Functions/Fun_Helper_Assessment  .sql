CREATE OR ALTER FUNCTION [Assessment].fn_GetCurrentPersonID()
RETURNS INT
AS
BEGIN   
    DECLARE @PersonID INT;
    SELECT @PersonID = P.PersonID
    FROM Users.Account A
    JOIN Users.Person P ON A.AccountId = P.AccountId
    WHERE A.Username = SUSER_NAME()
      AND P.isDeleted = 0;
    RETURN @PersonID;
END;
GO

CREATE OR ALTER FUNCTION [Assessment].fn_GetCurrentUserRole()
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Role VARCHAR(20);
    DECLARE @PersonID INT = [Assessment].fn_GetCurrentPersonID();

    IF @PersonID IS NULL
        RETURN NULL;

    IF EXISTS (SELECT 1 FROM Users.Instructor WHERE InstructorID = @PersonID AND Is_Manager = 1)
        SET @Role = 'Manager';
    ELSE IF EXISTS (SELECT 1 FROM Users.Instructor WHERE InstructorID = @PersonID)
        SET @Role = 'Instructor';
    ELSE IF EXISTS (SELECT 1 FROM Users.Student WHERE StudentID = @PersonID)
        SET @Role = 'Student';

    RETURN @Role;
END;
GO

CREATE OR ALTER FUNCTION [Assessment].fn_IsCurrentUserManager()
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN dbo.fn_GetCurrentUserRole() = 'Manager' THEN 1 ELSE 0 END;
END;
GO