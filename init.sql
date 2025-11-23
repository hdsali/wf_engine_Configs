-- ==========================================
-- Create database if not exists
-- ==========================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'WorkFlow_V3')
BEGIN
    CREATE DATABASE WorkFlow_V3;
END
GO

USE WorkFlow_V3;
GO

-- ==========================================
-- Create Companies table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Companies')
BEGIN
    CREATE TABLE Companies (
        Id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
        Title NVARCHAR(MAX) NOT NULL
    );
END
GO

-- ==========================================
-- Create WorkflowDefinitions table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WorkflowDefinitions')
BEGIN
    CREATE TABLE WorkflowDefinitions (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(MAX) NOT NULL,
        Description NVARCHAR(MAX) NULL
    );
END
GO

-- ==========================================
-- Create WorkflowStates table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WorkflowStates')
BEGIN
    CREATE TABLE WorkflowStates (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        StateName NVARCHAR(MAX) NOT NULL,
        WorkflowDefinitionId INT NOT NULL,
        FOREIGN KEY (WorkflowDefinitionId) REFERENCES WorkflowDefinitions(Id) ON DELETE CASCADE
    );
END
GO

-- ==========================================
-- Create WorkflowTransitions table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WorkflowTransitions')
BEGIN
    CREATE TABLE WorkflowTransitions (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        FromStateId INT NOT NULL,
        ToStateId INT NOT NULL,
        Condition NVARCHAR(MAX) NOT NULL,
        WorkflowDefinitionId INT NOT NULL,
        FOREIGN KEY (WorkflowDefinitionId) REFERENCES WorkflowDefinitions(Id) ON DELETE CASCADE,
        FOREIGN KEY (FromStateId) REFERENCES WorkflowStates(Id) ,
        FOREIGN KEY (ToStateId) REFERENCES WorkflowStates(Id) 
    );
END
GO

-- ==========================================
-- Create WorkflowInstances table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WorkflowInstances')
BEGIN
    CREATE TABLE WorkflowInstances (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        WorkflowDefinitionId INT NOT NULL,
        CurrentStateId INT NOT NULL,
        CompanyId UNIQUEIDENTIFIER NOT NULL,
        StartDate DATETIME2 NOT NULL,
        EndDate DATETIME2 NULL,
        InitiatedBy NVARCHAR(MAX) NULL,
        WorkflowName NVARCHAR(MAX) NULL,
        FOREIGN KEY (WorkflowDefinitionId) REFERENCES WorkflowDefinitions(Id) ON DELETE CASCADE,
        FOREIGN KEY (CurrentStateId) REFERENCES WorkflowStates(Id) ,
        FOREIGN KEY (CompanyId) REFERENCES Companies(Id) 
    );
END
GO

-- ==========================================
-- Create WorkflowNotifications table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WorkflowNotifications')
BEGIN
    CREATE TABLE WorkflowNotifications (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        WorkflowInstanceId INT NOT NULL,
        StateName NVARCHAR(MAX) NOT NULL,
        Role NVARCHAR(MAX) NOT NULL,
        Message NVARCHAR(MAX) NOT NULL,
        IsRead BIT NOT NULL,
        CreatedAt DATETIME2 NOT NULL
    );
END
GO

-- ==========================================
-- Create WorkflowStateAssignments table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WorkflowStateAssignments')
BEGIN
    CREATE TABLE WorkflowStateAssignments (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        StateName NVARCHAR(MAX) NOT NULL,
        Role NVARCHAR(MAX) NOT NULL
    );
END
GO

-- ==========================================
-- Create WorkflowHistories table
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WorkflowHistories')
BEGIN
    CREATE TABLE WorkflowHistories (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        WorkflowInstanceId INT NOT NULL,
        FromStateId INT NOT NULL,
        ToStateId INT NOT NULL,
        Action NVARCHAR(MAX) NULL,
        PerformedBy NVARCHAR(MAX) NULL,
        Comment NVARCHAR(MAX) NULL,
        TransitionedAt DATETIME2 NOT NULL,
        FOREIGN KEY (WorkflowInstanceId) REFERENCES WorkflowInstances(Id) ON DELETE CASCADE,
        FOREIGN KEY (FromStateId) REFERENCES WorkflowStates(Id) ,
        FOREIGN KEY (ToStateId) REFERENCES WorkflowStates(Id) 
    );
END
GO

-- ==========================================
-- Seed WorkflowDefinitions
-- ==========================================
IF NOT EXISTS (
    SELECT 1 FROM Companies 
    WHERE Id = '3fa85f64-5717-4562-b3fc-2c963f66afa6'
)
BEGIN
    INSERT INTO Companies (Id, Title)
    VALUES ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Company1');
END
GO

INSERT INTO WorkflowDefinitions (Name, Description)
VALUES 
('WF1 - Simple Approval', 'Simple approval workflow'),
('WF3 - Transmittal approval', 'Includes document controll dispatching steps');
GO

-- ==========================================
-- Seed WorkflowStates
-- ==========================================
DECLARE @WF1Id INT = (SELECT Id FROM WorkflowDefinitions WHERE Name='WF1 - Simple Approval');
-- WF1 states
INSERT INTO WorkflowStates (StateName, WorkflowDefinitionId) VALUES
('Start', @WF1Id),
('Draft', @WF1Id),
('Review', @WF1Id),
('Approved', @WF1Id),
('Rejected', @WF1Id);
GO

-- WF3 states
DECLARE @WF3Id INT = (SELECT Id FROM WorkflowDefinitions WHERE Name='WF3 - Transmittal approval');
INSERT INTO WorkflowStates (StateName, WorkflowDefinitionId) VALUES
('Start', @WF3Id),
('Draft', @WF3Id),
('UnderReview', @WF3Id),
('PendingApproval', @WF3Id),
('ReadyforDispatch', @WF3Id),
('Dispatched', @WF3Id),
('Acknowledged', @WF3Id),
('Returned', @WF3Id),
('End', @WF3Id);
GO

-- ==========================================
-- Seed WorkflowTransitions
-- ==========================================

-- WF1 transitions
DECLARE @WF1Id INT = (SELECT Id FROM WorkflowDefinitions WHERE Name='WF1 - Simple Approval');
DECLARE @WF1Start INT = (SELECT Id FROM WorkflowStates WHERE StateName='Start' AND WorkflowDefinitionId=@WF1Id);
DECLARE @WF1Draft INT = (SELECT Id FROM WorkflowStates WHERE StateName='Draft' AND WorkflowDefinitionId=@WF1Id);
DECLARE @WF1Review INT = (SELECT Id FROM WorkflowStates WHERE StateName='Review' AND WorkflowDefinitionId=@WF1Id);
DECLARE @WF1Approved INT = (SELECT Id FROM WorkflowStates WHERE StateName='Approved' AND WorkflowDefinitionId=@WF1Id);
DECLARE @WF1Rejected INT = (SELECT Id FROM WorkflowStates WHERE StateName='Rejected' AND WorkflowDefinitionId=@WF1Id);

INSERT INTO WorkflowTransitions (FromStateId, ToStateId, Condition, WorkflowDefinitionId) VALUES
(@WF1Start, @WF1Draft, 'Initiate', @WF1Id),
(@WF1Draft, @WF1Review, 'Submit', @WF1Id),
(@WF1Review, @WF1Approved, 'Approve', @WF1Id),
(@WF1Review, @WF1Rejected, 'Reject', @WF1Id),
(@WF1Rejected, @WF1Draft, 'Revise', @WF1Id);
GO

-- WF3 transitions
DECLARE @WF3Id INT = (SELECT Id FROM WorkflowDefinitions WHERE Name='WF3 - Transmittal approval');
DECLARE @WF3Start INT = (SELECT Id FROM WorkflowStates WHERE StateName='Start' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3Draft INT = (SELECT Id FROM WorkflowStates WHERE StateName='Draft' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3UnderReview INT = (SELECT Id FROM WorkflowStates WHERE StateName='UnderReview' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3PendingApproval INT = (SELECT Id FROM WorkflowStates WHERE StateName='PendingApproval' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3ReadyforDispatch INT = (SELECT Id FROM WorkflowStates WHERE StateName='ReadyforDispatch' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3Dispatched INT = (SELECT Id FROM WorkflowStates WHERE StateName='Dispatched' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3Acknowledged INT = (SELECT Id FROM WorkflowStates WHERE StateName='Acknowledged' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3Returned INT = (SELECT Id FROM WorkflowStates WHERE StateName='Returned' AND WorkflowDefinitionId=@WF3Id);
DECLARE @WF3End INT = (SELECT Id FROM WorkflowStates WHERE StateName='End' AND WorkflowDefinitionId=@WF3Id);

INSERT INTO WorkflowTransitions (FromStateId, ToStateId, Condition, WorkflowDefinitionId) VALUES
(@WF3Start, @WF3Draft, 'Initiate', @WF3Id),
(@WF3Draft, @WF3UnderReview, 'Submit', @WF3Id),
(@WF3UnderReview, @WF3PendingApproval, 'LeadApprove', @WF3Id),
(@WF3PendingApproval, @WF3ReadyforDispatch, 'MngApprove', @WF3Id),
(@WF3ReadyforDispatch, @WF3Dispatched, 'Dispatch', @WF3Id),
(@WF3Dispatched, @WF3Acknowledged, 'WaitforAcknowledge', @WF3Id),
(@WF3Acknowledged, @WF3End, 'Acknowledged', @WF3Id),
(@WF3Acknowledged, @WF3Returned, 'Reject', @WF3Id),
(@WF3Returned, @WF3UnderReview, 'Revise+Version', @WF3Id);
GO
