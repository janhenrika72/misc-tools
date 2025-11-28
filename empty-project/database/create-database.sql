CREATE DATABASE xxxxxxxxxxxxx
GO

USE [xxxxxxxxxxxxx]
GO

CREATE TABLE [dbo].[Employee](
	[Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [PublicId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [nvarchar](50) NULL,
	[Name] [nvarchar](200) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[Email] [nvarchar](200) NULL,
	[StartDate] [datetime2](7) NULL
)
GO

