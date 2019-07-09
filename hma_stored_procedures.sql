USE [DB_127976_spaceradar]
GO

/****** Object:  StoredProcedure [dbo].[get_distinct_group_names]    Script Date: 7/9/2019 5:08:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_distinct_group_names] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT DISTINCT RESPONSIBLE_GROUP_NAME, RESPONSIBLE_GROUP_CODE ,TEAM_CODE,SUBTEAM_CODE
FROM dbo.HOP_DATA_NARS
   ORDER BY RESPONSIBLE_GROUP_NAME
   END
GO


/****** Object:  StoredProcedure [dbo].[get_distinct_group_names_filterd]    Script Date: 7/9/2019 5:08:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_distinct_group_names_filterd] 
	-- Add the parameters for the stored procedure here
	@teamCode As  varchar(256),
	@subTeamCode  As  varchar(256)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT DISTINCT RESPONSIBLE_GROUP_NAME, RESPONSIBLE_GROUP_CODE FROM dbo.HOP_DATA_NARS
where TEAM_CODE = @teamCode And SUBTEAM_CODE = @subTeamCode
   ORDER BY RESPONSIBLE_GROUP_NAME
   END
GO



/****** Object:  StoredProcedure [dbo].[get_nard_all_total_open_closes_pending_status]    Script Date: 7/9/2019 5:08:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_nard_all_total_open_closes_pending_status]
	-- Add the parameters for the stored procedure here
	 @Group_Names As dbo.StringTable READONLY       -- list og group names to filter on
      ,@Htr_Status As dbo.StringTable READONLY       -- list og group status to filter on
	 ,@Issued_Start_Date_Time as datetimeoffset(7)		--start date for intialize time range
	 ,@Issued_End_Date_Time as datetimeoffset(7)	-- end date for intialize time range
	 ,@Team_Code as varchar(10) = 'Q'				-- filter on team code
	 ,@Sub_Team_Code as varchar(10) = 'MP'		    -- filter on subteam code
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		Declare @OpenClosedTable table(
			Group_Name	varchar(500) NULL,		
			Total_Open	int NULL,
			Total_Closed	int NULL,
			Total_Pending	int NULL
		)
    -- Insert statements for procedure here
	Declare @NarsTable table(
RESPONSIBLE_ASSOCIATE_NAME	varchar(500) NULL,
RESPONSIBLE_GROUP_NAME	varchar(500) NULL,
RESPONSIBLE_GROUP_CODE  varchar(500) NULL,
RANK_CODE	varchar(50) NULL,
ISSUE_DATE	datetime NULL,
DUE_DATE		datetime NULL,
CLOSURE_DATE datetime NULL,		
DAYS_OPEN	int NULL,
DAYS_PAST_DUE	int NULL,
DAYS_SINCE_LAST_MAINTAIN 	int NULL,
HTR_STATUS_VALUE  varchar(500) NULL,
REPORT_TYPE_VALUE varchar(500) NULL,
REPORT_NUMBER varchar(500) NULL)

				Insert Into @NarsTable		
				EXECUTE  [dbo].get_nars_status
				@Group_Names
			   ,@Htr_Status
			   ,@Issued_Start_Date_Time 
			   ,@Issued_End_Date_Time




			SELECT RESPONSIBLE_GROUP_NAME as GroupName,	
			sum(case  when HTR_STATUS_VALUE = 'Open'  then 1 else 0 end) as TotalOpen,
	       sum(case  when HTR_STATUS_VALUE = 'Closed'  then 1 else 0 end) as TotalClosed,
	       sum(case  when HTR_STATUS_VALUE = 'Pending'  then 1 else 0 end) as TotalPending			 
			FROM @NarsTable
			Group by RESPONSIBLE_GROUP_NAME
			

END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_nars_day_open_lm_status]
-- Add the parameters for the stored procedure here	
      @Group_Names As dbo.StringTable READONLY       -- list og group names to filter on
     ,@Htr_Status As dbo.StringTable READONLY       -- list og group status to filter on
	 ,@Issued_Start_Date_Time as datetimeoffset(7)		--start date for intialize time range
	 ,@Issued_End_Date_Time as datetimeoffset(7)	-- end date for intialize time range
	 ,@Team_Code as varchar(10) = 'Q'				-- filter on team code
	 ,@Sub_Team_Code as varchar(10) = 'MP'		    -- filter on subteam code
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

Declare @GridChartData table(
RESPONSIBLE_ASSOCIATE_NAME	varchar(500) NULL,
RESPONSIBLE_GROUP_NAME	varchar(500) NULL,
RESPONSIBLE_GROUP_CODE  varchar(500) NULL,
RANK_CODE	varchar(50) NULL,
ISSUE_DATE	datetime NULL,
DUE_DATE		datetime NULL,
CLOSURE_DATE datetime NULL,		
DAYS_OPEN	int NULL,
DAYS_PAST_DUE	int NULL,
DAYS_SINCE_LAST_MAINTAIN 	int NULL,
HTR_STATUS_VALUE  varchar(500) NULL,
REPORT_TYPE_VALUE varchar(500) NULL,
REPORT_NUMBER varchar(500) NULL

)


Insert Into @GridChartData		
EXECUTE  [dbo].get_nars_status
   @Group_Names
  ,@Htr_Status
  ,@Issued_Start_Date_Time
  ,@Issued_End_Date_Time

    Select a.* ,b.ODLTE30,c.ODGT30LTE60 ,d.ODGT60LTE90, e.ODGT90LTE120 ,f.ODGT120 
  from
 (Select RESPONSIBLE_ASSOCIATE_NAME,
 RANK_CODE,
 sum(case  when DAYS_SINCE_LAST_MAINTAIN > 14 then 1 else 0 end) as LMGT14
 from   @GridChartData
 Group by RESPONSIBLE_ASSOCIATE_NAME
 , RANK_CODE
 --Order by RESPONSIBLE_ASSOCIATE_NAME,RANK_CODE,DAYS_SINCE_LAST_MAINTAIN_Sum
 )
 as A

 inner join 
(
Select RESPONSIBLE_ASSOCIATE_NAME,
 RANK_CODE,
 sum(case  when DAYS_OPEN <= 30   then 1 else 0 end) as ODLTE30
 from  @GridChartData
 Group by RESPONSIBLE_ASSOCIATE_NAME
 , RANK_CODE
 --Order by RESPONSIBLE_ASSOCIATE_NAME,RANK_CODE
 )
 as B
on a.RESPONSIBLE_ASSOCIATE_NAME = b.RESPONSIBLE_ASSOCIATE_NAME and a.RANK_CODE=b.RANK_CODE
inner join
(
Select RESPONSIBLE_ASSOCIATE_NAME,
 RANK_CODE,
 sum(case  when DAYS_OPEN > 30 and DAYS_OPEN <= 60  then 1 else 0 end) as ODGT30LTE60
 from  @GridChartData
 Group by RESPONSIBLE_ASSOCIATE_NAME
 , RANK_CODE
 )
 as C
on a.RESPONSIBLE_ASSOCIATE_NAME = c.RESPONSIBLE_ASSOCIATE_NAME and a.RANK_CODE=c.RANK_CODE

inner join
(Select RESPONSIBLE_ASSOCIATE_NAME,
 RANK_CODE,
 sum(case  when DAYS_OPEN > 60 and DAYS_OPEN <= 90  then 1 else 0 end) as ODGT60LTE90
from  @GridChartData
Group by RESPONSIBLE_ASSOCIATE_NAME
, RANK_CODE
)
 as d
on a.RESPONSIBLE_ASSOCIATE_NAME = d.RESPONSIBLE_ASSOCIATE_NAME and a.RANK_CODE=d.RANK_CODE

inner join
(
  Select RESPONSIBLE_ASSOCIATE_NAME,
 RANK_CODE,
 sum(case  when DAYS_OPEN > 90 and DAYS_OPEN <= 120  then 1 else 0 end) as ODGT90LTE120
 from  @GridChartData
 Group by RESPONSIBLE_ASSOCIATE_NAME
 , RANK_CODE
 )
  as e
on a.RESPONSIBLE_ASSOCIATE_NAME = e.RESPONSIBLE_ASSOCIATE_NAME and a.RANK_CODE=e.RANK_CODE

inner join
(
   Select RESPONSIBLE_ASSOCIATE_NAME,
 RANK_CODE,
 sum(case  when DAYS_OPEN > 120  then 1 else 0 end) as ODGT120
 from  @GridChartData
 Group by RESPONSIBLE_ASSOCIATE_NAME
 , RANK_CODE
)
  as f
on a.RESPONSIBLE_ASSOCIATE_NAME = f.RESPONSIBLE_ASSOCIATE_NAME and a.RANK_CODE=f.RANK_CODE

Order By  a.RESPONSIBLE_ASSOCIATE_NAME , a.RANK_CODE
END
GO


/****** Object:  StoredProcedure [dbo].[get_nars_report_compared]    Script Date: 7/9/2019 5:10:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_nars_report_compared]
	-- Add the parameters for the stored procedure here
 @Issued_Start_Date_Time as datetimeoffset(7)		--start date for intialize time range
	 ,@Issued_End_Date_Time as datetimeoffset(7)= Null	-- end date for intialize time range
	 ,@Team_Code as varchar(10) = 'Q'				-- filter on team code
	 ,@Sub_Team_Code as varchar(10) = 'MP'		    -- filter on subteam codeAS
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT RESPONSIBLE_GROUP_NAME, COUNT(*) as TotalCount
 FROM [DB_127976_spaceradar].[dbo].[HOP_DATA_NARS]
  where [TEAM_CODE] =@Team_Code 
			AND SUBTEAM_CODE=@Sub_Team_Code 
			And [ISSUE_TIMESTAMP] >=@Issued_Start_Date_Time
			And [ISSUE_TIMESTAMP] <=@Issued_End_Date_Time 
GROUP BY RESPONSIBLE_GROUP_NAME;
END
GO


/****** Object:  StoredProcedure [dbo].[get_nars_report_type_value]    Script Date: 7/9/2019 5:10:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_nars_report_type_value]
	-- Add the parameters for the stored procedure here
	  @Group_Names As dbo.StringTable READONLY  
	  ,@Issued_Start_Date_Time as datetimeoffset(7)		--start date for intialize time range
	 ,@Issued_End_Date_Time as datetimeoffset(7)= Null	-- end date for intialize time range
	 ,@Team_Code as varchar(10) = 'Q'				-- filter on team code
	 ,@Sub_Team_Code as varchar(10) = 'MP'		    -- filter on subteam codeAS
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT REPORT_TYPE_VALUE, COUNT(*) as TotalCount,hr.Description
 FROM [DB_127976_spaceradar].[dbo].[HOP_DATA_NARS] as h
 join dbo.HopReportValueType as hr on  h.REPORT_TYPE_VALUE = hr.ReportTypeValueId
  where [TEAM_CODE] =@Team_Code 
			AND SUBTEAM_CODE=@Sub_Team_Code 
			And [ISSUE_TIMESTAMP] >=@Issued_Start_Date_Time
			And [ISSUE_TIMESTAMP] <=@Issued_End_Date_Time 
GROUP BY REPORT_TYPE_VALUE,hr.Description

END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Steve Frierdich
-- Create date: 5/17/2019
-- Description:	Retrieves the information for displaying 
-- the NARS Status Open Reports by 13 Day Stats chart
-- =============================================
CREATE PROCEDURE [dbo].[get_nars_status]
-- Add the parameters for the stored procedure here
	
     @Group_Names As dbo.StringTable READONLY       -- list og group names to filter on
      ,@Htr_Status As dbo.StringTable READONLY       -- list og group status to filter on
	 ,@Issued_Start_Date_Time as datetimeoffset(7)		--start date for intialize time range
	 ,@Issued_End_Date_Time as datetimeoffset(7)= Null	-- end date for intialize time range
	 ,@Team_Code as varchar(10) = 'Q'				-- filter on team code
	 ,@Sub_Team_Code as varchar(10) = 'MP'		    -- filter on subteam code

	 -- filter string on various columns and order filter????????????
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	-- Record how many group names were passed to filter on
	Declare @rowsInGroupNamrsTable  int; 
	 Select @rowsInGroupNamrsTable= Count(*) from @Group_Names 

	Declare @rowsInHtrStatusTable  int; 
	 Select @rowsInHtrStatusTable= Count(*) from @Htr_Status 

	Declare @accept  int=@rowsInGroupNamrsTable; 
	
	if @Issued_End_Date_Time is Null
		THROW 51000, 'isue end Date is null', 1;
	
	if @Issued_Start_Date_Time is Null
		THROW 51001, 'isue start Date is null', 1;
	


	if (@Issued_Start_Date_Time >=@Issued_End_Date_Time)
		THROW 51002, 'isue start Date is greater or equal to issue end date', 1;


		SELECT  [RESPONSIBLE_ASSOCIATE_NAME]
		,[RESPONSIBLE_GROUP_NAME]
		, RESPONSIBLE_GROUP_CODE
		,[RANK_CODE] 
		, ISSUE_TIMESTAMP as ISSUE_DATE
		,case when [DUE_DATE] is not null then (Select [DUE_DATE]) 
				when  ORIGINAL_DUE_DATE  is not null then (Select ORIGINAL_DUE_DATE) 
				else NULL End as DUE_DATE
		,CLOSURE_DATE 
		,DAYS_OPEN
		,DAYS_PAST_DUE
		,DAYS_SINCE_LAST_MAINTAIN
		,HTR_STATUS_VALUE
	    ,REPORT_TYPE_VALUE
		,REPORT_NUMBER
		FROM [dbo].[HOP_DATA_NARS]
		 
		Where [TEAM_CODE] =@Team_Code 
			AND SUBTEAM_CODE=@Sub_Team_Code 
			And [ISSUE_TIMESTAMP] >=@Issued_Start_Date_Time
			And [ISSUE_TIMESTAMP] <=@Issued_End_Date_Time
			And  @rowsInGroupNamrsTable  =case  
				 When  @rowsInGroupNamrsTable > 0 And   EXISTS (SELECT StringValue FROM @Group_Names WHERE [StringValue] = RESPONSIBLE_GROUP_NAME )
				 		Then  @rowsInGroupNamrsTable
				  When  @rowsInGroupNamrsTable > 0 
					Then  0
				 Else
					0
				End
			And  @rowsInHtrStatusTable  =case  
				 When  @rowsInHtrStatusTable > 0 And   EXISTS (SELECT StringValue FROM @Htr_Status WHERE [StringValue] = HTR_STATUS_VALUE )
				 		Then  @rowsInHtrStatusTable
				  When  @rowsInHtrStatusTable > 0 
					Then  0
				 Else
					0
				End
		Order By [RESPONSIBLE_ASSOCIATE_NAME],[RESPONSIBLE_GROUP_NAME],[RANK_CODE]
		,ISSUE_DATE,DAYS_OPEN

END
GO

/****** Object:  StoredProcedure [dbo].[get_open_closed_status_by_month]    Script Date: 7/9/2019 5:14:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_open_closed_status_by_month]
	-- Add the parameters for the stored procedure here
  @Group_Names As dbo.StringTable READONLY       -- list og group names to filter on
      ,@Htr_Status As dbo.StringTable READONLY       -- list og group status to filter on
	 ,@Issued_Start_Date_Time as datetimeoffset(7)		--start date for intialize time range
	 ,@Issued_End_Date_Time as datetimeoffset(7)	-- end date for intialize time range
	 ,@Team_Code as varchar(10) = 'Q'				-- filter on team code
	 ,@Sub_Team_Code as varchar(10) = 'MP'		    -- filter on subteam code
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @Issued_Start_End_Date_Time datetimeoffset(7)
	Declare @NarsTable table(
				RESPONSIBLE_ASSOCIATE_NAME	varchar(500) NULL,
RESPONSIBLE_GROUP_NAME	varchar(500) NULL,
RESPONSIBLE_GROUP_CODE  varchar(500) NULL,
RANK_CODE	varchar(50) NULL,
ISSUE_DATE	datetime NULL,
DUE_DATE		datetime NULL,
CLOSURE_DATE datetime NULL,		
DAYS_OPEN	int NULL,
DAYS_PAST_DUE	int NULL,
DAYS_SINCE_LAST_MAINTAIN 	int NULL,
HTR_STATUS_VALUE  varchar(500) NULL,
REPORT_TYPE_VALUE varchar(500) NULL,
REPORT_NUMBER varchar(500) NULL
)


		-- Return table of total open and closed status per month 
		Declare @OpenClosedTable table(
			MONTH_DATE	datetimeoffset(7) NULL,		
			Total_Open	int NULL,
			Total_Closed	int NULL
		)

		-- Open and Close totals for the month
		DECLARE @TotalOpen as int
		DECLARE @TotalClosed as int

		-- Create first end range date time set at 3 am
		DECLARE @End_Date_Time datetimeoffset(7)
		Set @End_Date_Time=  DATEADD(month, 1,@Issued_Start_Date_Time) 
		Set @Issued_Start_End_Date_Time= DATETIMEFROMPARTS (  YEAR(@End_Date_Time),  Month(@End_Date_Time), 1, 3, 0, 0, 0 )  


    -- Insert statements for procedure here
	WHILE @Issued_Start_Date_Time < @Issued_End_Date_Time
		BEGIN
		   -- Get information on month span
			Delete From @NarsTable
			Insert Into @NarsTable		
				EXECUTE  [dbo].get_nars_status
				@Group_Names
			   ,@Htr_Status
			   ,@Issued_Start_Date_Time 
			   ,@Issued_Start_End_Date_Time

			   -- Get open and close total counts
			SELECT @TotalOpen =sum(case  when HTR_STATUS_VALUE = 'Open'  then 1 else 0 end) ,
	        @TotalClosed =sum(case  when HTR_STATUS_VALUE = 'Closed'  then 1 else 0 end) 
			FROM @NarsTable

			-- Store results fir return
			 Insert Into  @OpenClosedTable(MONTH_DATE,Total_Closed,Total_Open)
			 Values(@Issued_Start_Date_Time,@TotalClosed,@TotalOpen)

			 -- Increment month date spana by a month
			 SET @Issued_Start_Date_Time = DATEADD(MONTH,1,@Issued_Start_Date_Time)
			 SET @Issued_Start_End_Date_Time = DATEADD(MONTH,1,@Issued_Start_End_Date_Time)
			
			-- If month end date range greater than end while date range set month end to while end
			 if(@Issued_Start_End_Date_Time > @Issued_End_Date_Time) 
				Set @Issued_Start_End_Date_Time = @Issued_End_Date_Time
		End
		SELECT * from @OpenClosedTable
END
GO


/****** Object:  StoredProcedure [dbo].[get_status_counts]    Script Date: 7/9/2019 5:14:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Steve Frierdich
-- Create date: <Create Date,,>
-- Description:Return the total counts of diferent type of statuses
-- and the number which these statuses or report type value of HTR
-- =============================================
CREATE PROCEDURE [dbo].[get_status_counts]
	-- Add the parameters for the stored procedure here
 @Group_Name as varchar(500)
, @Group_Code as  varchar(500)
, @Issued_Start_Date_Time as datetimeoffset(7)
,@Issued_End_Date_Time as datetimeoffset(7)
 ,@Team_Code as varchar(10) = 'Q'				-- filter on team code
,@Sub_Team_Code as varchar(10) = 'MP'		    -- filter on subteam code	


	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select  RESPONSIBLE_ASSOCIATE_NAME,
	count(case HTR_STATUS_VALUE when 'Closed' then 1 else null end) as TotalClosed,
    count(case HTR_STATUS_VALUE when 'Open' then 1 else null end) as TotalOpen,
	count(case HTR_STATUS_VALUE when 'Pending' then 1 else null end) as TotalPending,
    count(case HTR_STATUS_VALUE when 'Pending CM Approval' then null else 0 end) as TotalPendingCmApp,
 	count(case REPORT_TYPE_VALUE when 'HTR' then 1 else 0 end) as TotalHTR
  
    FROM [DB_127976_spaceradar].[dbo].[HOP_DATA_NARS] 
Where 
  (HTR_STATUS_VALUE= 'Closed' or HTR_STATUS_VALUE= 'Open' or HTR_STATUS_VALUE= 'Pending' or HTR_STATUS_VALUE= 'Pending CM Approval')
--HTR_STATUS_VALUE= 'Closed'
 and TEAM_CODE= @Team_Code 
 and  SUBTEAM_CODE= @Sub_Team_Code 
and RESPONSIBLE_GROUP_NAME= @Group_Name  
and RESPONSIBLE_GROUP_CODE= @Group_Code 
 And [ISSUE_TIMESTAMP] >=@Issued_Start_Date_Time
And [ISSUE_TIMESTAMP] <@Issued_End_Date_Time 

 Group by RESPONSIBLE_ASSOCIATE_NAME
Order by RESPONSIBLE_ASSOCIATE_NAME
END
GO



