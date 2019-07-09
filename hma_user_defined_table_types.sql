USE [DB_127976_spaceradar]
GO

/****** Object:  UserDefinedTableType [dbo].[GetNarsStatusTable]    Script Date: 7/9/2019 5:32:56 AM ******/
CREATE TYPE [dbo].[GetNarsStatusTable] AS TABLE(
	[RESPONSIBLE_GROUP_NAME] [varchar](500) NULL,
	[RESPONSIBLE_GROUP_CODE] [varchar](500) NULL,
	[RESPONSIBLE_ASSOCIATE_NAME] [varchar](500) NULL,
	[ISSUE_TIMESTAMP] [datetime] NULL,
	[DUE_DATE] [datetime] NULL,
	[CLOSURE_DATE] [datetime] NULL,
	[DAYS_OPEN] [int] NULL,
	[DAYS_SINCE_LAST_MAINTAIN] [int] NULL,
	[DAYS_PAST_DUE] [int] NULL,
	[Ts] [binary](8) NULL
)
GO


CREATE TYPE [dbo].[IntTable] AS TABLE(
	[Id] [bigint] NOT NULL,
	[Ts] [binary](8) NULL
)
GO

GO

/****** Object:  UserDefinedTableType [dbo].[StringIntTable]    Script Date: 7/9/2019 5:33:40 AM ******/
CREATE TYPE [dbo].[StringIntTable] AS TABLE(
	[Id] [bigint] NOT NULL,
	[UserId] [nvarchar](250) NOT NULL,
	[Ts] [binary](8) NULL
)
GO