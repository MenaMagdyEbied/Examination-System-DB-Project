
USE ExamSystemDB;
GO

SELECT USER_NAME() AS [Status];
GO


DECLARE @EID INT;
DECLARE @S   DATETIME = DATEADD(DAY,   -1, GETDATE());
DECLARE @E   DATETIME = DATEADD(MINUTE, 5, GETDATE());
EXEC Assessment.sp_CreateExam
    @CourseID=6001, @BranchID=6001, @TrackID=6001, @IntakeID=6001,
    @ExamType='Exam', @Total_Time=60,
    @Start_Time=@S, @End_Time=@E,
    @ExamID=@EID OUTPUT;
GO

-- STEP 2: ADD QUESTIONS  (Q6001=20, Q6002=20, Q6003=15, Q6004=15, Q6005=30 = 100)
DECLARE @EID INT = (
    SELECT TOP 1 ExamID FROM Assessment.vw_ExamDetails
    WHERE CourseID=6001 AND ExamDeleted=0 ORDER BY ExamID DESC
);
EXEC Assessment.sp_UpsertExamQuestion @ExamID=@EID, @QuestionID=6001, @Question_Degree=20;
EXEC Assessment.sp_UpsertExamQuestion @ExamID=@EID, @QuestionID=6002, @Question_Degree=20;
EXEC Assessment.sp_UpsertExamQuestion @ExamID=@EID, @QuestionID=6003, @Question_Degree=15;
EXEC Assessment.sp_UpsertExamQuestion @ExamID=@EID, @QuestionID=6004, @Question_Degree=15;
EXEC Assessment.sp_UpsertExamQuestion @ExamID=@EID, @QuestionID=6005, @Question_Degree=30;
GO

-- STEP 3: BULK ASSIGN ALL STUDENTS
DECLARE @EID INT;
DECLARE @ST  DATETIME;
DECLARE @ET  DATETIME;
DECLARE @ED  DATE;
SELECT TOP 1
    @EID = ExamID,
    @ST  = Start_Time,
    @ET  = End_Time
FROM Assessment.vw_ExamDetails
WHERE CourseID=6001 AND ExamDeleted=0
ORDER BY ExamID DESC;
SET @ED = CAST(@ST AS DATE);
EXEC Assessment.sp_BulkAssignStudentsToExam
    @ExamID    = @EID,
    @Exam_Date = @ED,
    @Start_Time= @ST,
    @End_Time  = @ET;
GO

-- STEP 4: VIEW EXAM + ASSIGNMENTS
DECLARE @EID INT = (
    SELECT TOP 1 ExamID FROM Assessment.vw_ExamDetails
    WHERE CourseID=6001 AND ExamDeleted=0 ORDER BY ExamID DESC
);
EXEC Assessment.sp_ReadExam @ExamID=@EID;
SELECT StudentID, StudentName, Start_Time, End_Time, IsWindowActive
FROM Assessment.vw_StudentExamAssignments
WHERE ExamID = @EID;
GO


-- STEP 5: VIEW PENDING TEXT ANSWERS  --- Answer_ID 
EXEC Assessment.sp_GetPendingTextReviews;
GO


EXEC Assessment.sp_GradeTextAnswer @Answer_ID=46, @Is_Correct=1, @Earned_Degree=15;
GO

-- STEP 7: CALCULATE RESULTS + STATISTICS
DECLARE @EID INT = (
    SELECT TOP 1 ExamID FROM Assessment.vw_ExamDetails
    WHERE CourseID=6001 AND ExamDeleted=0 ORDER BY ExamID DESC
);
EXEC Assessment.sp_CalculateAllExamResults @ExamID=@EID;
EXEC Assessment.sp_GetExamStatistics       @ExamID=@EID;
EXEC Assessment.sp_GetExamAnswerSheet      @ExamID=@EID;
GO