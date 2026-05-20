/*
      stu_a_60001 / StuA@60001  
       stu_b_60001 / StuB@60001  
*/
USE ExamSystemDB;
GO

SELECT USER_NAME() AS [Status];
GO


SELECT ExamID, CourseName, ExamType, Start_Time, End_Time, IsWindowActive
FROM Assessment.vw_StudentExamAssignments;
GO
--------------------------------------------------------------------------

DECLARE @EID INT = (SELECT TOP 1 ExamID 
                    FROM Assessment.vw_StudentExamAssignments 
                    WHERE ExamID=-10 
                    ORDER BY ExamID DESC);

EXEC Assessment.sp_GetStudentExamQuestions @ExamID=@EID;
GO

-----------------------------------------------------------------------------
DECLARE @EID INT = (SELECT TOP 1 ExamID 
                    FROM Assessment.vw_StudentExamAssignments 
                    WHERE ExamID=10
                    ORDER BY ExamID DESC);
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6001, @Student_Answer='A key-value mapping';
PRINT ' Q1 submitted (wrong)';
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6002, @Student_Answer='lambda';
PRINT ' Q2 submitted (wrong)';
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6003, @Student_Answer='True';
PRINT ' Q3 submitted (correct)';
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6004, @Student_Answer='True';
PRINT ' Q4 submitted (wrong)';
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6005, @Student_Answer='I have no idea';
PRINT ' Q5 submitted (bad text)';
GO
--------------------------------upadet------------------------
DECLARE @EID INT = (SELECT TOP 1 ExamID 
                    FROM Assessment.vw_StudentExamAssignments 
                    WHERE ExamID=10
                    ORDER BY ExamID DESC);
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6001, @Student_Answer='An ordered mutable collection';
PRINT ' Q1 updated → CORRECT';
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6002, @Student_Answer='def';
PRINT ' Q2 updated → CORRECT';
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6004, @Student_Answer='False';
PRINT ' Q4 updated → CORRECT';
GO

----delete answer and resubmit-----------------------------
DECLARE @EID INT = (SELECT TOP 1 ExamID 
                    FROM Assessment.vw_StudentExamAssignments 
                    WHERE ExamID=10
                    ORDER BY ExamID DESC);
EXEC Assessment.sp_DeleteAnswer @ExamID=@EID, @QuestionID=6005;
GO

DECLARE @EID INT = (SELECT TOP 1 ExamID 
                    FROM Assessment.vw_StudentExamAssignments 
                    WHERE ExamID=10
                    ORDER BY ExamID DESC);
EXEC Assessment.sp_UpsertAnswer @ExamID=@EID, @QuestionID=6005,
    @Student_Answer='A list is mutable meaning you can change its elements while a tuple is immutable and cannot be changed after creation';
GO
----------------------------------------------------

EXEC Assessment.sp_GetStudentExamHistory;
GO

--------------------------------------------------------------------
SELECT CourseName, ExamType, Total_Score, Grade, Pass_Fail
FROM Assessment.vw_StudentExamResults;
GO

----------------------------------------------------------------------

DECLARE @EID INT = (SELECT TOP 1 ExamID 
                    FROM Assessment.vw_StudentExamAssignments
                    ORDER BY ExamID DESC);
EXEC Assessment.sp_StudentPostExamReview @ExamID=@EID;
GO


