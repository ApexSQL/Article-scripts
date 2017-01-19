CREATE DATABASE ApexSQLLogDEMO
GO

USE ApexSQLLogDEMO
GO

-- Set Full recovery model
ALTER DATABASE ApexSQLLogDEMO SET RECOVERY FULL
GO

-- Create full backup to initialize tlog chain
DECLARE @BackupLocation NVARCHAR(100)
EXEC master..xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',  
	@key = 'Software\Microsoft\MSSQLServer\MSSQLServer',  
	@value_name = 'BackupDirectory', @BackupLocation = @BackupLocation OUTPUT ;  
SET @BackupLocation = @BackupLocation + '\ApexSQLLogDEMO.bak'
BACKUP DATABASE ApexSQLLogDEMO TO DISK = @BackupLocation WITH INIT
GO

SET NOEXEC OFF
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NOCOUNT ON
SET XACT_ABORT ON
GO

--===================================
print 'Creating tables'
--===================================

BEGIN TRANSACTION
GO

CREATE TABLE [dbo].[authors]
(
	[au_id] varchar(11) CONSTRAINT [UPKCL_auidind] PRIMARY KEY,
	[au_lname] varchar(40) NOT NULL,
	[au_fname] varchar(20) NOT NULL,
	[phone] char(12) NOT NULL,
	[address] varchar(40) NULL,
	[city] varchar(20) NULL,
	[state] char(2) NULL,
	[zip] char(5) NULL,
	[contract] bit NOT NULL
)
GO

CREATE INDEX [aunmind] ON [dbo].[authors] ([au_lname], [au_fname])
GO

CREATE TABLE [dbo].[discounts]
(
	[discounttype] varchar(40) NOT NULL,
	[stor_id] char(4) NULL,
	[lowqty] smallint NULL,
	[highqty] smallint NULL,
	[discount] decimal(4,2) NOT NULL
)
GO

CREATE TABLE [dbo].[employee]
(
	[emp_id] char(9) CONSTRAINT [PK_emp_id] PRIMARY KEY NONCLUSTERED,
	[fname] varchar(20) NOT NULL,
	[minit] char(1) NULL,
	[lname] varchar(30) NOT NULL,
	[job_id] smallint NOT NULL,
	[job_lvl] tinyint NOT NULL,
	[pub_id] char(4) NOT NULL,
	[hire_date] datetime NOT NULL
)
GO

CREATE CLUSTERED INDEX [employee_ind] ON [dbo].[employee] ([lname], [fname], [minit])
GO

CREATE TABLE [dbo].[jobs]
(
	[job_id] smallint IDENTITY(1,1) CONSTRAINT [PK__jobs__22AA2996] PRIMARY KEY,
	[job_desc] varchar(50) NOT NULL,
	[min_lvl] tinyint NOT NULL,
	[max_lvl] tinyint NOT NULL
)
GO

CREATE TABLE [dbo].[pub_info]
(
	[pub_id] char(4) CONSTRAINT [UPKCL_pubinfo] PRIMARY KEY,
	[logo] image NULL,
	[pr_info] text NULL
)
GO

CREATE TABLE [dbo].[publishers]
(
	[pub_id] char(4) CONSTRAINT [UPKCL_pubind] PRIMARY KEY,
	[pub_name] varchar(40) NULL,
	[city] varchar(20) NULL,
	[state] char(2) NULL,
	[country] varchar(30) NULL
)
GO

CREATE TABLE [dbo].[roysched]
(
	[title_id] varchar(6) NOT NULL,
	[lorange] int NULL,
	[hirange] int NULL,
	[royalty] int NULL
)
GO

CREATE INDEX [titleidind] ON [dbo].[roysched] ([title_id])
GO

CREATE TABLE [dbo].[sales]
(
	[stor_id] char(4) NOT NULL,
	[ord_num] varchar(20) NOT NULL,
	[ord_date] datetime NOT NULL,
	[qty] smallint NOT NULL,
	[payterms] varchar(12) NOT NULL,
	[title_id] varchar(6) NOT NULL,
	CONSTRAINT [UPKCL_sales] PRIMARY KEY ([stor_id], [ord_num], [title_id])
)
GO

CREATE INDEX [titleidind] ON [dbo].[sales] ([title_id])
GO

CREATE TABLE [dbo].[stores]
(
	[stor_id] char(4) CONSTRAINT [UPK_storeid] PRIMARY KEY,
	[stor_name] varchar(40) NULL,
	[stor_address] varchar(40) NULL,
	[city] varchar(20) NULL,
	[state] char(2) NULL,
	[zip] char(5) NULL
)
GO

CREATE TABLE [dbo].[titleauthor]
(
	[au_id] varchar(11) NOT NULL,
	[title_id] varchar(6) NOT NULL,
	[au_ord] tinyint NULL,
	[royaltyper] int NULL,
	CONSTRAINT [UPKCL_taind] PRIMARY KEY ([au_id], [title_id])
)
GO

CREATE INDEX [auidind] ON [dbo].[titleauthor] ([au_id])
GO

CREATE INDEX [titleidind] ON [dbo].[titleauthor] ([title_id])
GO

CREATE TABLE [dbo].[titles]
(
	[title_id] varchar(6) CONSTRAINT [UPKCL_titleidind] PRIMARY KEY,
	[title] varchar(80) NOT NULL,
	[type] char(12) NOT NULL,
	[pub_id] char(4) NULL,
	[price] money NULL,
	[advance] money NULL,
	[royalty] int NULL,
	[ytd_sales] int NULL,
	[notes] varchar(200) NULL,
	[pubdate] datetime NOT NULL
)
GO

CREATE INDEX [titleind] ON [dbo].[titles] ([title])
GO

-- =======================================================
print 'Adding constraints'
-- =======================================================

ALTER TABLE [dbo].[authors] ADD
	CONSTRAINT [CK__authors__au_id__08EA5793] CHECK (([au_id] like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')),
	CONSTRAINT [CK__authors__zip__0AD2A005] CHECK (([zip] like '[0-9][0-9][0-9][0-9][0-9]')),
	CONSTRAINT [DF__authors__phone__09DE7BCC] DEFAULT ('UNKNOWN') FOR [phone]
GO

ALTER TABLE [dbo].[jobs] ADD
	CONSTRAINT [CK__jobs__min_lvl__24927208] CHECK ([min_lvl] >= 10),
	CONSTRAINT [CK__jobs__max_lvl__25869641] CHECK ([max_lvl] <= 250),
	CONSTRAINT [DF__jobs__job_desc__239E4DCF] DEFAULT ('New Position - title not formalized yet') FOR [job_desc]
GO

ALTER TABLE [dbo].[publishers] ADD
	CONSTRAINT [CK__publisher__pub_i__0DAF0CB0] CHECK ([pub_id] = '1756' or [pub_id] = '1622' or [pub_id] = '0877' or [pub_id] = '0736' or [pub_id] = '1389' or ([pub_id] like '99[0-9][0-9]')),
	CONSTRAINT [DF__publisher__count__0EA330E9] DEFAULT ('USA') FOR [country]
GO

ALTER TABLE [dbo].[discounts] ADD
	CONSTRAINT [FK__discounts__stor___20C1E124] FOREIGN KEY ([stor_id]) REFERENCES [dbo].[stores] ([stor_id])
GO

ALTER TABLE [dbo].[employee] ADD
	CONSTRAINT [FK__employee__job_id__2D27B809] FOREIGN KEY ([job_id]) REFERENCES [dbo].[jobs] ([job_id]),
	CONSTRAINT [FK__employee__pub_id__300424B4] FOREIGN KEY ([pub_id]) REFERENCES [dbo].[publishers] ([pub_id]),
	CONSTRAINT [CK_emp_id] CHECK (([emp_id] like '[A-Z][A-Z][A-Z][1-9][0-9][0-9][0-9][0-9][FM]') or ([emp_id] like '[A-Z]-[A-Z][1-9][0-9][0-9][0-9][0-9][FM]')),
	CONSTRAINT [DF__employee__job_id__2C3393D0] DEFAULT (1) FOR [job_id],
	CONSTRAINT [DF__employee__job_lv__2E1BDC42] DEFAULT (10) FOR [job_lvl],
	CONSTRAINT [DF__employee__pub_id__2F10007B] DEFAULT ('9952') FOR [pub_id],
	CONSTRAINT [DF__employee__hire_d__30F848ED] DEFAULT (getdate()) FOR [hire_date]
GO

ALTER TABLE [dbo].[pub_info] ADD
	CONSTRAINT [FK__pub_info__pub_id__286302EC] FOREIGN KEY ([pub_id]) REFERENCES [dbo].[publishers] ([pub_id])
GO


ALTER TABLE [dbo].[titles] ADD
	CONSTRAINT [FK__titles__pub_id__1273C1CD] FOREIGN KEY ([pub_id]) REFERENCES [dbo].[publishers] ([pub_id]),
	CONSTRAINT [DF__titles__type__117F9D94] DEFAULT ('UNDECIDED') FOR [type],
	CONSTRAINT [DF__titles__pubdate__1367E606] DEFAULT (getdate()) FOR [pubdate]
GO

ALTER TABLE [dbo].[roysched] ADD
	CONSTRAINT [FK__roysched__title___1ED998B2] FOREIGN KEY ([title_id]) REFERENCES [dbo].[titles] ([title_id])
GO

ALTER TABLE [dbo].[sales] ADD
	CONSTRAINT [FK__sales__stor_id__1BFD2C07] FOREIGN KEY ([stor_id]) REFERENCES [dbo].[stores] ([stor_id]),
	CONSTRAINT [FK__sales__title_id__1CF15040] FOREIGN KEY ([title_id]) REFERENCES [dbo].[titles] ([title_id])
GO

ALTER TABLE [dbo].[titleauthor] ADD
	CONSTRAINT [FK__titleauth__au_id__164452B1] FOREIGN KEY ([au_id]) REFERENCES [dbo].[authors] ([au_id]),
	CONSTRAINT [FK__titleauth__title__173876EA] FOREIGN KEY ([title_id]) REFERENCES [dbo].[titles] ([title_id])
GO

COMMIT TRANSACTION
GO
SET NOEXEC OFF
GO

SET NOCOUNT ON

CREATE TYPE SSN
FROM varchar(11) NOT NULL ;
GO

CREATE TABLE TestNewTypes
(
	id int IDENTITY (1,1),
	GeomCol1 geometry, 
	GeomCol2 AS GeomCol1.STAsText(),
	GeogCol1 geography, 
	GeogCol2 AS GeogCol1.STAsText(),
	SsnValue SSN
)
GO

CREATE TABLE TestHierarchy
(
	EmployeeId hierarchyid PRIMARY KEY,
	LastChild hierarchyid, 
	EmployeeName nvarchar(50) 
)
GO

CREATE PROCEDURE AddTestHierarchy(@mgrid hierarchyid, @EmpName nvarchar(50)) AS
BEGIN
	DECLARE @last_child hierarchyid
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRANSACTION 
		UPDATE TestHierarchy SET @last_child = LastChild = EmployeeId.GetDescendant(LastChild, NULL) WHERE EmployeeId = @mgrid
		INSERT TestHierarchy (EmployeeId, EmployeeName) VALUES(@last_child, @EmpName)
	COMMIT
END
GO

-- =======================================================
print 'Inserting data'
-- =======================================================

INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('147-51-2221', 'Erceg', 'Ivan', 'UNKNOWN     ', NULL, NULL, NULL, NULL, 0)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('172-32-1176', 'White', 'Johnson', '408 496-7223', '10932 Bigge Rd.', 'Menlo Park', 'CA', '94025', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('213-46-8915', 'Green', 'Marjorie', '415 986-7020', '309 63rd St. #411', 'Oakland', 'CA', '94618', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('238-95-7766', 'Carson', 'Cheryl', '415 548-7723', '589 Darwin Ln.', 'Berkeley', 'CA', '94705', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('267-41-2394', 'O''Leary', 'Michael', '408 286-2428', '22 Cleveland Av. #14', 'San Jose', 'CA', '95128', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('274-80-9391', 'Straight', 'Dean', '415 834-2919', '5420 College Av.', 'Oakland', 'CA', '94609', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('341-22-1782', 'Smith', 'Meander', '913 843-0462', '10 Mississippi Dr.', 'Lawrence', 'KS', '66044', 0)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('409-56-7008', 'Bennet', 'Abraham', '415 658-9932', '6223 Bateman St.', 'Berkeley', 'CA', '94705', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('427-17-2319', 'Dull', 'Ann', '415 836-7128', '3410 Blonde St.', 'Palo Alto', 'CA', '94301', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('472-27-2349', 'Gringlesby', 'Burt', '707 938-6445', 'PO Box 792', 'Covelo', 'CA', '95428', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('486-29-1786', 'Locksley', 'Charlene', '415 585-4620', '18 Broadway Av.', 'San Francisco', 'CA', '94130', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('527-72-3246', 'Greene', 'Morningstar', '615 297-2723', '22 Graybar House Rd.', 'Nashville', 'TN', '37215', 0)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('648-92-1872', 'Blotchet-Halls', 'Reginald', '503 745-6402', '55 Hillsdale Bl.', 'Corvallis', 'OR', '97330', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('672-71-3249', 'Yokomoto', 'Akiko', '415 935-4228', '3 Silver Ct.', 'Walnut Creek', 'CA', '94595', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('712-45-1867', 'del Castillo', 'Innes', '615 996-8275', '2286 Cram Pl. #86', 'Ann Arbor', 'MI', '48105', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('722-51-5454', 'DeFrance', 'Michel', '219 547-9982', '3 Balding Pl.', 'Gary', 'IN', '46403', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('724-08-9931', 'Stringer', 'Dirk', '415 843-2991', '5420 Telegraph Av.', 'Oakland', 'CA', '94609', 0)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('724-80-9391', 'MacFeather', 'Stearns', '415 354-7128', '44 Upland Hts.', 'Oakland', 'CA', '94612', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('756-30-7391', 'Karsen', 'Livia', '415 534-9219', '5720 McAuley St.', 'Oakland', 'CA', '94609', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('807-91-6654', 'Panteley', 'Sylvia', '301 946-8853', '1956 Arlington Pl.', 'Rockville', 'MD', '20853', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('846-92-7186', 'Hunter', 'Sheryl', '415 836-7128', '3410 Blonde St.', 'Palo Alto', 'CA', '94301', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('893-72-1158', 'McBadden', 'Heather', '707 448-4982', '301 Putnam', 'Vacaville', 'CA', '95688', 0)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('899-46-2035', 'Ringer', 'Anne', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', '84152', 1)
INSERT INTO [dbo].[authors] ([au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract]) VALUES ('998-72-3567', 'Ringer', 'Albert', '801 826-0752', '67 Seventh Av.', 'Salt Lake City', 'UT', '84152', 1)

SET IDENTITY_INSERT [dbo].[jobs] ON

INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (1, 'New Hire - Job not specified TEST', 10, 10)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (2, 'Chief Executive Officer TEST', 200, 250)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (3, 'Business Operations Manager TEST', 175, 225)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (4, 'Chief Financial Officier TEST', 175, 250)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (5, 'Publisher TEST', 150, 250)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (6, 'Managing Editor TEST', 140, 225)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (7, 'Marketing Manager TEST', 120, 200)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (8, 'Public Relations Manager TEST', 100, 175)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (9, 'Acquisitions Manager TEST', 75, 175)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (10, 'Productions Manager TEST', 75, 165)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (11, 'Operations Manager TEST', 75, 150)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (12, 'Editor TEST', 25, 100)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (13, 'Sales Representative TEST', 25, 100)
INSERT INTO [dbo].[jobs] ([job_id], [job_desc], [min_lvl], [max_lvl]) VALUES (14, 'Designer TEST', 25, 100)

SET IDENTITY_INSERT [dbo].[jobs] OFF


INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('0736', 'New Moon Books', 'Boston', 'MA', 'USA')
INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('0877', 'Binnet & Hardley', 'Washington', 'DC', 'USA')
INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('1389', 'Algodata Infosystems', 'Berkeley', 'CA', 'USA')
INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('1622', 'Five Lakes Publishing', 'Chicago', 'IL', 'USA')
INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('1756', 'Ramona Publishers', 'Dallas', 'TX', 'USA')
INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('9901', 'GGG&G', 'München', NULL, 'Germany')
INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('9952', 'Scootney Books', 'New York', 'NY', 'USA')
INSERT INTO [dbo].[publishers] ([pub_id], [pub_name], [city], [state], [country]) VALUES ('9999', 'Lucerne Publishing', 'Paris', NULL, 'France')

INSERT INTO [dbo].[stores] ([stor_id], [stor_name], [stor_address], [city], [state], [zip]) VALUES ('6380', 'Eric the Read Books', '788 Catamaugus Ave.', 'Seattle', 'WA', '98056')
INSERT INTO [dbo].[stores] ([stor_id], [stor_name], [stor_address], [city], [state], [zip]) VALUES ('7066', 'Barnum''s', '567 Pasadena Ave.', 'Tustin', 'CA', '92789')
INSERT INTO [dbo].[stores] ([stor_id], [stor_name], [stor_address], [city], [state], [zip]) VALUES ('7067', 'News & Brews', '577 First St.', 'Los Gatos', 'CA', '96745')
INSERT INTO [dbo].[stores] ([stor_id], [stor_name], [stor_address], [city], [state], [zip]) VALUES ('7131', 'Doc-U-Mat: Quality Laundry and Books', '24-A Avogadro Way', 'Remulade', 'WA', '98014')
INSERT INTO [dbo].[stores] ([stor_id], [stor_name], [stor_address], [city], [state], [zip]) VALUES ('7896', 'Fricative Bookshop', '89 Madison St.', 'Fremont', 'CA', '90019')
INSERT INTO [dbo].[stores] ([stor_id], [stor_name], [stor_address], [city], [state], [zip]) VALUES ('8042', 'Bookbeat', '679 Carson St.', 'Portland', 'OR', '89076')

INSERT INTO [dbo].[discounts] ([discounttype], [stor_id], [lowqty], [highqty], [discount]) VALUES ('Initial Customer', NULL, NULL, NULL, 10.5)
INSERT INTO [dbo].[discounts] ([discounttype], [stor_id], [lowqty], [highqty], [discount]) VALUES ('Volume Discount', NULL, 100, 1000, 6.7)
INSERT INTO [dbo].[discounts] ([discounttype], [stor_id], [lowqty], [highqty], [discount]) VALUES ('Customer Discount', '8042', NULL, NULL, 5.0)

INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PMA42628M', 'Paolo', 'M', 'Accorti', 13, 35, '0877', '19920827 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PSA89086M', 'Pedro', 'S', 'Afonso', 14, 89, '1389', '19901224 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('VPA30890F', 'Victoria', 'P', 'Ashworth', 6, 140, '0877', '19900913 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('H-B39728F', 'Helen', ' ', 'Bennett', 12, 35, '0877', '19890921 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('L-B31947F', 'Lesley', ' ', 'Brown', 7, 120, '0877', '19910213 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('F-C16315M', 'Francisco', ' ', 'Chang', 4, 227, '9952', '19901103 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PTC11962M', 'Philip', 'T', 'Cramer', 2, 215, '9952', '19891111 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('A-C71970F', 'Aria', ' ', 'Cruz', 10, 87, '1389', '19911026 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('AMD15433F', 'Ann', 'M', 'Devon', 3, 200, '9952', '19910716 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('ARD36773F', 'Anabela', 'R', 'Domingues', 8, 100, '0877', '19930127 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PHF38899M', 'Peter', 'H', 'Franken', 10, 75, '0877', '19920517 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PXH22250M', 'Paul', 'X', 'Henriot', 5, 159, '0877', '19930819 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('CFH28514M', 'Carlos', 'F', 'Hernadez', 5, 211, '9999', '19890421 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PDI47470M', 'Palle', 'D', 'Ibsen', 7, 195, '0736', '19930509 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('KJJ92907F', 'Karla', 'J', 'Jablonski', 9, 170, '9999', '19940311 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('KFJ64308F', 'Karin', 'F', 'Josephs', 14, 100, '0736', '19921017 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('MGK44605M', 'Matti', 'G', 'Karttunen', 6, 220, '0736', '19940501 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('POK93028M', 'Pirkko', 'O', 'Koskitalo', 10, 80, '9999', '19931129 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('JYL26161F', 'Janine', 'Y', 'Labrune', 5, 172, '9901', '19910526 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('M-L67958F', 'Maria', ' ', 'Larsson', 7, 135, '1389', '19920327 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('Y-L77953M', 'Yoshi', ' ', 'Latimer', 12, 32, '1389', '19890611 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('LAL21447M', 'Laurence', 'A', 'Lebihan', 5, 175, '0736', '19900603 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('ENL44273F', 'Elizabeth', 'N', 'Lincoln', 14, 35, '0877', '19900724 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PCM98509F', 'Patricia', 'C', 'McKenna', 11, 150, '9999', '19890801 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('R-M53550M', 'Roland', ' ', 'Mendel', 11, 150, '0736', '19910905 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('RBM23061F', 'Rita', 'B', 'Muller', 5, 198, '1622', '19931009 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('HAN90777M', 'Helvetius', 'A', 'Nagy', 7, 120, '9999', '19930319 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('TPO55093M', 'Timothy', 'P', 'O''Rourke', 13, 100, '0736', '19880619 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('SKO22412M', 'Sven', 'K', 'Ottlieb', 5, 150, '1389', '19910405 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('MAP77183M', 'Miguel', 'A', 'Paolino', 11, 112, '1389', '19921207 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('PSP68661F', 'Paula', 'S', 'Parente', 8, 125, '1389', '19940119 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('M-P91209M', 'Manuel', ' ', 'Pereira', 8, 101, '9999', '19890109 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('MJP25939M', 'Maria', 'J', 'Pontes', 5, 246, '1756', '19890301 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('M-R38834F', 'Martine', ' ', 'Rance', 9, 75, '0877', '19920205 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('DWR65030M', 'Diego', 'W', 'Roel', 6, 192, '1389', '19911216 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('A-R89858F', 'Annette', ' ', 'Roulet', 6, 152, '9999', '19900221 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('MMS49649F', 'Mary', 'M', 'Saveley', 8, 175, '0736', '19930629 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('CGS88322F', 'Carine', 'G', 'Schmitt', 13, 64, '1389', '19920707 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('MAS70474F', 'Margaret', 'A', 'Smith', 9, 78, '1389', '19880929 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('HAS54740M', 'Howard', 'A', 'Snyder', 12, 100, '0736', '19881119 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('MFS52347M', 'Martin', 'F', 'Sommer', 10, 165, '0736', '19900413 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('GHT50241M', 'Gary', 'H', 'Thomas', 9, 170, '0736', '19880809 00:00:00.000')
INSERT INTO [dbo].[employee] ([emp_id], [fname], [minit], [lname], [job_id], [job_lvl], [pub_id], [hire_date]) VALUES ('DBT39435M', 'Daniel', 'B', 'Tonini', 11, 75, '0877', '19900101 00:00:00.000')

INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'0736', 
	0x474946383961D3001F00B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C00000000D3001F004004FFF0C949ABBD38EBCDBBFF60288E245001686792236ABAB03BC5B055B3F843D3B99DE2AB532A36FB15253B19E5A6231A934CA18CB75C1191D69BF62AAD467F5CF036D8243791369F516ADEF9304AF8F30A3563D7E54CFC04BF24377B5D697E6451333D8821757F898D8E8F1F76657877907259755E5493962081798D9F8A846D9B4A929385A7A5458CA0777362ACAF585E6C6A84AD429555BAA9A471A89D8E8BA2C3C7C82DC9C8AECBCECF1EC2D09143A66E80D3D9BC2C41D76AD28FB2CD509ADAA9AAC62594A3DF81C65FE0BDB5B0CDF4E276DEF6DD78EF6B86FA6C82C5A2648A54AB6AAAE4C1027864DE392E3AF4582BF582DFC07D9244ADA2480BD4C6767BFF32AE0BF3EF603B3907490A4427CE21A7330A6D0584B810664D7F383FA25932488FB96D0F37BDF9491448D1A348937A52CAB4A9D3784EF5E58B4A5545D54BC568FABC9A68DD526ED0A6B8AA17331BD91E5AD9D1D390CED23D88F54A3ACB0A955ADDAD9A50B50D87296E3EB9C76A7CDAABC86B2460040DF34D3995515AB9FF125F1AFA0DAB20A0972382CCB9F9E5AEBC368B21EEDB66EDA15F1347BE2DFDEBB44A7B7C6889240D9473EB73322F4E8D8DBBE14D960B6519BCE5724BB95789350E97EA4BF3718CDD64068D751A261D8B1539D6DCDE3C37F68E1FB58E5DCED8A44477537049852EFD253CEE38C973B7E9D97A488C2979FB936FBAFF2CF5CB79E35830400C31860F4A9BE925D4439F81B6A073BEF1575F593C01A25B26127255D45D4A45B65B851A36C56154678568A20E1100003B, 
	REPLICATE('This is sample text data for New Moon Books, publisher 0736 in the pubs database. New Moon Books is located in Boston, Massachusetts.
', 20))

INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'0877', 
	0x4749463839618B002F00B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C000000008B002F004004FFF0C949ABBD38EBCDBBFFA0048464089CE384A62BD596309CC6F4F58A287EBA79ED73B3D26A482C1A8FC8A47249FCCD76BC1F3058D94135579C9345053D835768560CFE6A555D343A1B6D3FC6DC2A377E66DBA5F8DBEBF6EEE1FF2A805B463A47828269871F7A3D7C7C8A3E899093947F666A756567996E6C519E167692646E7D9C98A42295ABAC24A092AD364C737EB15EB61B8E8DB58FB81DB0BE8C6470A0BE58C618BAC365C5C836CEA1BCBBC4C0D0AAD6D14C85CDD86FDDDFAB5F43A580DCB519A25B9BAE989BC3EEA9A7EBD9BF54619A7DF8BBA87475EDA770D6C58B968C59A27402FB99E2378FC7187010D5558948B15CC58B4E20CE9A762E62B558CAB86839FC088D24AB90854662BCD60D653E832BBD7924F49226469327FDEC91C6AD2538972E6FFEE429720D4E63472901251A33A9D28DB47A5A731A7325D56D50B36ADDAA2463D5AF1EAE82F5F84FAA946656AA21AC31D0C4BF85CBA87912D6D194D4B535C5DDDBA93221CB226D022E9437D89C594305FD321C0CB7DFA5C58223036E088F3139B9032563DD0BE66D2ACD8B2BCB9283CEDEE3C6A53EE39BA7579A62C1294917DC473035E0B9E3183F9A3BB6F7ABDE608B018800003B, 
	REPLICATE('This is sample text data for Binnet & Hardley, publisher 0877 in the pubs database. Binnet & Hardley is located in Washington, D.C.
', 5))

INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'1389', 
	0x474946383961C2001D00B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C00000000C2001D004004FFF0C949ABBD38EBCDBBFF60288E1C609E2840AE2C969E6D2CCFB339D90F2CE1F8AEE6BC9FEF26EC01413AA3F2D76BAA96C7A154EA7CC29C449AC7A8ED7A2FDC2FED25149B29E4D479FD55A7CBD931DC35CFA4916171BEFDAABC51546541684C8285847151537F898A588D89806045947491757B6C9A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A95A6A3E64169923B0901A775B7566B25D7F8C888A5150BE7B8F93847D8DC3C07983BEBDC1878BCFAF6F44BBD0AD71C9CBD653BFD5CEC7D1C3DFDB8197D8959CB9AAB8B7EBEEEFF0BA92F1B6B5F4A0F6F776D3FA9EBCFD748C01DCB4AB5DBF7C03CF1454070F61423D491C326BA18E211081250C7AB12867619825F37F2ECE1168AC242B6A274556D121D28FA46C11E78564C5B295308F21BBF5CAD6CCE52C7018813932C4ED5C517346B7C1C2683368349D49A19D0439D31538A452A916135A0B19A59AAB9E6A835A0EABD00E5CD11D1D478C1C59714053AA4C4955AB4B9956879AB497F62E1CBA2373DA25B752239F8787119390AB5806C74E1100003B, 
	REPLICATE('This is sample text data for Algodata Infosystems, publisher 1389 in the pubs database. Algodata Infosystems is located in Berkeley, California.
', 10))

INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'1622', 
	0x474946383961F5003400B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C00000000F50034004004FFF0C949ABBD38EBCDBBFF60288E64D90166AA016CEBBEB02ACF746D67E82DC2ACEEFFC0A02997B31027C521EF25698D8E42230E049D3E8AD8537385BC4179DB6B574C26637BE58BF38A1EB393DF2CE55CA52731F77918BE9FAFCD6180817F697F5F6E6C7A836D62876A817A79898A7E31524D708E7299159C9456929F9044777C6575A563A68E827D9D4C8D334BB3B051B6B7B83A8490B91EB4B3BDC1C251A1C24BC3C8C9C8C5C4BFCCCAD0D135ACC36B2E3BBCB655AD1CDB8F6921DEB8D48AA9ADA46046D7E0DC829B9D98E9988878D9AAE5AEF875BC6DEFF7E7A35C9943F18CCA3175C0A4295C48625F3B8610234A0C17D159C289189515CC7531A3C7891BFF9B59FA4812634820F24AAA94882EA50D8BBB3E8813598B8A3D7C0D6F12CB8710E5BA7536D9ED3C458F8B509CF17CE94CEA658F254D944889528306E83C245089629DDA4F8BD65885049ACBB7ADAB2A5364AFDAF344902752409A6085FA39105EBB3C2DAB2E52FA8611B7ACFA060956CB1370598176DB3E74FB956CCCA77207BB6B8CAAAADEA3FFBE01A48CD871D65569C37E25A458C5C9572E57AADE59F7F40A98B456CB36560F730967B3737B74ADBBB7EFDABF830BE70B11F6C8E1C82F31345E33B9F3A5C698FB7D4E9D779083D4B313D7985ABB77E0C9B07F1F0F3EFA71F2E8ED56EB98BEBD7559306FC72C6995EA7499F3B5DDA403FF17538AB6FD20C9FF7D463D531681971888E0104E45069D7C742D58DB7B29B45454811B381420635135B5D838D6E487612F876D98D984B73D2820877DFD871523F5E161D97DD7FCB4C82E31BEC8176856D9D8487D95E1E5D711401AE2448EF11074E47E9D69359382E8A8871391880C28E5861636399950FEFCA55E315D8279255C2C6AA89899B68588961C5B82C366693359F1CA89ACACB959971D76F6E6607B6E410E9D57B1A9196A52BDD56636CC08BA519C5E1EDA8743688906DA9D53F2E367999656A96292E2781397A6264E62A04E25FE49A59354696958409B11F527639DEAC84E7795553A9AACA85C68E8977D2A7919A5A7F83329A46F0D79698BF60D98688CCC118A6C3F8F38E6D89C8C12F635E49145F6132D69DCCE684725FC0546C3B40875D79E70A5867A8274E69E8BAEAC1FEEC02E92EE3AA7ADA015365BEFBE83F2EB6F351100003B, 
	REPLICATE('This is sample text data for Five Lakes Publishing, publisher 1622 in the pubs database. Five Lakes Publishing is located in Chicago, Illinois.
',125))

INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'1756', 
	0x474946383961E3002500B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C00000000E30025004004FFF0C949ABBD38EBCDBBFF60288E240858E705A4D2EA4E6E0CC7324DD1EB9CDBBAFCE1AC878DE7ABBD84476452C963369F2F288E933A595B404DB27834E67A5FEC37ACEC517D4EB24E5C8D069966361A5E8ED3C3DCA5AA54B9B2AE2D423082817F848286898386858754887B8A8D939094947E918B7D8780959E9D817C18986FA2A6A75A7B22A59B378E1DACAEB18F1940B6A8B8A853727AB5BD4E76676A37BFB9AF2A564D6BC0776E635BCE6DCFD2C3C873716879D4746C6053DA76E0DAB3A133D6D5B290929F9CEAEDEB6FA0C435EF9E97F59896EC28EEFA9DFF69A21C1BB4CA1E3E63084DB42B970FD6407D05C9E59298B0A2C58B18337AA0E88DA3468DC3FFD0692187A7982F5F2271B152162DE54795CEB0F0DAF8EBDA2A932F1FF203B38C484B6ED07674194ACD639679424B4EDB36279B4D3852FE1095266743955138C5209ADA6D5CB26DCDFC644DD351EACF804BCD32421A562DB6965F25AADD11B056BD7BA436C903E82A1D4A3D024769BAE777B0BB7887F51A0E022E9589BCFCE0DD6527597223C4917502ACBCF8D5E6C49F0B6FA60751A7C2748A3EE7DD6B70B5628F9A5873C6DB5936E57EB843C726043B95EBDE394F3584EC7096ED8DA60D86001EBCB9F3E72F99439F0E7DEC7297BA84D9924EFDB11A65566B8EFB510C7CC258DBB7779F7834A9756E6C97D114F95E5429F13CE5F7F9AAF51C996928604710FF544AFDC79717C10CD85157C6EDD75F7EB49C81D45C5EA9674E5BBBA065941BFB45F3D62D5E99E11488516568A15D1292255F635E8045E0520F3E15A0798DB5C5A08105EE52E3884C05255778E6F5C4A287CCB4D84D1D41CE08CD913C56656482EAEDE8E38D71B974553C199EC324573C3669237C585588E52D1ACE049F85521648659556CD83445D27C9F4D68501CE580E31748ED4948C0E3E88959B257C87E39D0A8EC5D812559234996A9EE5B6E864FE31BA5262971DE40FA5B75D9A487A9A79975C6AB5DD06EA6CCA9DB94FA6A1568AD8A4C33DBA6A5995EE5450AC0AA24A9C6DBAE9F6883CB48976D0ABA8D90AA9A88D6246C2ABA3FE8A1B43CA229B9C58AFC11E071AB1D1BE366DB5C9AE85DCA48595466B83AC95C61DA60D1146EEB3BB817ADA40A08CFBDBB2EB9972EB6EDB66D26D71768D5B2B1FEFC65B11AFA5FA96C93AF50AA6AFBEFE263C1DC0FCA2AB8AC210472C310A1100003B, 
	'This is sample text data for Ramona Publishers, publisher 1756 in the pubs database. Ramona Publishers is located in Dallas, Texas.')
	
INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'9901', 
	0x4749463839615D002200B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C000000005D0022004004FFF0C949ABBD38EBCDFB03DF078C249895A386AA68BB9E6E0ACE623ABD1BC9E9985DFFB89E8E366BED782C5332563ABA4245A6744AAD5AAF4D2276CBED5EA1D026C528B230CD38B2C92721D78CC4772526748F9F611EB28DE7AFE25E818283604A1E8788898A7385838E8F55856F6C2C1D86392F6B9730708D6C5477673758A3865E92627E94754E173697A6A975809368949BB2AE7B9A6865AA734F80A2A17DA576AA5BB667C290CDCE4379CFD2CE9ED3D6A7CCD7DAA4D9C79341C8B9DF5FC052A8DEBA9BB696767B9C7FD5B8BBF23EABB9706BCAE5F05AB7E6C4C7488DDAF7251BC062530EFE93638C5B3580ECD4951312C217C425E73E89D38709D79D810D393BD20A528CE0AA704AA2D4D3082E583C89BD2C2D720753E1C8922697D44CF6AE53BF6D4041750B4AD467C54548932A1D7374A9D3A789004400003B, 
	'This is sample text data for GGG&G, publisher 9901 in the pubs database. GGG&G is located in München, Germany.')
	
INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'9952', 
	0x47494638396107012800B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C00000000070128004004FFF0C949ABBD38EBCDBBFF60288E6469660005AC2C7BB56D05A7D24C4F339E3F765FC716980C3824F28418E4D1A552DA8ACCA5517A7B526F275912690D2A9BD11D14AB8B8257E7E9776BDEE452C2279C47A5CBEDEF2B3C3FBF9FC85981821D7D76868588878A898C8B838F1C8D928E733890829399949B979D9E9FA074A1A3A4A5A6A7458F583E69803F53AF4C62AD5E6DB13B6B3DAEAC6EBA64B365B26BB7ABBEB5C07FB428BCC4C8C1CCC7BBB065637C7A9B7BBE8CDADBDA8B7C31D9E1D88E2FA89E9AE9E49AE7EDA48DA2EEF2F3F4F597AEF6F9FAFBFC805D6CD28C0164C64D18BE3AAD88D87AA5C1DBC07FD59CE54293F0E0882AC39ED9CA2886E3308FB3FF262EBC726D591823204F2E0C09A4A3B32CFEACBC24198D86C48FD3E208D43832E3C0671A2D89737167281AA333219AC048D061499A3C83BEC8090BD84E5A99DE808B730DE9516B727CE85AE7C122BF73EAD29255CB76ADDBB6EC549C8504F7AD5DB37343A98D97576EDDBF7CFB0AEE8457EF5D4E83132BAEB1B8B1E3C749204B9EACB830E5CB984DE1F339A4E1CC88C93CB7D989D72234D1D3A672FEF85055C483C80A06742ADB664F3563119E417D5A8F52DFB1512AEC5D82E9C8662A477FB19A72B6F2E714413F8D0654AA75A8C4C648FDBC346ACDCD5487AFC439BE8BC8E8AA7F6BD77D2B7DF4E6C5882E57DFBDE2F56AEE6D87DFB8BFE06BE7E8F1C6CBCE4D2DC15751803C5956567EFA1D47A041E5F1176183CC1D571D21C2850396565CF5B1D5571D8AC21D08E099A15E85269E87207B1736B31E6FE620324E582116F5215178C86763518A9068DF7FE8C9C6207DCD0104A47B6B717388901EFA27238E3482454E43BB61E8D388F7FD44DD32473E79D43A527633232561E6F86536660256891699D175989A6F1A020A9C75C9D5E68274C619D79D91B5C5189F7906CA67297129D88F9E881A3AA83E8AB623E85E8B0EDAE89C892216E9A584B80318A69C7E3269A7A046FA69A8A4B6094004003B, 
	'This is sample text data for Scootney Books, publisher 9952 in the pubs database. Scootney Books is located in New York City, New York.')
	
INSERT INTO [dbo].[pub_info] ([pub_id], [logo], [pr_info]) VALUES (
	'9999', 
	0x474946383961A9002400B30F00000000800000008000808000000080800080008080808080C0C0C0FF000000FF00FFFF000000FFFF00FF00FFFFFFFFFF21F9040100000F002C00000000A90024004004FFF0C949ABBD38EBCDBBFF60F8011A609E67653EA8D48A702CCFF44566689ED67CEFFF23D58E7513B686444A6EA26B126FC8E74AC82421A7ABE5F4594D61B7BBF0D6F562719A68A07ACDC6389925749AFC6EDBEFBCA24D3E96E2FF803D7A1672468131736E494A8B5C848D8633834B916E598B657E4A83905F7D9B7B56986064A09BA2A68D63603A2E717C9487B2B3209CA7AD52594751B4BD80B65D75B799BEC5BFAF7CC6CACB6638852ACC409F901BD33EB6BCCDC1D1CEA9967B23C082C3709662A69FA4A591E7AE84D87A5FA0AB502F43AC5D74EB9367B0624593FA5CB101ED144173E5F4315AE8485B4287FCBE39E446B1624173FEAC59DC2809594623D9C3388A54E4ACD59C642353E2F098E919319530DD61C405C7CBCB9831C5E5A2192C244E983A3FFE1CDA21282CA248ABB18C25336952A389D689E489B0D24483243B66CD8775A315801AA5A60A6B2DAC074E3741D6BBA8902BA687E9A6D1A3B6D6D15C7460C77AA3E3E556D79EBAF4AAAAB2CFCF578671DFDE657598305D51F7BE5E5A25361ED3388EED0A84B2B7535D6072C1D62DB5588BE5CCA5B1BDA377B99E3CBE9EDA31944A951ADF7DB15263A1429B37BB7E429D8EC4D754B87164078F2B87012002003B, 
	REPLICATE('This is sample text data for Lucerne Publishing, publisher 9999 in the pubs database. Lucerne publishing is located in Paris, France.
', 5))

INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('BU1032', 'The Busy Executive''s Database Guide', 'business    ', '1389', 19.99, 5000.0, 10, 4095, 'An overview of available database systems with emphasis on common business applications. Illustrated.', '19910612 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('BU1111', 'Cooking with Computers: Surreptitious Balance Sheets', 'business    ', '1389', 11.95, 5000.0, 10, 3876, 'Helpful hints on how to use your electronic resources to the best advantage.', '19910609 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('BU2075', 'You Can Combat Computer Stress!', 'business    ', '0736', 2.99, 10125.0, 24, 18722, 'The latest medical and psychological techniques for living with the electronic office. Easy-to-understand explanations.', '19910630 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('BU7832', 'Straight Talk About Computers', 'business    ', '1389', 19.99, 5000.0, 10, 4095, 'Annotated analysis of what computers can do for you: a no-hype guide for the critical user.', '19910622 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('IE1234', 'My Life Writting Software', 'psychology  ', NULL, 599.0, 0.0, 60, NULL, NULL, '20040121 02:06:42.600')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('MC2222', 'Silicon Valley Gastronomic Treats', 'mod_cook    ', '0877', 19.99, 0.0, 12, 2032, 'Favorite recipes for quick, easy, and elegant meals.', '19910609 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('MC3021', 'The Gourmet Microwave', 'mod_cook    ', '0877', 2.99, 15000.0, 24, 22246, 'Traditional French gourmet recipes adapted for modern microwave cooking.', '19910618 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('MC3026', 'The Psychology of Computer Cooking', 'UNDECIDED   ', '0877', NULL, NULL, NULL, NULL, NULL, '19981113 03:10:53.657')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PC1035', 'But Is It User Friendly?', 'popular_comp', '1389', 22.95, 7000.0, 16, 8780, 'A survey of software for the naive user, focusing on the ''friendliness'' of each.', '19910630 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PC8888', 'Secrets of Silicon Valley', 'popular_comp', '1389', 20.0, 8000.0, 10, 4095, 'Muckraking reporting on the world''s largest computer hardware and software manufacturers.', '19940612 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PC9999', 'Net Etiquette', 'popular_comp', '1389', NULL, NULL, NULL, NULL, 'A must-read for computer conferencing.', '19981113 03:10:53.670')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PS1372', 'Computer Phobic AND Non-Phobic Individuals: Behavior Variations', 'psychology  ', '0877', 21.59, 7000.0, 10, 375, 'A must for the specialist, this book examines the difference between those who hate and fear computers and those who don''t.', '19911021 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PS2091', 'Is Anger the Enemy?', 'psychology  ', '0736', 10.95, 2275.0, 12, 2045, 'Carefully researched study of the effects of strong emotions on the body. Metabolic charts included.', '19910615 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PS2106', 'Life Without Fear', 'psychology  ', '0736', 7.0, 6000.0, 10, 111, 'New exercise, meditation, and nutritional techniques that can reduce the shock of daily interactions. Popular audience. Sample menus included, exercise video available separately.', '19911005 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PS3333', 'Prolonged Data Deprivation: Four Case Studies', 'psychology  ', '0736', 19.99, 2000.0, 10, 4072, 'What happens when the data runs dry? Searching evaluations of information-shortage effects.', '19910612 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('PS7777', 'Emotional Security: A New Algorithm', 'psychology  ', '0736', 7.99, 4000.0, 10, 3336, 'Protecting yourself and your loved ones from undue emotional stress in the modern world. Use of computer and nutritional aids emphasized.', '19910612 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('TC3218', 'Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean', 'trad_cook   ', '0877', 20.95, 7000.0, 10, 375, 'Profusely illustrated in color, this makes a wonderful gift book for a cuisine-oriented friend.', '19911021 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('TC4203', 'Fifty Years in Buckingham Palace Kitchens', 'trad_cook   ', '0877', 11.95, 4000.0, 14, 15096, 'More anecdotes from the Queen''s favorite cook describing life among English royalty. Recipes, techniques, tender vignettes.', '19910612 00:00:00.000')
INSERT INTO [dbo].[titles] ([title_id], [title], [type], [pub_id], [price], [advance], [royalty], [ytd_sales], [notes], [pubdate]) VALUES ('TC7777', 'Sushi, Anyone?', 'trad_cook   ', '0877', 14.99, 8000.0, 10, 4095, 'Detailed instructions on how to make authentic Japanese sushi in your spare time.', '19910612 00:00:00.000')

INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1032', 0, 5000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1032', 5001, 50000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC1035', 0, 2000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC1035', 2001, 3000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC1035', 3001, 4000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC1035', 4001, 10000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC1035', 10001, 50000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 0, 1000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 1001, 3000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 3001, 5000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 5001, 7000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 7001, 10000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 10001, 12000, 20)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 12001, 14000, 22)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU2075', 14001, 50000, 24)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2091', 0, 1000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2091', 1001, 5000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2091', 5001, 10000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2091', 10001, 50000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2106', 0, 2000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2106', 2001, 5000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2106', 5001, 10000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS2106', 10001, 50000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 0, 1000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 1001, 2000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 2001, 4000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 4001, 6000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 6001, 8000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 8001, 10000, 20)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 10001, 12000, 22)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC3021', 12001, 50000, 24)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 0, 2000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 2001, 4000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 4001, 6000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 6001, 8000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 8001, 10000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 10001, 12000, 20)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 12001, 14000, 22)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC3218', 14001, 50000, 24)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC8888', 0, 5000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC8888', 5001, 10000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC8888', 10001, 15000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PC8888', 15001, 50000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS7777', 0, 5000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS7777', 5001, 50000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS3333', 0, 5000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS3333', 5001, 10000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS3333', 10001, 15000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS3333', 15001, 50000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 0, 4000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 4001, 8000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 8001, 10000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 12001, 16000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 16001, 20000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 20001, 24000, 20)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 24001, 28000, 22)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU1111', 28001, 50000, 24)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC2222', 0, 2000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC2222', 2001, 4000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC2222', 4001, 8000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC2222', 8001, 12000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC2222', 12001, 20000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('MC2222', 20001, 50000, 20)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC7777', 0, 5000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC7777', 5001, 15000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC7777', 15001, 50000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC4203', 0, 2000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC4203', 2001, 8000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC4203', 8001, 16000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC4203', 16001, 24000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC4203', 24001, 32000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC4203', 32001, 40000, 20)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('TC4203', 40001, 50000, 22)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 0, 5000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 5001, 10000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 10001, 15000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 15001, 20000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 20001, 25000, 18)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 25001, 30000, 20)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 30001, 35000, 22)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('BU7832', 35001, 50000, 24)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS1372', 0, 10000, 10)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS1372', 10001, 20000, 12)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS1372', 20001, 30000, 14)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS1372', 30001, 40000, 16)
INSERT INTO [dbo].[roysched] ([title_id], [lorange], [hirange], [royalty]) VALUES ('PS1372', 40001, 50000, 18)

INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('6380', '6871', '19940914 00:00:00.000', 5, 'Net 60', 'BU1032')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('6380', '722a', '19940913 00:00:00.000', 3, 'Net 60', 'PS2091')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7066', 'A2976', '19930524 00:00:00.000', 50, 'Net 30', 'PC8888')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7066', 'QA7442.3', '19940913 00:00:00.000', 75, 'ON invoice', 'PS2091')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7067', 'D4482', '19940914 00:00:00.000', 10, 'Net 60', 'PS2091')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7067', 'P2121', '19920615 00:00:00.000', 40, 'Net 30', 'TC3218')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7067', 'P2121', '19920615 00:00:00.000', 20, 'Net 30', 'TC4203')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7067', 'P2121', '19920615 00:00:00.000', 20, 'Net 30', 'TC7777')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7131', 'N914008', '19940914 00:00:00.000', 20, 'Net 30', 'PS2091')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7131', 'N914014', '19940914 00:00:00.000', 25, 'Net 30', 'MC3021')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7131', 'P3087a', '19930529 00:00:00.000', 20, 'Net 60', 'PS1372')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7131', 'P3087a', '19930529 00:00:00.000', 25, 'Net 60', 'PS2106')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7131', 'P3087a', '19930529 00:00:00.000', 15, 'Net 60', 'PS3333')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7131', 'P3087a', '19930529 00:00:00.000', 25, 'Net 60', 'PS7777')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7896', 'QQ2299', '19931028 00:00:00.000', 15, 'Net 60', 'BU7832')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7896', 'TQ456', '19931212 00:00:00.000', 10, 'Net 60', 'MC2222')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('7896', 'X999', '19930221 00:00:00.000', 35, 'ON invoice', 'BU2075')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('8042', '423LL922', '19940914 00:00:00.000', 15, 'ON invoice', 'MC3021')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('8042', '423LL930', '19940914 00:00:00.000', 10, 'ON invoice', 'BU1032')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('8042', 'P723', '19930311 00:00:00.000', 25, 'Net 30', 'BU1111')
INSERT INTO [dbo].[sales] ([stor_id], [ord_num], [ord_date], [qty], [payterms], [title_id]) VALUES ('8042', 'QA879.1', '19930522 00:00:00.000', 30, 'Net 30', 'PC1035')

INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('172-32-1176', 'PS3333', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('213-46-8915', 'BU1032', 2, 40)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('213-46-8915', 'BU2075', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('238-95-7766', 'PC1035', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('267-41-2394', 'BU1111', 2, 40)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('267-41-2394', 'TC7777', 2, 30)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('274-80-9391', 'BU7832', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('409-56-7008', 'BU1032', 1, 60)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('427-17-2319', 'PC8888', 1, 50)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('472-27-2349', 'TC7777', 3, 30)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('486-29-1786', 'PC9999', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('486-29-1786', 'PS7777', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('648-92-1872', 'TC4203', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('672-71-3249', 'TC7777', 1, 40)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('712-45-1867', 'MC2222', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('722-51-5454', 'MC3021', 1, 75)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('724-80-9391', 'BU1111', 1, 60)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('724-80-9391', 'PS1372', 2, 25)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('756-30-7391', 'PS1372', 1, 75)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('807-91-6654', 'TC3218', 1, 100)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('846-92-7186', 'PC8888', 2, 50)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('899-46-2035', 'MC3021', 2, 25)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('899-46-2035', 'PS2091', 2, 50)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('998-72-3567', 'PS2091', 1, 50)
INSERT INTO [dbo].[titleauthor] ([au_id], [title_id], [au_ord], [royaltyper]) VALUES ('998-72-3567', 'PS2106', 1, 100)

BEGIN TRAN

UPDATE authors
SET
	contract = 1
WHERE
	au_id = '147-51-2221'
GO

DELETE authors
WHERE
	au_id = '147-51-2221'

COMMIT TRAN
GO

UPDATE discounts
SET
	discount = 6.9
WHERE
	discounttype = 'Volume Discount'
GO

UPDATE jobs
SET
	min_lvl = min_lvl + 5
GO

INSERT INTO TestNewTypes (GeomCol1, GeogCol1, SsnValue) VALUES (geometry::STGeomFromText('LINESTRING (100 100, 20 180, 180 180)', 0), geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656)', 4326), 'Line string');
INSERT INTO TestNewTypes (GeomCol1, GeogCol1, SsnValue) VALUES (geometry::STGeomFromText('POLYGON ((0 0, 150 0, 150 150, 0 150, 0 0))', 0), geography::STGeomFromText('POLYGON((-122.358 47.653, -122.348 47.649, -122.348 47.658, -122.358 47.658, -122.358 47.653))', 4326), 'Polygon');
GO

INSERT TestHierarchy (EmployeeId, EmployeeName) VALUES(hierarchyid::GetRoot(), 'David') ;
GO
AddTestHierarchy 0x, 'Sariya'
GO
AddTestHierarchy 0x58, 'Mary'
GO

-- =======================================================
print 'Deleting data'
-- =======================================================
exec sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'

DELETE FROM titleauthor
DELETE FROM sales
DELETE FROM roysched
DELETE FROM titles
DELETE FROM pub_info
DELETE FROM employee
DELETE FROM discounts
DELETE FROM stores
DELETE FROM publishers
DELETE FROM jobs
DELETE FROM authors
DELETE FROM TestNewTypes
DELETE FROM TestHierarchy
GO

exec sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'

CREATE TABLE All_Colations
(
	COLLATION_NAME VARCHAR(6000),
	COLLATION_ID INT,
	CODE_PAGE INT,
	TEST SQL_VARIANT
)
GO

DECLARE collations CURSOR FOR
	SELECT * FROM fn_helpcollations() WHERE CAST(COLLATIONPROPERTY(name, 'CodePage') AS INT) != 0

OPEN collations

DECLARE @name NVARCHAR(128)
DECLARE @description NVARCHAR(4000)

FETCH NEXT FROM collations INTO @name, @description

SET NOCOUNT ON

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @statement NVARCHAR(4000)
	SET @statement = N'INSERT INTO All_Colations VALUES(''' + @name + ''', ' + CAST(COLLATIONPROPERTY(@name, 'CollationId') AS VARCHAR(20)) + ', ' + CAST(COLLATIONPROPERTY(@name, 'CodePage') AS VARCHAR(10)) + ', ''€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ'' COLLATE ' + @name + ')'
	EXEC sp_executesql @statement

	FETCH NEXT FROM collations
	INTO @name, @description
END

CLOSE collations
DEALLOCATE collations
GO

DELETE FROM All_Colations

--=========================================
print 'Creating all types table'
--=========================================
SET NOCOUNT ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE TestAllTypes
(
	PrimaryKey Int Identity(1,1) Primary Key,
	Comment VarChar(100) Null,
	ExpectedEngineOutput NVarChar(1000) Null,
	BigIntValue BigInt Null,
	BinaryValue Binary Null,
	Binary2Value Binary(2) Null,
	Binary20Value Binary(20) Null,
	BitValue Bit Null,
	CharValue Char Null,
	Char2Value Char(2) Null,
	Char20Value Char(20) Null,
	DateTimeValue DateTime Null,
	DecimalValue Decimal Null,
	Decimal_9_5Value Decimal(9,5) Null,
	Decimal_19_5Value Decimal(19,5) Null,
	Decimal_28_5Value Decimal(28,5) Null,
	Decimal_38_5Value Decimal(38,5) Null,
	FloatValue Float Null,
	Float24Value Float(24) Null,
	Float53Value Float(53) Null,
	ImageValue Image Null,
	IntValue Int Null,
	MoneyValue Money Null,
	NCharValue NChar Null,
	NChar2Value NChar(2) Null,
	NChar20Value NChar(20) Null,
	NTextValue NText Null,
	NumericValue Numeric Null,
	Numeric_9_5Value Numeric(9,5) Null,
	Numeric_19_5Value Numeric(19,5) Null,
	Numeric_28_5Value Numeric(28,5) Null,
	Numeric_38_5Value Numeric(38,5) Null,
	NVarCharValue NVarChar Null,
	NVarChar2Value NVarChar(2) Null,
	NVarChar20Value NVarChar(20) Null,
	NVarChar1000Value NVarChar(1000) Null,
	NVarCharMaxValue NVarChar(Max) Null,
	RealValue Real Null,
	SmallDateTimeValue SmallDateTime Null,
	SmallIntValue SmallInt Null,
	SmallMoneyValue SmallMoney Null,
	SqlVariantValue Sql_Variant Null,
	SysNameValue SysName Null,
	TextValue Text Null,
	TimestampValue Timestamp Null,
	TinyIntValue TinyInt Null,
	UniqueIdentifierValue UniqueIdentifier Null,
	VarBinaryValue VarBinary Null,
	VarBinary2Value VarBinary(2) Null,
	VarBinary20Value VarBinary(20) Null,
	VarBinaryMaxValue VarBinary(max) Null,
	VarCharValue VarChar Null,
	VarChar2Value VarChar(2) Null,
	VarChar20Value VarChar(20) Null,
	VarCharMaxValue VarChar(max) Null,
	XmlValue Xml Null
)
GO

-- Adding SQL 2008 types
ALTER TABLE TestAllTypes ADD
	DateValue Date Null,
	DateTime2Value DateTime2 Null,
	DateTime2_0Value DateTime2(0) Null,
	DateTime2_1Value DateTime2(1) Null,
	DateTime2_2Value DateTime2(2) Null,
	DateTime2_3Value DateTime2(3) Null,
	DateTime2_4Value DateTime2(4) Null,
	DateTime2_5Value DateTime2(5) Null,
	DateTime2_6Value DateTime2(6) Null,
	DateTime2_7Value DateTime2(7) Null,
	DateTimeOffsetValue DateTimeOffset Null,
	DateTimeOffset0Value DateTimeOffset(0) Null,
	DateTimeOffset1Value DateTimeOffset(1) Null,
	DateTimeOffset2Value DateTimeOffset(2) Null,
	DateTimeOffset3Value DateTimeOffset(3) Null,
	DateTimeOffset4Value DateTimeOffset(4) Null,
	DateTimeOffset5Value DateTimeOffset(5) Null,
	DateTimeOffset6Value DateTimeOffset(6) Null,
	DateTimeOffset7Value DateTimeOffset(7) Null,
	GeographyValue Geography Null,
	GeometryValue Geometry Null,
	HierarchyIdValue HierarchyId Null,
	TimeValue Time Null,
	Time0Value Time(0) Null,
	Time1Value Time(1) Null,
	Time2Value Time(2) Null,
	Time3Value Time(3) Null,
	Time4Value Time(4) Null,
	Time5Value Time(5) Null,
	Time6Value Time(6) Null,
	Time7Value Time(7) Null
GO

--=========================================
PRINT 'Adding test data to TestAllTypes'
PRINT 'If you are executing on versions before 2008 expect errors after this point.'
--=========================================

GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('All NULL', null, null)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(255)', '255', 255)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(256)', '256', 256)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(65535)', '65535', 65535)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(65536)', '65536', 65536)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(2147483647)', '2147483647', 2147483647)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(2147483648)', '2147483648', 2147483648)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative 255)', '-255', -255)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative 256)', '-256', -256)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative 65535)', '-65535', -65535)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative 65536)', '-65536', -65536)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative 2147483647)', '-2147483647', -2147483647)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative 2147483648)', '-2147483648', -2147483648)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Min)', '-9223372036854775808', -9223372036854775808)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Max)', '9223372036854775807', 9223372036854775807)
GO
DECLARE @RANDOM BIGINT
SET @RANDOM = RAND() * 9223372036854775807
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Random)', CAST(@RANDOM AS VARCHAR(100)), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BigIntValue) VALUES('BigIntValue(Negative Random)', CAST(-@RANDOM AS VARCHAR(100)), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BinaryValue) VALUES('BinaryValue(Empty)', '0x00', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BinaryValue) VALUES('BinaryValue(One Byte)', '0x01', 0x01)
GO
DECLARE @RANDOM BINARY
SET @RANDOM = RAND() * 255
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BinaryValue) VALUES('BinaryValue(Random)', CONVERT(VARCHAR(100), @RANDOM, 1), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary2Value) VALUES('Binary2Value(Empty)', '0x0000', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary2Value) VALUES('Binary2Value(One Byte)', '0x0100', 0x01)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary2Value) VALUES('Binary2Value(Max)', '0xFFFF', 0xffff)
GO
DECLARE @RANDOM BINARY(2)
SET @RANDOM = CAST(RAND() * 65535 AS BINARY(2))
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary2Value) VALUES('Binary2Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 1), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary20Value) VALUES('Binary20Value(Empty)', '0x0000000000000000000000000000000000000000', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary20Value) VALUES('Binary20Value(One Byte)', '0x0100000000000000000000000000000000000000', 0x01)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary20Value) VALUES('Binary20Value(Max)', '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', 0xffffffffffffffffffffffffffffffffffffffff)
GO
DECLARE @RANDOM BINARY(20)
SET @RANDOM = CAST(NEWID() AS BINARY(20))
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Binary20Value) VALUES('Binary20Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 1), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BitValue) VALUES('BitValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, BitValue) VALUES('BitValue(One)', '1', 1)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, CharValue) VALUES('CharValue(Empty)', ' ', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, CharValue) VALUES('CharValue(One Char)', '1', '1')
GO
DECLARE @RANDOM CHAR
SET @RANDOM = CHAR(32 + RAND() * (127 - 32))
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, CharValue) VALUES('CharValue(Random)', CAST(@RANDOM AS VARCHAR(100)), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char2Value) VALUES('Char2Value(Empty)', '  ', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char2Value) VALUES('Char2Value(One Char)', '1 ', '1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char2Value) VALUES('Char2Value(Max)', 'ZZ', 'ZZ')
GO
DECLARE @RANDOM CHAR(2)
SET @RANDOM = CHAR(32 + RAND() * (127 - 32)) + CHAR(32 + RAND() * (127 - 32))
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char2Value) VALUES('Char2Value(Random)', CAST(@RANDOM AS VARCHAR(100)), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char20Value) VALUES('Char20Value(Empty)', '                    ', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char20Value) VALUES('Char20Value(One Char)', '1                   ', '1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char20Value) VALUES('Char20Value(Max)', 'ZZZZZZZZZZZZZZZZZZZZ', 'ZZZZZZZZZZZZZZZZZZZZ')
GO
DECLARE @RANDOM CHAR(20)
SET @RANDOM = LEFT(CAST(NEWID() AS VARCHAR(100)), 20)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Char20Value) VALUES('Char20Value(Random)', CAST(@RANDOM AS VARCHAR(100)), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateValue) VALUES('DateValue(Min)', '0001-01-01', '0001-01-01')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateValue) VALUES('DateValue(Max)', '9999-12-31', '9999-12-31')
GO
DECLARE @RANDOM DATE
SET @RANDOM = GETDATE()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateValue) VALUES('DateValue(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeValue) VALUES('DateTimeValue(Min)', '1753-01-01 00:00:00.000', '1753-01-01 00:00:00.000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeValue) VALUES('DateTimeValue(Max)', '9999-12-31 23:59:59.997', '9999-12-31 23:59:59.997')
GO
DECLARE @RANDOM DATETIME
SET @RANDOM = GETDATE()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeValue) VALUES('DateTimeValue(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2Value) VALUES('DateTime2Value(Min)', '0001-01-01 00:00:00.0000000', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2Value) VALUES('DateTime2Value(Max)', '9999-12-31 23:59:59.9999999', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2Value) VALUES('DateTime2Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_0Value) VALUES('DateTime2_0Value(Min)', '0001-01-01 00:00:00', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_0Value) VALUES('DateTime2_0Value(Max)', '9999-12-31 23:59:59', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(0)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_0Value) VALUES('DateTime2_0Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_1Value) VALUES('DateTime2_1Value(Min)', '0001-01-01 00:00:00.0', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_1Value) VALUES('DateTime2_1Value(Max)', '9999-12-31 23:59:59.9', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(1)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_1Value) VALUES('DateTime2_1Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_2Value) VALUES('DateTime2_2Value(Min)', '0001-01-01 00:00:00.00', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_2Value) VALUES('DateTime2_2Value(Max)', '9999-12-31 23:59:59.99', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(2)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_2Value) VALUES('DateTime2_2Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_3Value) VALUES('DateTime2_3Value(Min)', '0001-01-01 00:00:00.000', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_3Value) VALUES('DateTime2_3Value(Max)', '9999-12-31 23:59:59.999', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(3)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_3Value) VALUES('DateTime2_3Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_4Value) VALUES('DateTime2_4Value(Min)', '0001-01-01 00:00:00.0000', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_4Value) VALUES('DateTime2_4Value(Max)', '9999-12-31 23:59:59.9999', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(4)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_4Value) VALUES('DateTime2_4Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_5Value) VALUES('DateTime2_5Value(Min)', '0001-01-01 00:00:00.00000', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_5Value) VALUES('DateTime2_5Value(Max)', '9999-12-31 23:59:59.99999', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(5)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_5Value) VALUES('DateTime2_5Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_6Value) VALUES('DateTime2_6Value(Min)', '0001-01-01 00:00:00.000000', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_6Value) VALUES('DateTime2_6Value(Max)', '9999-12-31 23:59:59.999999', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(6)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_6Value) VALUES('DateTime2_6Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_7Value) VALUES('DateTime2_7Value(Min)', '0001-01-01 00:00:00.0000000', '0001-01-01 00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_7Value) VALUES('DateTime2_7Value(Max)', '9999-12-31 23:59:59.9999999', '9999-12-31 23:59:59.9999999')
GO
DECLARE @RANDOM DATETIME2(7)
SET @RANDOM = SYSDATETIME()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTime2_7Value) VALUES('DateTime2_7Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffsetValue) VALUES('DateTimeOffsetValue(Min)', '0001-01-01 00:00:00.0000000 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffsetValue) VALUES('DateTimeOffsetValue(Max)', '9999-12-31 18:59:59.9999999 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffsetValue) VALUES('DateTimeOffsetValue(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset0Value) VALUES('DateTimeOffset0Value(Min)', '0001-01-01 00:00:00 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset0Value) VALUES('DateTimeOffset0Value(Max)', '9999-12-31 18:59:59 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(0)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset0Value) VALUES('DateTimeOffset0Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset1Value) VALUES('DateTimeOffset1Value(Min)', '0001-01-01 00:00:00.0 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset1Value) VALUES('DateTimeOffset1Value(Max)', '9999-12-31 18:59:59.9 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(1)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset1Value) VALUES('DateTimeOffset1Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset2Value) VALUES('DateTimeOffset2Value(Min)', '0001-01-01 00:00:00.00 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset2Value) VALUES('DateTimeOffset2Value(Max)', '9999-12-31 18:59:59.99 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(2)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset2Value) VALUES('DateTimeOffset2Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset3Value) VALUES('DateTimeOffset3Value(Min)', '0001-01-01 00:00:00.000 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset3Value) VALUES('DateTimeOffset3Value(Max)', '9999-12-31 18:59:59.999 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(3)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset3Value) VALUES('DateTimeOffset3Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset4Value) VALUES('DateTimeOffset4Value(Min)', '0001-01-01 00:00:00.0000 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset4Value) VALUES('DateTimeOffset4Value(Max)', '9999-12-31 18:59:59.9999 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(4)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset4Value) VALUES('DateTimeOffset4Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset5Value) VALUES('DateTimeOffset5Value(Min)', '0001-01-01 00:00:00.00000 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset5Value) VALUES('DateTimeOffset5Value(Max)', '9999-12-31 18:59:59.99999 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(5)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset5Value) VALUES('DateTimeOffset5Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset6Value) VALUES('DateTimeOffset6Value(Min)', '0001-01-01 00:00:00.000000 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset6Value) VALUES('DateTimeOffset6Value(Max)', '9999-12-31 18:59:59.999999 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(6)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset6Value) VALUES('DateTimeOffset6Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset7Value) VALUES('DateTimeOffset7Value(Min)', '0001-01-01 00:00:00.0000000 -05:00', '0001-01-01 00:00:00.0000000 -05:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset7Value) VALUES('DateTimeOffset7Value(Max)', '9999-12-31 18:59:59.9999999 -05:00', '9999-12-31 18:59:59.9999999 -05:00')
GO
DECLARE @RANDOM DATETIMEOFFSET(7)
SET @RANDOM = SYSDATETIMEOFFSET()
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DateTimeOffset7Value) VALUES('DateTimeOffset7Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 121), @RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DecimalValue) VALUES('DecimalValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DecimalValue) VALUES('DecimalValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DecimalValue) VALUES('DecimalValue(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DecimalValue) VALUES('DecimalValue(Min)', '-999999999999999999', -999999999999999999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DecimalValue) VALUES('DecimalValue(Max)', '999999999999999999', 999999999999999999)
GO
DECLARE @RANDOM DECIMAL
SET @RANDOM = RAND() * 999999999999999999
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DecimalValue) VALUES('DecimalValue(Random)', CONVERT(VARCHAR(100), @RANDOM), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, DecimalValue) VALUES('DecimalValue(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_9_5Value) VALUES('Decimal_9_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_9_5Value) VALUES('Decimal_9_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_9_5Value) VALUES('Decimal_9_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_9_5Value) VALUES('Decimal_9_5Value(Min)', '-9999.99999', -9999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_9_5Value) VALUES('Decimal_9_5Value(Max)', '9999.99999', 9999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_9_5Value(Known Issue 4)', '1000.00000', 1000.00000)
GO
DECLARE @RANDOM DECIMAL(9, 5)
SET @RANDOM = RAND() * 9999.99999
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_9_5Value) VALUES('Decimal_9_5Value(Random)', CONVERT(VARCHAR(100), @RANDOM), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_9_5Value) VALUES('Decimal_9_5Value(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(Min)', '-99999999999999.99999', -99999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(Max)', '99999999999999.99999', 99999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(Known Issue 4)', '10000000000000.00000', 10000000000000.00000)
GO
DECLARE @RANDOM DECIMAL(19, 5)
SET @RANDOM =
	CAST(RAND() * 99999999999999.99999 AS DECIMAL(19, 5))
	+ CAST(RAND() * 9999.99999 AS DECIMAL(19, 5))
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(Random)', CONVERT(VARCHAR(100), @RANDOM), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_19_5Value) VALUES('Decimal_19_5Value(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Min)', '-99999999999999999999999.99999', -99999999999999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Max)', '99999999999999999999999.99999', 99999999999999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Known Issue)', '13446584765481376190938.70368', 13446584765481376190938.70368)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Known Issue 2)', '3446584765481376190938.70368', 3446584765481376190938.70368)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Known Issue 3)', '446584765481376190938.70368', 446584765481376190938.70368)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Known Issue 4)', '10000000000000000000000.00000', 10000000000000000000000.00000)
GO
DECLARE @RANDOM DECIMAL(28, 5)
SET @RANDOM =
	CAST(RAND() * 99999999999999999999999.99999 AS DECIMAL(28, 5))
	+ CAST(RAND() * 99999999999999.99999 AS DECIMAL(28, 5))
	+ CAST(RAND() * 9999.99999 AS DECIMAL(28, 5))
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Random)', CONVERT(VARCHAR(100), @RANDOM), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_28_5Value) VALUES('Decimal_28_5Value(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Min)', '-999999999999999999999999999999999.99999', -999999999999999999999999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Max)', '999999999999999999999999999999999.99999', 999999999999999999999999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Known Issue)', '555199718819119806866360174750440.86658', 555199718819119806866360174750440.86658)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Known Issue 2)', '55199718819119806866360174750440.86658', 55199718819119806866360174750440.86658)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Known Issue 3)', '5199718819119806866360174750440.86658', 5199718819119806866360174750440.86658)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ -5)', '0.00001', 0.00001)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ -4)', '0.00010', 0.00010)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ -3)', '0.00100', 0.00100)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ -2)', '0.01000', 0.01000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ -1)', '0.10000', 0.10000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 0)', '1.00000', 1.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 1)', '10.00000', 10.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 2)', '100.00000', 100.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 3)', '1000.00000', 1000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 4)', '10000.00000', 10000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 5)', '100000.00000', 100000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 6)', '1000000.00000', 1000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 7)', '10000000.00000', 10000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 8)', '100000000.00000', 100000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 9)', '1000000000.00000', 1000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 10)', '10000000000.00000', 10000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 11)', '100000000000.00000', 100000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 12)', '1000000000000.00000', 1000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 13)', '10000000000000.00000', 10000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 14)', '100000000000000.00000', 100000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 15)', '1000000000000000.00000', 1000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 16)', '10000000000000000.00000', 10000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 17)', '100000000000000000.00000', 100000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 18)', '1000000000000000000.00000', 1000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 19)', '10000000000000000000.00000', 10000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 20)', '100000000000000000000.00000', 100000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 21)', '1000000000000000000000.00000', 1000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 22)', '10000000000000000000000.00000', 10000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 23)', '100000000000000000000000.00000', 100000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 24)', '1000000000000000000000000.00000', 1000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 25)', '10000000000000000000000000.00000', 10000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 26)', '100000000000000000000000000.00000', 100000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 27)', '1000000000000000000000000000.00000', 1000000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 28)', '10000000000000000000000000000.00000', 10000000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 29)', '100000000000000000000000000000.00000', 100000000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 30)', '1000000000000000000000000000000.00000', 1000000000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 31)', '10000000000000000000000000000000.00000', 10000000000000000000000000000000.00000)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(10 ^ 32)', '100000000000000000000000000000000.00000', 100000000000000000000000000000000.00000)
GO
DECLARE @RANDOM DECIMAL(38, 5)
SET @RANDOM =
	CAST(RAND() * 999999999999999999999999999999999.99999 AS DECIMAL(38, 5))
	+ CAST(RAND() * 99999999999999999999999.99999 AS DECIMAL(38, 5))
	+ CAST(RAND() * 99999999999999.99999 AS DECIMAL(38, 5))
	+ CAST(RAND() * 9999.99999 AS DECIMAL(38, 5))
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Random)', CONVERT(VARCHAR(100), @RANDOM), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Decimal_38_5Value) VALUES('Decimal_38_5Value(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(Min)', '-1.7976931348623e+308', -1.7976931348623e308)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(Max)', '1.7976931348623e+308', 1.7976931348623e308)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(Absolute Min)', '1.79769313486232e-307', 1.79769313486232e-307)
GO
DECLARE @RANDOM FLOAT
SET @RANDOM = RAND() * 1.7976931348623e+308
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(Random)', CONVERT(VARCHAR(100), @RANDOM, 2), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, FloatValue) VALUES('FloatValue(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM, 2), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(Min)', '-3.402823e+38', -3.402823e38)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(Max)', '3.402823e+38', 3.402823e38)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(Absolute Min)', '1.797693e-38', 1.79769313486232e-38)
GO
DECLARE @RANDOM FLOAT(24)
SET @RANDOM = RAND() * 3.402823e+38
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(Random)', CONVERT(VARCHAR(100), @RANDOM, 1), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float24Value) VALUES('Float24Value(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM, 1), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(Min)', '-1.7976931348623e+308', -1.7976931348623e308)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(Max)', '1.7976931348623e+308', 1.7976931348623e308)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(Absolute Min)', '1.79769313486232e-307', 1.79769313486232e-307)
GO
DECLARE @RANDOM FLOAT(53)
SET @RANDOM = RAND() * 1.7976931348623e308
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(Random)', CONVERT(VARCHAR(100), @RANDOM), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Float53Value) VALUES('Float53Value(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, GeographyValue) VALUES('GeographyValue(Empty POINT)', '0xe61000000104000000000000000001000000ffffffffffffffff01', geography::STGeomFromText('POINT EMPTY', 4326))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, GeographyValue) VALUES('GeographyValue(POINT 0 0)', '0xe6100000010c00000000000000000000000000000000', geography::STGeomFromText('POINT (0 0)', 4326))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, GeographyValue) VALUES('GeographyValue(POINT 100 45)', '0xe6100000010c00000000008046400000000000005940', geography::STGeomFromText('POINT (100 45)', 4326))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, GeometryValue) VALUES('GeometryValue(Empty POINT)', '0x000000000104000000000000000001000000ffffffffffffffff01', geometry::STGeomFromText('POINT EMPTY', 0))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, GeometryValue) VALUES('GeometryValue(POINT 0 0)', '0x00000000010c00000000000000000000000000000000', geometry::STGeomFromText('POINT (0 0)', 0))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, GeometryValue) VALUES('GeometryValue(POINT 100 100)', '0x00000000010c00000000000059400000000000005940', geometry::STGeomFromText('POINT (100 100)', 0))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(Empty)', '0x', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(Root)', '0x', hierarchyid::GetRoot())
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(1 level)', '0x58', '/1/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(2 level)', '0x5c20', '/1/4/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(3 level)', '0x5c34c0', '/1/4/9/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(4 level)', '0x5c34f044', '/1/4/9/16/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(5 level)', '0x5c34f0470cc0', '/1/4/9/16/25/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(6 level)', '0x5c34f0470cf264', '/1/4/9/16/25/36/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(7 level)', '0x5c34f0470cf26744c0', '/1/4/9/16/25/36/49/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(8 level)', '0x5c34f0470cf26744f644', '/1/4/9/16/25/36/49/64/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(9 level)', '0x5c34f0470cf26744f6478013', '/1/4/9/16/25/36/49/64/81/')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, HierarchyIdValue) VALUES('HierarchyIdValue(10 level)', '0x5c34f0470cf26744f6478013e02640', '/1/4/9/16/25/36/49/64/81/100/')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, ImageValue) VALUES('ImageValue(Empty)', '0x', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, ImageValue) VALUES('ImageValue(One Byte)', '0x01', 0x01)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, ImageValue) VALUES('ImageValue(Twenty Bytes)', '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', CAST(REPLICATE(CAST(CHAR(255) AS VARCHAR(MAX)), 20) AS IMAGE))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, ImageValue) VALUES('ImageValue(Twenty KiloBytes)', '0xFFFFFF...', CAST(REPLICATE(CAST(CHAR(255) AS VARCHAR(MAX)), 20 * 1024) AS IMAGE))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, IntValue) VALUES('IntValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, IntValue) VALUES('IntValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, IntValue) VALUES('IntValue(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, IntValue) VALUES('IntValue(Min)', '-2147483648', -2147483648)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, IntValue) VALUES('IntValue(Max)', '2147483647', 2147483647)
GO
DECLARE @RANDOM INT
SET @RANDOM = RAND() * 2147483647
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, IntValue) VALUES('IntValue(Random)', CONVERT(VARCHAR(100), @RANDOM), @RANDOM)
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, IntValue) VALUES('IntValue(Negative Random)', CONVERT(VARCHAR(100), -@RANDOM), -@RANDOM)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, MoneyValue) VALUES('MoneyValue(Zero)', '0.0000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, MoneyValue) VALUES('MoneyValue(One)', '1.0000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, MoneyValue) VALUES('MoneyValue(Negative One)', '-1.0000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, MoneyValue) VALUES('MoneyValue(Min)', '-922337203685477.5808', -922337203685477.5808)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, MoneyValue) VALUES('MoneyValue(Max)', '922337203685477.5807', 922337203685477.5807)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NCharValue) VALUES('NCharValue(Empty)', ' ', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NCharValue) VALUES('NCharValue(One NChar)', '1', N'1')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NChar2Value) VALUES('NChar2Value(Empty)', '  ', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NChar2Value) VALUES('NChar2Value(One NChar)', '1 ', N'1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NChar2Value) VALUES('NChar2Value(Max)', 'ZZ', N'ZZ')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NChar20Value) VALUES('NChar20Value(Empty)', '                    ', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NChar20Value) VALUES('NChar20Value(One NChar)', '1                   ', N'1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NChar20Value) VALUES('NChar20Value(Max)', 'ZZZZZZZZZZZZZZZZZZZZ', N'ZZZZZZZZZZZZZZZZZZZZ')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NTextValue) VALUES('NTextValue(Empty)', '', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NTextValue) VALUES('NTextValue(One NChar)', '1', N'1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NTextValue) VALUES('NTextValue(Twenty NChars)', 'ZZZZZZZZZZZZZZZZZZZZ', CAST(REPLICATE(CAST(N'Z' AS NVARCHAR(MAX)), 20) AS NTEXT))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NTextValue) VALUES('NTextValue(Twenty Thousand NChars)', 'ZZZ...', CAST(REPLICATE(CAST(N'Z' AS NVARCHAR(MAX)), 20 * 1000) AS NTEXT))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NumericValue) VALUES('NumericValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NumericValue) VALUES('NumericValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NumericValue) VALUES('NumericValue(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NumericValue) VALUES('NumericValue(Min)', '-999999999999999999', -999999999999999999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NumericValue) VALUES('NumericValue(Max)', '999999999999999999', 999999999999999999)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_9_5Value) VALUES('Numeric_9_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_9_5Value) VALUES('Numeric_9_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_9_5Value) VALUES('Numeric_9_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_9_5Value) VALUES('Numeric_9_5Value(Min)', '-9999.99999', -9999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_9_5Value) VALUES('Numeric_9_5Value(Max)', '9999.99999', 9999.99999)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_19_5Value) VALUES('Numeric_19_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_19_5Value) VALUES('Numeric_19_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_19_5Value) VALUES('Numeric_19_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_19_5Value) VALUES('Numeric_19_5Value(Min)', '-99999999999999.99999', -99999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_19_5Value) VALUES('Numeric_19_5Value(Max)', '99999999999999.99999', 99999999999999.99999)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_28_5Value) VALUES('Numeric_28_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_28_5Value) VALUES('Numeric_28_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_28_5Value) VALUES('Numeric_28_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_28_5Value) VALUES('Numeric_28_5Value(Min)', '-99999999999999999999999.99999', -99999999999999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_28_5Value) VALUES('Numeric_28_5Value(Max)', '99999999999999999999999.99999', 99999999999999999999999.99999)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_38_5Value) VALUES('Numeric_38_5Value(Zero)', '0.00000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_38_5Value) VALUES('Numeric_38_5Value(One)', '1.00000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_38_5Value) VALUES('Numeric_38_5Value(Negative One)', '-1.00000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_38_5Value) VALUES('Numeric_38_5Value(Min)', '-999999999999999999999999999999999.99999', -999999999999999999999999999999999.99999)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Numeric_38_5Value) VALUES('Numeric_38_5Value(Max)', '999999999999999999999999999999999.99999', 999999999999999999999999999999999.99999)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharValue) VALUES('NVarCharValue(Empty)', '', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharValue) VALUES('NVarCharValue(One NChar)', '1', N'1')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar2Value) VALUES('NVarChar2Value(Empty)', '', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar2Value) VALUES('NVarChar2Value(One NChar)', '1', N'1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar2Value) VALUES('NVarChar2Value(Max)', 'ZZ', N'ZZ')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar20Value) VALUES('NVarChar20Value(Empty)', '', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar20Value) VALUES('NVarChar20Value(One NChar)', '1', N'1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar20Value) VALUES('NVarChar20Value(Max)', 'ZZZZZZZZZZZZZZZZZZZZ', N'ZZZZZZZZZZZZZZZZZZZZ')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar1000Value) VALUES('NVarChar1000Value(German)', N'Öl fließt', N'Öl fließt')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar1000Value) VALUES('NVarChar1000Value(Russian)', N'Москва', N'Москва')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar1000Value) VALUES('NVarChar1000Value(Japanese)', N'　♪リンゴ可愛いや可愛いやリンゴ。半世紀も前に流行した「リンゴの歌」がぴったりするかもしれない。米アップルコンピュータ社のパソコン「マック（マッキントッシュ）」を、こよなく愛する人たちのことだ。「アップル信者」なんて言い方まである。', N'　♪リンゴ可愛いや可愛いやリンゴ。半世紀も前に流行した「リンゴの歌」がぴったりするかもしれない。米アップルコンピュータ社のパソコン「マック（マッキントッシュ）」を、こよなく愛する人たちのことだ。「アップル信者」なんて言い方まである。')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar1000Value) VALUES('NVarChar1000Value(Serbian Latin))', N'ŠšĐđČčĆćŽž', N'ŠšĐđČčĆćŽž')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarChar1000Value) VALUES('NVarChar1000Value(Korean)', N'향찰/鄕札 구결/口訣 이두/吏讀', N'향찰/鄕札 구결/口訣 이두/吏讀')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(Empty)', '', N'')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(One NChar)', '1', N'1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(Twenty NChars)', 'ZZZZZZZZZZZZZZZZZZZZ', CAST(REPLICATE(CAST(N'Z' AS NVARCHAR(MAX)), 20) AS NVARCHAR(MAX)))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(Twenty Thousand NChars)', 'ZZZ...', CAST(REPLICATE(CAST(N'Z' AS NVARCHAR(MAX)), 20 * 1000) AS NVARCHAR(MAX)))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(German)', N'Öl fließt', N'Öl fließt')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(Russian)', N'Москва', N'Москва')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(Japanese)', N'　♪リンゴ可愛いや可愛いやリンゴ。半世紀も前に流行した「リンゴの歌」がぴったりするかもしれない。米アップルコンピュータ社のパソコン「マック（マッキントッシュ）」を、こよなく愛する人たちのことだ。「アップル信者」なんて言い方まである。', N'　♪リンゴ可愛いや可愛いやリンゴ。半世紀も前に流行した「リンゴの歌」がぴったりするかもしれない。米アップルコンピュータ社のパソコン「マック（マッキントッシュ）」を、こよなく愛する人たちのことだ。「アップル信者」なんて言い方まである。')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(Serbian Latin))', N'ŠšĐđČčĆćŽž', N'ŠšĐđČčĆćŽž')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, NVarCharMaxValue) VALUES('NVarCharMaxValue(Korean)', N'향찰/鄕札 구결/口訣 이두/吏讀', N'향찰/鄕札 구결/口訣 이두/吏讀')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(TwoBytesCompressed)', '3.5', 3.5)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(Negative TwoBytesCompressed)', '-3.5', -3.5)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(Min)', '-3.402823e+38', -3.4028231e38)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(Max)', '3.402823e+38', 3.4028231e38)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, RealValue) VALUES('RealValue(Absolute Min)', '1.797693e-38', 1.79769313486232e-38)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallDateTimeValue) VALUES('SmallDateTimeValue(Min)', '1900-01-01 00:00:00', '1900-01-01 00:00:00')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallDateTimeValue) VALUES('SmallDateTimeValue(Max)', '2079-06-06 23:59:00', '2079-06-06 23:59:29')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallIntValue) VALUES('SmallIntValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallIntValue) VALUES('SmallIntValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallIntValue) VALUES('SmallIntValue(Negative One)', '-1', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallIntValue) VALUES('SmallIntValue(Min)', '-32768', -32768)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallIntValue) VALUES('SmallIntValue(Max)', '32767', 32767)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallMoneyValue) VALUES('SmallMoneyValue(Zero)', '0.0000', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallMoneyValue) VALUES('SmallMoneyValue(One)', '1.0000', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallMoneyValue) VALUES('SmallMoneyValue(Negative One)', '-1.0000', -1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallMoneyValue) VALUES('SmallMoneyValue(Min)', '-214748.3648', -214748.3648)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SmallMoneyValue) VALUES('SmallMoneyValue(Max)', '214748.3647', 214748.3647)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TextValue) VALUES('TextValue(Empty)', '', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TextValue) VALUES('TextValue(One Char)', '1', '1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TextValue) VALUES('TextValue(Twenty Chars)', 'ZZZZZZZZZZZZZZZZZZZZ', CAST(REPLICATE(CAST('Z' AS VARCHAR(MAX)), 20) AS TEXT))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TextValue) VALUES('TextValue(Twenty Thousand Chars)', 'ZZZ...', CAST(REPLICATE(CAST('Z' AS VARCHAR(MAX)), 20 * 1000) AS TEXT))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TimeValue) VALUES('TimeValue(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TimeValue) VALUES('TimeValue(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TimeValue) VALUES('TimeValue(Max)', '23:59:59.9999999', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time0Value) VALUES('Time0Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time0Value) VALUES('Time0Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time0Value) VALUES('Time0Value(Max)', '23:59:59', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time1Value) VALUES('Time1Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time1Value) VALUES('Time1Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time1Value) VALUES('Time1Value(Max)', '23:59:59.9000000', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time2Value) VALUES('Time2Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time2Value) VALUES('Time2Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time2Value) VALUES('Time2Value(Max)', '23:59:59.9900000', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time3Value) VALUES('Time3Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time3Value) VALUES('Time3Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time3Value) VALUES('Time3Value(Max)', '23:59:59.9990000', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time4Value) VALUES('Time4Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time4Value) VALUES('Time4Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time4Value) VALUES('Time4Value(Max)', '23:59:59.9999000', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time5Value) VALUES('Time5Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time5Value) VALUES('Time5Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time5Value) VALUES('Time5Value(Max)', '23:59:59.9999900', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time6Value) VALUES('Time6Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time6Value) VALUES('Time6Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time6Value) VALUES('Time6Value(Max)', '23:59:59.9999990', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time7Value) VALUES('Time7Value(Min)', '00:00:00', '00:00:00.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time7Value) VALUES('Time7Value(GoodCompression)', '00:00:01', '00:00:01.0000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, Time7Value) VALUES('Time7Value(Max)', '23:59:59.9999999', '23:59:59.9999999')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TinyIntValue) VALUES('TinyIntValue(Zero)', '0', 0)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TinyIntValue) VALUES('TinyIntValue(One)', '1', 1)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, TinyIntValue) VALUES('TinyIntValue(Max)', '255', 255)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, UniqueIdentifierValue) VALUES('UniqueIdentifierValue(Min)', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, UniqueIdentifierValue) VALUES('UniqueIdentifierValue(Max)', 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF', 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinaryValue) VALUES('VarBinaryValue(Empty)', '0x', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinaryValue) VALUES('VarBinaryValue(One Byte)', '0x01', 0x01)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinary2Value) VALUES('VarBinary2Value(Empty)', '0x', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinary2Value) VALUES('VarBinary2Value(One Byte)', '0x01', 0x01)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinary2Value) VALUES('VarBinary2Value(Max)', '0xFFFF', 0xffff)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinary20Value) VALUES('VarBinary20Value(Empty)', '0x', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinary20Value) VALUES('VarBinary20Value(One Byte)', '0x01', 0x01)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinary20Value) VALUES('VarBinary20Value(Max)', '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', 0xffffffffffffffffffffffffffffffffffffffff)
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinaryMaxValue) VALUES('VarBinaryMaxValue(Empty)', '0x', 0x)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinaryMaxValue) VALUES('VarBinaryMaxValue(One Byte)', '0x01', 0x01)
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinaryMaxValue) VALUES('VarBinaryMaxValue(Twenty Bytes)', '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', CAST(REPLICATE(CAST(CHAR(255) AS VARCHAR(MAX)), 20) AS VARBINARY(MAX)))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarBinaryMaxValue) VALUES('VarBinaryMaxValue(Twenty KiloBytes)', '0xFFFFFF...', CAST(REPLICATE(CAST(CHAR(255) AS VARCHAR(MAX)), 20 * 1024) AS VARBINARY(MAX)))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarCharValue) VALUES('VarCharValue(Empty)', '', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarCharValue) VALUES('VarCharValue(One Char)', '1', '1')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarChar2Value) VALUES('VarChar2Value(Empty)', '', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarChar2Value) VALUES('VarChar2Value(One Char)', '1', '1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarChar2Value) VALUES('VarChar2Value(Max)', 'ZZ', 'ZZ')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarChar20Value) VALUES('VarChar20Value(Empty)', '', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarChar20Value) VALUES('VarChar20Value(One Char)', '1', '1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarChar20Value) VALUES('VarChar20Value(Max)', 'ZZZZZZZZZZZZZZZZZZZZ', 'ZZZZZZZZZZZZZZZZZZZZ')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarCharMaxValue) VALUES('VarCharMaxValue(Empty)', '', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarCharMaxValue) VALUES('VarCharMaxValue(One Char)', '1', '1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarCharMaxValue) VALUES('VarCharMaxValue(Twenty Chars)', 'ZZZZZZZZZZZZZZZZZZZZ', CAST(REPLICATE(CAST('Z' AS VARCHAR(MAX)), 20) AS VARCHAR(MAX)))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, VarCharMaxValue) VALUES('VarCharMaxValue(Twenty Thousand Chars)', 'ZZZ...', CAST(REPLICATE(CAST('Z' AS VARCHAR(MAX)), 20 * 1000) AS VARCHAR(MAX)))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(Empty)', '', '')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(One Char)', '1', '1')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(Twenty Chars)', 'ZZZZZZZZZZZZZZZZZZZZ', CAST(REPLICATE(CAST('Z' AS VARCHAR(MAX)), 20) AS VARCHAR(MAX)))
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(Twenty Thousand Chars)', 'ZZZ...', CAST(REPLICATE(CAST('Z' AS VARCHAR(MAX)), 20 * 1000) AS VARCHAR(MAX)))
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(Empty Tag)', '<tag />', '<tag />')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(One Char Tag)', '<tag>1</tag>', '<tag>1</tag>')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(Twenty Chars Tag)', '<tag>ZZZZZZZZZZZZZZZZZZZZ</tag>', '<tag>ZZZZZZZZZZZZZZZZZZZZ</tag>')
GO
INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, XmlValue) VALUES('XmlValue(Twenty Thousand Chars Tag)', '<tag/>ZZZ...</tag>', '<tag>' + CAST(REPLICATE(CAST('Z' AS VARCHAR(MAX)), 20 * 1000) AS VARCHAR(MAX)) + '</tag>')
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, BigIntValue
FROM TestAllTypes
WHERE BigIntValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, BinaryValue
FROM TestAllTypes
WHERE BinaryValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Binary2Value
FROM TestAllTypes
WHERE Binary2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Binary20Value
FROM TestAllTypes
WHERE Binary20Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, BitValue
FROM TestAllTypes
WHERE BitValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, CharValue
FROM TestAllTypes
WHERE CharValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Char2Value
FROM TestAllTypes
WHERE Char2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Char20Value
FROM TestAllTypes
WHERE Char20Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateValue
FROM TestAllTypes
WHERE DateValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeValue
FROM TestAllTypes
WHERE DateTimeValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2Value
FROM TestAllTypes
WHERE DateTime2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_0Value
FROM TestAllTypes
WHERE DateTime2_0Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_1Value
FROM TestAllTypes
WHERE DateTime2_1Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_2Value
FROM TestAllTypes
WHERE DateTime2_2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_3Value
FROM TestAllTypes
WHERE DateTime2_3Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_4Value
FROM TestAllTypes
WHERE DateTime2_4Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_5Value
FROM TestAllTypes
WHERE DateTime2_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_6Value
FROM TestAllTypes
WHERE DateTime2_6Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTime2_7Value
FROM TestAllTypes
WHERE DateTime2_7Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffsetValue
FROM TestAllTypes
WHERE DateTimeOffsetValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset0Value
FROM TestAllTypes
WHERE DateTimeOffset0Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset1Value
FROM TestAllTypes
WHERE DateTimeOffset1Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset2Value
FROM TestAllTypes
WHERE DateTimeOffset2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset3Value
FROM TestAllTypes
WHERE DateTimeOffset3Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset4Value
FROM TestAllTypes
WHERE DateTimeOffset4Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset5Value
FROM TestAllTypes
WHERE DateTimeOffset5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset6Value
FROM TestAllTypes
WHERE DateTimeOffset6Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DateTimeOffset7Value
FROM TestAllTypes
WHERE DateTimeOffset7Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, DecimalValue
FROM TestAllTypes
WHERE DecimalValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Decimal_9_5Value
FROM TestAllTypes
WHERE Decimal_9_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Decimal_19_5Value
FROM TestAllTypes
WHERE Decimal_19_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Decimal_28_5Value
FROM TestAllTypes
WHERE Decimal_28_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Decimal_38_5Value
FROM TestAllTypes
WHERE Decimal_38_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, FloatValue
FROM TestAllTypes
WHERE FloatValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Float24Value
FROM TestAllTypes
WHERE Float24Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Float53Value
FROM TestAllTypes
WHERE Float53Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, IntValue
FROM TestAllTypes
WHERE IntValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, MoneyValue
FROM TestAllTypes
WHERE MoneyValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NCharValue
FROM TestAllTypes
WHERE NCharValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NChar2Value
FROM TestAllTypes
WHERE NChar2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NChar20Value
FROM TestAllTypes
WHERE NChar20Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NumericValue
FROM TestAllTypes
WHERE NumericValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Numeric_9_5Value
FROM TestAllTypes
WHERE Numeric_9_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Numeric_19_5Value
FROM TestAllTypes
WHERE Numeric_19_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Numeric_28_5Value
FROM TestAllTypes
WHERE Numeric_28_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Numeric_38_5Value
FROM TestAllTypes
WHERE Numeric_38_5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NVarCharValue
FROM TestAllTypes
WHERE NVarCharValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NVarChar2Value
FROM TestAllTypes
WHERE NVarChar2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NVarChar20Value
FROM TestAllTypes
WHERE NVarChar20Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, NVarChar1000Value
FROM TestAllTypes
WHERE NVarChar1000Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, RealValue
FROM TestAllTypes
WHERE RealValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, SmallDateTimeValue
FROM TestAllTypes
WHERE SmallDateTimeValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, SmallIntValue
FROM TestAllTypes
WHERE SmallIntValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, SmallMoneyValue
FROM TestAllTypes
WHERE SmallMoneyValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, SysNameValue
FROM TestAllTypes
WHERE SysNameValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, TimeValue
FROM TestAllTypes
WHERE TimeValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time0Value
FROM TestAllTypes
WHERE Time0Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time1Value
FROM TestAllTypes
WHERE Time1Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time2Value
FROM TestAllTypes
WHERE Time2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time3Value
FROM TestAllTypes
WHERE Time3Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time4Value
FROM TestAllTypes
WHERE Time4Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time5Value
FROM TestAllTypes
WHERE Time5Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time6Value
FROM TestAllTypes
WHERE Time6Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, Time7Value
FROM TestAllTypes
WHERE Time7Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, TinyIntValue
FROM TestAllTypes
WHERE TinyIntValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, UniqueIdentifierValue
FROM TestAllTypes
WHERE UniqueIdentifierValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, VarBinaryValue
FROM TestAllTypes
WHERE VarBinaryValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, VarBinary2Value
FROM TestAllTypes
WHERE VarBinary2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, VarBinary20Value
FROM TestAllTypes
WHERE VarBinary20Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, VarCharValue
FROM TestAllTypes
WHERE VarCharValue IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, VarChar2Value
FROM TestAllTypes
WHERE VarChar2Value IS NOT NULL
GO

INSERT INTO TestAllTypes(Comment, ExpectedEngineOutput, SqlVariantValue)
SELECT 'SQL_VARIANT: ' + Comment, ExpectedEngineOutput, VarChar20Value
FROM TestAllTypes
WHERE VarChar20Value IS NOT NULL
GO

--=========================================
print 'Runing SELECT INTO test data'
--=========================================
GO

SELECT *
INTO TestAllTypesFromSelectInto
FROM TestAllTypes
GO

--=========================================
print 'Adding FILESTREAM and SPARSE test data. This will work only on SQL 2008 and later.'
print 'If you are executing on versions before 2008 expect errors after this point.'
--=========================================

ALTER DATABASE ApexSQLLogDEMO ADD FILEGROUP [TEST_FILESTREAM] CONTAINS FILESTREAM 
GO

DECLARE @defaultDataDir NVARCHAR(4000)

EXEC master.dbo.xp_instance_regread
	N'HKEY_LOCAL_MACHINE',
	N'Software\Microsoft\MSSQLServer\MSSQLServer',
	N'DefaultData',
	@defaultDataDir OUTPUT,
	'no_output'

IF @defaultDataDir IS NULL
BEGIN
	EXEC master.dbo.xp_instance_regread
		N'HKEY_LOCAL_MACHINE',
		N'SOFTWARE\Microsoft\MSSQLServer\Setup',
		N'SQLPath',
		@defaultDataDir OUTPUT,
		'no_output'
		
	SET @defaultDataDir = @defaultDataDir + '\Data'
END

DECLARE @fileStreamDir NVARCHAR(4000)
SET @fileStreamDir = @defaultDataDir + '\ApexSQLLogDEMO_FileStream'

--=========================================
PRINT 'Adding FILESTREAM logical file at ' + @fileStreamDir
--=========================================

DECLARE @sql NVARCHAR(4000)
SET @sql = 'ALTER DATABASE ApexSQLLogDEMO ADD FILE (' +
	'NAME = N''ApexSQLLogDEMO_FileStream'', ' +
	'FILENAME = ''' + @fileStreamDir + ''') ' +
	'TO FILEGROUP [TEST_FILESTREAM]'

EXEC sp_executesql @sql
GO

USE ApexSQLLogDEMO
GO

CREATE TABLE TestFileStream
(
	PK INT PRIMARY KEY,
	[Id] [uniqueidentifier] ROWGUIDCOL NOT NULL UNIQUE DEFAULT NEWID(), 
	Data VARBINARY(MAX) FILESTREAM
)
GO

INSERT INTO TestFileStream(Pk, Data) VALUES(1, NULL)
INSERT INTO TestFileStream(Pk, Data) VALUES(2, 0x)
INSERT INTO TestFileStream(Pk, Data) VALUES(3, 0x00)
INSERT INTO TestFileStream(Pk, Data) VALUES(4, 0x0000)
INSERT INTO TestFileStream(Pk, Data) VALUES(5, CAST(REPLICATE(0x01, 10000) AS VARBINARY(MAX)))
GO

DELETE FROM TestFileStream
GO

--=========================================
print 'Creating sparse test'
--=========================================

PRINT 'Creating TestAllTypes_Sparse table'
CREATE TABLE TestAllTypes_Sparse
(
	PrimaryKey Int Primary Key,
	Comment VarChar(100) Null,
	ExpectedEngineOutput NVarChar(1000),
	BigIntValue BigInt SPARSE Null,
	BinaryValue Binary SPARSE Null,
	Binary2Value Binary(2) SPARSE Null,
	Binary20Value Binary(20) SPARSE Null,
	BitValue Bit SPARSE Null,
	CharValue Char SPARSE Null,
	Char2Value Char(2) SPARSE Null,
	Char20Value Char(20) SPARSE Null,
	DateTimeValue DateTime SPARSE Null,
	DecimalValue Decimal SPARSE Null,
	Decimal_9_5Value Decimal(9,5) SPARSE Null,
	Decimal_19_5Value Decimal(19,5) SPARSE Null,
	Decimal_28_5Value Decimal(28,5) SPARSE Null,
	Decimal_38_5Value Decimal(38,5) SPARSE Null,
	FloatValue Float SPARSE Null,
	Float24Value Float(24) SPARSE Null,
	Float53Value Float(53) SPARSE Null,
	ImageValue Image Null,
	IntValue Int SPARSE Null,
	MoneyValue Money SPARSE Null,
	NCharValue NChar SPARSE Null,
	NChar2Value NChar(2) SPARSE Null,
	NChar20Value NChar(20) SPARSE Null,
	NTextValue NText Null,
	NumericValue Numeric SPARSE Null,
	Numeric_9_5Value Numeric(9,5) SPARSE Null,
	Numeric_19_5Value Numeric(19,5) SPARSE Null,
	Numeric_28_5Value Numeric(28,5) SPARSE Null,
	Numeric_38_5Value Numeric(38,5) SPARSE Null,
	NVarCharValue NVarChar SPARSE Null,
	NVarChar2Value NVarChar(2) SPARSE Null,
	NVarChar20Value NVarChar(20) SPARSE Null,
	NVarChar1000Value NVarChar(1000) SPARSE Null,
	NVarCharMaxValue NVarChar(Max) SPARSE Null,
	RealValue Real SPARSE Null,
	SmallDateTimeValue SmallDateTime SPARSE Null,
	SmallIntValue SmallInt SPARSE Null,
	SmallMoneyValue SmallMoney SPARSE Null,
	SqlVariantValue Sql_Variant SPARSE Null,
	SysNameValue SysName SPARSE Null,
	TextValue Text Null,
	TimestampValue Timestamp Null,
	TinyIntValue TinyInt SPARSE Null,
	UniqueIdentifierValue UniqueIdentifier SPARSE Null,
	VarBinaryValue VarBinary SPARSE Null,
	VarBinary2Value VarBinary(2) SPARSE Null,
	VarBinary20Value VarBinary(20) SPARSE Null,
	VarBinaryMaxValue VarBinary(max) SPARSE Null,
	VarCharValue VarChar SPARSE Null,
	VarChar2Value VarChar(2) SPARSE Null,
	VarChar20Value VarChar(20) SPARSE Null,
	VarCharMaxValue VarChar(max) SPARSE Null,
	XmlValue Xml SPARSE Null
)
GO

-- Adding SQL 2008 types to TestAllTypes_Sparse'
ALTER TABLE TestAllTypes_Sparse ADD
	DateValue Date SPARSE Null,
	DateTime2Value DateTime2 SPARSE Null,
	DateTime2_0Value DateTime2(0) SPARSE Null,
	DateTime2_1Value DateTime2(1) SPARSE Null,
	DateTime2_2Value DateTime2(2) SPARSE Null,
	DateTime2_3Value DateTime2(3) SPARSE Null,
	DateTime2_4Value DateTime2(4) SPARSE Null,
	DateTime2_5Value DateTime2(5) SPARSE Null,
	DateTime2_6Value DateTime2(6) SPARSE Null,
	DateTime2_7Value DateTime2(7) SPARSE Null,
	DateTimeOffsetValue DateTimeOffset SPARSE Null,
	DateTimeOffset0Value DateTimeOffset(0) SPARSE Null,
	DateTimeOffset1Value DateTimeOffset(1) SPARSE Null,
	DateTimeOffset2Value DateTimeOffset(2) SPARSE Null,
	DateTimeOffset3Value DateTimeOffset(3) SPARSE Null,
	DateTimeOffset4Value DateTimeOffset(4) SPARSE Null,
	DateTimeOffset5Value DateTimeOffset(5) SPARSE Null,
	DateTimeOffset6Value DateTimeOffset(6) SPARSE Null,
	DateTimeOffset7Value DateTimeOffset(7) SPARSE Null,
	GeographyValue Geography Null,
	GeometryValue Geometry Null,
	HierarchyIdValue HierarchyId SPARSE Null,
	TimeValue Time SPARSE Null,
	Time0Value Time(0) SPARSE Null,
	Time1Value Time(1) SPARSE Null,
	Time2Value Time(2) SPARSE Null,
	Time3Value Time(3) SPARSE Null,
	Time4Value Time(4) SPARSE Null,
	Time5Value Time(5) SPARSE Null,
	Time6Value Time(6) SPARSE Null,
	Time7Value Time(7) SPARSE Null
GO

--=========================================
print 'Adding test data to TestAllTypes_Sparse'
print 'If you are executing on versions before 2008 expect errors after this point.'
--=========================================

INSERT
INTO TestAllTypes_Sparse
(
	PrimaryKey,
	Comment,
	ExpectedEngineOutput,
	BigIntValue,
	BinaryValue,
	Binary2Value,
	Binary20Value,
	BitValue,
	CharValue,
	Char2Value,
	Char20Value,
	DateTimeValue,
	DecimalValue,
	Decimal_9_5Value,
	Decimal_19_5Value,
	Decimal_28_5Value,
	Decimal_38_5Value,
	FloatValue,
	Float24Value,
	Float53Value,
	ImageValue,
	IntValue,
	MoneyValue,
	NCharValue,
	NChar2Value,
	NChar20Value,
	NTextValue,
	NumericValue,
	Numeric_9_5Value,
	Numeric_19_5Value,
	Numeric_28_5Value,
	Numeric_38_5Value,
	NVarCharValue,
	NVarChar2Value,
	NVarChar20Value,
	NVarChar1000Value,
	RealValue,
	SmallDateTimeValue,
	SmallIntValue,
	SmallMoneyValue,
	SqlVariantValue,
	SysNameValue,
	TextValue,
	TinyIntValue,
	UniqueIdentifierValue,
	VarBinaryValue,
	VarBinary2Value,
	VarBinary20Value,
	VarCharValue,
	VarChar2Value,
	VarChar20Value,
	NVarCharMaxValue,
	VarBinaryMaxValue,
	VarCharMaxValue,
	XmlValue,
	DateValue,
	DateTime2Value,
	DateTime2_0Value,
	DateTime2_1Value,
	DateTime2_2Value,
	DateTime2_3Value,
	DateTime2_4Value,
	DateTime2_5Value,
	DateTime2_6Value,
	DateTime2_7Value,
	DateTimeOffsetValue,
	DateTimeOffset0Value,
	DateTimeOffset1Value,
	DateTimeOffset2Value,
	DateTimeOffset3Value,
	DateTimeOffset4Value,
	DateTimeOffset5Value,
	DateTimeOffset6Value,
	DateTimeOffset7Value,
	GeographyValue,
	GeometryValue,
	HierarchyIdValue,
	TimeValue,
	Time0Value,
	Time1Value,
	Time2Value,
	Time3Value,
	Time4Value,
	Time5Value,
	Time6Value,
	Time7Value
)
SELECT
	PrimaryKey,
	Comment,
	ExpectedEngineOutput,
	BigIntValue,
	BinaryValue,
	Binary2Value,
	Binary20Value,
	BitValue,
	CharValue,
	Char2Value,
	Char20Value,
	DateTimeValue,
	DecimalValue,
	Decimal_9_5Value,
	Decimal_19_5Value,
	Decimal_28_5Value,
	Decimal_38_5Value,
	FloatValue,
	Float24Value,
	Float53Value,
	ImageValue,
	IntValue,
	MoneyValue,
	NCharValue,
	NChar2Value,
	NChar20Value,
	NTextValue,
	NumericValue,
	Numeric_9_5Value,
	Numeric_19_5Value,
	Numeric_28_5Value,
	Numeric_38_5Value,
	NVarCharValue,
	NVarChar2Value,
	NVarChar20Value,
	NVarChar1000Value,
	RealValue,
	SmallDateTimeValue,
	SmallIntValue,
	SmallMoneyValue,
	SqlVariantValue,
	SysNameValue,
	TextValue,
	TinyIntValue,
	UniqueIdentifierValue,
	VarBinaryValue,
	VarBinary2Value,
	VarBinary20Value,
	VarCharValue,
	VarChar2Value,
	VarChar20Value,
	NVarCharMaxValue,
	VarBinaryMaxValue,
	VarCharMaxValue,
	XmlValue,
	DateValue,
	DateTime2Value,
	DateTime2_0Value,
	DateTime2_1Value,
	DateTime2_2Value,
	DateTime2_3Value,
	DateTime2_4Value,
	DateTime2_5Value,
	DateTime2_6Value,
	DateTime2_7Value,
	DateTimeOffsetValue,
	DateTimeOffset0Value,
	DateTimeOffset1Value,
	DateTimeOffset2Value,
	DateTimeOffset3Value,
	DateTimeOffset4Value,
	DateTimeOffset5Value,
	DateTimeOffset6Value,
	DateTimeOffset7Value,
	GeographyValue,
	GeometryValue,
	HierarchyIdValue,
	TimeValue,
	Time0Value,
	Time1Value,
	Time2Value,
	Time3Value,
	Time4Value,
	Time5Value,
	Time6Value,
	Time7Value
FROM TestAllTypes
GO

PRINT 'Creating TestAllTypes_RowCompression table'
CREATE TABLE TestAllTypes_RowCompression
(
	PrimaryKey Int Primary Key,
	Comment VarChar(100) Null,
	ExpectedEngineOutput NVarChar(1000) Null,
	BigIntValue BigInt Null,
	BinaryValue Binary Null,
	Binary2Value Binary(2) Null,
	Binary20Value Binary(20) Null,
	BitValue Bit Null,
	CharValue Char Null,
	Char2Value Char(2) Null,
	Char20Value Char(20) Null,
	DateTimeValue DateTime Null,
	DecimalValue Decimal Null,
	Decimal_9_5Value Decimal(9,5) Null,
	Decimal_19_5Value Decimal(19,5) Null,
	Decimal_28_5Value Decimal(28,5) Null,
	Decimal_38_5Value Decimal(38,5) Null,
	FloatValue Float Null,
	Float24Value Float(24) Null,
	Float53Value Float(53) Null,
	ImageValue Image Null,
	IntValue Int Null,
	MoneyValue Money Null,
	NCharValue NChar Null,
	NChar2Value NChar(2) Null,
	NChar20Value NChar(20) Null,
	NTextValue NText Null,
	NumericValue Numeric Null,
	Numeric_9_5Value Numeric(9,5) Null,
	Numeric_19_5Value Numeric(19,5) Null,
	Numeric_28_5Value Numeric(28,5) Null,
	Numeric_38_5Value Numeric(38,5) Null,
	NVarCharValue NVarChar Null,
	NVarChar2Value NVarChar(2) Null,
	NVarChar20Value NVarChar(20) Null,
	NVarChar1000Value NVarChar(1000) Null,
	NVarCharMaxValue NVarChar(Max) Null,
	RealValue Real Null,
	SmallDateTimeValue SmallDateTime Null,
	SmallIntValue SmallInt Null,
	SmallMoneyValue SmallMoney Null,
	SqlVariantValue Sql_Variant Null,
	SysNameValue SysName Null,
	TextValue Text Null,
	TimestampValue Timestamp Null,
	TinyIntValue TinyInt Null,
	UniqueIdentifierValue UniqueIdentifier Null,
	VarBinaryValue VarBinary Null,
	VarBinary2Value VarBinary(2) Null,
	VarBinary20Value VarBinary(20) Null,
	VarBinaryMaxValue VarBinary(max) Null,
	VarCharValue VarChar Null,
	VarChar2Value VarChar(2) Null,
	VarChar20Value VarChar(20) Null,
	VarCharMaxValue VarChar(max) Null,
	XmlValue Xml Null
)
WITH (DATA_COMPRESSION = ROW)
GO

-- Adding SQL 2008 types to TestAllTypes_RowCompression
ALTER TABLE TestAllTypes_RowCompression ADD
	DateValue Date Null,
	DateTime2Value DateTime2 Null,
	DateTime2_0Value DateTime2(0) Null,
	DateTime2_1Value DateTime2(1) Null,
	DateTime2_2Value DateTime2(2) Null,
	DateTime2_3Value DateTime2(3) Null,
	DateTime2_4Value DateTime2(4) Null,
	DateTime2_5Value DateTime2(5) Null,
	DateTime2_6Value DateTime2(6) Null,
	DateTime2_7Value DateTime2(7) Null,
	DateTimeOffsetValue DateTimeOffset Null,
	DateTimeOffset0Value DateTimeOffset(0) Null,
	DateTimeOffset1Value DateTimeOffset(1) Null,
	DateTimeOffset2Value DateTimeOffset(2) Null,
	DateTimeOffset3Value DateTimeOffset(3) Null,
	DateTimeOffset4Value DateTimeOffset(4) Null,
	DateTimeOffset5Value DateTimeOffset(5) Null,
	DateTimeOffset6Value DateTimeOffset(6) Null,
	DateTimeOffset7Value DateTimeOffset(7) Null,
	GeographyValue Geography Null,
	GeometryValue Geometry Null,
	HierarchyIdValue HierarchyId Null,
	TimeValue Time Null,
	Time0Value Time(0) Null,
	Time1Value Time(1) Null,
	Time2Value Time(2) Null,
	Time3Value Time(3) Null,
	Time4Value Time(4) Null,
	Time5Value Time(5) Null,
	Time6Value Time(6) Null,
	Time7Value Time(7) Null
GO

--=========================================
PRINT 'Adding test data to TestAllTypes_RowCompression'
PRINT 'If you are executing on versions before 2008 expect errors after this point.'
--=========================================

INSERT
INTO TestAllTypes_RowCompression
(
	PrimaryKey,
	Comment,
	ExpectedEngineOutput,
	BigIntValue,
	BinaryValue,
	Binary2Value,
	Binary20Value,
	BitValue,
	CharValue,
	Char2Value,
	Char20Value,
	DateTimeValue,
	DecimalValue,
	Decimal_9_5Value,
	Decimal_19_5Value,
	Decimal_28_5Value,
	Decimal_38_5Value,
	FloatValue,
	Float24Value,
	Float53Value,
	ImageValue,
	IntValue,
	MoneyValue,
	NCharValue,
	NChar2Value,
	NChar20Value,
	NTextValue,
	NumericValue,
	Numeric_9_5Value,
	Numeric_19_5Value,
	Numeric_28_5Value,
	Numeric_38_5Value,
	NVarCharValue,
	NVarChar2Value,
	NVarChar20Value,
	NVarChar1000Value,
	RealValue,
	SmallDateTimeValue,
	SmallIntValue,
	SmallMoneyValue,
	SqlVariantValue,
	SysNameValue,
	TextValue,
	TinyIntValue,
	UniqueIdentifierValue,
	VarBinaryValue,
	VarBinary2Value,
	VarBinary20Value,
	VarCharValue,
	VarChar2Value,
	VarChar20Value,
	NVarCharMaxValue,
	VarBinaryMaxValue,
	VarCharMaxValue,
	XmlValue,
	DateValue,
	DateTime2Value,
	DateTime2_0Value,
	DateTime2_1Value,
	DateTime2_2Value,
	DateTime2_3Value,
	DateTime2_4Value,
	DateTime2_5Value,
	DateTime2_6Value,
	DateTime2_7Value,
	DateTimeOffsetValue,
	DateTimeOffset0Value,
	DateTimeOffset1Value,
	DateTimeOffset2Value,
	DateTimeOffset3Value,
	DateTimeOffset4Value,
	DateTimeOffset5Value,
	DateTimeOffset6Value,
	DateTimeOffset7Value,
	GeographyValue,
	GeometryValue,
	HierarchyIdValue,
	TimeValue,
	Time0Value,
	Time1Value,
	Time2Value,
	Time3Value,
	Time4Value,
	Time5Value,
	Time6Value,
	Time7Value
)
SELECT
	PrimaryKey,
	Comment,
	ExpectedEngineOutput,
	BigIntValue,
	BinaryValue,
	Binary2Value,
	Binary20Value,
	BitValue,
	CharValue,
	Char2Value,
	Char20Value,
	DateTimeValue,
	DecimalValue,
	Decimal_9_5Value,
	Decimal_19_5Value,
	Decimal_28_5Value,
	Decimal_38_5Value,
	FloatValue,
	Float24Value,
	Float53Value,
	ImageValue,
	IntValue,
	MoneyValue,
	NCharValue,
	NChar2Value,
	NChar20Value,
	NTextValue,
	NumericValue,
	Numeric_9_5Value,
	Numeric_19_5Value,
	Numeric_28_5Value,
	Numeric_38_5Value,
	NVarCharValue,
	NVarChar2Value,
	NVarChar20Value,
	NVarChar1000Value,
	RealValue,
	SmallDateTimeValue,
	SmallIntValue,
	SmallMoneyValue,
	SqlVariantValue,
	SysNameValue,
	TextValue,
	TinyIntValue,
	UniqueIdentifierValue,
	VarBinaryValue,
	VarBinary2Value,
	VarBinary20Value,
	VarCharValue,
	VarChar2Value,
	VarChar20Value,
	NVarCharMaxValue,
	VarBinaryMaxValue,
	VarCharMaxValue,
	XmlValue,
	DateValue,
	DateTime2Value,
	DateTime2_0Value,
	DateTime2_1Value,
	DateTime2_2Value,
	DateTime2_3Value,
	DateTime2_4Value,
	DateTime2_5Value,
	DateTime2_6Value,
	DateTime2_7Value,
	DateTimeOffsetValue,
	DateTimeOffset0Value,
	DateTimeOffset1Value,
	DateTimeOffset2Value,
	DateTimeOffset3Value,
	DateTimeOffset4Value,
	DateTimeOffset5Value,
	DateTimeOffset6Value,
	DateTimeOffset7Value,
	GeographyValue,
	GeometryValue,
	HierarchyIdValue,
	TimeValue,
	Time0Value,
	Time1Value,
	Time2Value,
	Time3Value,
	Time4Value,
	Time5Value,
	Time6Value,
	Time7Value
FROM TestAllTypes
GO

--=========================================
PRINT 'Creating TestAllTypes_PageCompression table'
--=========================================
CREATE TABLE TestAllTypes_PageCompression
(
	PrimaryKey Int Primary Key Clustered,
	Comment VarChar(100) Null,
	ExpectedEngineOutput NVarChar(1000) Null,
	BigIntValue BigInt Null,
	BinaryValue Binary Null,
	Binary2Value Binary(2) Null,
	Binary20Value Binary(20) Null,
	BitValue Bit Null,
	CharValue Char Null,
	Char2Value Char(2) Null,
	Char20Value Char(20) Null,
	DateTimeValue DateTime Null,
	DecimalValue Decimal Null,
	Decimal_9_5Value Decimal(9,5) Null,
	Decimal_19_5Value Decimal(19,5) Null,
	Decimal_28_5Value Decimal(28,5) Null,
	Decimal_38_5Value Decimal(38,5) Null,
	FloatValue Float Null,
	Float24Value Float(24) Null,
	Float53Value Float(53) Null,
	ImageValue Image Null,
	IntValue Int Null,
	MoneyValue Money Null,
	NCharValue NChar Null,
	NChar2Value NChar(2) Null,
	NChar20Value NChar(20) Null,
	NTextValue NText Null,
	NumericValue Numeric Null,
	Numeric_9_5Value Numeric(9,5) Null,
	Numeric_19_5Value Numeric(19,5) Null,
	Numeric_28_5Value Numeric(28,5) Null,
	Numeric_38_5Value Numeric(38,5) Null,
	NVarCharValue NVarChar Null,
	NVarChar2Value NVarChar(2) Null,
	NVarChar20Value NVarChar(20) Null,
	NVarChar1000Value NVarChar(1000) Null,
	NVarCharMaxValue NVarChar(Max) Null,
	RealValue Real Null,
	SmallDateTimeValue SmallDateTime Null,
	SmallIntValue SmallInt Null,
	SmallMoneyValue SmallMoney Null,
	SqlVariantValue Sql_Variant Null,
	SysNameValue SysName Null,
	TextValue Text Null,
	TimestampValue Timestamp Null,
	TinyIntValue TinyInt Null,
	UniqueIdentifierValue UniqueIdentifier Null,
	VarBinaryValue VarBinary Null,
	VarBinary2Value VarBinary(2) Null,
	VarBinary20Value VarBinary(20) Null,
	VarBinaryMaxValue VarBinary(max) Null,
	VarCharValue VarChar Null,
	VarChar2Value VarChar(2) Null,
	VarChar20Value VarChar(20) Null,
	VarCharMaxValue VarChar(max) Null,
	XmlValue Xml Null
)
WITH (DATA_COMPRESSION = PAGE)
GO

-- Adding SQL 2008 types to TestAllTypes_PageCompression
ALTER TABLE TestAllTypes_PageCompression ADD
	DateValue Date Null,
	DateTime2Value DateTime2 Null,
	DateTime2_0Value DateTime2(0) Null,
	DateTime2_1Value DateTime2(1) Null,
	DateTime2_2Value DateTime2(2) Null,
	DateTime2_3Value DateTime2(3) Null,
	DateTime2_4Value DateTime2(4) Null,
	DateTime2_5Value DateTime2(5) Null,
	DateTime2_6Value DateTime2(6) Null,
	DateTime2_7Value DateTime2(7) Null,
	DateTimeOffsetValue DateTimeOffset Null,
	DateTimeOffset0Value DateTimeOffset(0) Null,
	DateTimeOffset1Value DateTimeOffset(1) Null,
	DateTimeOffset2Value DateTimeOffset(2) Null,
	DateTimeOffset3Value DateTimeOffset(3) Null,
	DateTimeOffset4Value DateTimeOffset(4) Null,
	DateTimeOffset5Value DateTimeOffset(5) Null,
	DateTimeOffset6Value DateTimeOffset(6) Null,
	DateTimeOffset7Value DateTimeOffset(7) Null,
	GeographyValue Geography Null,
	GeometryValue Geometry Null,
	HierarchyIdValue HierarchyId Null,
	TimeValue Time Null,
	Time0Value Time(0) Null,
	Time1Value Time(1) Null,
	Time2Value Time(2) Null,
	Time3Value Time(3) Null,
	Time4Value Time(4) Null,
	Time5Value Time(5) Null,
	Time6Value Time(6) Null,
	Time7Value Time(7) Null
GO

--=========================================
PRINT 'Adding test data to TestAllTypes_PageCompression'
PRINT 'If you are executing on versions before 2008 expect errors after this point.'
--=========================================

INSERT
INTO TestAllTypes_PageCompression
(
	PrimaryKey,
	Comment,
	ExpectedEngineOutput,
	BigIntValue,
	BinaryValue,
	Binary2Value,
	Binary20Value,
	BitValue,
	CharValue,
	Char2Value,
	Char20Value,
	DateTimeValue,
	DecimalValue,
	Decimal_9_5Value,
	Decimal_19_5Value,
	Decimal_28_5Value,
	Decimal_38_5Value,
	FloatValue,
	Float24Value,
	Float53Value,
	ImageValue,
	IntValue,
	MoneyValue,
	NCharValue,
	NChar2Value,
	NChar20Value,
	NTextValue,
	NumericValue,
	Numeric_9_5Value,
	Numeric_19_5Value,
	Numeric_28_5Value,
	Numeric_38_5Value,
	NVarCharValue,
	NVarChar2Value,
	NVarChar20Value,
	NVarChar1000Value,
	RealValue,
	SmallDateTimeValue,
	SmallIntValue,
	SmallMoneyValue,
	SqlVariantValue,
	SysNameValue,
	TextValue,
	TinyIntValue,
	UniqueIdentifierValue,
	VarBinaryValue,
	VarBinary2Value,
	VarBinary20Value,
	VarCharValue,
	VarChar2Value,
	VarChar20Value,
	NVarCharMaxValue,
	VarBinaryMaxValue,
	VarCharMaxValue,
	XmlValue,
	DateValue,
	DateTime2Value,
	DateTime2_0Value,
	DateTime2_1Value,
	DateTime2_2Value,
	DateTime2_3Value,
	DateTime2_4Value,
	DateTime2_5Value,
	DateTime2_6Value,
	DateTime2_7Value,
	DateTimeOffsetValue,
	DateTimeOffset0Value,
	DateTimeOffset1Value,
	DateTimeOffset2Value,
	DateTimeOffset3Value,
	DateTimeOffset4Value,
	DateTimeOffset5Value,
	DateTimeOffset6Value,
	DateTimeOffset7Value,
	GeographyValue,
	GeometryValue,
	HierarchyIdValue,
	TimeValue,
	Time0Value,
	Time1Value,
	Time2Value,
	Time3Value,
	Time4Value,
	Time5Value,
	Time6Value,
	Time7Value
)
SELECT
	PrimaryKey,
	Comment,
	ExpectedEngineOutput,
	BigIntValue,
	BinaryValue,
	Binary2Value,
	Binary20Value,
	BitValue,
	CharValue,
	Char2Value,
	Char20Value,
	DateTimeValue,
	DecimalValue,
	Decimal_9_5Value,
	Decimal_19_5Value,
	Decimal_28_5Value,
	Decimal_38_5Value,
	FloatValue,
	Float24Value,
	Float53Value,
	ImageValue,
	IntValue,
	MoneyValue,
	NCharValue,
	NChar2Value,
	NChar20Value,
	NTextValue,
	NumericValue,
	Numeric_9_5Value,
	Numeric_19_5Value,
	Numeric_28_5Value,
	Numeric_38_5Value,
	NVarCharValue,
	NVarChar2Value,
	NVarChar20Value,
	NVarChar1000Value,
	RealValue,
	SmallDateTimeValue,
	SmallIntValue,
	SmallMoneyValue,
	SqlVariantValue,
	SysNameValue,
	TextValue,
	TinyIntValue,
	UniqueIdentifierValue,
	VarBinaryValue,
	VarBinary2Value,
	VarBinary20Value,
	VarCharValue,
	VarChar2Value,
	VarChar20Value,
	NVarCharMaxValue,
	VarBinaryMaxValue,
	VarCharMaxValue,
	XmlValue,
	DateValue,
	DateTime2Value,
	DateTime2_0Value,
	DateTime2_1Value,
	DateTime2_2Value,
	DateTime2_3Value,
	DateTime2_4Value,
	DateTime2_5Value,
	DateTime2_6Value,
	DateTime2_7Value,
	DateTimeOffsetValue,
	DateTimeOffset0Value,
	DateTimeOffset1Value,
	DateTimeOffset2Value,
	DateTimeOffset3Value,
	DateTimeOffset4Value,
	DateTimeOffset5Value,
	DateTimeOffset6Value,
	DateTimeOffset7Value,
	GeographyValue,
	GeometryValue,
	HierarchyIdValue,
	TimeValue,
	Time0Value,
	Time1Value,
	Time2Value,
	Time3Value,
	Time4Value,
	Time5Value,
	Time6Value,
	Time7Value
FROM TestAllTypes
GO

--=========================================
PRINT 'Deleting data from all TestAllTypes tables'
--=========================================

DELETE FROM TestAllTypes
GO

DELETE FROM TestAllTypes_PageCompression
GO

DELETE FROM TestAllTypes_Sparse
GO

DELETE FROM TestAllTypes_RowCompression
GO

CREATE TABLE TestUnicodeCompression
(
	PK INT PRIMARY KEY,
	Comment VARCHAR(200),
	CompressedText NVARCHAR(2000),
	UncompressedText NVARCHAR(MAX)
)
WITH (DATA_COMPRESSION = ROW)
GO

INSERT INTO TestUnicodeCompression VALUES(1, 'German', N'Öl fließt', N'Öl fließt')
INSERT INTO TestUnicodeCompression VALUES(2, 'Russian', N'Москва', N'Москва')
INSERT INTO TestUnicodeCompression VALUES(3, 'Japanese', N'　♪リンゴ可愛いや可愛いやリンゴ。半世紀も前に流行した「リンゴの歌」がぴったりするかもしれない。米アップルコンピュータ社のパソコン「マック（マッキントッシュ）」を、こよなく愛する人たちのことだ。「アップル信者」なんて言い方まである。', N'　♪リンゴ可愛いや可愛いやリンゴ。半世紀も前に流行した「リンゴの歌」がぴったりするかもしれない。米アップルコンピュータ社のパソコン「マック（マッキントッシュ）」を、こよなく愛する人たちのことだ。「アップル信者」なんて言い方まである。')
INSERT INTO TestUnicodeCompression VALUES(4, 'Serbian Latin', N'ŠšĐđČčĆćŽž', N'ŠšĐđČčĆćŽž')
INSERT INTO TestUnicodeCompression VALUES(5, 'Korean', N'향찰/鄕札 구결/口訣 이두/吏讀', N'향찰/鄕札 구결/口訣 이두/吏讀')
GO

DELETE FROM TestUnicodeCompression
GO

CREATE TABLE TestPageCompressionWithMixedClusteredKey
(
	PK1 NVARCHAR(50),
	PK2 INT,
	PK3 INT,
	VALUE VARCHAR(100)
)
WITH (DATA_COMPRESSION = PAGE)
GO

CREATE CLUSTERED INDEX CI_TestPageCompressionWithMixedClusteredKey ON TestPageCompressionWithMixedClusteredKey(PK1, PK2, PK3)
GO

DECLARE @i INT
SET @i = 0
WHILE @i < 250
BEGIN
	INSERT INTO TestPageCompressionWithMixedClusteredKey VALUES(
		'A LONG PREFIX + ' + CAST((@i / 2) AS NVARCHAR(20)),
		@i / 2,
		NULL,
		'TestPageCompressionWithMixedClusteredKey'
	)
	SET @i = @i + 1
END
GO

UPDATE TestPageCompressionWithMixedClusteredKey SET VALUE = VALUE + 'X'
GO

DELETE FROM TestPageCompressionWithMixedClusteredKey WHERE PK2 % 4 = 0
GO
print 'Generating 10 tables with random data'

declare @table_count int
set @table_count = 10

declare @i int
set @i = 0

while @i < @table_count -- n tables with 20 columns each
begin
	declare @sql nvarchar(4000)

	set @sql = '
		create table table_' + cast(@i as varchar) + '
		(
			column1 int identity(1,1) primary key,
			column2 int,
			column3 int,
			column4 int,
			column5 int,
			column6 int,
			column7 int,
			column8 int,
			column9 int,
			column10 int,
			column11 int,
			column12 int,
			column13 int,
			column14 int,
			column15 int,
			column16 int,
			column17 int,
			column18 int,
			column19 int,
			column20 int
		)
	'

	exec sp_executesql @sql

	set @i = @i + 1

	if @i % 10 = 0
	begin
		print cast(getdate() as varchar) + char(9) + cast(@i as varchar)
	end
end
go

print 'Inserting 1,000 rows into 10 random tables'

insert into table_5 values(919111,766512,716172,993641,51199,700179,749065,148608,920473,450938,634988,625599,343761,974086,342772,322327,389588,572055,904264)
insert into table_6 values(822894,651658,415682,819326,4301,285531,270306,289375,804969,53251,826223,406356,431457,445693,418318,407480,618960,354898,339600)
insert into table_5 values(844461,880681,568795,229332,58687,496419,914814,297852,903030,844108,960638,39947,591671,585989,858153,263489,383341,568897,572417)
insert into table_9 values(551119,372612,697835,762281,657462,463713,781076,96705,57851,58742,528308,424468,64709,327868,819081,105032,564558,637661,138845)
insert into table_9 values(384418,512725,171772,904773,157025,795536,741435,23503,77840,226029,954182,25630,818919,323517,690916,310187,211360,444121,323069)
insert into table_9 values(182330,548091,112377,144004,559699,440175,858215,269999,278723,614727,244508,10446,902901,203108,649471,351284,904018,464662,462545)
insert into table_0 values(913987,187074,96402,905257,642205,307649,612685,863831,154610,201547,972615,101908,467343,882296,7154,182845,477409,2747,372091)
insert into table_8 values(211738,975146,597625,759362,609595,511845,775827,213496,483636,749303,492546,387387,451619,44873,974337,836175,111395,776314,410807)
insert into table_1 values(207272,528646,343730,445973,922567,469838,861492,127569,751193,755585,804345,496312,711214,74772,658299,478086,468256,347908,102106)
insert into table_4 values(147037,613020,246684,576153,298150,837618,450808,315429,605930,145971,545464,794993,418188,889117,248781,738215,187794,646645,98821)
insert into table_5 values(293068,867249,818405,788649,974494,100553,724851,911937,635950,863204,208734,919218,60978,69941,598941,94587,534285,900199,923192)
insert into table_3 values(853428,895024,866413,839539,812997,392481,447156,375423,564949,432452,722216,915985,968481,170442,946711,706489,393475,864559,697194)
insert into table_0 values(345411,965482,466456,925517,145289,123294,486659,996438,216089,164400,898259,257396,587274,559076,953969,13850,924551,129307,929151)
insert into table_8 values(190688,643999,394940,2089,486397,609329,311139,948254,707552,809532,828930,975815,947238,186562,132391,686898,533881,660927,495340)
insert into table_3 values(149107,304822,529983,398974,841548,495239,755538,740810,662755,928545,381090,28561,316424,963398,905323,187723,968928,970033,227195)
insert into table_1 values(936994,118745,342839,311491,423320,511022,163475,52563,281395,707612,89502,728765,624975,152290,469265,857203,940159,49116,762865)
insert into table_1 values(387291,849888,114355,629769,41612,939729,709788,239155,746050,304326,588116,146961,564021,263072,375194,806017,990011,199451,834531)
insert into table_1 values(984803,574817,642942,198828,620036,346784,147116,979564,338669,550726,429028,751900,224085,220243,338498,49948,137548,50248,620148)
insert into table_1 values(972073,562602,476179,122657,757478,183373,776678,595033,605541,1726,650996,230167,221238,616496,775291,64296,489808,320367,632048)
insert into table_1 values(783960,796458,709756,19768,272944,826757,653776,260038,669950,148165,379326,864595,168162,447556,958580,521532,965706,823683,807843)
insert into table_1 values(514914,772896,825826,283532,985274,520119,784606,169715,751930,74269,940291,52868,146014,330508,974941,277578,546871,307758,895429)
insert into table_3 values(412583,138162,839803,134493,409031,708253,790756,88527,998927,410292,301416,355250,365906,62120,258157,215939,962819,643726,529051)
insert into table_5 values(793524,959992,779980,580060,581243,348310,453470,454576,911494,63784,32232,859112,473666,748694,282260,869002,997453,563741,972162)
insert into table_3 values(899939,528257,233323,854784,2377,132151,89861,143760,630233,264717,188136,60991,32870,803370,935252,212331,157816,115184,917374)
insert into table_6 values(677754,143452,561551,791038,576440,133931,766686,709324,799496,10309,885291,188738,815862,637542,738318,405040,23050,950918,239362)
insert into table_7 values(520001,616222,901571,460664,164303,668541,569319,599083,831529,474751,320863,351794,414253,596276,260382,834810,313018,856841,74423)
insert into table_4 values(213250,74477,283972,932837,652864,517813,254621,490438,273347,38881,769350,71690,333779,671113,214694,442066,755917,238319,758000)
insert into table_5 values(497256,353470,332174,455784,496844,47743,650651,116092,172681,701568,123828,5703,10887,367055,948528,331344,13854,22333,30186)
insert into table_4 values(18382,25493,642385,453033,951710,152995,707842,345132,69686,93980,738198,907347,269910,80898,145354,604972,622115,103551,243118)
insert into table_9 values(337047,871828,870801,557809,179224,407719,459260,287671,949309,192039,598547,984435,255560,489777,341456,271148,95427,642650,215807)
insert into table_3 values(816488,996365,366528,120165,437559,948971,489573,423294,797844,35694,316459,216382,323169,187729,919328,721455,145364,116677,374241)
insert into table_8 values(247102,145702,927952,996575,108947,461720,924722,499067,792053,465999,985944,177506,504679,582332,991929,771696,912412,345957,266921)
insert into table_9 values(21028,968490,293020,900836,499978,895575,202341,135669,406501,171178,787899,591953,133310,635340,418019,123514,757727,924076,681837)
insert into table_6 values(786969,377533,663238,255536,547041,682872,324131,858467,265973,46256,731454,192798,369121,981931,705327,657261,350815,189539,781320)
insert into table_1 values(634753,778169,953215,195823,433775,529144,503116,554286,358612,275603,256430,699052,569648,494195,275843,815906,107923,350843,239920)
insert into table_3 values(394433,689021,915141,826324,682767,529794,562902,945790,245384,290566,864636,788789,130968,424802,800586,831321,520341,298301,329258)
insert into table_5 values(69114,176009,265513,645516,425884,804837,751682,238674,916845,350325,486257,146174,103618,115322,668163,498485,787315,344044,456749)
insert into table_5 values(421598,637227,934415,724046,872090,611846,857221,450735,974587,179099,138670,114362,314579,487347,672728,268175,628816,954594,388160)
insert into table_4 values(545195,216307,36316,344368,858702,919800,486753,965794,521267,472267,287844,785282,860678,47576,617152,393547,309344,990425,682611)
insert into table_1 values(489122,886342,491041,371222,740933,572368,17867,398945,318650,236407,156492,6625,668830,584985,129851,330468,949566,859972,351821)
insert into table_0 values(531050,276000,335131,847171,636992,419289,98727,758386,425613,964224,737569,684603,567213,89308,768223,251362,114797,693229,18408)
insert into table_8 values(408869,752472,57727,488111,370475,765470,108318,344540,184393,148174,518881,97436,805107,230320,759980,911788,90387,324478,539171)
insert into table_5 values(725525,788529,456247,11545,95223,676567,772230,286482,795800,976732,325942,693597,688828,70740,119273,938612,816916,580275,729030)
insert into table_7 values(305682,627387,728720,372405,755808,566408,324710,935217,855044,373951,770402,767312,92465,37624,276891,147291,88727,253350,346240)
insert into table_6 values(791637,863659,991154,783617,680109,13058,113617,408799,631968,466234,364407,975270,936984,628342,843479,627783,258145,76596,589445)
insert into table_8 values(519256,339139,770344,464941,838068,327985,906692,328629,944214,959493,414793,511287,217132,260098,608922,282948,88967,714478,403540)
insert into table_6 values(267454,893235,11983,716081,150229,615966,943938,889210,936464,953228,876547,576095,861280,10590,428393,602883,509011,361527,43937)
insert into table_2 values(238765,426344,56492,133641,480121,566453,849617,557892,520639,986580,94700,219491,698229,215564,958299,850367,644113,276332,900121)
insert into table_8 values(946412,938185,327887,27120,342071,363250,502400,359685,441056,776473,656670,778743,289601,419396,642851,523605,92586,619967,632445)
insert into table_9 values(494394,288580,751170,857320,679059,873380,483059,704241,528108,143045,140265,383015,926206,602106,899072,88858,113828,295985,21402)
insert into table_6 values(709768,121247,585662,162551,832131,828513,431089,259647,900985,871901,710664,548349,565420,497226,778624,32359,265727,817939,606548)
insert into table_0 values(124787,347004,643764,652302,822863,199474,185109,810530,808202,662555,960332,581458,646720,962196,928105,647483,605507,900534,440322)
insert into table_6 values(176621,842105,730663,243278,966530,114419,465590,965476,245923,335045,326265,313181,881124,497422,845675,452464,617765,838643,721964)
insert into table_1 values(935832,757395,260764,342491,92307,293496,19713,164283,620649,344443,363822,657855,847463,959427,856788,71076,560529,958246,521936)
insert into table_1 values(480555,530004,212578,619182,560930,771479,670718,774399,208186,486745,693542,597155,762563,400442,389379,256908,944491,348893,201380)
insert into table_7 values(542756,604256,657952,949868,924765,40292,151542,361672,220819,378726,256412,603819,438952,94342,852303,112694,136220,855296,572090)
insert into table_7 values(235724,916454,690784,777382,484684,875375,23471,59173,567001,870207,100616,629311,541733,858841,208990,671695,31419,91716,154475)
insert into table_1 values(440098,18258,39647,213256,660822,335454,855347,417021,347687,629160,266939,854929,980000,519412,895700,68705,765624,209295,331734)
insert into table_2 values(940863,177120,826197,53282,877314,352466,457008,340052,456954,253871,821199,699715,865559,971765,930667,430952,396531,210310,84625)
insert into table_3 values(461849,939217,408712,561940,384052,6085,811869,332574,732185,204836,6823,281224,56127,273760,689087,804092,29114,499721,669882)
insert into table_8 values(799856,141463,799785,973290,117567,976867,969313,862108,653994,619970,830086,77534,243540,709406,777616,430430,397683,726574,191757)
insert into table_7 values(796535,297863,335732,788759,607888,791827,617213,11520,276095,59791,791922,874760,914281,823304,159943,375779,462028,190290,935807)
insert into table_8 values(827445,564632,290273,164514,576870,19013,107998,438573,681022,835891,946007,134835,926732,410385,632167,608065,477534,365901,768099)
insert into table_7 values(135516,983724,347544,494669,614444,611345,485303,103896,834387,636146,905364,60858,429860,133201,310264,878994,477002,94490,748310)
insert into table_4 values(585746,96836,487149,527092,133315,790077,349843,237900,717352,843605,223895,188325,844041,197185,243789,254279,638884,967615,13274)
insert into table_7 values(299507,238475,266487,812959,357430,260259,991317,396160,719139,474341,136696,918603,812963,391672,235830,338197,305969,417442,216529)
insert into table_0 values(119290,936394,472066,154022,996597,276562,856698,373552,133780,888591,266042,991439,408970,211427,178845,572803,563709,343371,143505)
insert into table_2 values(697282,20748,290854,396163,325461,841536,212489,770916,554127,997508,557468,16064,64640,970910,974223,197098,178295,603394,760083)
insert into table_0 values(878033,66825,786561,61767,604743,305092,467980,7562,231764,374900,487149,354618,952216,655020,897280,399045,810718,447158,460892)
insert into table_6 values(986535,287422,587065,180517,183520,74699,932281,418356,60128,529089,788878,505509,722523,397104,999018,115725,216059,227528,871045)
insert into table_6 values(616152,799521,895106,389672,391803,655949,719873,871672,715682,377399,546380,785890,923571,823179,956154,694912,838559,469198,12525)
insert into table_8 values(950468,366511,434856,769679,528132,338100,216140,712741,488674,892550,886038,513603,82641,353879,12713,484918,266374,256082,140921)
insert into table_6 values(647310,153358,469370,824435,990850,875504,293229,524750,809051,288902,276424,831422,392910,368593,908228,568786,143356,724460,933701)
insert into table_0 values(533176,686905,822728,420876,779964,561867,759770,618305,464524,825589,417407,532032,359746,70703,743492,252539,828042,256526,22229)
insert into table_5 values(593685,61565,920714,389237,323571,490602,329286,220277,494037,198699,530564,333934,327152,421732,757525,626586,601927,152222,742242)
insert into table_7 values(584479,392488,785923,586708,626510,889044,612030,983006,340106,650596,926582,796055,868683,693407,947914,159085,972706,519833,701671)
insert into table_0 values(646119,839197,375903,355185,409280,439773,745841,886812,55702,537298,17855,852183,978107,5558,417709,885542,969793,411509,443526)
insert into table_7 values(941203,613266,404413,475745,605909,463418,592263,900720,567968,572572,716266,718175,834881,563715,554466,188505,388219,603573,317251)
insert into table_8 values(499631,700797,534196,188906,15429,778485,844817,390770,9254,12690,667968,816010,987821,419578,753919,148993,447965,557679,493896)
insert into table_1 values(608112,612658,443909,228515,474943,119439,926120,171176,25413,427425,737465,221516,120678,395158,832824,817104,225909,607273,950468)
insert into table_9 values(232563,404623,39487,858061,480308,555946,921603,336525,43222,205954,877201,594997,904673,867064,218868,795740,61740,905274,414264)
insert into table_7 values(391157,150659,886895,503792,130591,405523,595821,871684,109902,42837,772543,619324,731173,664323,932115,24879,124117,450458,361963)
insert into table_5 values(955062,644519,432950,742679,727733,991596,230999,920303,631778,818613,313071,277752,405564,197379,537017,359149,288243,135851,861542)
insert into table_9 values(91239,637510,747813,564765,60023,212176,82182,381450,263000,992109,959859,168630,136080,513874,274944,715311,308942,762603,629685)
insert into table_4 values(58943,469642,91031,804259,542208,101204,893120,80937,985346,284705,354170,402600,846245,586692,788672,760025,757609,313137,246394)
insert into table_4 values(43426,381471,762613,564783,357566,968119,503222,734723,760417,759760,446571,64293,208282,756865,572078,294409,109228,530360,952896)
insert into table_1 values(17078,501297,541245,969635,609033,177400,77380,781331,207788,987103,687406,864675,113629,267141,862935,999520,83490,7300,565402)
insert into table_0 values(266016,699916,335849,237102,666854,737563,847803,568535,177466,389420,484444,180222,48426,588547,918512,386126,665071,226658,187898)
insert into table_5 values(16653,949338,545151,754429,597728,822199,177008,227439,605319,41830,649429,576905,351039,218098,842804,800114,742991,250350,517746)
insert into table_4 values(961855,875201,973134,50169,81711,322695,838507,958693,764792,575730,397067,698876,511470,187877,677853,651487,709430,993330,846427)
insert into table_7 values(582797,283824,979319,391564,283960,839975,635790,660698,211582,944402,277992,629808,472316,26827,803508,735337,117288,406455,371161)
insert into table_1 values(294234,290212,204373,104536,137698,86135,27188,475501,747675,363735,737359,602050,405248,734374,483027,803095,567651,940692,91155)
insert into table_4 values(966525,973504,206447,170271,306293,641473,5058,132234,20258,933105,2946,22156,84172,631747,490764,866518,374970,889763,582615)
insert into table_6 values(988195,364916,39610,481224,583531,879739,121298,512462,987220,147638,358807,845169,635857,882066,486666,444021,344225,26006,966801)
insert into table_0 values(393291,679573,697188,361060,516556,206062,229089,255945,906746,997123,90719,855418,885590,9853,308153,446536,356064,104159,968668)
insert into table_5 values(108780,227986,520802,678860,333023,688054,158907,740843,639934,493673,855762,995636,413444,634417,506641,816867,855220,760500,585259)
insert into table_3 values(404588,292070,459810,540302,572220,394985,130867,264216,625422,909580,606390,717202,469421,639018,530781,475582,953674,642843,868946)
insert into table_4 values(455380,76831,133112,698217,270938,409685,395248,154731,755354,804047,652817,708896,505586,484299,660517,683107,484320,390347,916354)
insert into table_8 values(434870,694446,856873,230827,95224,547758,326551,764809,743772,275184,99856,102133,747248,131795,960742,841607,930980,172217,157010)
insert into table_5 values(19007,222586,984095,489608,948642,684276,330800,554567,254818,941491,92163,65817,208421,622503,89943,649990,23030,848559,531136)
insert into table_1 values(752279,513719,64751,702418,389800,700622,677222,663322,61338,529422,803298,621258,792538,137043,677735,22867,90516,754235,605419)
insert into table_0 values(649047,292321,986590,993439,58717,117919,185407,312186,841726,418480,577191,554063,31278,564669,611764,175253,173506,166581,894501)
insert into table_1 values(305615,843348,414703,368367,428930,665489,525637,438419,29762,9419,351383,518438,637000,702275,402864,32665,830478,719489,171906)
insert into table_8 values(119609,506960,552689,5572,626303,744171,221220,397497,316900,62275,911049,333501,621365,517849,997309,454960,444417,327070,550110)
insert into table_9 values(415532,545226,351776,570637,75375,680209,368102,687473,322577,256938,125554,872806,334399,285097,799772,982704,474222,472206,159454)
insert into table_5 values(309592,906604,249598,684496,186590,694695,434754,431870,485352,202143,50070,911986,463091,328634,123819,250843,288459,630975,608400)
insert into table_5 values(952358,273518,881041,642708,199306,282309,623627,120784,427041,115791,881619,770995,541175,792883,282925,338876,233154,504032,876412)
insert into table_6 values(526847,56760,486708,799943,463420,32393,851200,867647,178478,388289,740710,940268,876226,231862,145773,253943,858076,718713,982720)
insert into table_9 values(219583,180686,204908,330166,436553,906235,77705,35381,648999,443808,823775,850351,114163,500283,517017,445092,489702,967384,350118)
insert into table_2 values(193948,307384,892613,889906,930005,242093,34811,130987,887284,140274,192754,818230,51729,226199,705111,911622,759678,697980,1026)
insert into table_3 values(959349,431125,731985,69480,328419,350691,307436,401210,745327,702624,964917,445783,963581,313470,609138,378456,231421,974318,508277)
insert into table_3 values(137398,496892,165411,310382,649351,309286,601862,846729,320472,506379,194786,558030,120369,782107,823183,834373,16322,283419,304619)
insert into table_2 values(455626,662708,239662,872197,406438,132757,551194,96860,362829,176643,369991,674286,880286,916335,550288,123994,296269,895171,405404)
insert into table_8 values(932768,812876,156969,94864,999744,238435,119085,851307,48287,419340,733515,116563,671833,15060,215169,829547,25710,612007,946016)
insert into table_7 values(492429,683845,944696,895870,383070,796155,814479,585730,292652,781092,20553,410566,288830,415631,776313,774265,801094,361114,70015)
insert into table_4 values(191733,942300,110198,535891,762240,704787,216062,901118,48882,767158,991099,135003,431726,856969,952917,336768,497840,845018,781525)
insert into table_7 values(239264,592534,568217,579694,539046,148096,134607,985450,602181,741215,902184,807204,564644,61116,376968,484342,134729,48156,106122)
insert into table_0 values(865236,923737,569016,768968,470911,78566,77484,437916,684041,542031,927166,272917,229874,287861,954490,550453,447405,423260,39692)
insert into table_8 values(832560,116114,424718,512906,107977,227328,324413,778989,731067,650477,606756,79430,881482,28804,417453,365965,353298,486358,490755)
insert into table_6 values(283133,910036,571807,414722,357090,177844,405137,892057,251942,494850,987734,169471,226771,80490,550519,120602,209751,82809,143839)
insert into table_2 values(160094,736058,126768,874433,968274,683997,989529,196623,768691,118600,484584,4623,919890,869888,342318,582451,258740,867451,209409)
insert into table_5 values(72015,756594,999023,235480,538128,518102,634914,738516,854016,470468,417276,391179,475947,115611,268738,425121,685775,567633,195348)
insert into table_7 values(729320,644697,364890,374546,189814,251184,47068,205310,601604,864039,769203,523137,394407,787163,119858,460101,357060,85778,908521)
insert into table_8 values(79607,956786,70949,17304,102539,568279,413546,975251,876571,77626,274221,540916,89400,60336,225382,912400,540237,89476,546312)
insert into table_7 values(203099,849352,433222,559963,343508,776321,799244,437980,974901,943550,344624,514809,325063,292898,773663,631526,314221,296698,208229)
insert into table_4 values(16518,161871,946851,34996,798351,147874,356443,795101,599428,588910,298736,578525,703669,396157,494971,623221,664621,288052,477554)
insert into table_5 values(200401,500178,235080,155019,623195,385814,672334,411395,529129,953070,498997,30688,705532,207770,591023,304441,257246,93583,208395)
insert into table_2 values(813747,781353,254088,954971,278791,674467,620023,707855,362500,505735,702533,237678,312629,233520,770855,826510,836147,223151,837728)
insert into table_8 values(654133,89181,730992,197304,523503,64202,751825,892677,339024,833373,438273,766206,643386,571211,19192,12001,737294,220422,890525)
insert into table_9 values(946253,275371,139449,509319,10258,617324,918180,27753,241870,872488,458515,143785,72362,574142,61779,144971,779081,529087,48611)
insert into table_3 values(417232,21025,482697,806380,546603,170776,802631,13941,713887,190511,587052,868981,215184,781458,772089,289693,80528,70670,712410)
insert into table_1 values(714483,180712,883802,535666,664872,659683,909537,147660,34011,599268,542889,416427,997037,963601,28287,683541,260209,900946,836185)
insert into table_4 values(354200,733171,361020,62539,949263,399511,91745,483367,749961,519062,183644,23582,872259,650110,287458,259866,312630,279816,718601)
insert into table_6 values(168160,782094,665577,65897,747589,752455,601263,297968,822055,757629,322835,598927,188157,892026,347336,147759,978834,242990,793540)
insert into table_7 values(203516,235108,520614,868676,74281,848818,717984,156160,719389,16917,192652,203580,218638,907036,816273,408119,72655,640202,993647)
insert into table_3 values(699860,750496,810669,376902,348856,482074,253834,515184,12957,565840,713887,220878,76695,8539,921686,510226,885265,779201,674186)
insert into table_8 values(29139,647622,59287,584755,484297,605941,843625,609099,929543,374041,265464,14626,158896,912508,988059,732438,918580,24391,94739)
insert into table_0 values(632067,51803,719928,485093,649215,779529,162456,707029,611943,870052,911116,978553,625664,481831,49178,824806,474053,444506,240624)
insert into table_2 values(469673,334663,652701,365880,871713,583798,160069,513446,75451,410620,797808,798946,111950,304623,113317,497831,365485,499037,697468)
insert into table_2 values(829230,815700,828901,32549,59185,391303,378960,778439,543625,692748,200747,337843,422998,998234,746519,791102,52782,194222,205528)
insert into table_8 values(467680,41215,501294,178786,830715,220771,742705,161534,113176,898988,376907,691169,210578,407107,970547,992490,164718,577678,355927)
insert into table_6 values(145042,942475,416036,859301,570071,863028,912887,21642,804148,156357,193842,31905,805959,120092,385290,973028,33842,819061,879194)
insert into table_0 values(980016,192670,34150,659241,294303,502382,729736,551805,261342,527229,782984,10658,258847,248856,657429,207823,45899,384157,447020)
insert into table_6 values(864587,748016,122931,184251,637862,115964,839513,888144,882747,425948,724155,971954,500575,726119,157559,688527,705006,102384,965500)
insert into table_6 values(313484,882490,196900,315210,545876,4768,608516,495447,516550,318446,391156,278626,24321,206218,267692,724549,190307,558174,40438)
insert into table_9 values(310545,57733,937996,959319,376091,324606,485677,423195,809129,216408,146899,844904,459316,478441,73869,289749,833418,304147,95986)
insert into table_8 values(553554,558728,298903,708567,124945,67558,199258,962793,619386,899311,93234,879459,152870,764585,830992,93504,361629,934089,441482)
insert into table_2 values(331180,421389,49717,780337,230485,582892,52465,523155,938336,361185,985076,167369,873390,348146,56326,364050,495908,314859,285401)
insert into table_9 values(310635,744821,438397,80392,214765,456595,515836,903027,732011,110740,725024,698069,191918,70945,101585,391058,846548,112289,30129)
insert into table_9 values(524245,701198,398332,802638,305022,147862,896427,815235,671853,73695,144837,575987,936730,771413,963391,6493,582187,600366,31015)
insert into table_4 values(778962,674961,743019,162869,565731,443110,293219,858406,650637,254995,157341,483306,797487,976682,677290,957638,471240,572184,295407)
insert into table_8 values(196536,126331,257901,160435,961927,127412,939828,39120,559252,70274,654796,128374,202499,165998,136781,690875,371380,173093,471366)
insert into table_0 values(56800,633697,532898,78762,746755,13035,892196,46937,908126,952444,448358,476162,319953,104037,618751,786467,91476,783112,314797)
insert into table_5 values(338675,418000,449035,176489,753792,34553,568596,874305,881824,904061,865317,673739,42837,680226,672862,75328,413369,503369,135424)
insert into table_0 values(750331,188731,194190,478993,957402,529171,98894,631473,390376,548973,335690,657069,823891,463990,825180,549994,286253,450975,637304)
insert into table_3 values(464045,553522,94199,581036,530754,936727,855007,71842,667123,47258,743440,658547,509394,731737,158186,113425,661916,624834,748234)
insert into table_9 values(116158,407943,309004,740837,727192,512962,731184,658856,334488,597200,376510,683528,615755,790467,884948,855982,966361,241862,655820)
insert into table_1 values(386988,823288,233178,709348,830584,658480,614992,234197,916100,954692,693909,854923,787199,651395,618382,621437,266548,680462,325051)
insert into table_5 values(555632,813971,127782,953112,702784,175360,389494,674718,567014,285780,964960,343143,578487,884901,625570,571890,399757,886004,315107)
insert into table_4 values(626457,327404,740812,168268,126301,515483,966475,832061,564983,645970,865623,225692,919178,613734,134459,749356,411815,740355,895552)
insert into table_3 values(223893,637483,789838,509977,877138,189644,300634,757039,212349,464093,439569,660331,883966,912430,876693,183120,473251,187781,991298)
insert into table_4 values(816185,177036,83240,25608,26225,111176,470639,635539,42874,816403,890109,496231,254292,715140,474157,987678,653611,215294,215081)
insert into table_0 values(964617,507982,989231,842928,487922,568913,696378,132617,406652,969668,549696,845269,466956,48278,146907,818105,535794,584633,419218)
insert into table_4 values(516002,720464,879292,117432,727848,645139,404309,511553,288076,682558,686223,667202,285088,907738,414774,54668,905792,372675,713452)
insert into table_3 values(239847,620195,951106,539173,61770,887256,138250,939619,738833,43404,929339,321375,964448,160442,427298,131933,943514,560358,330385)
insert into table_0 values(851471,132227,175813,924949,711900,302215,756333,291087,270552,733509,710824,250437,114448,365794,234909,560760,270573,829965,377027)
insert into table_6 values(332493,831236,646154,832051,391530,31208,598745,126957,545150,334534,728936,1232,552598,711394,563725,672549,276433,861784,292720)
insert into table_8 values(471076,2989,906428,745592,801183,209665,365263,817496,685510,150977,982759,530526,807044,844078,734825,23444,600315,838191,60455)
insert into table_4 values(930962,851095,667911,699569,908424,470998,735071,821666,5945,680307,859700,148288,449078,1147,278454,619603,442414,338507,803293)
insert into table_5 values(961311,310059,442402,631014,30622,312314,991914,776769,907981,233134,994235,69196,117282,568787,610650,31976,683402,759553,961711)
insert into table_5 values(691005,245985,38561,756191,555338,731799,256942,255926,326493,967746,35482,29739,822644,399149,510219,162380,293317,13435,493956)
insert into table_5 values(619569,159249,990122,688581,678738,674989,213731,336272,24212,308785,245514,783709,187718,279958,674689,692208,168232,63793,800725)
insert into table_8 values(246137,610423,694328,763870,239316,754442,108100,859780,46208,604558,182046,758608,911994,162994,362444,171048,691393,563625,956104)
insert into table_7 values(167439,514662,881204,357069,857874,833098,569190,766533,897566,634095,668091,96114,493631,759966,208072,787931,703062,382684,73903)
insert into table_4 values(386149,249928,721863,438075,791774,551799,803034,16609,891712,184789,485778,749435,680138,504063,620818,590577,321592,971389,151935)
insert into table_8 values(892619,833679,447417,43157,944089,894462,509322,967390,161464,160618,845836,906152,436865,926586,145590,346273,879818,568604,165819)
insert into table_0 values(819075,109342,470159,245695,168409,928765,264510,294492,76012,875726,554266,937571,995591,495748,424095,265961,894428,985011,916052)
insert into table_8 values(714960,178380,994909,192170,26853,297832,463656,649389,207417,315238,966878,258514,552555,672326,677300,64996,876565,71852,594213)
insert into table_2 values(508091,791484,799617,507148,660548,687377,86033,81296,248948,649793,130596,560617,605865,895113,997300,56452,265594,888835,166946)
insert into table_9 values(164672,748299,404945,264231,839823,885390,698741,907998,989236,484038,668189,517961,538014,304150,6819,49318,756110,137851,207648)
insert into table_9 values(224799,984212,885147,243155,855885,361880,922102,634539,216662,53162,799794,883655,655419,125206,340583,883737,813752,87656,408143)
insert into table_5 values(535034,379484,460990,276133,947528,560039,607456,467204,835211,30787,246924,866455,24649,557044,469252,253372,956224,911325,984414)
insert into table_2 values(176790,46618,195679,595523,200459,35683,651568,363844,277334,682531,452311,992259,919970,274434,414928,369183,594326,231812,611598)
insert into table_4 values(15082,575443,387316,137373,531540,420934,56782,302406,818208,147436,928860,964064,816664,539215,102579,823391,161514,936243,328481)
insert into table_1 values(644052,354189,111843,899222,57911,759280,643701,243232,64953,643838,600666,979647,489959,964060,623088,838729,633288,141968,244527)
insert into table_8 values(718543,817650,596338,472469,67463,412664,665530,701122,874627,679332,394430,133112,656935,419137,32902,536343,759907,520624,787532)
insert into table_0 values(240220,156432,667409,610139,698317,187280,778736,525296,915424,698689,824296,55082,857308,940502,590584,400697,600473,910750,405818)
insert into table_0 values(72893,465981,697873,359178,754009,117250,851485,33653,985404,45082,652248,779235,29225,367336,426711,613332,967995,690402,916887)
insert into table_9 values(789664,45336,808001,897226,25072,210943,824645,739582,116983,758080,518141,276796,680311,840639,466569,928598,68452,601260,509086)
insert into table_3 values(93836,359249,797740,14550,257557,198079,979714,651544,27217,930826,990809,61762,694977,548846,374738,835026,372565,890559,894818)
insert into table_0 values(470547,981601,627289,316804,4643,955338,748729,382197,932580,439784,731230,6401,365390,103436,297451,319639,84371,322900,86788)
insert into table_5 values(921776,942724,408725,875185,962013,983986,866275,631244,690410,20011,394679,232291,56324,463172,396001,957049,659037,552763,244883)
insert into table_7 values(925634,268092,877825,675189,100625,562215,47588,499014,931394,761343,529537,712215,272002,257790,522328,410810,587801,640335,882692)
insert into table_3 values(189350,79242,568061,739526,953952,637935,662870,742908,359,230656,563612,183813,611313,426841,637554,736664,475568,163858,520277)
insert into table_4 values(144600,42846,818028,714965,396508,501756,169923,610117,127229,948811,845590,116098,16344,683640,991137,587769,887399,868851,364635)
insert into table_2 values(250294,259869,455438,867694,167668,650596,280320,448747,761316,691840,121776,347408,505841,270749,364817,811444,891115,691214,642149)
insert into table_3 values(812624,75607,183251,985272,505635,275848,684213,129366,956177,968184,866374,526726,583908,790203,123100,204073,530787,427618,285230)
insert into table_3 values(220794,595394,895103,916843,725170,966691,461993,481593,716158,245451,790833,371564,126749,798596,822922,450677,266163,574252,331637)
insert into table_5 values(269146,874106,176611,163285,904289,35016,729810,331893,553992,78611,463817,757697,781311,296643,38647,762720,977771,136961,336399)
insert into table_3 values(602835,101009,501000,722956,846005,249229,351923,47015,259155,824619,821894,658146,54446,587797,541293,726116,387111,342437,628137)
insert into table_0 values(344135,939232,776506,839100,544624,470180,538094,484473,837555,620529,809987,577024,179904,51926,732485,760040,72217,394159,833135)
insert into table_3 values(359033,485932,182820,890160,624700,890149,7651,652341,732275,246919,460866,953720,522420,547821,796070,358937,477037,975491,259192)
insert into table_3 values(674047,196926,333329,315835,754027,74154,377206,165644,102013,111014,684863,151578,492403,910251,191113,426310,294455,70792,571128)
insert into table_0 values(940083,878335,605531,194955,777854,988028,208105,793851,275468,225150,543907,802042,474581,397695,60207,976971,809963,570906,416265)
insert into table_7 values(993769,145486,226002,787425,678922,332110,488912,180414,825869,686195,988979,436716,998705,427301,709993,920973,456852,939353,919993)
insert into table_4 values(76216,812001,806103,747108,266850,72386,163594,449258,406598,375651,583807,454145,755215,117999,625738,763276,492243,389127,710159)
insert into table_2 values(250872,187169,31536,158871,35656,240155,753136,455114,203817,575278,360418,996275,227948,65614,449871,957218,630583,929834,282692)
insert into table_5 values(879462,719170,767312,706557,113820,173948,423204,622863,689563,869038,655003,809769,818798,776838,244619,133886,927692,751917,615213)
insert into table_7 values(413768,714765,845526,828927,385436,172152,196980,933024,305133,344019,221929,795520,98236,650105,283159,906495,3476,386475,762429)
insert into table_8 values(520683,188052,926560,196855,205984,384151,254634,751670,243889,559296,259637,51502,232092,802170,105898,903005,984072,129057,949989)
insert into table_9 values(809162,11081,205260,752003,567047,686804,286525,21095,793692,217562,916534,371517,308982,231526,150735,702489,538118,708874,878041)
insert into table_6 values(967502,804969,602737,22299,484231,7043,914179,532351,541343,90287,247119,304796,788796,958094,85413,742244,262165,727347,541483)
insert into table_3 values(657084,735383,737657,932908,824417,271553,53210,569109,986251,74583,816774,198265,526780,643055,284221,977696,613589,75214,927021)
insert into table_0 values(21347,378058,527642,623832,995307,900064,898783,341402,681314,46267,763849,964886,273150,667822,519974,472784,435026,516261,38776)
insert into table_1 values(850918,220782,579837,845973,596073,137174,289936,133282,805798,454392,894368,569086,352756,644038,931119,146344,286996,512733,684649)
insert into table_2 values(666293,829901,64106,705012,860143,211191,953597,912231,369545,224290,552413,256877,809293,934971,711193,825221,517607,944709,662111)
insert into table_1 values(199737,171261,477682,256237,986906,428439,789373,241281,567545,463397,656097,766382,590895,773649,442089,813030,852161,992060,223123)
insert into table_3 values(622406,81568,439797,105745,562624,21047,574039,626828,431242,843356,920077,953092,543023,217596,430343,749199,116964,903140,803888)
insert into table_6 values(742708,450115,765335,184350,251392,302981,211417,796654,891407,508327,478865,696701,98011,354847,148879,610151,796863,918594,765114)
insert into table_0 values(51888,525863,131772,419686,864816,237336,266902,152898,115720,119348,102002,525803,221056,269236,8357,105603,639435,448047,689959)
insert into table_9 values(232562,338377,51615,315002,887444,739135,60613,765233,193033,475773,515308,420310,287793,600130,29986,254983,2876,416459,451849)
insert into table_6 values(313144,970461,428025,868959,753764,545210,477918,544365,185789,979168,896679,695208,603967,654698,79828,586954,783658,592636,681594)
insert into table_9 values(949857,798545,251430,919297,933303,913627,705029,657036,28605,997467,484734,628399,479023,958671,373447,643827,289305,392759,429574)
insert into table_7 values(104529,863109,865451,487836,338362,450151,831310,759521,51168,439908,925277,902813,312438,373827,717865,532282,16344,352396,267393)
insert into table_3 values(64048,406308,19456,884646,950822,304568,113389,733351,320564,547084,900591,523349,576345,657434,431551,408071,63875,459287,344497)
insert into table_0 values(747783,868364,11172,157780,953902,700416,381546,404081,796651,437253,232186,394322,455534,841915,102724,30812,351058,883091,117467)
insert into table_7 values(530341,948958,346903,372027,364626,226998,468882,528317,69976,770726,223458,427034,513162,368132,514075,853774,433394,770709,261178)
insert into table_6 values(479062,937394,854316,379274,732913,42881,48731,928463,817454,765167,156997,211373,183014,988886,962683,49109,524273,919820,242629)
insert into table_4 values(814894,700092,287392,794896,673635,392707,201308,461561,499312,670221,201311,530196,256492,951759,449184,455285,463968,775404,679386)
insert into table_6 values(851655,89544,860930,976569,517766,465212,42652,603148,609797,794983,534636,842172,201147,753814,463100,235454,292830,670949,384912)
insert into table_2 values(777735,929432,441867,113666,800366,44365,419300,901547,759931,267950,21824,623934,568657,825162,43005,392488,594629,516776,870307)
insert into table_5 values(131606,241364,697166,510974,237250,699841,497181,727533,787871,716191,864655,923331,3804,12854,630723,140184,915085,459108,613806)
insert into table_6 values(672077,722282,775205,497713,975842,448366,320643,441809,481292,95835,698072,418551,625209,832870,108262,793235,818281,447932,985303)
insert into table_0 values(700255,683508,574338,312420,328720,216504,589250,663442,362283,625665,707045,652183,85983,43247,21079,940602,259737,588531,806204)
insert into table_2 values(359638,748090,543760,632987,676144,258815,185028,236971,186667,406962,431541,457342,586451,102643,623363,758688,290502,144869,101584)
insert into table_4 values(806525,234641,458154,77797,21225,977539,790374,445745,424612,558693,902438,594817,559075,269973,207927,975180,258225,800805,137053)
insert into table_3 values(272732,9961,740613,364822,46691,840600,23215,771403,149547,892467,815696,933864,444447,668704,527449,963107,347325,485760,204865)
insert into table_3 values(361771,502036,245378,348100,14698,658160,882949,196271,313580,166727,345284,801500,346644,116283,586398,512050,208110,618054,539246)
insert into table_3 values(497392,214074,488610,151624,691506,198559,912586,457165,209079,257520,769860,673768,90040,400180,13575,893008,977590,956078,205727)
insert into table_9 values(34205,44224,830273,231866,59795,391563,217306,914184,459614,964376,75418,975708,651507,248479,74998,503204,909788,251697,886267)
insert into table_3 values(430060,587997,949512,435768,419139,309907,177141,797450,129931,788278,223240,750242,193980,224091,702618,758079,887969,643512,489398)
insert into table_9 values(929128,862239,678122,42876,95221,874499,66430,508485,503954,564920,776310,341604,34951,641183,683767,765816,887686,385642,390092)
insert into table_7 values(778966,852187,447043,154587,957599,986192,692559,367248,977801,999555,587919,973107,635480,109696,402461,143470,501442,70412,72151)
insert into table_2 values(411284,845554,625423,433580,135916,275896,366711,435426,67636,493923,922748,121582,920663,239770,37516,823392,792562,806966,34683)
insert into table_7 values(953124,680569,951815,476857,569192,525521,389585,86212,769204,750421,287614,702699,543816,468522,115998,645999,183900,2709,21858)
insert into table_0 values(226846,308089,699440,620289,170081,523841,16090,527814,797318,134956,740058,9461,422051,484198,298104,630393,152561,652665,646754)
insert into table_3 values(965254,202541,441934,283216,772913,142217,709373,509657,622301,919152,834629,784711,741479,470514,776788,802409,43801,691742,425642)
insert into table_4 values(950197,96058,1759,956780,521736,961554,114770,826629,100435,20475,183219,801087,888117,361225,866166,92139,439008,175843,960774)
insert into table_5 values(536865,294969,354449,968237,113169,28685,823758,114465,979557,425938,163639,727190,732661,266885,328641,233759,961022,2133,271566)
insert into table_3 values(753886,643094,26141,726425,381587,922835,13244,825547,460602,525112,996558,20000,545930,870647,706894,69699,569198,657017,841519)
insert into table_0 values(80948,887101,183649,413229,921713,869665,457046,379332,801876,272312,530301,203739,670525,128453,680881,136933,979263,525567,811351)
insert into table_5 values(40245,28109,751615,126024,15552,915181,524247,225098,281046,475468,679376,648671,769693,831117,504018,567458,460521,90581,290651)
insert into table_9 values(776615,253253,711672,539019,99342,238524,348181,515474,198162,560956,8891,985548,959509,755096,317818,418255,639091,809305,291584)
insert into table_8 values(197937,76059,232127,605260,660766,135074,6961,130477,701410,449285,240317,795362,948070,567989,910339,135294,393274,956134,474694)
insert into table_0 values(284249,149610,720010,9807,979085,12507,160935,23664,321098,191892,653116,655991,975246,573658,898343,254534,775157,604692,703673)
insert into table_0 values(619405,282519,936624,612921,545738,570071,316829,995872,103905,216845,262854,16945,936884,236877,224798,386829,983840,946697,182570)
insert into table_0 values(581936,491472,628705,328270,925879,434858,877782,821440,60300,840963,101863,65690,666089,114094,542949,787601,403945,199100,704189)
insert into table_7 values(996388,327147,950988,989817,227044,139478,601613,613637,566734,743687,532511,275234,79339,219207,392411,487063,885776,56250,691441)
insert into table_6 values(720950,24390,218037,773350,684093,519663,583074,315031,397450,660275,171254,116164,730627,344076,181480,819192,742349,50016,798104)
insert into table_8 values(254382,960763,205212,285853,427784,92653,107490,640492,82860,964617,675574,28890,643756,5080,150930,780064,712690,630664,150243)
insert into table_2 values(89908,828074,576026,888736,910500,829699,938732,653750,114881,30122,951190,183185,928241,638878,629788,269421,492427,478022,104966)
insert into table_6 values(68468,342865,476584,923579,123432,278773,304816,269625,983445,58486,247769,955762,674754,23579,288225,467604,213902,743335,856114)
insert into table_6 values(442088,817551,141228,502704,122539,710098,732742,653918,227779,943590,773460,543208,625437,401404,498675,277950,710984,567776,860724)
insert into table_1 values(48979,998798,758778,366566,187959,963209,81060,824501,318242,368181,115629,417065,790494,584063,807443,672139,854309,867456,503044)
insert into table_0 values(404284,395175,678843,175666,758875,244738,322391,190210,913952,913209,153834,619804,101898,654161,807424,32359,199616,213971,609179)
insert into table_2 values(322758,987547,138185,938217,809576,479615,25720,317660,580140,979833,878566,641213,416012,507514,250689,373994,239119,66718,432553)
insert into table_2 values(603456,858975,127428,794482,102325,224098,352487,580083,404196,118979,654263,667326,324665,831520,961783,171226,370332,440473,64327)
insert into table_7 values(956933,716731,454237,128373,937011,75080,636874,856209,674125,732638,780094,320989,172630,949441,600921,203726,77795,460183,338032)
insert into table_1 values(416766,473463,497093,804866,655764,35131,275353,159743,605171,336712,875040,791552,240499,274724,257994,238629,886645,239703,438390)
insert into table_2 values(469679,49333,382495,801612,335875,892321,42890,689718,86868,22326,949175,50905,238243,763235,579968,875640,588605,142820,348846)
insert into table_3 values(236643,363803,498701,182840,24231,818848,9361,700123,446570,647675,667409,302995,273794,585727,220494,163692,190552,659982,787301)
insert into table_5 values(334691,835861,142353,169962,640061,430083,699195,633334,165979,711528,153823,538949,840517,212103,361893,796720,589515,578006,244297)
insert into table_0 values(735653,823044,162700,665912,852299,373024,119043,973424,436684,524489,84626,938994,992726,225293,889815,659228,157573,195928,274239)
insert into table_4 values(802881,455192,760963,578068,506533,595046,546488,303946,160381,89524,795768,484963,827585,776594,611154,270265,59999,630221,129031)
insert into table_6 values(184264,319113,303514,893577,815466,563826,514081,540735,666441,466575,805776,534752,399519,169252,276621,971687,269041,663462,643850)
insert into table_5 values(316146,794075,775673,182090,116451,96133,572669,312722,523663,451072,342246,916544,587912,806395,375307,208941,68261,376616,924293)
insert into table_8 values(593588,951642,674132,553703,196489,18162,853350,283394,572233,34135,196012,898727,83504,545399,31584,879122,614160,513772,785517)
insert into table_4 values(374101,161188,702404,932508,52971,970529,823744,41303,126639,645371,136481,477513,418655,508668,305471,639171,924135,701516,336761)
insert into table_2 values(290387,631473,871779,897721,550913,694299,91308,896416,208888,196867,441439,140719,894635,871331,802478,182975,599627,801555,379277)
insert into table_3 values(253914,102524,847804,128182,353350,598112,383470,365306,941339,57634,322103,993779,822170,965293,962524,93731,39003,693500,25183)
insert into table_5 values(334585,353872,907224,914976,15962,986152,527656,364603,522556,751103,117078,110450,875815,119850,598205,745027,661681,903162,692426)
insert into table_6 values(65240,39133,591146,634412,985516,259490,775272,568592,277546,425075,580209,585940,872592,54256,395938,254156,560443,945510,242959)
insert into table_7 values(189031,173264,639168,374512,820537,592609,277056,97814,387420,762861,243100,376340,623852,864990,376256,168739,262925,284615,350325)
insert into table_6 values(818160,68081,810802,683689,620226,466217,961998,532230,97355,551044,170702,183399,257247,583058,132694,984209,131523,60755,394140)
insert into table_3 values(536393,526800,289748,510238,216248,832160,157522,119002,738971,515527,627288,59570,693141,794585,100718,848106,400391,554937,730432)
insert into table_9 values(868630,221523,860118,132253,208924,252536,4638,247975,197482,180830,302359,429514,596054,197442,277742,551827,127430,307777,983095)
insert into table_4 values(433709,847746,915533,816956,854650,639274,565172,648032,244087,861354,362883,694985,644550,575830,147829,589323,584449,196082,476809)
insert into table_2 values(387094,542400,586401,935063,777256,489199,306349,668691,121455,171771,302405,815901,334338,329543,786673,407255,187290,191500,506199)
insert into table_6 values(111283,570028,21685,304872,99801,898692,427174,671862,386442,340315,226315,992071,981355,911129,274421,60621,768028,757812,243383)
insert into table_0 values(80452,188358,529541,306098,903191,546819,650147,845223,632962,39308,869366,127169,998159,361287,430575,655695,957449,844443,338322)
insert into table_9 values(63623,548768,550025,853826,675744,703654,238755,461293,85233,337058,483770,810605,156519,880619,212397,103477,923832,93999,490569)
insert into table_0 values(451152,876128,344907,326325,468907,912512,244513,272195,679219,305616,879434,994921,556779,680514,315804,242903,783862,579289,900252)
insert into table_6 values(112313,937576,616457,536855,492643,728950,187567,835693,956514,727137,376285,152110,986466,721235,69800,519360,270233,130522,982149)
insert into table_9 values(442273,79150,177649,120653,874635,780118,87895,68303,33388,193616,316139,371531,413270,428471,844799,950264,974758,745363,10306)
insert into table_6 values(793495,736771,942549,241166,745159,968262,823694,799468,357188,348537,954599,611384,891674,79241,588402,795874,481239,421969,8910)
insert into table_6 values(335244,59654,623170,848302,359657,358153,529321,776868,146026,864637,436303,113454,965803,157984,224878,782993,428866,528279,508364)
insert into table_9 values(608439,654966,705654,560455,858017,634184,73046,371942,354994,623753,584954,178932,28141,267535,84173,972667,473765,66651,641008)
insert into table_4 values(447849,606666,436899,538701,217853,160200,510023,418169,724895,280664,920761,1714,285712,214134,943917,517155,588997,458060,264011)
insert into table_3 values(498294,888324,60947,896977,400318,425891,779646,682288,740180,321521,9361,193435,182895,204913,1022,484513,576535,380149,323029)
insert into table_6 values(793343,133186,988714,847306,107168,405619,532346,985461,759311,707223,165160,380012,94048,470103,574441,465265,425401,612315,298337)
insert into table_2 values(2187,859010,424453,94641,57301,889217,773954,131628,153124,957623,293578,595163,247485,252911,951433,279694,803695,144752,344797)
insert into table_2 values(384399,888391,66416,163107,396174,160971,957563,90295,121363,847111,621299,795167,313980,639575,756594,536415,507845,330472,819248)
insert into table_3 values(903415,235362,413574,147931,405344,51510,558296,952141,383159,647760,923807,974073,62752,915909,406746,781257,826663,672175,390942)
insert into table_7 values(285348,79112,228712,95028,425146,952002,607188,518835,264182,10026,400041,409683,30270,513748,166470,840523,177904,466262,918910)
insert into table_7 values(304207,803684,568772,365295,573344,59271,173920,45292,89754,3612,483907,227330,329458,861995,295143,276552,43954,534089,495996)
insert into table_9 values(216861,400974,94664,615943,899429,291600,213345,56955,413465,746126,908516,787232,334315,56928,923494,362936,781463,775312,478622)
insert into table_2 values(470676,717104,473232,175464,266799,788075,901437,665122,60868,661223,822759,49101,91164,996519,61369,28526,431624,701231,769794)
insert into table_3 values(302486,393283,430459,391866,549312,784430,260828,179148,516566,447768,211326,630409,377484,842167,350793,367858,348875,970649,808089)
insert into table_3 values(823769,428035,855383,113125,247411,879069,25398,151872,824161,1346,15291,128064,239618,433219,86919,109393,672617,926829,14965)
insert into table_7 values(595911,748400,634540,928226,106331,145856,221693,396275,90789,889256,891452,724410,327238,179596,530326,464847,963906,554176,970714)
insert into table_7 values(761963,115344,384842,679467,536644,67522,152987,176497,523289,250233,142920,970622,419295,125954,17715,649066,170359,639040,586276)
insert into table_0 values(901340,930033,313024,450465,370339,518337,271838,734662,273261,952114,949823,378790,96636,984514,760362,740468,610971,352477,823716)
insert into table_6 values(806425,492427,735524,418332,773759,305956,67174,125500,397510,577238,687729,388565,428365,807353,206953,831162,293661,680666,195541)
insert into table_1 values(959975,842067,449272,829617,633276,980838,692273,469794,285276,422943,507835,210375,140135,206022,387973,869478,291418,760529,866883)
insert into table_2 values(273098,774864,691231,91483,38251,300619,597685,311324,380318,231850,157838,267169,572077,804761,254831,480967,21488,727793,130215)
insert into table_8 values(537760,266517,261609,472029,842553,114008,623913,384730,304013,644096,925447,425340,809843,222635,880452,232542,938730,75926,584976)
insert into table_3 values(891582,424039,552395,454015,884296,196747,430882,352263,19610,433646,50702,525437,863634,667320,463755,453226,316399,410889,473323)
insert into table_3 values(638900,262683,74948,586201,466037,65049,391180,45609,462562,457829,452806,397291,426027,68752,826168,31999,262968,30727,836248)
insert into table_7 values(266004,302473,489770,99320,261418,362246,603196,843776,194974,659328,507065,772227,53616,785768,177852,26441,665,109859,705342)
insert into table_9 values(62905,693774,269395,973443,851719,393762,610673,960749,267911,713321,188589,46125,595190,813216,635963,179514,533693,589183,835563)
insert into table_1 values(635748,463580,46832,432481,454585,844166,316654,492649,387846,536093,824873,435388,748152,160530,384188,190702,180214,448597,800067)
insert into table_8 values(644878,527191,963891,788972,359037,659265,508209,523874,184040,571825,937322,527097,908451,870455,601148,979486,330864,693460,500563)
insert into table_3 values(918894,450296,322296,269681,395387,870520,411059,383650,411836,581516,489376,311036,718954,257116,505660,950613,386713,1258,19807)
insert into table_1 values(807299,439453,972923,856049,929866,840714,166181,824671,527344,286764,872830,767472,385862,696832,720133,363640,5247,61164,952286)
insert into table_9 values(984923,40694,951189,256179,372661,191160,51399,679845,247420,752106,377177,749634,937723,545678,284578,801677,625416,464843,462923)
insert into table_3 values(806204,102240,952644,889271,121842,521862,745967,879905,872036,334226,898418,233831,692414,843807,932007,169534,667982,397997,262927)
insert into table_7 values(27448,228232,529503,938212,547495,721030,3806,795961,487592,336564,19597,183459,884659,600917,246760,439851,292720,724679,43600)
insert into table_6 values(396348,881844,202121,697901,81474,226147,766776,156214,622264,606924,417522,245449,931927,242933,169203,386964,813339,407095,340182)
insert into table_8 values(266660,542792,350406,838362,308575,667681,512066,971870,109838,375960,242524,82651,922811,868063,217742,830819,127600,408281,497240)
insert into table_2 values(430543,216487,465274,258684,817668,158300,758641,727601,738835,875317,304951,896733,292332,293154,155176,397429,687353,400791,12331)
insert into table_5 values(863259,828713,322733,830771,741555,935500,212515,454148,367059,203186,713944,190996,201127,193462,955769,822316,247283,575565,356294)
insert into table_9 values(551727,634390,184164,832519,763409,394462,919490,451414,440066,307431,600011,325795,92359,258600,600545,863282,64336,839043,482471)
insert into table_5 values(640853,649228,337920,516823,381625,189620,799640,571658,126369,154799,886717,278804,22426,543050,874907,281085,47361,499327,235146)
insert into table_4 values(788540,429148,506046,664707,104179,217072,509981,31886,282070,298092,473002,864129,809603,61541,752127,764370,444317,10153,326574)
insert into table_3 values(573461,329435,809242,264667,449366,10231,65986,495978,860533,855345,929951,854337,794876,34539,413374,703440,19113,745329,569760)
insert into table_1 values(221412,375337,313695,466613,614326,795797,808527,395925,314015,643162,690011,961512,295776,878258,116288,845521,731183,675255,947647)
insert into table_9 values(817302,354910,119906,730582,83893,775306,552114,879168,971822,605188,171550,371769,206641,638347,329826,252519,238493,737939,148182)
insert into table_9 values(484282,813039,579447,90860,266366,152644,238288,849611,667477,131227,142209,901620,6930,119557,769533,908839,492020,25638,103221)
insert into table_0 values(723642,860088,385,711048,244897,491627,319400,177807,152830,609958,21018,804608,35437,439690,107145,245242,222335,665853,348142)
insert into table_9 values(404774,669656,133294,613426,344991,866311,422770,984316,55504,98644,129624,260309,941651,993527,708346,593178,372152,622437,380709)
insert into table_9 values(54128,593423,540876,517778,317574,519390,426230,966166,447602,108695,878380,465868,548829,144519,798200,791796,731458,132930,472568)
insert into table_3 values(231133,81423,55893,978420,586948,122771,594915,628331,767043,781825,987662,117369,829042,477232,633727,261530,106775,932540,16815)
insert into table_2 values(941797,899753,89796,787752,782134,723006,530668,771430,902363,326169,896707,863245,985865,609083,568787,533923,303841,960211,822082)
insert into table_7 values(353036,664555,461577,250820,995198,726267,423330,921493,775298,29341,951848,430251,949377,520325,90984,514504,907766,804955,642679)
insert into table_0 values(707228,987879,555691,776306,139150,705271,269023,704569,516836,544345,580569,3714,142622,702248,410412,211449,549037,565310,788583)
insert into table_0 values(59325,916178,413118,951020,132171,869718,94023,712305,968761,230585,711012,523248,681207,780391,64856,793346,764732,610024,922546)
insert into table_9 values(820934,941192,352062,485276,134334,522391,262532,410439,886133,637719,474819,128276,379196,833684,407278,372057,251477,68810,970355)
insert into table_2 values(432628,742876,658674,419267,42981,905907,831099,836700,995681,368323,797229,862293,212037,344999,201800,816923,511446,248582,560505)
insert into table_4 values(162930,776218,588160,218467,675694,311944,57139,938760,351691,608287,657065,280981,161222,319136,1425,364972,50294,219755,199511)
insert into table_1 values(807238,818722,921241,545714,401400,922021,209232,732187,561579,717319,763767,814515,57510,874370,344748,867209,899632,93585,173447)
insert into table_5 values(20884,597336,835810,74888,855556,856401,289054,474176,461388,16484,188302,219985,247430,837877,931667,990461,897164,552498,299785)
insert into table_6 values(63363,811989,289561,568355,793803,4138,313579,925717,836110,363974,206545,615703,925304,369251,169475,498342,454861,781357,586938)
insert into table_0 values(675456,95916,630313,324117,632818,834320,140542,416796,326321,4153,150046,742281,557249,931322,641129,158397,310391,119193,194811)
insert into table_9 values(346122,153958,668220,923855,141559,91980,638659,333810,862988,855101,726600,732283,814775,562794,997337,636066,75540,472853,364713)
insert into table_5 values(524000,628252,879641,78062,291688,381764,545375,209536,918800,491164,353038,203390,553484,879859,798320,213622,82402,991768,513419)
insert into table_8 values(881765,982046,583024,261963,148152,471107,31686,530909,666487,102116,485690,995113,980399,966782,745117,146294,706643,410064,882250)
insert into table_0 values(774073,941970,868327,80677,163440,928470,437464,458725,856347,884056,643166,442843,650298,8403,444970,312710,786489,385606,46984)
insert into table_4 values(262416,915026,273784,747136,681360,342126,40919,902219,439990,719510,944065,744870,844317,185473,484450,242681,26396,549673,116740)
insert into table_5 values(946056,659525,780623,744204,369473,166244,210321,770418,189933,503451,370594,140240,970248,556623,149003,306540,174340,705873,593687)
insert into table_4 values(755135,353575,438662,512593,993077,601952,143755,404194,685552,657271,908561,626550,275204,553580,175707,974388,230633,770460,623651)
insert into table_7 values(289490,571442,693597,140862,68518,287915,141766,515421,773104,505422,282158,240568,729309,427206,967725,665982,855262,469489,733242)
insert into table_1 values(578837,769527,725881,995583,983699,961057,737860,478214,793098,937016,569727,187456,255898,723842,845828,246087,115190,609076,671915)
insert into table_3 values(210309,483668,319873,964781,608128,199009,413103,497242,56758,936301,358716,538802,481914,406634,51216,715915,392658,323074,247646)
insert into table_1 values(515947,359326,229777,581896,995364,525115,669310,162188,498516,354012,700133,218154,841422,808133,880870,709684,174896,132278,922955)
insert into table_9 values(732886,763458,330012,349504,368835,118596,320522,457858,113637,85673,833224,58585,120106,157585,751530,463635,463481,101872,155840)
insert into table_0 values(973174,913979,322883,38138,678680,28304,870382,19238,907844,573482,409927,417003,490447,457228,946503,264792,685554,696643,832593)
insert into table_3 values(67549,777829,948874,694,931611,355390,776848,37137,841850,265116,280153,316180,670189,941478,341778,167474,729396,187338,637374)
insert into table_3 values(643192,458828,884403,561531,799101,808224,994591,900344,209653,449663,443268,596784,617186,145661,476296,493926,620231,978915,75705)
insert into table_8 values(762017,545539,113048,707867,582133,740534,542854,207298,694871,844039,32743,802006,288075,493162,571647,810023,650223,53019,792730)
insert into table_5 values(806194,115372,822984,924017,587244,419229,643398,568257,956820,197045,143895,410208,606818,477650,258529,862036,592333,420731,826060)
insert into table_5 values(259660,581475,948598,388824,557162,81996,153014,459354,817548,335451,119622,108262,114552,91374,815482,44767,474286,862349,25581)
insert into table_1 values(338790,950844,46711,727808,64272,437088,114073,16356,160110,766766,640942,447865,286269,680300,843103,238776,514765,859346,750957)
insert into table_7 values(30354,482661,705034,246138,777476,792007,865057,149506,697331,569281,74707,362867,423041,655320,747988,35217,347294,610034,184475)
insert into table_4 values(268916,369191,826890,619295,107901,334110,335946,887137,955177,387790,487128,157827,829239,347937,150831,394442,876519,590900,612769)
insert into table_3 values(996631,734252,429094,420715,857977,665900,261943,743350,938141,598666,806726,25650,720136,900245,303131,424923,66667,154566,526289)
insert into table_2 values(651692,366589,870810,904555,764310,631700,93031,517020,966965,889212,574027,840475,632432,951826,496024,314632,357587,910149,796715)
insert into table_0 values(923662,442383,149005,540676,213898,98593,797089,920081,668655,378528,941648,889000,211709,660716,604774,872696,682929,78477,170726)
insert into table_5 values(864999,776987,768017,457032,972322,596460,216821,423476,358895,598048,954127,625400,917053,641291,166267,323207,480247,192114,794085)
insert into table_5 values(265080,411682,846893,565500,39998,527650,608887,84132,764642,314238,953570,94622,184547,462392,70960,969573,754957,689215,443199)
insert into table_9 values(694874,700626,105597,11893,252391,724523,878865,376475,392228,175892,581946,693716,739640,476851,197790,26344,617234,802947,523287)
insert into table_8 values(662670,484796,123021,773664,682020,740378,550040,618555,134420,867074,966576,699262,731506,771596,759330,350084,449330,843563,672122)
insert into table_8 values(334597,121926,313267,421956,500237,806969,927704,682428,236970,131932,668981,950451,254525,649686,274049,423870,711232,90184,467192)
insert into table_3 values(301074,801001,614401,709265,195713,140437,240851,988485,340350,594851,797131,711790,268971,813585,795384,885728,372323,284287,943183)
insert into table_6 values(366631,741268,10348,593853,941588,710372,536591,563717,274967,655874,355703,886484,177809,96994,65419,73253,901994,146436,243709)
insert into table_7 values(829817,465120,805792,829814,537364,325042,527795,444929,909297,209888,37081,268041,843250,555124,544726,923198,928981,572213,811774)
insert into table_3 values(299803,571942,440846,673277,887585,935154,92405,358904,743477,215183,351052,549253,533273,995311,452566,514637,135536,191327,174349)
insert into table_7 values(778782,387972,954120,531977,779096,670321,600022,127055,635624,43688,893659,423638,531867,346059,555481,408508,143862,818745,415484)
insert into table_6 values(699716,594898,348633,242389,367637,96145,12360,371590,709390,810228,949327,722385,463484,481989,557839,341095,421934,337229,370511)
insert into table_4 values(35335,282007,6736,566043,848984,161683,130845,314008,809963,368580,31098,82604,913688,789845,460514,867587,851293,559253,603420)
insert into table_3 values(70836,103761,626489,764309,728460,192640,625680,873957,439002,167962,113383,127864,416291,225635,802068,645326,455196,375071,872608)
insert into table_3 values(291295,436613,133408,269082,824003,694961,42183,313065,459648,792553,931594,142740,247595,302157,856988,490336,907136,698339,748129)
insert into table_3 values(330817,99556,225498,646129,455472,327070,234116,491421,173670,839656,890612,281192,673668,505669,261164,684382,661052,552259,49006)
insert into table_1 values(621556,300250,834482,233529,155297,573022,623608,562374,284998,673395,821343,583103,329357,649478,721569,818325,283810,232600,268171)
insert into table_6 values(297371,424728,433244,802411,393616,86282,908729,118086,635279,652672,798023,41269,316217,80853,57608,728421,172335,429167,102629)
insert into table_3 values(254254,975709,553864,814080,143644,657215,388537,992472,826199,978605,158924,946287,27089,755205,556302,830552,756699,983358,141078)
insert into table_1 values(818977,696335,659963,373651,866793,893261,537993,949907,941073,92162,260538,671431,972643,598105,225516,147598,236206,986093,469241)
insert into table_6 values(762788,316662,771839,617594,230612,327855,855735,72921,350297,957956,253061,289459,144619,706055,462210,350322,131825,690558,294547)
insert into table_0 values(781895,524996,857326,233940,967760,666196,126866,718768,489282,943033,217592,482985,435402,223770,71122,483557,824073,777555,942782)
insert into table_5 values(442856,503605,920612,592512,864621,616706,428459,912983,354583,782840,825939,554326,13688,981443,960184,375317,348337,604674,804603)
insert into table_9 values(743722,966999,421762,282407,487087,755661,219013,6913,413907,672725,226012,260037,481214,527705,380468,348749,116209,204166,977272)
insert into table_7 values(655332,592206,330120,154943,55324,955499,964313,747039,292473,351970,4470,127191,524225,820332,220780,394180,520361,143407,267823)
insert into table_6 values(514963,804746,512966,813949,228598,45078,924980,771838,597584,659755,633166,406207,86842,2967,117056,904353,516985,168167,498038)
insert into table_8 values(105790,929193,641660,31366,76743,266293,692386,887759,123817,480909,503285,361110,764654,101067,408467,692299,676518,477311,162311)
insert into table_8 values(537858,131109,149564,509848,634820,223496,596219,287265,278724,60684,776488,443791,435966,553928,201380,471981,226142,602568,341686)
insert into table_1 values(965692,794651,425457,863638,754213,606992,11355,830743,610463,191441,313689,24847,596291,4824,3294,814696,471916,478052,147113)
insert into table_1 values(396925,841481,613255,451681,582015,923174,496484,805421,868009,799377,758962,334050,675040,615560,491784,181838,629976,998189,227002)
insert into table_2 values(42823,825027,373289,508085,622211,368160,871951,781758,342048,774652,279180,842865,390929,408016,6179,192571,698504,773145,838870)
insert into table_1 values(545757,216112,872574,358724,312069,723847,937634,168687,715970,365323,562423,567569,783538,344959,636928,219876,168928,43518,506173)
insert into table_9 values(523992,381418,431731,653119,831495,439961,767804,539563,42497,959816,562474,228066,337239,277922,4560,830646,225885,962784,757103)
insert into table_3 values(764015,625371,779233,71394,289068,418090,138893,687563,943694,986880,265987,639411,375627,221337,962571,20819,677923,304844,43022)
insert into table_1 values(390046,864585,883167,742098,908575,364241,866679,675925,565793,834580,725322,835341,879340,624513,341589,35359,992837,361288,274183)
insert into table_0 values(637146,817633,548738,179568,386462,732593,979902,605638,868804,807231,689087,984249,835042,613466,529763,499583,892197,512596,442847)
insert into table_3 values(974402,556370,272892,805238,214549,579978,183492,731446,453066,812572,330912,851636,275638,434206,924891,701840,75345,195521,998025)
insert into table_4 values(560216,278767,878941,552346,224077,10393,166163,959556,828845,176733,958658,150963,952412,248074,296484,137399,495047,272940,677565)
insert into table_6 values(562019,79422,783095,58821,569264,881045,577265,720384,521999,279369,468046,747166,344453,446709,666391,540248,742883,812414,538273)
insert into table_1 values(304946,108243,536600,948738,825655,175828,210937,55123,802399,429277,26871,29271,718067,887065,366327,823481,281046,985397,478537)
insert into table_5 values(207399,8591,320309,255582,514728,448602,521163,608020,122782,191118,713655,125069,306286,493232,935690,882369,699510,706413,467695)
insert into table_2 values(427774,820956,979352,136792,42195,63757,990912,150685,896892,925600,513452,976713,93408,466205,95818,524894,536580,307955,807919)
insert into table_7 values(486086,205663,685782,903697,379012,39253,728780,392476,523749,926849,84422,169423,326793,132707,826978,574915,748693,466367,634292)
insert into table_9 values(319610,498651,367064,50716,263039,852983,1316,554139,329364,564530,464351,983918,346462,964939,198108,565805,110979,131167,629188)
insert into table_0 values(177608,579091,564802,681574,296952,374501,710194,961610,438560,796707,254519,672736,468531,643569,115466,981885,445780,476112,235499)
insert into table_9 values(429569,302940,721284,738139,297775,870262,202638,811117,953303,363413,63876,31357,899041,892286,522010,434306,918494,783331,980117)
insert into table_1 values(523560,518032,130091,56759,126268,98700,289237,152295,883562,629737,391184,29071,485576,97400,145658,852903,77414,984372,279261)
insert into table_3 values(860408,783781,181017,453436,295383,653125,577277,848344,248410,818702,522336,969151,901437,449510,328809,213719,662917,194785,850751)
insert into table_0 values(511166,498498,486359,645226,952585,859711,860681,260278,538326,19133,90749,694578,97617,213713,231636,115212,418249,786308,62845)
insert into table_3 values(407619,537381,884825,723489,281431,226887,465243,69516,506580,734105,841172,772573,971861,795549,678957,284323,502600,784208,937797)
insert into table_9 values(126152,711310,944734,477838,544255,615017,410929,455998,314266,495374,641360,3301,146445,474808,147068,827947,202121,573957,828432)
insert into table_7 values(71338,923293,623964,757363,207745,708007,851973,290351,166866,728397,248093,440050,767325,517321,401816,780721,393011,495867,401195)
insert into table_4 values(330794,484619,259697,482803,98730,599784,621335,187914,106016,369532,603750,40346,999050,776942,394525,384410,335408,734219,151066)
insert into table_3 values(855994,845135,227747,805947,270712,231848,449629,752146,750233,435730,661903,931642,37158,49905,23756,239169,721518,397775,369610)
insert into table_6 values(279706,992094,301964,193778,804858,492767,965614,183689,660696,322303,440470,520302,485738,165800,13403,700995,441989,13678,799209)
insert into table_5 values(484658,312756,423823,205556,673408,586539,405594,285835,826313,767877,869587,52763,209061,864139,362004,134155,8329,609040,702845)
insert into table_5 values(540078,839613,766599,849452,439076,681853,820016,200865,689971,804882,824499,365630,242414,961037,393774,188929,668819,845750,744262)
insert into table_9 values(672658,783201,534163,648629,208672,956358,377634,767987,804329,347575,591447,84555,523647,22448,332458,675688,172438,253608,960504)
insert into table_1 values(934152,622962,118308,916244,225347,853765,441410,49540,851018,724781,281693,226616,279429,934215,521182,473104,128720,758208,257716)
insert into table_0 values(984800,143708,770114,984982,479207,172132,744375,53979,946341,616510,48096,254632,3372,896937,165046,64259,947524,904911,501209)
insert into table_6 values(429238,232391,603094,841805,798900,352733,892082,456887,563490,282029,716105,224614,954551,114043,61028,111158,641284,365697,109168)
insert into table_5 values(2945,84353,288923,347157,682832,63951,747113,53201,172300,594452,194678,136048,690422,687194,684879,774752,172084,277282,841315)
insert into table_5 values(934916,855028,870079,46685,550322,319012,365544,253679,673473,181228,580310,748479,861283,712891,500368,865044,264454,306323,93192)
insert into table_2 values(223001,546453,773298,684649,314500,979179,216654,554566,315354,600360,291702,496790,612161,889812,292077,124645,668355,172242,863258)
insert into table_7 values(106963,935071,781083,18177,810173,990193,890390,304773,937840,212648,927794,458782,963560,359748,60967,730296,929567,896491,38491)
insert into table_8 values(658385,849411,176148,13948,256023,65862,294940,611780,774661,827588,931216,244901,239308,68467,601665,785752,461084,8877,793042)
insert into table_8 values(682,856726,428617,930089,444235,803940,919213,446989,808541,432476,39412,219006,682626,711489,104615,391952,440045,178750,902509)
insert into table_6 values(181371,125795,793640,505737,870717,866303,28073,38414,746507,244775,125760,796913,929480,90768,54358,650379,335642,493352,723043)
insert into table_7 values(785700,395475,946154,475779,269571,427242,288890,930042,969963,579777,238297,117509,128844,789770,295859,270365,937335,674295,977091)
insert into table_9 values(907116,877877,474727,615352,175417,752933,900462,156583,489513,657972,790592,17908,610895,336877,771509,933286,60938,895538,547130)
insert into table_8 values(577449,117809,957174,289609,177440,658996,916029,71483,622727,889539,39583,743328,205736,255578,819348,221030,194923,204439,538049)
insert into table_1 values(252421,547683,117306,104270,606239,566303,986568,418712,592311,329139,15666,733968,782203,933643,803722,205537,918319,657341,242490)
insert into table_5 values(659235,952702,820631,368727,789501,603074,239426,61438,232226,315209,399470,806675,846402,319214,797040,293089,680639,33650,584290)
insert into table_3 values(542943,267453,999125,554075,288630,717369,573106,598541,836282,654754,481912,704529,299091,821534,991817,969500,170303,494580,874882)
insert into table_6 values(125288,226807,230266,566377,783463,277991,864038,568323,584681,893705,589666,834850,241442,273577,425820,600850,237802,368107,540569)
insert into table_8 values(19194,240802,433041,227284,808410,978808,485051,127241,495237,942173,316130,836083,27258,894306,365314,676173,5051,763794,237313)
insert into table_9 values(320771,356587,388605,188862,317407,277746,599768,298273,652852,932074,95886,536504,112283,581031,507244,154489,777635,341373,205179)
insert into table_3 values(891041,94619,655730,133056,234718,613167,912598,609576,712482,574732,451528,199131,100263,85037,653818,329662,88590,602624,527643)
insert into table_0 values(487377,490371,141758,526587,8932,854833,66016,432164,915743,83065,703732,775073,88231,902816,929387,886746,923433,356893,40098)
insert into table_0 values(722928,127681,507246,672597,55144,621705,318360,382066,900505,831007,514646,17610,445841,205185,33329,827600,992247,102039,266058)
insert into table_2 values(368930,675684,183894,633762,992122,86630,520277,341094,584029,86485,132316,512271,537462,467405,870400,188479,770448,343404,6957)
insert into table_0 values(914643,704986,981165,290958,390003,387134,301799,568872,58597,52685,803646,838428,826017,198591,234158,890487,466552,314997,224379)
insert into table_4 values(32710,33634,662537,621331,398958,264091,535682,241253,451118,277893,99688,382932,739985,229897,696940,344283,312793,716467,989586)
insert into table_6 values(819035,495241,963769,742836,761691,623873,767457,82867,315832,820712,956536,455697,425862,598283,964582,207094,391731,754967,823091)
insert into table_4 values(101508,571554,261487,339858,28915,246030,35468,851676,554763,525376,92419,334247,285940,514727,699456,822821,650620,302781,122086)
insert into table_4 values(922277,637603,308571,920305,96841,995766,238614,913159,128487,100677,349068,250765,950254,469195,654911,740654,188913,933649,870990)
insert into table_2 values(885855,393670,551202,85936,945168,640018,794012,931367,343816,407921,672025,917526,769455,932980,250146,452202,651101,55139,617458)
insert into table_9 values(19750,610108,892942,814694,791696,88156,920033,16109,245132,861743,709296,630454,852461,342088,699652,716205,706815,679063,791890)
insert into table_7 values(905211,201685,117273,503761,110243,354342,249919,199505,897020,340266,103071,633409,74601,210875,321682,569052,561255,771606,700278)
insert into table_7 values(251416,126841,408835,638468,137387,963032,176523,94211,213181,778532,625207,705417,701380,547521,909168,138184,187764,716917,773541)
insert into table_3 values(442289,574090,580062,202178,829571,175205,440713,741977,105817,412160,469683,187297,816547,196107,909077,125590,811144,847309,584742)
insert into table_6 values(938124,694561,212635,549222,350095,544481,996161,547716,477652,463886,205462,359918,281171,975041,654029,857972,490729,783393,14727)
insert into table_1 values(785647,858867,975744,254329,783490,87,936409,174359,813717,142383,114525,348183,311064,826667,482778,135863,808842,506025,177195)
insert into table_0 values(608727,58149,532372,380466,704485,831042,720966,279790,217705,11183,258272,978970,31827,974691,522302,93710,696959,86939,244096)
insert into table_4 values(991470,465699,235067,567724,407629,36610,743698,208213,991282,717522,792246,740426,793561,550156,78133,700381,471351,201586,883347)
insert into table_1 values(568559,453901,831157,468795,275016,141744,615784,427732,219333,253551,204249,534078,855179,145760,227480,482875,451253,797752,800270)
insert into table_1 values(947685,97095,588132,906453,264555,52482,715322,442286,251757,282083,780390,597480,87021,606164,425158,650428,472410,874455,826672)
insert into table_2 values(11795,483314,20315,72447,745003,364083,793678,92951,899111,738861,24165,856777,728711,203075,609827,3047,288430,962313,960664)
insert into table_7 values(837907,780344,451674,180830,425676,304374,330723,870450,554170,39277,386058,211988,736336,865524,287122,189725,97781,914308,796567)
insert into table_3 values(771460,792632,920401,295648,92843,133970,322603,804988,364424,279195,354233,336868,107637,161439,178175,327817,504057,809302,460854)
insert into table_0 values(802162,602129,521889,993457,967435,761538,879309,628996,214505,455467,573875,427225,62742,666189,709101,474359,503051,290439,420634)
insert into table_1 values(453668,932219,966821,416360,941080,390204,464525,710483,673946,23597,910907,234393,247710,112883,408879,483246,121357,710012,761551)
insert into table_5 values(311712,626350,943040,486396,529113,764316,811329,886930,198939,338281,160539,201696,367356,303889,905821,316502,38036,591892,991118)
insert into table_8 values(174971,476844,302247,623260,947567,298690,325387,564975,680010,729002,589650,160869,735068,383890,32853,158540,212565,272404,734953)
insert into table_7 values(149733,240128,479283,329210,337390,22685,896554,151106,454128,208333,981443,363494,148672,109142,670762,433410,720761,178299,772719)
insert into table_2 values(850981,233158,208219,160145,557552,491792,760438,726010,775753,310651,12759,218937,716261,878643,151074,611147,488751,230272,971363)
insert into table_6 values(275579,52844,940164,924166,270303,753291,390207,811775,687564,807133,149482,584859,391630,833439,410199,174770,932484,489073,819779)
insert into table_0 values(840760,666375,860138,195038,730053,718687,412531,741686,13811,801784,816948,676822,78818,656306,231761,521637,876604,315426,802821)
insert into table_0 values(301366,863891,310047,254308,694928,547810,970663,880496,607992,478883,126671,101497,511690,38140,21776,209004,47293,866980,186435)
insert into table_3 values(844004,110417,72125,241600,11246,145758,786545,276551,575093,413127,65619,338751,241786,994778,631372,88190,341914,955446,984153)
insert into table_2 values(871868,968984,988099,589547,458500,775223,805302,546845,894843,243051,714720,214047,618759,150720,539659,664638,77320,104859,299536)
insert into table_4 values(681196,36378,738472,730924,773540,431381,100032,516881,108765,178907,21006,375419,743684,569925,646411,548511,369074,723039,519732)
insert into table_9 values(190461,29263,2552,861672,411618,887657,250382,976004,839583,622676,576943,836967,423301,35100,182959,758882,553126,969742,82239)
insert into table_0 values(345526,997984,764675,364191,155736,664598,942984,443165,858844,504882,609646,439670,75047,538639,496542,718099,26365,365437,917719)
insert into table_1 values(545306,740914,999898,348159,99904,257945,407356,283590,824518,242650,416893,69823,521839,450585,847899,714145,379988,654970,72515)
insert into table_0 values(462077,920337,633144,249058,296008,243600,875420,768592,553717,672920,912905,50160,659690,277148,826464,817732,63892,318407,258362)
insert into table_5 values(961177,190462,682067,554366,351051,869405,299004,798169,831153,847754,31952,75162,570449,950302,479036,547850,628312,833370,826784)
insert into table_1 values(387467,333894,534438,369352,939780,867097,76523,22111,737933,107534,407615,196360,453962,763359,534362,344773,992051,629086,107776)
insert into table_3 values(359242,613403,286358,966774,843349,227096,897024,261890,46546,839610,556151,956572,20371,282771,599519,668253,496196,120871,46468)
insert into table_1 values(316282,469781,381762,367475,141052,853401,864256,146464,811643,445276,496666,863934,222181,648413,398687,686830,248065,281506,534438)
insert into table_8 values(2668,747682,494532,980055,296948,223016,91790,376567,775643,328116,623371,632018,715634,880331,56989,594011,376786,69721,830562)
insert into table_8 values(697749,147903,851640,27388,204535,195883,543995,337590,915068,168826,720859,31449,89642,831652,969010,41670,689594,927791,479238)
insert into table_3 values(696302,626645,210662,630962,429455,333150,553726,526967,489935,49844,954993,384886,695909,484416,727031,878562,331369,794876,174390)
insert into table_8 values(672339,195140,954536,310474,950562,876924,850391,192713,559855,920874,252309,416492,861685,858515,53848,914772,295795,904534,826632)
insert into table_9 values(4715,666678,614854,824931,910785,965339,345157,212760,127575,619950,886963,334187,206262,175400,686912,925473,435204,320243,283143)
insert into table_0 values(685376,542439,156271,771812,401912,581900,653601,601436,538462,312588,707569,138381,491723,667853,224559,535914,525133,8617,100900)
insert into table_4 values(615532,784881,92372,705416,3356,198413,133704,290167,501205,668092,763068,505002,796407,551878,87481,386176,486947,632942,536499)
insert into table_7 values(452531,517328,756775,403958,33362,997344,991724,99712,217180,311512,318543,392333,372069,38605,462428,414925,123421,33600,698203)
insert into table_9 values(653685,268792,683084,493659,991873,178554,329224,197362,604077,392236,458888,767097,709309,172339,130990,263371,835461,742884,437229)
insert into table_0 values(637740,795625,74006,849689,327436,559453,34783,181385,505790,73281,552857,514222,243656,729500,544722,571636,545715,7526,403440)
insert into table_4 values(858735,925465,274888,553855,786527,102034,151022,665231,907325,92661,413633,405979,640642,787151,726335,822944,98000,213198,860945)
insert into table_1 values(682622,194150,117367,487958,641415,552797,217613,565366,100395,401830,252129,500000,135962,234050,103997,686900,884842,992798,187562)
insert into table_6 values(539443,243500,90752,412877,875694,134601,451656,333740,84652,422767,240298,355438,242397,460500,816031,198211,807753,568845,119592)
insert into table_4 values(910455,469557,495481,269866,941818,385612,941934,416428,255092,795688,218731,403224,806342,394735,543186,361922,775869,427549,72184)
insert into table_6 values(125786,657560,622568,451614,963920,451824,901733,700832,313016,176528,331778,797007,456623,262163,858975,192400,972371,26475,944558)
insert into table_0 values(634035,913037,317053,630217,529673,970516,992856,432550,256632,174642,40315,556416,742448,337044,324288,614646,260720,574223,261341)
insert into table_6 values(614308,499239,662068,929995,16802,514807,425557,463545,229028,468676,739383,656662,998907,657572,789083,867653,131847,39718,103964)
insert into table_6 values(715382,126836,591791,769060,686126,998250,446456,667473,191175,419830,633457,670643,8774,526426,853615,998972,714364,743752,921399)
insert into table_2 values(378852,824091,224519,477312,321439,607884,144510,957481,831265,13271,762356,439600,96375,179573,655474,414753,270229,614830,788308)
insert into table_0 values(294667,344095,389396,115686,369115,791722,611401,223008,360239,700043,316661,444722,94625,926712,270952,321454,299884,717258,427768)
insert into table_0 values(209301,705212,287079,894323,776187,220690,402646,247834,135369,129521,379368,423574,921051,373478,834924,196208,536115,786013,165870)
insert into table_1 values(443651,973201,164050,642856,83121,948825,549963,763623,996731,370044,88565,177126,700139,40499,207964,952387,12367,932007,212558)
insert into table_5 values(643675,911807,365837,996893,10903,444223,972130,488129,410511,224757,338396,628237,421081,805615,275415,901657,404582,594867,639433)
insert into table_8 values(711502,838721,791923,455652,788565,917000,424355,509614,175912,263176,700769,998735,515644,21874,225520,396080,8857,706435,224)
insert into table_3 values(756640,79105,328801,475250,566645,41401,685688,808215,726657,453031,841435,354447,725108,831912,116594,97819,518831,835584,46258)
insert into table_9 values(23021,909595,215639,69670,107882,253393,698772,954450,441808,759033,575587,683442,412307,726086,749407,485333,110107,420982,295108)
insert into table_4 values(503341,720583,424147,352402,865732,419147,275291,304270,202938,633097,849525,655931,764665,154123,573757,973447,74301,518463,668612)
insert into table_6 values(605463,54744,680956,522987,732350,555215,206871,812372,716787,316735,592921,477594,651194,826421,336904,723663,32618,581194,847597)
insert into table_2 values(175218,613670,764709,861186,984528,458448,722641,21584,128877,824635,680158,425096,119394,549947,25725,448045,160123,584419,722318)
insert into table_2 values(505679,33648,349819,103375,354134,156273,814849,793188,187098,916312,700545,524292,614887,78765,223183,888261,242447,430917,585758)
insert into table_2 values(271387,102719,411252,693665,967316,169419,513886,643711,655085,554705,132776,262430,556399,289541,151453,613493,863659,301577,306886)
insert into table_8 values(526393,542992,987822,179326,125662,717517,655752,156070,281611,391966,699878,168447,455752,166421,318805,840631,67592,138998,279869)
insert into table_6 values(93708,272238,936294,360646,106590,187879,977415,672254,861433,953028,355615,949713,197355,55121,36668,900749,878876,369310,911521)
insert into table_8 values(920241,990096,116703,118548,406468,552157,148388,285408,790512,93810,747873,273157,265967,351794,658522,161278,858772,727777,830035)
insert into table_3 values(370975,648010,949268,279130,356246,241157,389425,719002,766172,607596,195255,415735,815240,945954,120247,723913,160147,221774,190684)
insert into table_9 values(206761,840186,109389,38862,477902,792365,237820,931489,422595,420501,832145,44047,230300,539827,511288,410771,285213,195891,438773)
insert into table_4 values(709486,968362,474668,959968,262840,377737,42054,992076,177027,247916,853473,132414,500192,956636,590440,210554,694722,579495,16530)
insert into table_0 values(388660,911303,699582,930105,113807,929865,502338,787571,897144,777569,134868,353648,920148,376047,130239,132906,323282,709776,669028)
insert into table_6 values(685239,680786,373901,490398,512550,607249,877882,977840,142671,760278,894904,440030,708892,269507,570257,727851,274203,638272,548035)
insert into table_8 values(925600,305309,730180,65716,611496,686987,760956,222679,105430,453629,223871,720123,519649,221456,569301,482772,385125,311931,676515)
insert into table_0 values(801821,574915,218813,242599,306841,143659,245398,467803,475900,349621,828154,545495,526861,355871,836904,846388,74783,228101,663311)
insert into table_1 values(880514,478021,947387,217504,843512,197743,480887,689161,740244,112014,928829,392183,108454,43473,320082,114923,63795,234965,836672)
insert into table_7 values(438620,297953,490243,182495,603076,877325,716479,810063,915708,531826,625740,284997,251995,903511,367523,304692,477234,662642,266966)
insert into table_1 values(600144,879449,540063,215467,303971,526811,149122,184582,101346,362172,884541,768632,871871,545907,986304,713590,704115,844121,931115)
insert into table_6 values(899989,508609,266705,634283,125360,982411,277554,787488,488433,554431,630330,632736,281424,69779,291107,950328,82097,850398,87372)
insert into table_0 values(343580,265035,932176,667135,346225,179302,162254,558341,397885,214676,173081,477613,956980,93818,855565,795169,357540,130479,450905)
insert into table_1 values(303867,242015,425445,699193,901332,436194,705788,207140,86423,835361,262506,673276,585295,627195,700082,263993,511777,971916,838497)
insert into table_4 values(179378,932855,897650,624420,224966,523575,413049,986897,208388,961530,442311,428278,594621,24556,433238,121580,520305,536547,309138)
insert into table_2 values(6766,438718,49783,55722,43548,267355,510843,525831,227440,620506,136414,987909,433630,937324,888698,837894,287171,794501,977326)
insert into table_4 values(729530,518919,369036,493300,404052,57530,276529,391698,339588,511650,4567,523509,408741,285486,420415,182698,776038,551090,585406)
insert into table_7 values(198897,795990,559553,765907,793789,871868,649776,91292,62898,430315,309338,333068,6846,708187,590632,125242,523078,468596,617405)
insert into table_1 values(990521,690906,222707,662312,71478,314840,115168,884798,981219,338280,42529,167240,713659,195416,697655,786056,537576,555989,205211)
insert into table_5 values(430635,918826,240319,798304,433874,682845,631090,322486,616257,420796,497700,152503,19650,714809,466705,480600,325876,18589,650757)
insert into table_7 values(620174,155869,183086,528825,831670,166527,448107,471634,55115,678744,175949,854840,416047,88040,543469,99705,812367,500876,372054)
insert into table_5 values(181151,159855,581253,883533,289904,641561,90612,699284,450564,689112,672492,342196,828453,860672,891342,762833,783917,112024,410241)
insert into table_4 values(501808,422471,955652,47346,699647,386415,568241,906272,796169,301529,672075,824936,332303,827988,989410,997911,997491,60880,661393)
insert into table_7 values(495588,319546,978829,732942,223084,206013,303716,120898,478124,433120,153162,444449,364088,842603,474387,491199,476268,55514,868208)
insert into table_7 values(662108,382299,190135,547564,308803,151579,38871,414390,151295,813018,209351,829041,248403,262949,299730,685512,994970,173746,834321)
insert into table_5 values(423791,489751,726465,768801,256790,990443,924814,969440,87203,747525,295629,379074,106963,941063,861743,591294,415213,348977,337408)
insert into table_0 values(627076,298489,304147,802352,155255,774679,77165,682371,959337,275628,996685,176444,811257,346402,725316,932868,540442,428255,551775)
insert into table_4 values(537136,487418,844578,118706,644049,478149,148663,63480,17890,565809,529214,819786,379208,876983,446595,485442,81393,564224,342145)
insert into table_0 values(280110,833878,305161,555051,201670,785306,769559,265516,698224,534630,519742,833076,656096,257286,281467,229667,44567,963000,875864)
insert into table_7 values(779813,170361,590996,726275,804851,300462,128179,310016,990828,257418,783014,620044,519431,624856,645071,257228,912357,371946,913523)
insert into table_3 values(152889,174508,956659,888053,508298,475689,208746,56031,155058,682797,908934,37374,926369,707562,802226,976002,317057,536851,449366)
insert into table_7 values(959378,288683,77692,989863,420801,355067,434782,80233,815281,989673,996071,473988,918002,15277,309708,191477,644633,920496,160073)
insert into table_3 values(575670,638818,529410,484223,461388,124702,151964,708409,699517,230947,507507,234000,405645,215172,640459,264559,709093,503557,851651)
insert into table_0 values(120881,500299,208384,625384,697547,479176,236144,775356,321293,943062,359533,519256,793129,793027,270802,613979,340344,398514,840681)
insert into table_8 values(818243,993662,429917,370645,691524,527535,636410,851816,966395,3601,548967,113010,997702,309748,286911,997389,727385,261003,345020)
insert into table_1 values(189221,997023,85741,193768,461880,534651,615518,750247,929310,851783,988740,572915,957311,232729,481279,978089,913326,362084,423471)
insert into table_1 values(298640,584072,557431,547512,953349,574470,426221,612763,503264,872684,890753,253027,613928,723496,975425,96867,182106,143322,231940)
insert into table_8 values(167038,118417,421976,712845,438563,356588,86443,128450,12429,991394,152639,574947,805614,939530,348049,378112,167699,276652,74096)
insert into table_5 values(407332,164152,743122,726065,663740,919572,866205,548416,855579,785464,318508,684433,611236,889259,599273,352193,694327,755787,148231)
insert into table_5 values(293284,837389,371551,502101,687942,504839,725202,788160,124565,11993,549984,209559,279918,691636,109403,810792,777529,789063,744231)
insert into table_0 values(773938,52438,548127,325383,310300,192682,418770,869143,823790,586791,120179,143201,45094,699050,822125,348795,997018,489639,786326)
insert into table_0 values(431605,797748,406485,734937,856820,537772,936345,655126,694852,711527,42858,16721,640849,341399,29611,67221,703208,325627,757032)
insert into table_2 values(463442,519440,264154,351908,575895,741786,355254,781603,445828,388426,983421,162526,993828,879181,958067,731987,590526,715425,816186)
insert into table_9 values(185291,467987,937560,509708,727965,106851,406703,611407,771414,720786,836935,637084,64489,785194,595733,864542,894820,551068,31745)
insert into table_9 values(260219,832426,382679,906295,502841,947486,300423,482669,169426,22863,218842,198736,955727,128731,275554,647137,325961,619628,814996)
insert into table_2 values(449833,55730,362112,532219,30376,23350,856578,185523,425440,510794,398696,563204,470765,353942,158628,766528,170751,695058,466485)
insert into table_0 values(755199,493038,723100,860719,883833,957659,972878,701799,500923,285187,453539,171367,928949,566624,547610,274103,871120,785235,958931)
insert into table_6 values(791269,137216,683232,328639,71117,500451,359025,211978,68015,100811,310431,966811,259409,295543,678768,604180,192579,577831,523348)
insert into table_3 values(896046,429802,665193,808658,806311,247956,907173,728009,55610,602648,996485,898036,362131,556472,99339,630052,881587,315501,566867)
insert into table_4 values(639178,867284,730908,470172,456693,806128,934453,653098,721177,97104,344397,895042,470994,583668,743359,684186,262767,534559,77196)
insert into table_6 values(140099,232725,686784,626584,88523,34355,899622,544332,967625,280965,441710,980270,261076,452519,180955,965695,731172,336720,838169)
insert into table_8 values(625151,962575,198555,450383,15115,88875,891654,684767,171463,501049,99490,366571,971223,779673,937210,796611,287665,123008,447477)
insert into table_2 values(750825,878994,390192,409658,601496,913236,565205,807025,370222,53136,442869,621319,273609,881922,172806,133644,273618,5310,27398)
insert into table_5 values(794341,431964,753884,28081,307910,444999,648138,403931,953554,875079,870915,523295,144346,724065,514265,513405,620039,970847,584984)
insert into table_6 values(251387,800449,927746,305748,717067,126425,140020,816895,607934,584630,744843,628509,424760,53,245654,216830,169385,158176,822654)
insert into table_0 values(347998,946521,755921,598537,131894,781608,218209,59088,116128,772127,702712,878367,731007,415217,647896,257817,692236,619052,42283)
insert into table_8 values(288170,201055,76929,279629,190277,730363,578604,81902,515862,891054,952622,686767,762134,355520,152059,731419,640884,698259,350155)
insert into table_6 values(221465,878218,990555,289272,901070,574688,512974,294563,461459,315859,803027,348581,831658,260778,652306,12614,188726,666500,762155)
insert into table_9 values(695282,544442,631608,556122,216055,390475,823425,37638,120617,592258,530945,148430,572714,302478,174340,734719,364199,994676,487255)
insert into table_1 values(570167,810643,212994,511747,255829,907482,522988,604546,120659,219299,714845,344152,499792,650869,507102,327195,251079,584780,679621)
insert into table_0 values(597722,883801,713923,14645,797511,107710,701736,162251,239239,757272,580067,506296,753421,533677,550561,357488,816629,705829,669899)
insert into table_4 values(938004,272578,239645,750200,951412,507740,990224,761650,404819,761500,904145,443628,67899,466670,73698,314138,674701,53924,167942)
insert into table_6 values(131712,631798,789676,790139,755662,460487,504198,261724,794921,195588,763961,925555,156788,265911,10610,808937,214026,431029,24523)
insert into table_9 values(421429,72763,760410,666202,370051,704134,281553,23520,946551,149144,401051,906105,287375,466232,647763,755369,689125,731275,965377)
insert into table_5 values(696789,468945,905146,736987,831741,694464,688558,536529,902032,170531,133395,76655,664643,710000,755920,67597,395880,856551,848298)
insert into table_7 values(391572,131566,577916,90074,915290,545960,451384,149429,241116,377253,151612,818115,277783,491706,665681,200283,834750,240021,457718)
insert into table_7 values(740923,280701,602916,403809,657372,463601,899709,872913,303777,655017,125285,440188,583232,162743,184712,487725,511336,813505,999500)
insert into table_4 values(313204,409915,304321,245207,790071,646602,210449,387825,467888,174696,565101,610087,693519,263261,107835,936412,412888,279165,374098)
insert into table_7 values(887139,918942,413059,616086,252844,295987,609460,90818,703593,257726,288315,179941,611631,411881,564861,492594,669741,701500,144326)
insert into table_2 values(549839,963004,409182,447425,494066,441399,888826,858454,81387,427684,469716,651830,520870,282230,761483,647485,762901,771199,562398)
insert into table_1 values(741873,902912,903771,529691,362260,533548,411360,889293,471017,846365,711587,551179,882849,377605,519528,244009,488715,706221,62119)
insert into table_9 values(963847,236417,561994,862534,491670,868535,310482,94880,535031,202876,851599,721066,791983,50710,13936,911606,505283,908595,684884)
insert into table_3 values(14998,378117,364205,950459,916664,217011,655648,323732,467415,651686,903666,841512,773889,122628,834374,385650,757115,586580,351251)
insert into table_4 values(375512,955513,347314,462842,700982,385334,893631,599049,779423,114528,873108,64294,513351,918365,812085,868889,370383,137242,880444)
insert into table_3 values(993642,933116,593168,626376,799759,473582,908544,849490,103040,688141,104788,425655,980167,630825,849429,273627,624067,488533,453436)
insert into table_7 values(599027,411664,547532,107362,981716,71755,452913,289681,366268,602716,537752,324416,356475,726287,307991,562819,713394,45414,65996)
insert into table_5 values(152638,992788,516973,605939,452320,617378,163020,999752,969081,897988,639234,936325,439901,723738,352164,718669,483136,197184,62684)
insert into table_7 values(766359,854212,61525,81721,223581,276376,345266,544575,254718,238706,42067,298857,420342,123739,444559,198005,623444,653356,696665)
insert into table_5 values(973520,93688,994285,513743,213250,379444,137556,165000,268174,122152,826159,9663,338013,88084,730460,44200,23590,927698,47850)
insert into table_0 values(343252,633288,764966,592509,79882,991851,320129,941667,789641,369998,344067,447850,514006,705556,442503,675521,752472,360248,566646)
insert into table_3 values(430866,309629,106961,610763,531810,843450,211876,431097,115449,412521,307544,32451,23769,178170,577492,752356,547709,850280,880560)
insert into table_6 values(711070,376709,639498,128113,817393,902884,436828,984478,97429,780075,289390,648908,178814,443617,141412,343798,314627,706972,861709)
insert into table_6 values(133912,69565,140182,902042,379083,284273,922748,794622,637807,615383,418971,701248,978162,312236,620925,304583,607866,418389,808856)
insert into table_6 values(660563,185284,137940,923118,1185,524890,170656,523160,747238,504305,597993,600993,836162,436385,93222,731722,615095,459931,324460)
insert into table_6 values(540032,248334,685941,807089,827178,349774,325567,789017,869023,216570,286550,153814,49046,191116,858624,28762,891509,654247,282779)
insert into table_7 values(71976,666510,620504,53044,701255,901828,525523,702518,545790,437913,872481,891573,642819,668040,49442,372928,728972,92969,228053)
insert into table_7 values(396831,188775,387319,448043,322370,232177,433494,106439,894155,549280,111322,575022,923553,946855,702587,730766,407483,277692,962421)
insert into table_8 values(955420,442875,257285,541000,996308,379899,142490,378345,958162,614106,881114,892730,752258,876981,545944,883360,108381,504178,31346)
insert into table_1 values(873583,331447,707691,303987,132059,610041,271129,402100,158731,931591,599279,66447,814800,968747,964934,466698,685591,562696,730701)
insert into table_7 values(400021,715482,60907,802868,585260,257733,594621,779484,647184,233060,589133,612005,977767,476832,260282,624637,148705,40468,438748)
insert into table_9 values(280108,722133,735336,62160,143534,984856,958135,684337,545210,294774,885202,65247,77972,331315,475459,605000,607026,460447,393898)
insert into table_7 values(103588,510908,673798,850167,173024,310251,631541,535630,968535,308157,136769,419654,268752,639369,963600,520778,537307,510665,908675)
insert into table_9 values(678807,172899,376724,826487,263392,525146,743377,872143,668625,126012,860316,429575,277917,279396,381434,102454,722640,918515,549119)
insert into table_9 values(362386,863283,682862,570927,984091,264330,747076,531584,28876,161453,601208,71955,991101,245708,489160,148274,545893,861524,462098)
insert into table_6 values(583487,184151,943211,103726,687795,448120,685279,444617,188785,347706,236179,235807,579640,881368,877021,162214,986953,672747,776652)
insert into table_4 values(845198,267319,558735,948090,531991,479378,565818,172170,402310,570180,933075,890936,49179,19206,49958,553569,349061,153024,516206)
insert into table_5 values(595736,44867,223634,30870,186300,759699,972733,197541,288372,377492,827198,410291,811992,333310,238064,108206,98244,960370,133795)
insert into table_2 values(831584,71433,235976,287590,866479,992398,633594,74999,437671,122798,387326,80818,512412,478837,75009,866195,849801,902579,338039)
insert into table_0 values(172508,291396,456859,395563,224660,238538,991237,645399,509109,753673,148667,270764,375373,55858,150887,876500,165513,856082,360225)
insert into table_9 values(901596,127074,395252,157015,276484,57653,984769,340414,905472,988278,984528,209526,133798,175347,129070,489368,582532,326987,711887)
insert into table_6 values(448339,378646,835454,135099,254699,899482,456625,32568,138875,897962,471307,385401,364622,67456,606845,308627,486878,226445,879231)
insert into table_0 values(589469,158543,733079,973952,159604,826414,480574,617908,536008,274945,273775,443423,369363,325686,547409,194923,152127,747088,266969)
insert into table_9 values(27571,72438,948544,253712,809493,924651,436394,628240,165995,599947,502797,154352,680318,714537,799116,976595,873528,527435,178886)
insert into table_6 values(929898,780612,971224,308380,372687,798778,653976,333278,609821,496618,947622,857961,345189,542657,124967,954216,303050,419889,960650)
insert into table_1 values(542930,754,170264,676183,248766,105066,895339,620567,489195,144312,798481,223278,360725,586250,229366,429262,638746,400165,132751)
insert into table_6 values(624953,887914,36141,801179,501891,639478,63740,607139,732064,320531,605503,698214,788520,71037,530777,416340,313373,337886,778217)
insert into table_3 values(739013,821255,740638,950649,118221,19826,387687,506324,421492,48450,994611,671635,401612,880253,630848,264714,52028,398625,806610)
insert into table_1 values(151999,631419,62144,483466,880293,353810,190811,226259,227324,507692,491744,636672,898658,56875,518311,481091,190056,520801,489961)
insert into table_4 values(209597,639166,124019,969582,412593,757213,670370,396056,138087,844285,518083,452754,530989,309525,52935,882828,520742,914997,555676)
insert into table_7 values(432853,317971,70790,421193,495750,497808,869345,206699,961202,87549,355707,80780,309022,973100,746647,696433,191194,721357,806813)
insert into table_5 values(706458,176665,63852,715259,800239,723096,905204,409132,806485,529430,509623,943891,17244,459808,392532,649178,660136,747411,76723)
insert into table_7 values(406416,488261,914587,656026,942711,689682,477933,925915,735130,928203,488894,164069,615289,161206,744198,125554,871366,196495,82251)
insert into table_7 values(989134,645509,761640,226243,540936,892287,792205,350998,579830,945123,606096,309565,695446,383240,41720,989686,511087,371473,547451)
insert into table_0 values(871376,446244,48035,305799,847324,378256,680179,153573,991720,643546,930130,882545,453231,991509,781026,142906,33733,370577,743464)
insert into table_3 values(724014,409314,969797,739757,880495,778740,83751,398363,881353,305650,406406,679059,235598,38683,473485,70596,937482,128414,390862)
insert into table_4 values(947698,912795,809552,595761,984707,446992,829624,394658,536534,947946,114180,30484,592222,997735,101972,151138,665563,123137,634312)
insert into table_9 values(417791,498227,317571,839330,947945,655651,748727,971271,308173,667169,264155,319232,851785,106648,407871,830529,370436,583294,533947)
insert into table_2 values(767612,951569,24254,311643,204869,588932,106467,321399,71538,107292,557977,345604,314357,991529,216459,394375,634185,255019,834803)
insert into table_0 values(881494,671789,384739,269408,595009,361744,138327,670165,155771,681882,869471,774142,627024,102405,573743,886426,426323,656395,84701)
insert into table_5 values(389110,264507,455729,461252,371016,973962,486405,443541,277987,916024,643673,504970,962439,616003,424948,229663,222308,558788,808393)
insert into table_1 values(367379,734661,266241,370863,631360,571851,394882,964052,23889,631976,329243,124010,410246,776044,258900,976696,863302,713661,893890)
insert into table_0 values(790138,905657,177033,810935,371923,52456,808211,589516,590678,347499,409719,133605,838253,172711,195555,937517,696735,404142,348164)
insert into table_5 values(468373,779887,229785,931562,558316,996785,403380,207638,257940,720619,133252,493538,78264,874270,46125,315921,603122,232364,334630)
insert into table_1 values(290401,988421,209022,462196,93974,885227,302560,485070,999803,779440,183052,188363,646191,429110,85104,304101,979620,786226,36791)
insert into table_2 values(119856,934712,732412,88044,943455,594752,187804,899797,30607,600046,182026,837208,642726,474307,878417,41638,369721,700233,619407)
insert into table_1 values(872512,490308,307810,701801,92811,641805,323200,648394,743467,10403,878910,237193,972769,837519,215240,896975,885934,261992,662800)
insert into table_2 values(852885,161622,403896,758519,357677,55384,500260,113324,116533,768635,495423,769652,956639,538824,539658,191033,494550,296493,769116)
insert into table_9 values(143312,611284,563256,844629,284634,259005,617202,368187,67623,11288,793892,489044,444202,868257,309170,663406,348870,237591,150854)
insert into table_2 values(491586,454726,508857,983328,826383,519955,421911,840623,554908,63185,128138,741466,126778,727600,354353,771098,279731,659076,235405)
insert into table_0 values(158449,841842,911525,372722,876239,252604,285376,680097,910065,960326,375450,525343,841839,112706,571507,849370,350357,11647,149141)
insert into table_1 values(195515,511668,761214,58176,914198,164646,608521,993962,701588,208683,794161,19512,22932,798403,284491,327721,183363,508721,797443)
insert into table_3 values(193191,210992,444083,589929,398555,559197,642666,261697,60366,90297,199143,263580,308957,407041,968368,71252,511227,80237,428942)
insert into table_4 values(658073,494311,200597,760019,258997,927914,12711,453665,845792,820701,12626,305552,38841,136797,335603,990755,227720,390892,747423)
insert into table_3 values(561855,944426,415918,106825,877281,255777,616109,224581,332784,31963,447563,276723,406075,491894,662401,102297,519706,892291,649574)
insert into table_0 values(729163,462851,849705,155719,274249,640456,245545,18431,28850,477590,218292,15957,570067,448233,672328,664758,965156,923789,249970)
insert into table_3 values(560947,65636,311993,367618,154937,944645,350068,538404,678811,541160,36456,602492,64134,88184,881454,800562,311,482273,92226)
insert into table_0 values(221162,700451,948389,534994,794308,881039,774657,26654,540765,840614,43242,911733,643023,768457,667729,677328,22327,885651,907124)
insert into table_2 values(51264,526871,366072,910338,258283,873705,812848,919189,156943,897137,729109,958262,61374,857629,163580,313880,792897,857665,826215)
insert into table_6 values(663449,370234,178736,695331,733627,701812,434000,629434,742876,235735,168562,828848,863601,55123,464842,925044,255477,888119,76069)
insert into table_8 values(351914,596313,632752,324348,96086,691703,396303,474405,993606,968602,414753,959524,84467,600163,59221,317941,512081,963060,398051)
insert into table_2 values(535745,966082,945193,433936,726428,356867,711511,12302,898272,764983,200753,478617,638053,367495,29234,748813,290583,590937,117763)
insert into table_3 values(45598,818636,376303,946290,173527,663528,227599,43786,566798,770316,911241,559464,48843,431069,30530,906586,851438,49773,362754)
insert into table_4 values(637104,613657,74322,617646,480417,842016,227080,35208,143963,829434,554564,628339,974766,765420,834272,138348,974845,170590,483929)
insert into table_9 values(481828,543761,353267,384691,156094,638274,178353,340205,206154,181045,250763,883266,130359,467978,479293,701248,189745,377485,102435)
insert into table_3 values(590201,714676,683857,749749,56858,87948,465043,482601,97786,576201,50401,64053,852957,919043,761970,989119,11005,666412,294423)
insert into table_6 values(733046,995537,527778,781696,359789,815956,400211,12556,745868,654734,329822,318437,136202,990127,538373,347191,711380,753114,441226)
insert into table_0 values(224783,994257,528572,385158,715072,943205,297724,596588,940544,953439,212198,842063,560333,838642,653957,810432,824554,91262,815431)
insert into table_3 values(750415,318070,837796,150063,320880,282986,306812,712035,47460,11835,620515,887494,479052,799599,678134,564161,24644,768330,12591)
insert into table_7 values(460674,232662,717321,199735,432954,823034,600683,843334,686947,653529,248023,517998,178607,228452,992879,236233,603618,406676,529335)
insert into table_6 values(947291,560484,740972,925314,275013,658424,816981,660081,313290,508503,792345,581116,435443,970598,673674,748126,325690,56303,967679)
insert into table_7 values(923805,529535,596762,207123,788531,565183,67353,281174,251976,582178,698243,268520,660630,324238,814358,983610,929662,310497,146667)
insert into table_5 values(724561,839198,24361,62094,855374,36618,406419,809292,645935,260638,271915,16566,971000,959663,242700,290240,552397,377934,960228)
insert into table_3 values(106282,410759,331240,163611,722910,737708,752574,78616,438070,713977,623425,645311,244553,242786,513093,197906,366099,972082,45698)
insert into table_8 values(420968,762885,276038,155326,260402,781223,855531,643794,708290,730727,588849,489866,415532,851751,745940,720930,890919,865020,327885)
insert into table_8 values(825052,520305,787391,134445,460659,492280,207776,165936,621696,534394,957844,204332,58483,450834,770406,449176,730040,460171,530820)
insert into table_7 values(875028,968073,806201,740443,576728,539725,191456,294993,878297,576244,607653,392270,596242,621239,423475,436550,598471,856524,621721)
insert into table_3 values(785723,831407,12204,414211,696555,847671,661563,984791,800128,448607,981408,603802,60244,859835,765434,212148,146919,761186,290329)
insert into table_5 values(716320,290068,621927,972008,372216,741957,109417,898144,279481,2196,564566,619645,395438,315817,221199,806975,818996,855630,205419)
insert into table_8 values(416854,722234,676682,710951,764084,279993,577185,194186,162437,355005,404732,548576,18083,203176,463890,758637,647926,436069,134293)
insert into table_6 values(500244,828545,744850,374497,918711,989844,811855,17437,537431,598720,925644,105786,963711,742573,990626,437455,479901,602798,990346)
insert into table_9 values(388753,592404,572742,229816,545144,135416,500532,287534,963311,387726,601658,367704,163362,314410,913957,845538,961867,245055,14198)
insert into table_1 values(648452,930995,753680,191094,141907,77958,627379,989538,729977,158323,489244,161769,613109,66268,113644,762140,798224,703476,926234)
insert into table_9 values(380120,23048,369507,22092,355437,975633,848407,867380,663703,577746,182067,752956,513928,978140,697151,143547,723906,617759,202744)
insert into table_0 values(132506,329928,744550,417713,138835,309375,809777,995951,502360,719860,223266,616100,663902,487700,606892,491355,782588,561241,161607)
insert into table_2 values(416689,337932,762110,213666,473402,38639,90270,792155,970074,207512,73347,60597,412770,158961,768405,31276,786193,783854,940661)
insert into table_4 values(329335,958848,249074,2259,770,279961,882882,639509,875130,102800,916559,876277,806390,118658,239006,165563,173368,668650,64119)
insert into table_8 values(689605,470962,331635,224551,295369,125458,56727,348503,641767,801202,879800,906993,857840,91000,913703,853176,103029,669493,365964)
insert into table_9 values(587182,235193,151854,835807,489204,832477,783614,940715,223139,794713,441759,104175,942319,36455,437726,213695,39970,570968,709575)
insert into table_7 values(641943,795549,382732,359505,810453,628079,949371,165295,394644,453460,684868,509116,599020,753389,771877,539967,972874,440114,57161)
insert into table_8 values(728795,287525,218760,528515,28167,288551,193479,199963,338091,70332,79565,709159,38219,451736,364248,700041,905639,473366,769897)
insert into table_5 values(684522,65781,338300,503892,963260,307230,20295,889128,904202,843683,534588,27850,379971,292324,691873,534971,391621,132905,573063)
insert into table_8 values(571243,917504,850195,670019,707734,943513,993152,681578,238497,464585,248200,65613,886242,105737,26540,540532,863500,815590,494204)
insert into table_5 values(65788,35149,905384,222039,229892,732910,731083,512419,938381,347524,139849,553074,822169,414589,174404,11488,343865,76784,469541)
insert into table_4 values(32220,136188,178570,269391,667909,626485,26676,414271,915121,947104,222248,452340,702157,731705,660457,238008,737436,111147,678925)
insert into table_2 values(864305,353374,17813,378863,74360,53217,60372,279477,448226,551584,221368,725344,450823,480634,556374,72793,829834,442288,384939)
insert into table_8 values(492667,738514,663370,448830,837444,345727,679664,787979,455316,527598,930871,633652,692210,615132,946634,502848,323333,743572,71525)
insert into table_5 values(68091,241122,289858,19860,984012,719300,868114,120236,322236,967854,897178,318897,74649,345716,407112,87883,831303,167702,260057)
insert into table_1 values(5094,4399,872741,688754,517079,847566,89152,28310,258133,672200,67451,71238,935125,32693,882085,970800,592840,600587,697489)
insert into table_0 values(164870,332281,770303,186190,770706,343270,483550,248004,292204,949574,12338,983582,781035,179624,1382,275036,403144,151263,815362)
insert into table_6 values(280673,576171,658291,335551,105708,370523,123941,63061,459242,646721,793051,74109,454867,626763,470415,6506,546008,553176,94736)
insert into table_9 values(673069,163521,421784,514340,873829,511988,396623,891491,764025,379815,64204,379150,99439,135723,150740,347443,274116,484913,613365)
insert into table_4 values(286156,527247,229111,593394,19903,67632,344435,928166,775453,102277,361971,489040,376793,881371,817111,789559,597454,251953,495640)
insert into table_9 values(799180,954218,876361,70637,724553,865982,56783,393833,265655,330187,758050,544184,828038,972694,499993,610141,280574,141252,706979)
insert into table_7 values(29485,934258,69984,173515,387639,6629,483982,727444,584708,659883,477496,753843,739877,893706,771336,561057,580555,487026,466180)
insert into table_6 values(758626,776355,818308,300398,238547,228114,882811,867964,38626,140873,350900,901617,967015,890943,635696,93200,562896,420184,760865)
insert into table_4 values(52874,251023,450589,841280,339632,408087,591645,45380,121106,832859,920773,336019,972631,563896,62055,902905,861971,865754,942527)
insert into table_7 values(255783,283338,730229,173784,262990,759565,865334,531442,324021,816328,547201,703351,125524,575761,855867,355234,173109,161565,912830)
insert into table_0 values(180561,314450,337604,529998,688052,924733,818493,982114,489436,880344,835392,370946,719865,507881,166214,55368,228510,226298,453523)
insert into table_9 values(754875,321426,148252,343751,890791,956325,634547,912057,515891,973256,743515,926121,407389,288585,984016,987124,652731,982453,711151)
insert into table_3 values(945102,662642,305985,540010,802502,318654,837745,436705,932919,694294,171544,119877,931752,553938,384931,178439,741798,45813,120616)
insert into table_7 values(124591,645689,403482,944128,780368,723354,607352,67794,761350,497728,956455,604637,433476,351567,244756,951655,780126,801953,141267)
insert into table_9 values(672211,446071,663732,253439,190718,292474,601283,44187,856082,90861,409081,679092,496462,791979,52573,551902,400114,570796,422243)
insert into table_9 values(796427,287426,216092,366724,6319,100669,388827,770592,399015,447698,737170,349556,4929,942893,465205,890808,381943,614211,367633)
insert into table_8 values(604558,551029,345378,222125,102731,585888,942097,957480,914000,840503,157051,771155,343261,468750,149763,410818,42538,238814,179657)
insert into table_0 values(919061,305155,569679,440321,896933,67695,933657,362194,748997,790481,246793,403334,564821,427982,312788,275287,138697,463155,554773)
insert into table_5 values(226989,619516,373602,392545,776964,624472,700939,421465,139262,785131,665221,194616,355372,717208,994247,418947,604104,154339,798118)
insert into table_7 values(966093,220843,378372,989333,225516,171065,615839,909146,190276,121212,141146,697867,869456,459812,832478,149392,91857,904029,990778)
insert into table_2 values(725104,962110,763692,515757,768459,357897,619513,27107,99297,490745,561777,917889,224357,60758,950990,680662,892703,914954,141558)
insert into table_6 values(620724,689561,127790,836002,680551,144563,78568,944474,636172,167128,16604,601544,87659,333154,39658,210408,158859,800783,407886)
insert into table_2 values(338092,668583,404848,372479,37158,999148,819864,85894,357964,449827,238795,182288,796087,27492,67516,607870,995802,165062,954053)
insert into table_0 values(363730,115416,158826,763509,737113,650557,767002,475105,7989,35434,256595,937715,18129,293432,110456,294359,380291,265430,149857)
insert into table_2 values(458502,171099,201451,675029,285431,323808,761586,633738,587318,762671,291573,589744,666912,128856,524340,201106,649769,250060,120260)
insert into table_4 values(499798,178913,307444,634823,124230,5236,708282,117344,366099,425807,140731,246048,792978,393174,399820,192235,347116,299159,593276)
insert into table_8 values(529741,765354,183742,105005,287185,630676,714751,946377,113089,301430,307967,387678,734098,456850,815635,908820,13938,90804,767842)
insert into table_3 values(763538,619762,255512,293181,36510,388478,662841,183205,233636,813411,663406,825751,435533,498566,513704,155257,792021,550356,217240)
insert into table_1 values(186421,160577,326109,744848,80160,532744,338136,25823,638243,552869,96527,624050,936335,799097,478115,2340,184436,517719,795533)
insert into table_1 values(845597,95831,514915,552347,568269,725368,353001,841020,92821,38600,561467,490223,185977,945031,886603,280724,557023,540126,191632)
insert into table_0 values(919987,629105,786274,682927,334303,710526,11618,159465,580736,646797,616803,542201,597536,404337,707589,73871,171308,425660,547842)
insert into table_9 values(256389,367766,706664,276760,702227,610098,853958,2860,683370,121380,690276,202763,540077,852222,633899,770701,145239,640903,600427)
insert into table_0 values(398763,999964,615877,411423,693940,629346,436269,58707,768426,473085,305496,399403,712300,30871,607458,148635,524054,10896,541550)
insert into table_8 values(925158,725153,78512,982928,402245,956877,431629,892702,705631,956687,702475,163445,302444,862015,270844,77363,979789,818506,27141)
insert into table_0 values(591281,702806,248262,322408,559648,785128,389326,805517,746395,993115,345074,323103,412002,580595,51917,970755,165033,801649,303580)
insert into table_1 values(383203,337592,938751,758795,121662,175448,609133,471900,463844,71339,851764,100619,196262,306910,516339,607863,516646,956304,719894)
insert into table_7 values(643286,994353,394374,324437,786789,961362,903928,9885,474866,862094,894386,494476,178700,562270,860995,515325,99436,211878,834084)
insert into table_7 values(412682,979037,941295,851690,196422,225556,812522,519901,922517,880980,314358,967595,725900,48437,249787,937892,112014,137130,646251)
insert into table_4 values(15533,331973,957543,485611,631099,50682,738405,709360,497274,701762,740450,74255,365732,864149,899570,518940,184509,67481,74708)
insert into table_2 values(964914,836237,256213,655845,947798,387544,56811,958609,286911,714768,692696,745949,829839,15133,386701,974329,115929,705348,951337)
insert into table_6 values(540332,463334,121111,218124,642073,108189,891035,54714,859987,855477,6224,707034,677978,964625,338115,333532,46214,997741,622656)
insert into table_2 values(916242,409506,540407,342820,652422,73670,234237,487200,917332,805019,160630,456077,417358,809849,722483,403544,851552,538676,627905)
insert into table_0 values(347589,67389,188062,855407,422187,178289,234530,6995,295264,421854,652763,348522,458859,191,111031,17231,709532,308726,882861)
insert into table_7 values(352185,954588,741731,164786,536396,264435,944364,567892,520385,213263,671473,299006,112963,661444,464144,200063,101668,956236,384676)
insert into table_3 values(88541,553271,178624,510577,434638,654118,173777,654153,530080,395491,396671,897271,875465,923863,945454,374451,161448,873491,772333)
insert into table_4 values(243605,498833,124676,80989,176645,937706,613979,552826,207740,628811,343833,111961,792864,858597,300073,719248,385139,168683,404392)
insert into table_5 values(831286,647143,70139,120131,927748,295267,873231,149077,217622,298055,42076,539980,252149,494640,236275,713917,521953,491506,366434)
insert into table_6 values(723823,746053,466269,592875,744911,215112,575526,994713,432651,366015,479315,844337,54163,852959,391910,393288,768311,203967,496672)
insert into table_1 values(402684,777077,562738,355702,709840,416873,392497,819867,985176,554172,958705,157169,642625,960364,283016,128471,242499,149653,600812)
insert into table_5 values(531838,853742,161856,828116,588137,481824,52391,501740,269967,387949,818201,222528,716378,575552,652838,612620,166766,73724,222013)
insert into table_7 values(683306,22132,154232,930364,463100,794209,942993,499183,651112,747605,50432,589605,492128,790068,755370,227901,301927,694041,853891)
insert into table_0 values(713280,835122,144112,559022,235846,595802,175949,748939,571823,14395,315398,545370,946083,299446,321100,158426,611508,712891,593848)
insert into table_1 values(904520,60817,168710,358113,691862,50891,613441,368878,606294,427584,19142,286350,207211,799766,628402,420176,565318,207732,988849)
insert into table_4 values(464298,87561,921153,726489,906958,453916,684509,50949,224614,418294,168122,87186,525202,508259,238524,374285,926380,850134,416486)
insert into table_1 values(351510,579781,846145,430670,369065,139732,994633,767822,808210,575602,255346,116655,298727,155131,803134,249347,118878,963855,966749)
insert into table_0 values(645673,623401,153907,560356,737822,507408,445040,420767,253363,129993,487502,681098,57863,611957,163146,807566,505214,872131,546718)
insert into table_1 values(11653,645039,424862,775986,414991,736671,321797,747882,90533,371236,146088,413183,300511,940039,722181,581937,644929,239139,758334)
insert into table_7 values(538443,790668,603449,871210,553038,351113,184488,254643,847995,116098,865830,684153,809379,966386,445456,456297,43063,377717,519868)
insert into table_9 values(124023,602953,686919,299330,998642,26863,378437,972374,120523,530035,971700,272032,591213,653815,330525,825122,565050,211842,229776)
insert into table_5 values(546837,792314,464253,708521,719754,786720,522147,143902,594497,291810,537404,992313,804608,129950,53216,73982,149981,874575,148548)
insert into table_1 values(920498,469180,835013,614497,361417,970200,59150,760064,430979,837711,371123,957051,683422,2943,174258,446977,199315,456205,886746)
insert into table_9 values(33188,812226,591428,635563,165707,118274,595376,888655,333018,335459,76549,590447,645961,768584,80661,507843,482088,490328,170602)
insert into table_6 values(842792,434238,881470,955554,82672,731811,187105,165242,41667,743827,570744,18799,173049,149332,706530,449836,74095,758090,867272)
insert into table_7 values(321282,390437,67342,520918,978478,5964,434660,30232,53975,695778,509437,4780,433368,975905,703621,686833,643659,756699,906719)
insert into table_1 values(977083,732862,705683,125805,124992,386063,724882,425311,213056,925295,161447,401282,284177,835832,818903,168898,275429,430575,968707)
insert into table_5 values(473944,31329,244630,253788,222984,878916,29125,875374,202776,278407,394900,951245,75330,318699,459382,677768,45724,917456,673804)
insert into table_3 values(443330,706328,972572,727103,651074,820802,973200,147247,206740,744859,896260,211077,289203,374618,946553,554437,857202,645655,593205)
insert into table_9 values(10330,875527,749414,472492,615619,121108,165811,723083,91598,33519,476555,357268,97026,380935,361967,336583,588273,454562,61844)
insert into table_3 values(815367,948581,507634,575863,156466,259411,535932,328153,360524,625940,137824,713242,467536,229803,341872,950159,897157,900242,844641)
insert into table_7 values(895468,117408,37160,304461,412229,386441,708912,892647,239316,855297,441114,565767,151880,639529,502104,875406,166452,929258,366061)
insert into table_0 values(730292,429453,56992,97419,631964,420191,585507,222934,990229,95015,366802,682460,488823,96975,911709,87102,743780,128921,119351)
insert into table_9 values(8356,71474,965321,594925,925881,104230,220408,291693,6876,625061,55603,656090,970470,314096,618197,947290,836120,442495,109565)
insert into table_2 values(846097,624860,859748,294025,453657,439437,404568,583959,409514,405722,301238,289522,874800,647875,709608,58196,428190,362183,947839)
insert into table_8 values(310458,685583,758366,650719,141798,253501,867456,406271,290481,103196,781421,4983,730441,79715,31820,825725,804826,422207,51847)
insert into table_6 values(448429,614162,137409,588665,170462,665818,438150,117643,668528,326140,785861,386353,364404,837029,707219,96978,801676,84852,54790)
insert into table_0 values(934791,342693,15227,424051,500365,932799,252146,697397,847036,430903,667011,657255,878536,833517,932264,243527,843386,762292,576402)
insert into table_3 values(264442,809254,198968,985440,438747,995887,819999,200146,352290,415881,774977,112332,270651,393717,180302,626158,391958,650748,139065)
insert into table_3 values(837961,687876,524897,56588,442892,234777,784707,693279,686644,767311,628135,172078,293218,143089,712960,558003,559860,786451,48663)
insert into table_4 values(281482,538351,91729,993388,589854,114256,562284,749296,893281,111363,683986,649754,537433,497774,810342,24539,117230,740280,592465)
insert into table_4 values(653623,82665,913113,642939,817467,665285,889743,274099,189100,685896,608692,599848,147036,127012,604014,223474,2741,331382,721911)
insert into table_2 values(902308,732886,153690,684349,401455,678790,756196,126628,257471,96972,791037,428151,670149,96263,411402,570828,427906,932402,714734)
insert into table_3 values(393744,420570,423077,309028,821595,711644,264611,215091,837215,268845,201142,540919,18296,72031,304038,692216,88979,38351,98500)
insert into table_3 values(87956,638436,417328,342757,485728,47446,361635,316885,328458,918350,699780,402575,784857,625043,923528,968761,443043,653189,184384)
insert into table_9 values(293929,396844,7471,147225,547391,976591,699266,561205,524442,703757,279040,684507,752510,500066,40713,522526,903806,419604,257812)
insert into table_0 values(730784,862290,54285,738239,960796,934246,140676,301224,659918,295427,833121,89407,516786,318748,702335,801782,426206,70880,937843)
insert into table_8 values(666086,581885,453812,688237,713835,169083,308626,698086,647882,62223,922997,658456,425284,822636,423619,324569,867123,402409,291616)
insert into table_6 values(589765,680754,217540,346936,640808,906377,224953,102600,850936,795286,294157,49803,245830,940035,27488,338681,763475,441706,424736)
insert into table_0 values(848651,832188,444653,699866,240475,8312,163656,368668,50740,695308,748106,326110,43740,756724,202518,545349,406220,692835,945830)
insert into table_5 values(587073,667687,151332,926236,766139,644982,726424,846052,185653,521145,574943,495382,522217,373252,322957,109506,967068,498679,23237)
insert into table_5 values(654931,589346,175590,256917,247685,464600,354901,927876,720908,658092,446660,294880,151574,787231,161935,931697,685887,498265,121451)
insert into table_8 values(545435,403208,222795,374316,365022,132357,333815,367260,144163,821073,416660,197876,984496,649677,388524,400134,469645,256295,866456)
insert into table_7 values(98265,96266,638475,755532,66050,96611,625485,322387,660959,259627,419106,212222,979750,226992,141324,946899,395397,173197,753031)
insert into table_9 values(173659,202326,104210,163297,797435,976384,968940,998361,898213,16929,610485,810575,799851,991596,140681,374589,560711,378007,404747)
insert into table_4 values(48349,779682,561361,602499,55444,218484,532190,654857,319495,801595,719605,797664,542290,127485,478551,13450,309365,270930,698308)
insert into table_9 values(59068,938877,123791,434797,9589,538210,73392,791441,31075,343719,377283,705964,949240,288553,895697,671168,317742,567555,44514)
insert into table_4 values(862155,131821,341094,756309,298262,810596,312896,465379,735874,564933,219520,257741,632250,76784,163619,399482,412036,437800,147166)
insert into table_2 values(320485,801619,674305,341567,829980,350135,445641,176629,649839,958485,242641,827754,439374,983080,972639,139113,281903,689463,138209)
insert into table_0 values(206387,712492,475536,351761,411499,812941,53707,85870,495171,120201,202500,442142,427489,807341,441364,769301,269928,302275,608501)
insert into table_3 values(106997,652347,388735,600528,13636,181798,336353,211577,329852,435630,72666,17749,7887,107815,822181,17704,837081,67592,577487)
insert into table_4 values(98583,574273,545437,390955,112297,560577,660902,423284,899189,666554,466953,491214,96569,42992,233047,467376,336486,173455,322368)
insert into table_8 values(871015,469930,567678,610732,819446,573785,505147,236473,479379,147841,272285,653374,175483,877012,763487,158983,585441,437066,83876)
insert into table_9 values(228223,260316,144719,722200,541202,463780,317690,396909,979196,136651,173894,753261,84153,534871,551192,427420,911490,924858,952426)
insert into table_4 values(743000,344627,56643,657365,544835,34577,922390,122024,942226,117747,789185,92819,773075,163694,825093,458529,182096,902906,800453)
insert into table_9 values(922474,347265,49035,638938,72503,432593,945597,816381,252987,271129,425137,907990,330645,34597,806066,625945,153686,880810,704682)
insert into table_9 values(274907,243914,634528,861940,816044,660941,126832,441680,501911,156410,563438,451230,415904,647680,273315,328682,37242,888664,790821)
insert into table_6 values(403834,967671,668904,589284,342152,789310,817550,924137,37028,189084,742578,639688,92133,404697,659302,317208,484192,713034,486409)
insert into table_1 values(548386,711991,225284,399728,92862,477721,530732,777379,929204,875222,78327,911487,400455,84979,635996,706399,294384,899065,876306)
insert into table_9 values(27794,379717,47080,3108,138063,740514,67808,391930,199349,968284,125021,240369,224116,187236,871648,114755,288743,196590,875881)
insert into table_3 values(770599,383885,291033,257518,549221,267589,400079,35277,936755,611373,635091,788138,836073,963626,239651,831758,91966,239150,666002)
insert into table_1 values(715536,156487,195845,5722,805339,747969,270497,363543,574614,105948,848466,409627,556198,613885,660825,987366,200800,746361,966397)
insert into table_0 values(577806,109020,561870,954189,95358,331447,590949,850293,860812,501491,349108,88899,413532,860808,48490,227162,758872,584283,914652)
insert into table_6 values(563289,125813,549695,381997,195116,14716,166403,48884,392971,449153,68058,511066,86590,811789,723655,91195,955924,710899,737780)
insert into table_4 values(599353,846417,629543,922345,480091,71612,131122,593531,793393,155407,853712,539093,814407,221533,167644,254578,333842,364589,891438)
insert into table_1 values(481490,352370,20649,123688,636079,295683,541056,355565,550852,722665,839165,993974,502527,846775,596477,821757,403871,702110,346209)
insert into table_2 values(663432,618094,417950,527734,681051,895570,279008,981947,955716,758442,159098,453659,295108,338086,285331,319001,175273,920419,575175)
insert into table_1 values(348176,831039,975285,544739,288117,235255,714523,116024,668833,839185,144352,615458,39820,250998,153833,703020,577167,501571,594503)
insert into table_3 values(942740,118288,467236,946367,24006,338222,726034,152450,790625,535005,677534,288518,13834,617973,694791,438431,756783,702636,95976)
insert into table_8 values(192293,108995,346835,231163,681584,699932,742767,602969,102246,69677,774156,155099,26065,131833,286892,912543,267207,41687,636366)
insert into table_9 values(812950,760587,137508,862916,512089,675063,775027,295334,594541,143123,432098,661189,319427,731289,151890,209807,865347,816135,547349)
insert into table_0 values(992670,554547,855260,231585,630595,376339,95979,496756,199658,748317,235895,883837,954502,902848,747878,159414,138268,501948,25832)
insert into table_2 values(323098,920172,195444,261091,517728,632471,851216,282506,889980,434398,285287,896342,724535,979224,798537,197651,493776,189373,654021)
insert into table_3 values(61380,705819,516607,824821,794435,843600,625159,647209,506373,184638,73206,264158,690561,205992,686742,358592,969474,591290,13443)
insert into table_1 values(80755,211776,923265,50661,902570,594004,776739,754638,364828,700730,207986,222400,637676,750706,512289,736577,728896,977181,933061)
insert into table_1 values(545957,206929,142733,319043,616865,391045,16607,253226,852815,944695,896825,890334,888726,677799,452517,677482,879962,872222,851298)
insert into table_0 values(53980,651408,560633,305393,363569,772914,12036,314975,164905,836439,37982,619307,271093,849512,90362,418263,825786,43276,825722)
insert into table_6 values(351794,448213,543667,742177,828840,711527,961324,479880,282106,158212,655417,970984,498878,2265,438136,23379,335999,903362,660303)
insert into table_9 values(590967,298395,812861,882769,965354,856603,787357,20536,352468,947223,310646,447328,755522,973218,343626,46789,33981,192972,702585)
insert into table_3 values(603204,943972,596682,659088,562247,972333,593722,384808,967012,408018,175331,902519,79511,593276,678768,143418,911897,318580,472420)
insert into table_2 values(887574,42544,278873,858103,288598,67152,59016,522101,651263,281732,541600,595887,978286,395436,337751,686838,105204,361521,199469)
insert into table_6 values(259278,61801,688351,505610,388803,224888,890454,859031,890606,571467,700288,519352,847196,26042,317366,755997,897030,777932,900964)
insert into table_6 values(52243,979486,230278,151954,921592,447315,672776,409433,833094,713513,271552,294532,622648,502445,968376,669046,940215,721628,114441)
insert into table_4 values(499815,747130,466125,495966,794973,248659,741601,33042,405894,772276,178395,296536,960010,191663,38182,85973,275361,232294,442784)
insert into table_2 values(703325,957597,589772,238210,332769,592991,364985,200929,638318,231345,288219,12199,940393,578105,356077,853084,63179,815107,650915)
insert into table_9 values(5634,36919,202667,572990,488893,453685,481207,865862,286840,552995,670216,755894,488939,874207,12775,151611,176884,832034,440530)
insert into table_3 values(162053,907094,564278,151353,70944,548665,73972,584210,677460,527543,762,267658,355375,149290,479852,379680,207905,950451,289844)
insert into table_5 values(525447,697750,466323,201529,737902,726836,199969,23690,303704,518815,993255,850642,746152,992265,454117,834287,893008,391632,400116)
insert into table_3 values(254988,759480,103736,938238,932550,998103,688472,664044,804684,693026,333593,720364,133297,115427,249617,322827,885501,167630,806478)
insert into table_2 values(91540,812525,382026,961437,646872,586385,30376,34876,533282,549486,148142,318294,342665,279475,688713,907077,563857,273305,523712)
insert into table_7 values(321349,135318,900806,972387,154877,335292,386195,895560,266486,193853,625025,343605,921085,143622,996505,742033,977242,988719,612088)
insert into table_2 values(330112,168513,677759,216793,619410,628639,925423,680637,675612,661370,950030,151623,622373,962444,381919,936073,288400,112645,264013)
insert into table_4 values(166641,972596,623826,409035,289535,363072,460573,96331,348676,485472,122988,401636,727226,956431,588985,246337,285175,324036,109083)
insert into table_5 values(241467,503717,84018,788076,346363,189716,669484,200234,148492,486951,435956,377834,637010,271405,570460,643799,544333,733056,902292)
insert into table_5 values(156633,230702,804618,474076,952706,454017,27664,218549,634404,459493,23864,810344,511285,75396,318375,257423,82574,401993,734230)
insert into table_2 values(832032,12437,616849,953710,351789,507970,563228,303892,200541,686348,329705,897944,639847,909970,787527,951111,606049,341517,126482)
insert into table_2 values(748589,545014,737801,243371,915036,285618,601172,877420,534832,240218,933610,708951,39831,421361,79367,649048,181485,76341,913280)
insert into table_7 values(410513,602708,447006,64756,280490,139534,870254,493986,936202,297217,781941,27342,90984,820258,650350,110409,16603,684517,533941)
insert into table_1 values(630625,918747,996827,704885,444689,141084,349908,848466,329579,915882,693559,881565,532134,393016,569089,879028,648910,787718,175820)
insert into table_8 values(929492,816819,910034,392627,907532,743961,526351,68001,64419,66524,60868,126105,478719,1999,680250,258232,676596,559978,530458)
insert into table_3 values(407948,683735,610273,388408,279848,552294,899045,887854,42932,406947,612477,452444,750031,492675,344105,499614,838469,839084,27394)
insert into table_1 values(453394,172862,240019,7389,413026,683284,765899,690818,682389,886276,748357,403776,542058,903625,558888,235563,669039,259666,482976)
insert into table_1 values(392575,22006,152289,872798,307727,779244,384694,663773,4483,930839,507319,423259,38502,32247,640200,373388,902668,906163,643067)
insert into table_3 values(774667,687805,789198,550141,197129,924275,639591,811114,934098,680255,389614,129844,309990,195862,112923,963279,995272,126759,160004)
insert into table_2 values(340816,479760,934350,139342,699789,742615,930253,730139,167604,493354,767300,589055,866135,120918,305330,60732,935934,533399,281817)
insert into table_2 values(102810,441582,962161,578011,965210,459334,886367,960845,66486,425684,405628,891629,382158,250363,881512,13290,831885,8713,396415)
insert into table_6 values(883761,859051,734865,161204,991282,666724,393587,852295,317783,217629,409529,780398,512374,116458,567515,798096,842282,478656,706887)
insert into table_8 values(624712,745837,197039,693763,502901,174022,688710,98632,810666,117143,330244,549778,797871,294400,288032,951426,280790,360077,783276)
insert into table_4 values(788442,437152,426448,704006,377274,104441,787150,344236,172893,743904,286913,425060,665687,433787,362218,344536,250108,481781,939991)
insert into table_6 values(536231,774283,693255,999707,817862,714319,77292,379267,449752,741978,291738,73657,263324,129973,612754,13863,655531,262903,593937)
insert into table_8 values(575411,572782,572266,409506,135270,596366,420705,482376,412878,501443,88081,995435,89997,769081,791485,678832,437871,702291,268423)
insert into table_3 values(782527,423425,95646,983404,977094,514932,778615,682863,675562,863561,816211,411151,378891,244054,634555,813836,226444,118439,659599)
insert into table_8 values(539502,126404,949112,653065,51847,651676,830406,639501,590167,854282,141356,332292,953473,903959,172441,379094,762223,801717,602660)
insert into table_4 values(931614,47638,625213,522288,274002,567513,429052,889879,340668,631975,258507,582546,742134,830711,549871,443718,952190,407663,298825)
insert into table_0 values(313496,955002,145583,240927,514433,570438,460844,693812,666955,636240,571757,863419,686174,969893,139014,30687,768235,25709,688903)
insert into table_1 values(663762,548532,433683,979310,232123,665024,419364,843619,135306,705227,480786,413459,489565,787870,791931,16753,749151,460977,788498)
insert into table_2 values(57621,457221,225667,803391,964430,578774,3498,732506,526028,977660,359249,236019,474730,927020,334855,322900,409754,904236,647331)
insert into table_0 values(27382,124747,488302,344823,261734,994060,259579,174381,609981,473806,502684,491778,392893,177156,121480,152759,641611,442896,539338)
insert into table_3 values(654061,787777,344967,803308,770829,15289,240886,106144,839276,439523,895053,465621,970591,920905,52678,136548,212497,563917,778723)
insert into table_7 values(557089,256072,931091,175497,477514,784109,538423,574569,770376,283994,882150,169260,640193,318432,496832,738089,79988,556851,994472)
insert into table_4 values(433053,476110,492769,549816,810594,145515,692710,451815,465722,627990,857208,889170,117965,50045,695168,314886,250212,631265,631031)
insert into table_1 values(862250,885014,331768,58588,145451,984821,528923,125877,884715,159716,132126,877475,888031,736245,815697,915250,179298,196339,573740)
insert into table_7 values(216360,547262,536862,721088,921114,81091,694831,148331,810934,303070,891751,438089,342265,939797,355298,132012,333378,1051,314179)
insert into table_9 values(582244,249104,906985,788124,188595,766997,454998,153877,513261,964780,971053,121421,975964,502678,935230,135694,671425,744358,476096)
insert into table_4 values(518081,296496,403351,312747,379793,757378,77819,909502,314076,617473,984803,770424,521416,161872,71214,415697,868204,817005,97026)
insert into table_7 values(844887,552096,207999,655651,769578,214309,675702,81369,757222,542163,290973,437045,489060,125787,664905,85795,445246,304440,837561)
insert into table_5 values(578439,434593,551025,484287,328466,476297,447107,361737,893913,591499,318662,863905,149542,152797,505192,60640,777798,958866,69004)
insert into table_0 values(937259,270904,109013,427812,582097,213536,927995,745613,250664,533654,317064,745065,696348,279656,211938,476972,238231,960320,209770)
insert into table_1 values(428197,386048,441191,292704,695242,292685,82619,721773,782045,535230,437170,509702,474313,830319,686016,678853,952517,309998,197973)
insert into table_6 values(165700,761636,569985,874957,832459,676572,979742,204881,221343,901460,892672,311849,336912,608382,735809,664628,932898,509585,342835)
insert into table_3 values(671854,311893,122041,904219,621722,940972,398759,936014,847747,93834,423177,576941,612021,637472,245369,7578,122269,707285,789021)
insert into table_0 values(285257,528703,115403,703573,309373,861964,581898,739532,226375,186911,494003,992691,840112,717361,571631,25128,607717,72113,176604)
insert into table_3 values(851170,170806,706299,390723,95744,411185,646125,604636,923820,545293,684798,81740,809704,191057,331117,510262,783369,927918,166759)
insert into table_4 values(310518,713251,12415,115293,862201,349879,519989,187184,154411,275565,868746,499733,817673,354092,938944,698379,869945,624580,869468)
insert into table_4 values(123163,970094,323645,842937,634573,986809,152948,512713,89714,56330,555994,946963,428106,848858,871213,772628,918011,33780,448393)
insert into table_0 values(836792,631785,110941,532175,383827,65075,228297,578295,573103,70656,140942,732178,429715,882179,797656,933965,270311,873175,607733)
insert into table_2 values(756723,74247,112258,167272,22892,121159,172689,301781,214984,20373,513949,627301,633547,190734,241469,531589,57791,824093,291825)
insert into table_6 values(105168,990008,46552,999930,955811,592379,72440,798215,781082,157787,886902,420337,20424,694521,928770,636173,356384,108362,171865)
insert into table_5 values(587867,996741,159517,53957,647310,228132,725096,571863,928158,867533,241230,687902,806284,665118,372987,371151,25335,618385,278070)
insert into table_6 values(784714,420896,996394,910078,660218,71048,406944,830905,140791,186594,854808,226013,878909,452094,297585,899962,449463,963504,845554)
insert into table_1 values(410691,722588,295259,888163,267205,288557,373095,699151,680336,267226,202251,241933,686260,844337,703006,31680,257187,378023,742581)
insert into table_8 values(827663,766469,361723,645117,182051,299276,766631,423108,103666,131526,819506,270593,873507,412338,479933,988029,292882,708856,619357)
insert into table_6 values(418321,773898,42960,584238,478470,818101,163194,374566,789310,504017,229498,8699,91928,631430,23639,25492,848259,749922,195218)
insert into table_6 values(606133,916341,427167,850660,148090,58240,6808,36854,790768,317486,406565,152643,890520,769017,483563,177787,926350,986518,35961)
insert into table_5 values(653640,920249,861827,799150,66269,15487,79504,732502,446480,331711,87433,642094,252750,955806,212842,562023,785056,742941,580540)
insert into table_9 values(781542,224636,503876,386112,922769,860472,988206,713130,540637,995954,847234,201043,539434,458887,478424,679301,670592,939943,75495)
insert into table_7 values(811000,538032,585982,698667,977199,483550,832544,317247,566945,949272,400209,892194,943568,710307,706433,197815,803999,525758,762553)
insert into table_6 values(351424,974448,611226,419359,570372,5893,611951,293338,14527,542730,355323,449066,486931,460211,446892,360778,39435,482133,820671)
insert into table_1 values(561891,475698,843916,185873,20959,636643,556249,263677,559876,709398,305301,479895,368807,501790,504227,732217,154476,412765,910392)
insert into table_4 values(410809,48666,490032,250535,347108,149481,21790,939335,42429,245004,784999,305235,781359,860901,156923,515194,790857,288025,92818)
insert into table_0 values(266681,684330,327623,113523,937347,116279,213403,491323,642525,131240,551124,740429,199092,465557,571352,868904,134536,744833,151257)
insert into table_9 values(899342,216767,353182,648661,848320,59768,705832,214791,378462,644142,772827,916420,351521,798201,658585,120012,310373,903519,409766)
insert into table_6 values(688600,55726,971994,512318,49264,945462,961710,241812,900052,565766,916352,417548,870598,148996,253335,110555,439952,37608,498986)
insert into table_4 values(486611,458869,491324,351911,566247,542072,634654,216645,269006,87908,923217,300009,739498,674315,41008,291397,191606,22548,682041)
insert into table_8 values(414489,566807,96147,483140,461196,541946,490965,604860,874329,397319,333741,505481,941707,528749,219772,422050,361603,908486,396814)
insert into table_8 values(59103,396429,234451,246007,462927,970719,490651,727353,62309,875695,750283,425924,11502,778924,406359,136058,811245,774122,936533)
insert into table_0 values(888961,204744,219090,837479,758258,22041,783601,949129,87829,225992,679264,955090,167782,709159,514279,642823,464851,812765,638698)
insert into table_7 values(104389,11648,394304,85296,569684,571403,93010,126761,627603,99028,954481,706411,342337,238146,38384,756187,767785,575141,540680)
insert into table_9 values(760705,203036,6114,827538,438352,558533,829930,738429,921991,38524,324241,790277,698103,823165,436490,434922,543654,647167,353918)
insert into table_0 values(347656,913727,461954,542226,412572,894563,361899,843885,450856,720778,407566,834528,98038,358760,13401,672330,326152,11259,817669)
insert into table_2 values(63693,407168,131604,595875,994648,773150,372541,770070,412999,398533,24931,786942,391452,748020,551528,462840,189165,593408,416804)
insert into table_5 values(663454,756412,592628,28123,582015,338150,364938,526029,753986,465447,587718,90902,714659,98565,676954,65019,414210,303951,891595)
insert into table_3 values(446580,948852,8385,557959,324428,580385,957029,771349,393058,994463,845032,624671,291177,694279,944590,187091,821738,484504,41549)
insert into table_2 values(258229,337501,124949,928559,388456,728700,418981,566317,536505,720828,546282,843959,290813,598761,297863,369297,431067,749925,827944)
insert into table_6 values(128154,876007,461406,950684,167053,112278,23532,81250,417638,835034,907080,776639,406132,326994,437948,827483,446002,58001,279196)
insert into table_1 values(56418,928361,688663,887766,931536,30305,566178,123630,486076,382814,20091,64664,42683,126235,609793,972663,886591,205084,357656)
insert into table_5 values(949861,776066,101709,727042,850430,360045,867547,456959,579897,355107,745895,634338,587965,536485,511083,787873,61502,410680,109247)
insert into table_1 values(666525,197000,553441,826777,333766,682548,244708,385710,679001,602872,903112,1612,52597,522385,943410,952160,821191,809202,835100)
insert into table_3 values(751326,76173,461386,124532,844326,751855,568239,118561,396945,932334,741511,813370,873628,263016,386948,196366,227495,405682,732333)
insert into table_9 values(734823,832514,957001,152511,376713,862443,62743,320767,192270,295348,406062,344636,243540,629118,255356,166385,692016,273669,561672)
insert into table_0 values(976336,269088,548722,877494,866255,961290,254790,250019,490347,437161,185295,272959,48080,291603,109210,347879,324800,394547,936728)
insert into table_5 values(600033,649228,871163,101253,596900,368424,868545,439416,633652,537213,937801,552055,866501,331021,779192,76009,428041,717974,207752)
insert into table_6 values(324358,572104,824356,75097,977721,731340,328288,581815,440198,604128,329117,199810,731657,367463,41685,806029,297316,256002,588793)
insert into table_9 values(270886,424695,189386,322845,528139,140486,110726,420772,511452,987388,943220,950144,485200,942255,753109,964084,223116,558324,123240)
insert into table_4 values(216433,220331,526512,939674,42566,429485,519558,991424,163258,162611,824322,25834,501809,675881,642828,268606,621945,950027,424807)
insert into table_6 values(812041,253928,117515,894776,755638,983400,271839,829222,526837,55783,649307,699357,901917,638396,52721,320845,461342,701815,447042)
insert into table_2 values(586637,275381,244927,485337,217286,729961,273415,38775,509448,891882,181525,19621,156606,803616,679533,525050,615671,613671,394849)
insert into table_0 values(391276,482688,47371,28812,377987,623528,445346,135270,748039,697334,819689,3805,941274,227088,237444,560941,630986,581567,143045)
insert into table_9 values(722023,286918,117457,55479,93859,529767,251758,184090,160276,608376,361523,98428,226143,717550,703929,257358,254103,757823,255985)
insert into table_4 values(434548,383904,61521,213148,744768,954101,743028,572626,453680,893384,748969,416162,343642,479966,488070,85856,800721,222467,225893)
insert into table_3 values(484844,831452,153036,674575,982505,916572,388614,381382,355358,763791,995535,206100,424568,947907,411529,158539,851760,588486,484696)
insert into table_5 values(447591,886889,51672,948958,435450,639410,342650,692016,789062,367255,76769,529277,430519,565760,291976,914127,951587,21727,239535)
insert into table_1 values(847387,613493,668846,369914,379663,855748,868909,440206,426378,460709,823088,253194,504784,452074,259488,831814,922920,977590,81110)
insert into table_2 values(897122,268509,309496,156127,455648,343047,794939,333954,640945,381843,735517,659503,313608,765976,864897,729829,896076,97501,686253)
insert into table_5 values(131156,598784,310957,561039,790432,673700,962979,407595,579351,828337,275670,651135,879725,479385,416872,823125,33392,642235,894059)
insert into table_0 values(70410,183836,32133,877922,391848,909206,969760,431779,7040,112104,452051,485944,826591,792758,68849,898492,587035,952472,802353)
insert into table_6 values(375739,921475,368173,544597,370374,723060,528688,542840,614479,755308,787768,67269,973179,968787,69522,672770,657076,326446,110099)
insert into table_4 values(964297,278938,780963,346595,835803,356349,88761,805468,825889,161823,907092,332765,766750,102622,898471,448141,234905,266937,412834)
insert into table_1 values(963966,532768,865928,755051,739083,830506,829806,907337,729507,343172,424752,984181,553611,95149,189268,859325,741127,19675,787584)
insert into table_9 values(56043,867035,828491,383871,360624,197365,421246,983370,257655,47280,405579,754529,19748,726245,500008,477588,335819,325719,957840)
insert into table_7 values(599727,775443,457092,483424,287110,921031,408640,354992,873794,470792,699278,507443,517857,218002,877834,167843,228537,856910,33634)
insert into table_5 values(52565,67725,318397,496420,588372,595908,342885,43487,621386,936055,859609,125527,631895,530288,420624,952383,817079,858171,489082)
insert into table_2 values(481990,157724,384293,800402,77262,783806,943382,956909,991641,402702,106700,681467,203178,178224,598170,811310,773492,264145,980436)
insert into table_2 values(615829,479755,957378,852327,696971,766857,309392,424294,195908,524193,471594,756642,814571,843799,683704,170377,639969,365554,798317)
insert into table_6 values(908864,740896,358312,356464,268339,161089,640432,636263,51248,470307,588121,808929,722092,60262,885778,456801,432143,905021,828936)
insert into table_6 values(325566,268338,315460,325134,892316,965965,824254,157624,832648,286741,368678,290495,202377,15229,471340,743088,810296,583393,797878)
insert into table_6 values(535184,167834,509355,523868,308140,343888,257689,445386,903612,566385,200756,562403,380106,840423,352816,882663,701633,103670,132613)
insert into table_3 values(503428,190815,10613,48989,778349,905940,253328,569883,782089,584086,69516,903225,648705,635155,193922,446595,992692,113175,697935)
insert into table_4 values(93182,737562,904781,449713,454343,864707,163028,384786,154999,784664,890567,483649,344248,973817,340231,967331,904004,443151,757010)
insert into table_0 values(337472,308245,590804,759706,312010,441220,904583,706795,664557,82759,721686,969067,177525,306347,742835,172612,983790,947892,521458)
insert into table_4 values(888004,293619,450913,871133,793097,548394,670267,800107,614962,199880,458953,420715,171021,120732,556486,429269,10115,94631,488125)
insert into table_5 values(87944,888656,299617,154072,699712,182274,894057,114645,624177,979787,158093,220776,699430,262804,578877,867944,489371,209098,910023)
insert into table_6 values(954249,977803,921131,283776,23669,542948,394017,454332,48786,270830,241788,925653,963298,618607,957226,366876,576282,668883,690373)
insert into table_2 values(438337,821501,612923,276005,495882,781634,479124,405548,799306,147668,731725,778644,483357,489410,704444,344680,197324,834742,847093)
insert into table_7 values(626089,738736,430520,67436,832130,360716,280693,505946,316796,381740,242328,350397,303747,508146,984220,91541,149510,176687,713187)
insert into table_8 values(771985,259310,236468,716672,873186,518341,324397,198664,466016,26514,196923,562763,93215,802597,36724,748560,296173,303960,394581)
insert into table_2 values(268853,756201,470912,156208,544071,963195,715100,465272,831496,319586,685725,794840,316997,536725,455362,529202,24656,601121,984400)
insert into table_0 values(703993,995078,424268,58140,701295,742650,668069,478179,837146,623340,297898,293404,558423,987068,310896,163505,33466,392610,230010)
insert into table_1 values(279591,884289,260720,828808,670665,126084,193064,355397,884367,642656,618057,115820,129282,235127,506759,917170,955499,341939,682351)
insert into table_6 values(234620,8266,64800,697320,27133,691396,449828,765608,652836,801423,305019,772644,158510,498620,502165,20402,857120,196415,427304)
insert into table_0 values(337226,111027,58637,784978,618262,161875,39992,705007,280290,690433,681477,29241,755054,149006,678998,653779,958487,200580,908076)
insert into table_4 values(118648,590740,644044,404481,88791,311622,843850,629139,993280,245699,762986,669635,984161,105520,313771,960138,448119,814199,717812)
insert into table_7 values(190051,189582,841573,537673,918187,655402,551634,472225,173134,857651,941422,145109,873500,429027,517069,957289,75974,369659,610002)
insert into table_9 values(385908,625066,848465,160945,184784,444793,43782,212047,956585,785292,765823,236633,202810,643116,495748,914311,366155,581606,799879)
insert into table_4 values(698414,810054,827362,726464,69548,753498,570403,527364,729741,939265,391950,619555,298296,447095,322524,272631,948316,88736,855888)
insert into table_2 values(361381,861305,577386,618713,771640,322474,556293,35976,951216,400314,438168,349130,202386,59177,408064,533965,895493,590486,3492)
insert into table_9 values(153948,376370,642555,810951,347273,771447,25122,562641,152253,595378,238102,601312,422538,924222,182994,630977,640445,926112,864708)
insert into table_6 values(278783,886014,499892,345640,929034,146754,559884,57733,280466,535676,637044,890757,201085,275381,100686,448131,257241,725350,465776)
insert into table_3 values(319275,990704,26342,117793,462205,857003,155941,856677,308315,845194,294656,202753,915782,681439,31186,742929,243141,104694,181396)
insert into table_6 values(997616,937539,733972,712386,954453,271850,105619,728011,790173,286891,897874,270178,93215,577454,94431,817337,944689,516676,753007)
insert into table_9 values(114024,887290,616630,305381,169195,742116,552588,229787,931718,972526,226141,776053,826523,458025,421327,5782,8501,588896,451380)
insert into table_6 values(293825,843997,589206,324026,179558,720391,470793,368094,201791,887130,574089,811554,146382,574233,943366,377689,46522,910987,999841)
insert into table_3 values(947870,864614,340566,254072,922506,486394,343591,978356,447009,243333,505550,318330,678477,471645,512717,366132,894422,900964,951610)
insert into table_7 values(743091,592417,235383,847108,865983,202788,21437,559531,261316,812500,341019,269123,248933,518116,834817,220321,124118,922339,108087)
insert into table_6 values(504420,541234,687497,654654,110080,792282,812149,966905,198769,486259,702027,309608,124061,56366,847005,307719,30561,866893,407916)
insert into table_7 values(577108,13356,287575,812263,6937,834089,451265,390878,644989,203504,325812,879220,834390,330896,926758,113372,857357,48645,143566)
insert into table_6 values(659784,903196,518627,33261,677650,265576,335279,559776,200637,671955,298374,359650,902860,76108,799949,350778,721219,794379,961365)
insert into table_8 values(171603,741153,602400,446402,179485,156682,29592,161282,663462,220433,815098,692608,191590,844549,552415,544451,670772,294863,539942)
insert into table_3 values(860905,227816,633567,827279,902825,782712,924173,399189,313504,832287,384190,686349,877222,84839,837926,143847,820953,939699,673566)
insert into table_9 values(485339,550412,708582,819024,967004,129702,526176,334993,91257,287740,18301,88004,198656,709166,909043,816248,862976,275093,803789)
insert into table_2 values(291891,7488,914648,799529,697013,92616,229893,210252,73972,854390,661275,614016,231826,39386,706771,600950,63067,228753,536826)
insert into table_2 values(264915,859163,967851,75970,644305,393707,136977,610452,427463,341192,737835,75894,742264,114311,996763,91671,986081,386167,790423)
insert into table_4 values(700906,796963,696707,776026,498026,717531,754873,405689,114417,209082,594523,686620,400618,930264,462779,236781,613266,111707,989167)
insert into table_8 values(352275,114704,239927,139482,391624,95182,401652,631730,124730,479285,590914,368216,106569,782506,857396,865175,375622,983189,767836)
insert into table_9 values(469750,992497,243035,712677,788176,707356,119203,441087,827384,967351,724693,274339,593892,515992,536997,599355,729518,895330,209309)
insert into table_4 values(727151,247989,863141,745769,619902,923177,595258,742458,905634,504666,404221,823732,730504,440374,202802,933785,425618,627353,270686)
insert into table_5 values(356261,85086,298508,181863,584745,826348,563597,866607,593496,540612,568232,679049,792538,618119,214963,184937,587204,53061,614257)
insert into table_6 values(649442,736317,404585,347816,582209,659863,870681,278159,926582,412500,312326,976052,919721,854088,317930,782598,87563,570960,482297)
insert into table_6 values(554913,37658,389673,850151,62730,665991,691333,948497,195774,881384,873633,531314,12609,524224,657494,747757,602846,654560,221143)
insert into table_4 values(787321,572200,621978,508355,624568,970275,195628,30436,605860,687214,212858,64066,164926,476061,453472,320881,550039,362998,46609)
insert into table_1 values(942247,86279,438799,720908,585717,667152,683047,643812,193058,25355,158881,488556,219561,587967,333635,988444,880538,411417,364165)
insert into table_1 values(646820,23977,284620,46202,639750,514597,561690,206251,514804,14882,894202,454279,208344,776339,615739,409384,88540,419122,484644)
insert into table_3 values(560127,516448,41405,660741,775540,993637,628764,754796,387992,718672,710157,123219,15466,518997,560589,178051,644312,423279,769502)
insert into table_9 values(800065,905084,313438,984894,155224,918276,848057,22697,153841,433119,427054,700702,822654,710302,549015,237574,244417,979421,456200)
insert into table_9 values(959253,379922,254889,134888,293066,365459,147777,924352,838542,942578,524516,440048,158913,7566,366351,404011,44358,991989,461250)
insert into table_7 values(200933,732167,859686,208791,647235,444084,286930,722079,19373,539233,665994,110215,927236,630742,18415,809632,625637,436423,278161)
GO
--===================================
print 'Creating transaction log backup'
--===================================
-- Create tlog backup #1
DECLARE @BackupLocation NVARCHAR(100)
EXEC master..xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',  
	@key = 'Software\Microsoft\MSSQLServer\MSSQLServer',  
	@value_name = 'BackupDirectory', @BackupLocation = @BackupLocation OUTPUT ;  
SET @BackupLocation = @BackupLocation + '\ApexSQLLogDEMOtlog1.bak'
BACKUP LOG ApexSQLLogDEMO TO DISK = @BackupLocation WITH INIT
GO

--===================================
print 'Performing 2,500 updates in random tables'
--===================================

update table_9 set column11 = 125550 where column1 = 44
update table_3 set column8 = 576276 where column1 = 70
update table_6 set column14 = 739869 where column1 = 55
update table_6 set column20 = 113684 where column1 = 41
update table_7 set column15 = 286741 where column1 = 51
update table_9 set column17 = 864204 where column1 = 48
update table_0 set column7 = 482322 where column1 = 45
update table_9 set column17 = 394185 where column1 = 43
update table_7 set column8 = 503875 where column1 = 78
update table_9 set column19 = 494354 where column1 = 0
update table_4 set column20 = 953792 where column1 = 95
update table_5 set column2 = 674613 where column1 = 78
update table_4 set column9 = 711645 where column1 = 54
update table_9 set column3 = 496787 where column1 = 28
update table_8 set column7 = 893796 where column1 = 10
update table_4 set column11 = 913663 where column1 = 19
update table_7 set column16 = 827272 where column1 = 37
update table_7 set column17 = 295209 where column1 = 85
update table_0 set column12 = 756635 where column1 = 56
update table_9 set column7 = 577929 where column1 = 0
update table_6 set column15 = 257611 where column1 = 20
update table_9 set column12 = 816053 where column1 = 5
update table_8 set column16 = 387239 where column1 = 71
update table_1 set column9 = 285759 where column1 = 72
update table_9 set column17 = 926229 where column1 = 95
update table_2 set column15 = 529702 where column1 = 58
update table_1 set column5 = 232548 where column1 = 27
update table_1 set column9 = 188125 where column1 = 96
update table_5 set column10 = 81726 where column1 = 11
update table_5 set column20 = 652530 where column1 = 8
update table_2 set column9 = 919483 where column1 = 36
update table_6 set column18 = 939641 where column1 = 67
update table_3 set column3 = 113216 where column1 = 67
update table_0 set column12 = 915281 where column1 = 32
update table_0 set column6 = 950806 where column1 = 81
update table_8 set column7 = 850841 where column1 = 77
update table_8 set column20 = 816988 where column1 = 39
update table_9 set column14 = 434994 where column1 = 77
update table_4 set column14 = 465417 where column1 = 2
update table_0 set column18 = 176864 where column1 = 36
update table_2 set column11 = 83079 where column1 = 11
update table_7 set column6 = 653336 where column1 = 53
update table_2 set column3 = 602635 where column1 = 29
update table_5 set column17 = 846453 where column1 = 13
update table_5 set column8 = 200119 where column1 = 57
update table_3 set column9 = 220400 where column1 = 85
update table_4 set column7 = 216422 where column1 = 44
update table_6 set column4 = 887575 where column1 = 32
update table_2 set column6 = 678142 where column1 = 31
update table_2 set column10 = 266507 where column1 = 2
update table_0 set column5 = 356169 where column1 = 46
update table_4 set column11 = 800903 where column1 = 64
update table_7 set column19 = 35099 where column1 = 20
update table_3 set column9 = 625304 where column1 = 21
update table_5 set column10 = 552515 where column1 = 44
update table_1 set column12 = 995112 where column1 = 12
update table_3 set column8 = 798888 where column1 = 85
update table_5 set column3 = 212979 where column1 = 88
update table_4 set column7 = 261514 where column1 = 66
update table_3 set column2 = 825100 where column1 = 2
update table_6 set column19 = 512052 where column1 = 95
update table_1 set column5 = 106477 where column1 = 29
update table_2 set column3 = 381020 where column1 = 43
update table_5 set column8 = 918417 where column1 = 97
update table_9 set column6 = 727443 where column1 = 10
update table_3 set column9 = 288260 where column1 = 18
update table_7 set column8 = 632411 where column1 = 12
update table_5 set column11 = 930668 where column1 = 31
update table_8 set column20 = 697561 where column1 = 99
update table_7 set column6 = 131189 where column1 = 45
update table_7 set column2 = 7108 where column1 = 15
update table_3 set column19 = 764477 where column1 = 97
update table_5 set column19 = 730336 where column1 = 37
update table_7 set column16 = 890835 where column1 = 62
update table_3 set column14 = 94428 where column1 = 37
update table_4 set column17 = 114461 where column1 = 90
update table_1 set column9 = 181006 where column1 = 23
update table_8 set column3 = 392247 where column1 = 50
update table_3 set column14 = 517485 where column1 = 23
update table_1 set column14 = 348222 where column1 = 54
update table_2 set column18 = 36622 where column1 = 41
update table_2 set column16 = 103496 where column1 = 28
update table_2 set column4 = 187341 where column1 = 82
update table_8 set column17 = 258442 where column1 = 67
update table_3 set column5 = 648526 where column1 = 8
update table_2 set column7 = 174300 where column1 = 48
update table_2 set column8 = 788796 where column1 = 98
update table_6 set column2 = 792097 where column1 = 58
update table_3 set column16 = 917365 where column1 = 63
update table_0 set column6 = 460911 where column1 = 79
update table_3 set column13 = 662815 where column1 = 96
update table_5 set column17 = 752094 where column1 = 59
update table_6 set column10 = 394554 where column1 = 1
update table_7 set column4 = 910202 where column1 = 97
update table_2 set column7 = 960599 where column1 = 51
update table_0 set column18 = 575579 where column1 = 74
update table_1 set column17 = 831746 where column1 = 22
update table_4 set column2 = 946869 where column1 = 11
update table_2 set column3 = 985683 where column1 = 40
update table_9 set column2 = 530052 where column1 = 56
update table_8 set column2 = 776800 where column1 = 48
update table_5 set column15 = 442539 where column1 = 62
update table_0 set column7 = 348058 where column1 = 37
update table_6 set column12 = 620338 where column1 = 47
update table_6 set column9 = 885342 where column1 = 65
update table_4 set column5 = 439599 where column1 = 35
update table_3 set column10 = 744589 where column1 = 63
update table_3 set column2 = 646830 where column1 = 23
update table_2 set column2 = 612453 where column1 = 93
update table_2 set column10 = 698700 where column1 = 66
update table_4 set column13 = 386521 where column1 = 67
update table_2 set column6 = 221932 where column1 = 26
update table_1 set column18 = 774693 where column1 = 28
update table_8 set column5 = 245128 where column1 = 12
update table_5 set column17 = 903765 where column1 = 32
update table_9 set column11 = 371212 where column1 = 58
update table_4 set column5 = 137260 where column1 = 22
update table_8 set column19 = 882524 where column1 = 86
update table_2 set column17 = 995788 where column1 = 41
update table_6 set column17 = 334503 where column1 = 93
update table_8 set column18 = 378177 where column1 = 53
update table_3 set column8 = 662128 where column1 = 43
update table_5 set column10 = 519592 where column1 = 93
update table_1 set column16 = 909946 where column1 = 60
update table_7 set column19 = 436662 where column1 = 73
update table_4 set column16 = 689263 where column1 = 51
update table_0 set column9 = 17492 where column1 = 25
update table_1 set column20 = 742572 where column1 = 68
update table_3 set column15 = 651733 where column1 = 17
update table_6 set column16 = 545788 where column1 = 60
update table_9 set column9 = 716615 where column1 = 80
update table_0 set column8 = 351614 where column1 = 22
update table_1 set column15 = 943473 where column1 = 88
update table_1 set column17 = 846006 where column1 = 54
update table_3 set column10 = 13204 where column1 = 28
update table_8 set column15 = 93185 where column1 = 43
update table_3 set column10 = 420657 where column1 = 95
update table_3 set column7 = 667104 where column1 = 29
update table_3 set column6 = 790681 where column1 = 30
update table_4 set column11 = 147305 where column1 = 84
update table_0 set column2 = 450990 where column1 = 40
update table_9 set column11 = 473638 where column1 = 72
update table_4 set column2 = 497792 where column1 = 78
update table_2 set column19 = 446266 where column1 = 71
update table_3 set column5 = 556158 where column1 = 52
update table_6 set column16 = 527185 where column1 = 82
update table_4 set column12 = 769568 where column1 = 62
update table_6 set column17 = 834432 where column1 = 84
update table_3 set column18 = 129196 where column1 = 53
update table_0 set column19 = 710131 where column1 = 9
update table_1 set column14 = 847292 where column1 = 24
update table_1 set column5 = 403805 where column1 = 70
update table_7 set column3 = 132382 where column1 = 93
update table_8 set column2 = 561322 where column1 = 84
update table_1 set column15 = 296646 where column1 = 36
update table_2 set column14 = 669033 where column1 = 66
update table_2 set column19 = 584520 where column1 = 5
update table_3 set column9 = 575216 where column1 = 73
update table_5 set column11 = 609792 where column1 = 31
update table_1 set column14 = 639772 where column1 = 39
update table_8 set column11 = 10786 where column1 = 55
update table_4 set column2 = 72312 where column1 = 49
update table_2 set column19 = 438532 where column1 = 10
update table_9 set column3 = 906304 where column1 = 52
update table_8 set column18 = 615164 where column1 = 16
update table_7 set column15 = 164902 where column1 = 82
update table_8 set column19 = 805061 where column1 = 63
update table_9 set column6 = 112472 where column1 = 20
update table_9 set column4 = 889119 where column1 = 90
update table_6 set column19 = 827411 where column1 = 95
update table_5 set column5 = 195206 where column1 = 97
update table_3 set column17 = 504320 where column1 = 66
update table_2 set column19 = 33398 where column1 = 78
update table_0 set column13 = 217149 where column1 = 6
update table_0 set column7 = 826967 where column1 = 32
update table_9 set column6 = 177350 where column1 = 13
update table_1 set column16 = 509752 where column1 = 85
update table_1 set column6 = 435229 where column1 = 91
update table_2 set column13 = 314350 where column1 = 9
update table_1 set column19 = 574822 where column1 = 33
update table_9 set column3 = 41976 where column1 = 44
update table_9 set column20 = 261503 where column1 = 41
update table_1 set column20 = 631469 where column1 = 16
update table_8 set column14 = 616441 where column1 = 22
update table_6 set column19 = 755511 where column1 = 22
update table_6 set column16 = 629822 where column1 = 38
update table_4 set column20 = 114580 where column1 = 62
update table_1 set column19 = 483400 where column1 = 62
update table_4 set column19 = 939581 where column1 = 44
update table_3 set column17 = 111943 where column1 = 20
update table_7 set column12 = 392741 where column1 = 58
update table_8 set column9 = 647305 where column1 = 4
update table_5 set column18 = 161685 where column1 = 64
update table_3 set column14 = 315836 where column1 = 62
update table_2 set column4 = 691161 where column1 = 50
update table_2 set column3 = 533224 where column1 = 5
update table_4 set column13 = 11586 where column1 = 35
update table_6 set column10 = 732676 where column1 = 70
update table_6 set column10 = 411937 where column1 = 63
update table_9 set column6 = 314288 where column1 = 98
update table_3 set column4 = 713853 where column1 = 9
update table_0 set column13 = 211275 where column1 = 81
update table_0 set column5 = 872657 where column1 = 83
update table_6 set column5 = 784191 where column1 = 88
update table_5 set column6 = 439925 where column1 = 17
update table_4 set column11 = 295583 where column1 = 64
update table_4 set column20 = 373915 where column1 = 1
update table_7 set column13 = 596119 where column1 = 53
update table_1 set column15 = 453605 where column1 = 37
update table_8 set column10 = 897455 where column1 = 79
update table_1 set column7 = 400131 where column1 = 81
update table_2 set column17 = 65524 where column1 = 21
update table_5 set column8 = 949327 where column1 = 26
update table_2 set column3 = 312071 where column1 = 9
update table_4 set column15 = 238069 where column1 = 64
update table_2 set column13 = 294974 where column1 = 63
update table_1 set column6 = 717065 where column1 = 46
update table_8 set column10 = 201494 where column1 = 27
update table_5 set column5 = 631178 where column1 = 2
update table_5 set column13 = 753050 where column1 = 6
update table_0 set column11 = 90683 where column1 = 72
update table_9 set column8 = 996294 where column1 = 1
update table_9 set column14 = 76440 where column1 = 64
update table_1 set column7 = 530736 where column1 = 43
update table_6 set column13 = 483377 where column1 = 19
update table_0 set column18 = 447450 where column1 = 42
update table_4 set column10 = 711480 where column1 = 18
update table_7 set column5 = 645145 where column1 = 46
update table_9 set column10 = 680165 where column1 = 81
update table_7 set column9 = 761205 where column1 = 88
update table_5 set column9 = 904601 where column1 = 37
update table_1 set column12 = 184859 where column1 = 61
update table_6 set column13 = 59150 where column1 = 1
update table_1 set column17 = 303560 where column1 = 93
update table_8 set column11 = 350375 where column1 = 46
update table_4 set column11 = 340977 where column1 = 7
update table_8 set column17 = 92805 where column1 = 51
update table_9 set column12 = 166406 where column1 = 68
update table_7 set column4 = 663862 where column1 = 29
update table_9 set column14 = 396421 where column1 = 9
update table_6 set column11 = 756697 where column1 = 16
update table_4 set column15 = 408533 where column1 = 77
update table_5 set column7 = 783243 where column1 = 97
update table_3 set column20 = 646730 where column1 = 74
update table_5 set column19 = 390390 where column1 = 48
update table_1 set column10 = 624159 where column1 = 16
update table_2 set column11 = 705484 where column1 = 97
update table_4 set column4 = 997288 where column1 = 21
update table_1 set column12 = 692713 where column1 = 19
update table_6 set column8 = 683805 where column1 = 43
update table_1 set column10 = 172482 where column1 = 45
update table_4 set column17 = 820082 where column1 = 36
update table_8 set column3 = 41166 where column1 = 97
update table_1 set column7 = 944395 where column1 = 83
update table_6 set column9 = 268155 where column1 = 34
update table_3 set column2 = 220634 where column1 = 87
update table_0 set column8 = 619640 where column1 = 99
update table_8 set column10 = 40247 where column1 = 36
update table_7 set column9 = 787991 where column1 = 84
update table_3 set column8 = 99195 where column1 = 63
update table_1 set column2 = 37779 where column1 = 42
update table_5 set column5 = 587974 where column1 = 11
update table_8 set column17 = 355945 where column1 = 86
update table_8 set column13 = 891393 where column1 = 15
update table_2 set column6 = 353489 where column1 = 34
update table_2 set column10 = 274770 where column1 = 85
update table_3 set column16 = 939464 where column1 = 13
update table_1 set column10 = 462808 where column1 = 11
update table_0 set column13 = 777347 where column1 = 8
update table_2 set column13 = 811634 where column1 = 8
update table_2 set column11 = 776407 where column1 = 17
update table_8 set column17 = 638363 where column1 = 44
update table_8 set column9 = 953002 where column1 = 74
update table_6 set column9 = 182198 where column1 = 9
update table_4 set column11 = 495981 where column1 = 15
update table_6 set column4 = 588971 where column1 = 86
update table_5 set column16 = 422934 where column1 = 89
update table_0 set column10 = 983690 where column1 = 98
update table_2 set column18 = 719234 where column1 = 4
update table_1 set column18 = 542828 where column1 = 53
update table_5 set column14 = 471084 where column1 = 62
update table_8 set column11 = 885467 where column1 = 50
update table_0 set column3 = 661876 where column1 = 30
update table_6 set column6 = 779987 where column1 = 30
update table_9 set column4 = 703496 where column1 = 91
update table_8 set column10 = 498383 where column1 = 60
update table_5 set column10 = 607214 where column1 = 5
update table_6 set column6 = 478526 where column1 = 38
update table_7 set column6 = 91676 where column1 = 3
update table_5 set column7 = 810370 where column1 = 99
update table_9 set column9 = 476666 where column1 = 6
update table_6 set column11 = 114238 where column1 = 54
update table_7 set column2 = 882089 where column1 = 55
update table_6 set column4 = 391743 where column1 = 83
update table_6 set column3 = 140384 where column1 = 65
update table_5 set column4 = 984358 where column1 = 49
update table_7 set column20 = 820675 where column1 = 83
update table_6 set column10 = 386262 where column1 = 2
update table_2 set column12 = 386862 where column1 = 93
update table_3 set column8 = 780112 where column1 = 5
update table_6 set column16 = 835144 where column1 = 46
update table_2 set column10 = 7010 where column1 = 21
update table_7 set column18 = 348148 where column1 = 77
update table_7 set column17 = 768123 where column1 = 82
update table_4 set column11 = 715461 where column1 = 32
update table_9 set column2 = 729959 where column1 = 66
update table_1 set column13 = 418437 where column1 = 97
update table_8 set column4 = 935870 where column1 = 96
update table_3 set column7 = 503364 where column1 = 1
update table_0 set column10 = 556506 where column1 = 5
update table_8 set column8 = 765732 where column1 = 95
update table_9 set column8 = 306680 where column1 = 43
update table_6 set column19 = 840081 where column1 = 74
update table_8 set column7 = 198 where column1 = 53
update table_2 set column2 = 575036 where column1 = 21
update table_4 set column2 = 361412 where column1 = 89
update table_9 set column18 = 478067 where column1 = 83
update table_4 set column15 = 867609 where column1 = 15
update table_1 set column18 = 155926 where column1 = 19
update table_2 set column3 = 951829 where column1 = 87
update table_8 set column19 = 837920 where column1 = 60
update table_4 set column5 = 747506 where column1 = 31
update table_2 set column13 = 909138 where column1 = 46
update table_8 set column20 = 370121 where column1 = 37
update table_3 set column6 = 730863 where column1 = 18
update table_7 set column9 = 276246 where column1 = 67
update table_9 set column16 = 1345 where column1 = 31
update table_8 set column13 = 495431 where column1 = 40
update table_1 set column12 = 637001 where column1 = 42
update table_4 set column13 = 937207 where column1 = 52
update table_9 set column17 = 390880 where column1 = 1
update table_3 set column20 = 740375 where column1 = 51
update table_7 set column4 = 281121 where column1 = 83
update table_8 set column9 = 62141 where column1 = 85
update table_5 set column13 = 724988 where column1 = 46
update table_1 set column12 = 456167 where column1 = 89
update table_0 set column14 = 791639 where column1 = 11
update table_1 set column7 = 227445 where column1 = 10
update table_3 set column13 = 534661 where column1 = 18
update table_6 set column17 = 121181 where column1 = 98
update table_3 set column9 = 738181 where column1 = 82
update table_5 set column13 = 146350 where column1 = 93
update table_4 set column10 = 17917 where column1 = 58
update table_1 set column11 = 414230 where column1 = 68
update table_5 set column17 = 818144 where column1 = 55
update table_3 set column19 = 494266 where column1 = 7
update table_8 set column6 = 270292 where column1 = 29
update table_1 set column15 = 107514 where column1 = 73
update table_9 set column13 = 230232 where column1 = 76
update table_5 set column7 = 966348 where column1 = 78
update table_6 set column11 = 203123 where column1 = 15
update table_5 set column6 = 211670 where column1 = 41
update table_5 set column12 = 397150 where column1 = 26
update table_9 set column15 = 295825 where column1 = 9
update table_3 set column8 = 681372 where column1 = 78
update table_4 set column12 = 987910 where column1 = 79
update table_2 set column15 = 844463 where column1 = 35
update table_5 set column16 = 960558 where column1 = 21
update table_7 set column2 = 915734 where column1 = 13
update table_6 set column9 = 889744 where column1 = 73
update table_9 set column4 = 621753 where column1 = 35
update table_1 set column20 = 360529 where column1 = 57
update table_9 set column3 = 250641 where column1 = 96
update table_8 set column18 = 26769 where column1 = 96
update table_5 set column2 = 584484 where column1 = 31
update table_1 set column19 = 250319 where column1 = 93
update table_9 set column13 = 728527 where column1 = 96
update table_7 set column8 = 838647 where column1 = 62
update table_6 set column4 = 62418 where column1 = 81
update table_0 set column10 = 776830 where column1 = 36
update table_5 set column8 = 660389 where column1 = 37
update table_1 set column7 = 871405 where column1 = 35
update table_0 set column17 = 882422 where column1 = 27
update table_7 set column6 = 181186 where column1 = 46
update table_0 set column16 = 451681 where column1 = 89
update table_4 set column15 = 475115 where column1 = 81
update table_6 set column13 = 424200 where column1 = 63
update table_4 set column3 = 766640 where column1 = 21
update table_0 set column3 = 577681 where column1 = 69
update table_5 set column11 = 59109 where column1 = 9
update table_5 set column14 = 391467 where column1 = 72
update table_2 set column9 = 562560 where column1 = 27
update table_7 set column16 = 570336 where column1 = 22
update table_4 set column14 = 164742 where column1 = 49
update table_9 set column13 = 599890 where column1 = 28
update table_1 set column9 = 22036 where column1 = 68
update table_7 set column6 = 535535 where column1 = 82
update table_5 set column3 = 265022 where column1 = 97
update table_9 set column4 = 315480 where column1 = 52
update table_8 set column9 = 646374 where column1 = 5
update table_2 set column9 = 778638 where column1 = 88
update table_2 set column3 = 295977 where column1 = 30
update table_6 set column2 = 662795 where column1 = 44
update table_9 set column13 = 399264 where column1 = 57
update table_5 set column20 = 470579 where column1 = 30
update table_5 set column8 = 829946 where column1 = 51
update table_7 set column14 = 374769 where column1 = 55
update table_3 set column14 = 275956 where column1 = 46
update table_9 set column18 = 838879 where column1 = 57
update table_6 set column5 = 85813 where column1 = 45
update table_1 set column15 = 851656 where column1 = 79
update table_8 set column5 = 478743 where column1 = 3
update table_6 set column3 = 834248 where column1 = 73
update table_6 set column11 = 816352 where column1 = 50
update table_6 set column4 = 634463 where column1 = 73
update table_6 set column11 = 140428 where column1 = 82
update table_7 set column16 = 634036 where column1 = 80
update table_5 set column15 = 40720 where column1 = 19
update table_1 set column2 = 850220 where column1 = 31
update table_0 set column18 = 433021 where column1 = 1
update table_3 set column12 = 626711 where column1 = 36
update table_1 set column14 = 19958 where column1 = 63
update table_9 set column4 = 203085 where column1 = 98
update table_2 set column17 = 959616 where column1 = 59
update table_2 set column10 = 647510 where column1 = 16
update table_0 set column14 = 373302 where column1 = 63
update table_9 set column16 = 194401 where column1 = 85
update table_4 set column14 = 477714 where column1 = 12
update table_1 set column16 = 356719 where column1 = 90
update table_0 set column9 = 195036 where column1 = 10
update table_5 set column11 = 717632 where column1 = 29
update table_7 set column7 = 481367 where column1 = 54
update table_1 set column15 = 842764 where column1 = 96
update table_0 set column11 = 353502 where column1 = 55
update table_8 set column9 = 404311 where column1 = 10
update table_8 set column20 = 167178 where column1 = 46
update table_6 set column3 = 514793 where column1 = 86
update table_3 set column7 = 365157 where column1 = 94
update table_2 set column10 = 164632 where column1 = 27
update table_5 set column2 = 684614 where column1 = 93
update table_8 set column15 = 8527 where column1 = 3
update table_7 set column11 = 106815 where column1 = 57
update table_6 set column15 = 377997 where column1 = 96
update table_2 set column3 = 892061 where column1 = 54
update table_3 set column7 = 806998 where column1 = 84
update table_0 set column13 = 282200 where column1 = 32
update table_9 set column6 = 480342 where column1 = 88
update table_5 set column20 = 790712 where column1 = 53
update table_5 set column16 = 42252 where column1 = 13
update table_7 set column14 = 385269 where column1 = 8
update table_5 set column18 = 995672 where column1 = 3
update table_5 set column11 = 252310 where column1 = 98
update table_0 set column8 = 771973 where column1 = 80
update table_8 set column8 = 142770 where column1 = 94
update table_7 set column9 = 447104 where column1 = 8
update table_7 set column6 = 342006 where column1 = 1
update table_7 set column5 = 830697 where column1 = 34
update table_5 set column5 = 944573 where column1 = 70
update table_4 set column7 = 604935 where column1 = 67
update table_0 set column9 = 752884 where column1 = 31
update table_5 set column11 = 364196 where column1 = 20
update table_6 set column10 = 794627 where column1 = 73
update table_6 set column12 = 728614 where column1 = 38
update table_1 set column5 = 694791 where column1 = 30
update table_9 set column15 = 45613 where column1 = 24
update table_6 set column3 = 27065 where column1 = 38
update table_3 set column16 = 683474 where column1 = 16
update table_0 set column4 = 910402 where column1 = 16
update table_7 set column15 = 739118 where column1 = 66
update table_5 set column18 = 372746 where column1 = 20
update table_3 set column3 = 150408 where column1 = 66
update table_1 set column18 = 778711 where column1 = 37
update table_2 set column16 = 183572 where column1 = 2
update table_3 set column19 = 221326 where column1 = 55
update table_9 set column10 = 973171 where column1 = 61
update table_6 set column20 = 161470 where column1 = 98
update table_7 set column9 = 493156 where column1 = 82
update table_6 set column19 = 139944 where column1 = 22
update table_6 set column4 = 816452 where column1 = 62
update table_4 set column19 = 857969 where column1 = 30
update table_8 set column2 = 870230 where column1 = 2
update table_5 set column3 = 64705 where column1 = 34
update table_8 set column14 = 850786 where column1 = 45
update table_0 set column16 = 501843 where column1 = 70
update table_0 set column15 = 268250 where column1 = 15
update table_6 set column20 = 279416 where column1 = 74
update table_7 set column9 = 795462 where column1 = 46
update table_1 set column15 = 109381 where column1 = 87
update table_1 set column6 = 875968 where column1 = 90
update table_7 set column2 = 668669 where column1 = 39
update table_6 set column18 = 637539 where column1 = 95
update table_2 set column3 = 941346 where column1 = 87
update table_7 set column3 = 223702 where column1 = 43
update table_7 set column14 = 841883 where column1 = 4
update table_6 set column9 = 997881 where column1 = 19
update table_6 set column2 = 288981 where column1 = 20
update table_6 set column3 = 48528 where column1 = 83
update table_0 set column13 = 346496 where column1 = 95
update table_7 set column20 = 670503 where column1 = 39
update table_1 set column6 = 519058 where column1 = 61
update table_6 set column13 = 232801 where column1 = 10
update table_8 set column20 = 247480 where column1 = 97
update table_9 set column12 = 698239 where column1 = 82
update table_5 set column9 = 728593 where column1 = 18
update table_9 set column16 = 259315 where column1 = 41
update table_6 set column14 = 509141 where column1 = 20
update table_6 set column12 = 227242 where column1 = 66
update table_8 set column16 = 460807 where column1 = 9
update table_2 set column6 = 331794 where column1 = 20
update table_4 set column11 = 121746 where column1 = 47
update table_0 set column10 = 618152 where column1 = 31
update table_4 set column6 = 820666 where column1 = 40
update table_3 set column19 = 462952 where column1 = 54
update table_4 set column7 = 919416 where column1 = 49
update table_1 set column19 = 77707 where column1 = 74
update table_1 set column19 = 766834 where column1 = 96
update table_9 set column19 = 444224 where column1 = 68
update table_6 set column3 = 777867 where column1 = 24
update table_3 set column9 = 340682 where column1 = 98
update table_3 set column7 = 378295 where column1 = 86
update table_4 set column7 = 56518 where column1 = 30
update table_3 set column4 = 374455 where column1 = 39
update table_7 set column2 = 477074 where column1 = 37
update table_2 set column7 = 72252 where column1 = 86
update table_3 set column10 = 88210 where column1 = 17
update table_9 set column17 = 131479 where column1 = 20
update table_4 set column3 = 503256 where column1 = 19
update table_1 set column5 = 271085 where column1 = 52
update table_3 set column15 = 248185 where column1 = 12
update table_8 set column11 = 386871 where column1 = 2
update table_3 set column2 = 243043 where column1 = 50
update table_0 set column19 = 437837 where column1 = 53
update table_4 set column12 = 303208 where column1 = 72
update table_6 set column16 = 778543 where column1 = 99
update table_1 set column4 = 48450 where column1 = 56
update table_5 set column11 = 703462 where column1 = 31
update table_1 set column8 = 530544 where column1 = 48
update table_6 set column12 = 704732 where column1 = 53
update table_5 set column20 = 446030 where column1 = 51
update table_8 set column11 = 992419 where column1 = 20
update table_4 set column16 = 548844 where column1 = 40
update table_8 set column17 = 467087 where column1 = 38
update table_3 set column8 = 118632 where column1 = 20
update table_1 set column20 = 847288 where column1 = 91
update table_5 set column2 = 757753 where column1 = 91
update table_8 set column11 = 915987 where column1 = 58
update table_9 set column18 = 718681 where column1 = 54
update table_3 set column10 = 77836 where column1 = 32
update table_5 set column14 = 966154 where column1 = 51
update table_2 set column10 = 460986 where column1 = 34
update table_9 set column3 = 324182 where column1 = 82
update table_5 set column14 = 635142 where column1 = 93
update table_9 set column19 = 996673 where column1 = 74
update table_1 set column14 = 283596 where column1 = 85
update table_6 set column10 = 490710 where column1 = 49
update table_8 set column17 = 180684 where column1 = 34
update table_9 set column20 = 678338 where column1 = 49
update table_2 set column15 = 893699 where column1 = 71
update table_5 set column15 = 560837 where column1 = 52
update table_9 set column10 = 599034 where column1 = 68
update table_3 set column19 = 610064 where column1 = 35
update table_4 set column10 = 192436 where column1 = 19
update table_6 set column6 = 506595 where column1 = 89
update table_6 set column3 = 760811 where column1 = 43
update table_4 set column8 = 323236 where column1 = 13
update table_0 set column18 = 854704 where column1 = 6
update table_0 set column9 = 541739 where column1 = 46
update table_3 set column13 = 478821 where column1 = 25
update table_4 set column5 = 4268 where column1 = 52
update table_0 set column7 = 548680 where column1 = 51
update table_4 set column9 = 60103 where column1 = 84
update table_8 set column19 = 828044 where column1 = 25
update table_2 set column6 = 835070 where column1 = 69
update table_3 set column14 = 582794 where column1 = 45
update table_7 set column10 = 325126 where column1 = 44
update table_7 set column9 = 527677 where column1 = 12
update table_3 set column11 = 529629 where column1 = 89
update table_4 set column17 = 21095 where column1 = 69
update table_3 set column20 = 117105 where column1 = 12
update table_7 set column4 = 224013 where column1 = 4
update table_0 set column7 = 126870 where column1 = 37
update table_0 set column12 = 432975 where column1 = 40
update table_0 set column7 = 553530 where column1 = 45
update table_8 set column2 = 131457 where column1 = 5
update table_2 set column14 = 392727 where column1 = 67
update table_2 set column11 = 975064 where column1 = 3
update table_7 set column17 = 510852 where column1 = 74
update table_9 set column6 = 813179 where column1 = 97
update table_6 set column18 = 203935 where column1 = 46
update table_0 set column16 = 843879 where column1 = 77
update table_2 set column19 = 603451 where column1 = 82
update table_8 set column4 = 888769 where column1 = 61
update table_9 set column8 = 306684 where column1 = 34
update table_7 set column10 = 428807 where column1 = 60
update table_6 set column10 = 375612 where column1 = 48
update table_9 set column16 = 430652 where column1 = 59
update table_2 set column20 = 338965 where column1 = 45
update table_3 set column8 = 119234 where column1 = 50
update table_6 set column19 = 440932 where column1 = 53
update table_2 set column3 = 153401 where column1 = 85
update table_7 set column6 = 326227 where column1 = 85
update table_9 set column13 = 64372 where column1 = 1
update table_2 set column7 = 990127 where column1 = 44
update table_7 set column15 = 333177 where column1 = 31
update table_8 set column3 = 769444 where column1 = 93
update table_1 set column15 = 612434 where column1 = 59
update table_7 set column12 = 718282 where column1 = 65
update table_7 set column3 = 78400 where column1 = 84
update table_8 set column18 = 2732 where column1 = 96
update table_1 set column12 = 281684 where column1 = 33
update table_9 set column18 = 693749 where column1 = 40
update table_4 set column18 = 53192 where column1 = 91
update table_6 set column11 = 72627 where column1 = 10
update table_3 set column15 = 100700 where column1 = 48
update table_3 set column13 = 716851 where column1 = 34
update table_9 set column12 = 782699 where column1 = 93
update table_5 set column6 = 983482 where column1 = 63
update table_4 set column13 = 484620 where column1 = 15
update table_3 set column6 = 66893 where column1 = 49
update table_8 set column9 = 109613 where column1 = 62
update table_7 set column15 = 156620 where column1 = 46
update table_6 set column15 = 416231 where column1 = 93
update table_1 set column7 = 449001 where column1 = 71
update table_1 set column9 = 222106 where column1 = 38
update table_0 set column18 = 325404 where column1 = 3
update table_5 set column10 = 378824 where column1 = 43
update table_4 set column17 = 182235 where column1 = 96
update table_5 set column2 = 467589 where column1 = 3
update table_5 set column15 = 333809 where column1 = 98
update table_4 set column8 = 423783 where column1 = 51
update table_3 set column10 = 927082 where column1 = 34
update table_3 set column4 = 210455 where column1 = 17
update table_2 set column13 = 789435 where column1 = 73
update table_5 set column12 = 887999 where column1 = 69
update table_0 set column10 = 504873 where column1 = 9
update table_6 set column9 = 510205 where column1 = 60
update table_8 set column7 = 218314 where column1 = 22
update table_1 set column20 = 57912 where column1 = 4
update table_7 set column4 = 62491 where column1 = 87
update table_7 set column16 = 635345 where column1 = 94
update table_5 set column16 = 420916 where column1 = 17
update table_7 set column11 = 666602 where column1 = 9
update table_6 set column15 = 622129 where column1 = 17
update table_7 set column13 = 1405 where column1 = 21
update table_6 set column7 = 791903 where column1 = 0
update table_8 set column13 = 850911 where column1 = 77
update table_0 set column19 = 483118 where column1 = 23
update table_6 set column15 = 570575 where column1 = 13
update table_4 set column19 = 949648 where column1 = 82
update table_8 set column3 = 837312 where column1 = 96
update table_6 set column2 = 267583 where column1 = 11
update table_5 set column15 = 648787 where column1 = 63
update table_8 set column19 = 81060 where column1 = 41
update table_3 set column8 = 473391 where column1 = 38
update table_9 set column19 = 697950 where column1 = 62
update table_1 set column4 = 84927 where column1 = 46
update table_4 set column17 = 988303 where column1 = 38
update table_1 set column12 = 574041 where column1 = 67
update table_0 set column4 = 18024 where column1 = 53
update table_6 set column6 = 482532 where column1 = 13
update table_0 set column13 = 837910 where column1 = 18
update table_3 set column19 = 693554 where column1 = 80
update table_2 set column12 = 803981 where column1 = 71
update table_4 set column8 = 496856 where column1 = 44
update table_5 set column20 = 232716 where column1 = 91
update table_2 set column10 = 414743 where column1 = 27
update table_4 set column8 = 846522 where column1 = 92
update table_7 set column11 = 581804 where column1 = 25
update table_1 set column6 = 12817 where column1 = 47
update table_1 set column18 = 855154 where column1 = 9
update table_8 set column14 = 335626 where column1 = 15
update table_4 set column2 = 590845 where column1 = 68
update table_5 set column20 = 531680 where column1 = 16
update table_5 set column16 = 866917 where column1 = 93
update table_0 set column8 = 85391 where column1 = 32
update table_3 set column10 = 294814 where column1 = 33
update table_1 set column2 = 713081 where column1 = 33
update table_8 set column8 = 120663 where column1 = 34
update table_5 set column9 = 15730 where column1 = 89
update table_6 set column4 = 205580 where column1 = 42
update table_5 set column3 = 96083 where column1 = 48
update table_9 set column20 = 685224 where column1 = 89
update table_8 set column10 = 846817 where column1 = 57
update table_7 set column15 = 312404 where column1 = 41
update table_8 set column5 = 965239 where column1 = 79
update table_3 set column6 = 799669 where column1 = 20
update table_2 set column12 = 432660 where column1 = 60
update table_6 set column3 = 969891 where column1 = 66
update table_6 set column18 = 750172 where column1 = 48
update table_9 set column9 = 783626 where column1 = 67
update table_0 set column20 = 572010 where column1 = 41
update table_6 set column18 = 693671 where column1 = 24
update table_8 set column3 = 321223 where column1 = 53
update table_2 set column5 = 43678 where column1 = 27
update table_6 set column19 = 566099 where column1 = 97
update table_0 set column6 = 17092 where column1 = 54
update table_6 set column5 = 328116 where column1 = 31
update table_9 set column16 = 218742 where column1 = 9
update table_1 set column20 = 468178 where column1 = 19
update table_0 set column11 = 122125 where column1 = 57
update table_6 set column3 = 149997 where column1 = 94
update table_1 set column14 = 555690 where column1 = 7
update table_8 set column14 = 364462 where column1 = 37
update table_5 set column17 = 557492 where column1 = 47
update table_0 set column9 = 510889 where column1 = 5
update table_1 set column9 = 669649 where column1 = 2
update table_5 set column15 = 156359 where column1 = 95
update table_2 set column12 = 505884 where column1 = 49
update table_9 set column9 = 352596 where column1 = 15
update table_7 set column20 = 364509 where column1 = 94
update table_5 set column8 = 111298 where column1 = 49
update table_5 set column3 = 33094 where column1 = 96
update table_4 set column2 = 614278 where column1 = 95
update table_8 set column3 = 114747 where column1 = 45
update table_5 set column8 = 999877 where column1 = 79
update table_0 set column4 = 671594 where column1 = 21
update table_1 set column15 = 849658 where column1 = 47
update table_0 set column6 = 900131 where column1 = 61
update table_9 set column13 = 956396 where column1 = 47
update table_0 set column3 = 277284 where column1 = 97
update table_9 set column10 = 707168 where column1 = 93
update table_8 set column3 = 360832 where column1 = 76
update table_9 set column5 = 393299 where column1 = 60
update table_2 set column11 = 99804 where column1 = 52
update table_8 set column13 = 491545 where column1 = 49
update table_5 set column8 = 564555 where column1 = 17
update table_1 set column20 = 615365 where column1 = 43
update table_2 set column6 = 805455 where column1 = 81
update table_3 set column18 = 410275 where column1 = 68
update table_7 set column18 = 679552 where column1 = 6
update table_7 set column18 = 935350 where column1 = 30
update table_9 set column17 = 804381 where column1 = 77
update table_9 set column8 = 229885 where column1 = 15
update table_7 set column3 = 343418 where column1 = 55
update table_2 set column17 = 632975 where column1 = 51
update table_7 set column16 = 662054 where column1 = 13
update table_7 set column17 = 102795 where column1 = 79
update table_8 set column9 = 145710 where column1 = 39
update table_8 set column5 = 102642 where column1 = 3
update table_4 set column17 = 525477 where column1 = 68
update table_4 set column18 = 425448 where column1 = 72
update table_8 set column3 = 772401 where column1 = 33
update table_2 set column6 = 974843 where column1 = 40
update table_9 set column16 = 19664 where column1 = 86
update table_1 set column15 = 710560 where column1 = 89
update table_6 set column4 = 85611 where column1 = 3
update table_4 set column4 = 31424 where column1 = 77
update table_1 set column3 = 929374 where column1 = 5
update table_4 set column13 = 186980 where column1 = 19
update table_0 set column14 = 922000 where column1 = 46
update table_3 set column10 = 661876 where column1 = 32
update table_3 set column12 = 287292 where column1 = 63
update table_1 set column10 = 160001 where column1 = 98
update table_5 set column10 = 32743 where column1 = 64
update table_4 set column10 = 281200 where column1 = 64
update table_9 set column19 = 117812 where column1 = 95
update table_6 set column9 = 34718 where column1 = 48
update table_8 set column8 = 389942 where column1 = 46
update table_0 set column5 = 970692 where column1 = 64
update table_9 set column4 = 906841 where column1 = 37
update table_0 set column2 = 566517 where column1 = 5
update table_1 set column17 = 358644 where column1 = 5
update table_2 set column15 = 568667 where column1 = 3
update table_2 set column8 = 504761 where column1 = 3
update table_7 set column2 = 816863 where column1 = 58
update table_7 set column6 = 322830 where column1 = 7
update table_0 set column15 = 964865 where column1 = 93
update table_8 set column17 = 664996 where column1 = 75
update table_2 set column18 = 364519 where column1 = 60
update table_7 set column3 = 42183 where column1 = 92
update table_2 set column5 = 806704 where column1 = 55
update table_8 set column15 = 265857 where column1 = 1
update table_1 set column8 = 238935 where column1 = 13
update table_4 set column14 = 984275 where column1 = 28
update table_0 set column19 = 961238 where column1 = 79
update table_2 set column12 = 55335 where column1 = 23
update table_4 set column12 = 155253 where column1 = 82
update table_4 set column3 = 486782 where column1 = 66
update table_8 set column20 = 993143 where column1 = 49
update table_9 set column16 = 781427 where column1 = 43
update table_2 set column2 = 247118 where column1 = 46
update table_7 set column10 = 121918 where column1 = 39
update table_1 set column12 = 498557 where column1 = 4
update table_9 set column7 = 656935 where column1 = 6
update table_7 set column3 = 262723 where column1 = 33
update table_0 set column15 = 159505 where column1 = 26
update table_0 set column19 = 366064 where column1 = 14
update table_2 set column9 = 706042 where column1 = 0
update table_8 set column15 = 292709 where column1 = 33
update table_4 set column18 = 945536 where column1 = 4
update table_2 set column5 = 843792 where column1 = 89
update table_2 set column5 = 952910 where column1 = 25
update table_0 set column11 = 528620 where column1 = 36
update table_6 set column19 = 596145 where column1 = 2
update table_9 set column2 = 496762 where column1 = 48
update table_7 set column20 = 391510 where column1 = 59
update table_8 set column4 = 203378 where column1 = 14
update table_4 set column20 = 159325 where column1 = 33
update table_8 set column13 = 946703 where column1 = 74
update table_0 set column4 = 406946 where column1 = 88
update table_2 set column5 = 3486 where column1 = 72
update table_8 set column10 = 203825 where column1 = 54
update table_7 set column9 = 480949 where column1 = 79
update table_4 set column16 = 363177 where column1 = 54
update table_9 set column7 = 940362 where column1 = 25
update table_5 set column6 = 558025 where column1 = 46
update table_6 set column13 = 616207 where column1 = 10
update table_8 set column5 = 661075 where column1 = 71
update table_2 set column5 = 690470 where column1 = 13
update table_4 set column3 = 820097 where column1 = 59
update table_0 set column16 = 307301 where column1 = 50
update table_2 set column6 = 49602 where column1 = 49
update table_2 set column9 = 573312 where column1 = 49
update table_4 set column7 = 495455 where column1 = 99
update table_4 set column4 = 767875 where column1 = 30
update table_3 set column9 = 946082 where column1 = 47
update table_9 set column18 = 248802 where column1 = 37
update table_9 set column8 = 642236 where column1 = 99
update table_1 set column7 = 705576 where column1 = 28
update table_3 set column19 = 642766 where column1 = 71
update table_8 set column16 = 641542 where column1 = 36
update table_1 set column7 = 334257 where column1 = 7
update table_0 set column12 = 58692 where column1 = 59
update table_8 set column12 = 96429 where column1 = 62
update table_5 set column19 = 673709 where column1 = 89
update table_8 set column18 = 373446 where column1 = 83
update table_7 set column13 = 628770 where column1 = 49
update table_1 set column6 = 616407 where column1 = 27
update table_9 set column5 = 162215 where column1 = 84
update table_3 set column9 = 944004 where column1 = 76
update table_2 set column6 = 789497 where column1 = 60
update table_4 set column9 = 178663 where column1 = 78
update table_5 set column5 = 109211 where column1 = 56
update table_5 set column11 = 853591 where column1 = 12
update table_5 set column11 = 776750 where column1 = 64
update table_9 set column14 = 250217 where column1 = 46
update table_7 set column3 = 78279 where column1 = 78
update table_4 set column4 = 436943 where column1 = 61
update table_3 set column3 = 173538 where column1 = 11
update table_9 set column11 = 152363 where column1 = 78
update table_6 set column2 = 263179 where column1 = 77
update table_3 set column16 = 990531 where column1 = 61
update table_0 set column14 = 390128 where column1 = 75
update table_2 set column12 = 698441 where column1 = 30
update table_3 set column16 = 674417 where column1 = 67
update table_6 set column11 = 958800 where column1 = 51
update table_4 set column16 = 609124 where column1 = 9
update table_9 set column4 = 302801 where column1 = 27
update table_7 set column15 = 787463 where column1 = 57
update table_2 set column11 = 754344 where column1 = 7
update table_0 set column4 = 708739 where column1 = 70
update table_0 set column9 = 73112 where column1 = 6
update table_3 set column9 = 119634 where column1 = 92
update table_6 set column10 = 477157 where column1 = 10
update table_5 set column18 = 368526 where column1 = 27
update table_9 set column4 = 442277 where column1 = 82
update table_4 set column20 = 50829 where column1 = 24
update table_9 set column13 = 874159 where column1 = 5
update table_6 set column15 = 819593 where column1 = 3
update table_1 set column14 = 191398 where column1 = 13
update table_8 set column2 = 482785 where column1 = 14
update table_3 set column9 = 816187 where column1 = 33
update table_6 set column17 = 530758 where column1 = 94
update table_2 set column5 = 726903 where column1 = 69
update table_3 set column18 = 644235 where column1 = 98
update table_4 set column15 = 214240 where column1 = 78
update table_5 set column15 = 894935 where column1 = 27
update table_5 set column8 = 605104 where column1 = 21
update table_6 set column12 = 60920 where column1 = 50
update table_2 set column7 = 909802 where column1 = 65
update table_0 set column7 = 509663 where column1 = 91
update table_2 set column12 = 752114 where column1 = 14
update table_9 set column16 = 520410 where column1 = 66
update table_2 set column18 = 89873 where column1 = 62
update table_1 set column5 = 21021 where column1 = 93
update table_2 set column2 = 570928 where column1 = 78
update table_9 set column16 = 188134 where column1 = 4
update table_9 set column3 = 17213 where column1 = 63
update table_1 set column3 = 6388 where column1 = 52
update table_3 set column19 = 886147 where column1 = 18
update table_1 set column20 = 864134 where column1 = 51
update table_0 set column12 = 768747 where column1 = 96
update table_8 set column17 = 79940 where column1 = 86
update table_6 set column3 = 977093 where column1 = 66
update table_3 set column20 = 119428 where column1 = 9
update table_9 set column3 = 136770 where column1 = 63
update table_1 set column19 = 402946 where column1 = 92
update table_4 set column4 = 699797 where column1 = 8
update table_8 set column16 = 273046 where column1 = 66
update table_8 set column17 = 760442 where column1 = 79
update table_1 set column17 = 324560 where column1 = 11
update table_7 set column19 = 930273 where column1 = 55
update table_3 set column16 = 759380 where column1 = 84
update table_5 set column20 = 806083 where column1 = 80
update table_2 set column20 = 622634 where column1 = 99
update table_7 set column15 = 335885 where column1 = 94
update table_3 set column7 = 857384 where column1 = 0
update table_5 set column12 = 855607 where column1 = 35
update table_7 set column11 = 921680 where column1 = 56
update table_9 set column19 = 750764 where column1 = 71
update table_9 set column19 = 99330 where column1 = 89
update table_4 set column11 = 2765 where column1 = 58
update table_0 set column17 = 86532 where column1 = 91
update table_8 set column18 = 36887 where column1 = 57
update table_2 set column15 = 469787 where column1 = 50
update table_7 set column5 = 268743 where column1 = 3
update table_1 set column5 = 277282 where column1 = 82
update table_3 set column2 = 360877 where column1 = 74
update table_1 set column6 = 300657 where column1 = 14
update table_9 set column14 = 194943 where column1 = 95
update table_4 set column9 = 939423 where column1 = 52
update table_0 set column8 = 426853 where column1 = 78
update table_4 set column9 = 799179 where column1 = 28
update table_7 set column15 = 53333 where column1 = 68
update table_8 set column11 = 298264 where column1 = 44
update table_6 set column8 = 707592 where column1 = 47
update table_1 set column16 = 419271 where column1 = 96
update table_5 set column15 = 89727 where column1 = 86
update table_0 set column7 = 547184 where column1 = 74
update table_7 set column9 = 586295 where column1 = 14
update table_4 set column12 = 259091 where column1 = 96
update table_9 set column12 = 942587 where column1 = 14
update table_6 set column11 = 600464 where column1 = 28
update table_1 set column14 = 347350 where column1 = 65
update table_2 set column11 = 237436 where column1 = 36
update table_2 set column9 = 7654 where column1 = 70
update table_0 set column7 = 618528 where column1 = 31
update table_6 set column4 = 898814 where column1 = 75
update table_5 set column7 = 258229 where column1 = 63
update table_9 set column7 = 858017 where column1 = 93
update table_7 set column20 = 881141 where column1 = 83
update table_0 set column12 = 643506 where column1 = 17
update table_5 set column9 = 603819 where column1 = 30
update table_8 set column11 = 292025 where column1 = 98
update table_4 set column9 = 240791 where column1 = 7
update table_7 set column13 = 579484 where column1 = 64
update table_3 set column16 = 612901 where column1 = 76
update table_1 set column10 = 345410 where column1 = 9
update table_0 set column17 = 636521 where column1 = 16
update table_1 set column15 = 547602 where column1 = 20
update table_7 set column15 = 314200 where column1 = 21
update table_4 set column8 = 658740 where column1 = 98
update table_1 set column6 = 449997 where column1 = 93
update table_3 set column10 = 902814 where column1 = 70
update table_3 set column16 = 257548 where column1 = 24
update table_3 set column18 = 5805 where column1 = 6
update table_7 set column19 = 641266 where column1 = 48
update table_0 set column7 = 978275 where column1 = 80
update table_0 set column14 = 225681 where column1 = 27
update table_7 set column20 = 285461 where column1 = 9
update table_2 set column17 = 606397 where column1 = 78
update table_1 set column18 = 374073 where column1 = 35
update table_1 set column17 = 450510 where column1 = 33
update table_7 set column5 = 322945 where column1 = 67
update table_4 set column19 = 459777 where column1 = 59
update table_0 set column12 = 906679 where column1 = 60
update table_4 set column19 = 161659 where column1 = 55
update table_5 set column10 = 150288 where column1 = 55
update table_8 set column6 = 401648 where column1 = 79
update table_6 set column16 = 227931 where column1 = 66
update table_0 set column17 = 564805 where column1 = 33
update table_3 set column12 = 666644 where column1 = 4
update table_0 set column17 = 189719 where column1 = 20
update table_4 set column5 = 251086 where column1 = 42
update table_2 set column17 = 418793 where column1 = 0
update table_7 set column14 = 734116 where column1 = 72
update table_7 set column6 = 800711 where column1 = 12
update table_1 set column12 = 103866 where column1 = 77
update table_2 set column6 = 472001 where column1 = 52
update table_7 set column5 = 975926 where column1 = 87
update table_3 set column6 = 774446 where column1 = 27
update table_5 set column3 = 32522 where column1 = 18
update table_1 set column18 = 749312 where column1 = 74
update table_4 set column12 = 737529 where column1 = 23
update table_1 set column3 = 328069 where column1 = 25
update table_0 set column16 = 516777 where column1 = 75
update table_5 set column3 = 814213 where column1 = 84
update table_2 set column13 = 146103 where column1 = 9
update table_4 set column17 = 653390 where column1 = 58
update table_0 set column15 = 786994 where column1 = 77
update table_5 set column20 = 955439 where column1 = 16
update table_5 set column3 = 210612 where column1 = 85
update table_3 set column7 = 324703 where column1 = 24
update table_6 set column18 = 771745 where column1 = 29
update table_3 set column2 = 569941 where column1 = 53
update table_9 set column14 = 318202 where column1 = 65
update table_9 set column11 = 640137 where column1 = 26
update table_9 set column3 = 701075 where column1 = 89
update table_0 set column10 = 11098 where column1 = 27
update table_3 set column9 = 923663 where column1 = 33
update table_4 set column6 = 43794 where column1 = 76
update table_6 set column19 = 326360 where column1 = 35
update table_4 set column7 = 679985 where column1 = 21
update table_8 set column14 = 650019 where column1 = 40
update table_5 set column13 = 904516 where column1 = 28
update table_0 set column2 = 169007 where column1 = 58
update table_3 set column8 = 398982 where column1 = 69
update table_3 set column5 = 410694 where column1 = 74
update table_0 set column14 = 308697 where column1 = 94
update table_1 set column12 = 495760 where column1 = 36
update table_5 set column11 = 832699 where column1 = 14
update table_6 set column6 = 989373 where column1 = 86
update table_9 set column15 = 586741 where column1 = 79
update table_9 set column16 = 753712 where column1 = 92
update table_1 set column4 = 910327 where column1 = 22
update table_8 set column7 = 514311 where column1 = 57
update table_8 set column20 = 121762 where column1 = 77
update table_6 set column18 = 545360 where column1 = 99
update table_2 set column16 = 761190 where column1 = 67
update table_7 set column8 = 392012 where column1 = 18
update table_7 set column2 = 307343 where column1 = 18
update table_7 set column2 = 800517 where column1 = 75
update table_6 set column3 = 41347 where column1 = 74
update table_3 set column17 = 778977 where column1 = 67
update table_7 set column20 = 673332 where column1 = 37
update table_3 set column19 = 684011 where column1 = 71
update table_8 set column5 = 69653 where column1 = 27
update table_2 set column6 = 332838 where column1 = 28
update table_6 set column5 = 450345 where column1 = 78
update table_4 set column5 = 546008 where column1 = 39
update table_2 set column10 = 582893 where column1 = 73
update table_4 set column9 = 507347 where column1 = 10
update table_0 set column5 = 602556 where column1 = 43
update table_6 set column8 = 606727 where column1 = 34
update table_4 set column12 = 408113 where column1 = 51
update table_1 set column2 = 838948 where column1 = 15
update table_2 set column4 = 477977 where column1 = 38
update table_7 set column14 = 370713 where column1 = 47
update table_5 set column16 = 797828 where column1 = 81
update table_9 set column4 = 191090 where column1 = 46
update table_3 set column14 = 233709 where column1 = 83
update table_8 set column20 = 53208 where column1 = 17
update table_7 set column7 = 816256 where column1 = 22
update table_8 set column12 = 536373 where column1 = 73
update table_6 set column5 = 34085 where column1 = 36
update table_7 set column3 = 672102 where column1 = 60
update table_9 set column6 = 546480 where column1 = 13
update table_3 set column13 = 593437 where column1 = 84
update table_1 set column4 = 436385 where column1 = 70
update table_6 set column6 = 180420 where column1 = 32
update table_5 set column11 = 499340 where column1 = 45
update table_0 set column9 = 416704 where column1 = 32
update table_2 set column15 = 190829 where column1 = 70
update table_4 set column11 = 647520 where column1 = 58
update table_7 set column3 = 81573 where column1 = 77
update table_7 set column3 = 258656 where column1 = 53
update table_7 set column14 = 541653 where column1 = 25
update table_9 set column17 = 583347 where column1 = 81
update table_4 set column16 = 41270 where column1 = 99
update table_7 set column2 = 432400 where column1 = 25
update table_5 set column15 = 67267 where column1 = 64
update table_9 set column9 = 957334 where column1 = 34
update table_3 set column20 = 91499 where column1 = 72
update table_1 set column16 = 139588 where column1 = 88
update table_0 set column5 = 65005 where column1 = 63
update table_3 set column9 = 594146 where column1 = 60
update table_6 set column15 = 710271 where column1 = 9
update table_4 set column10 = 381175 where column1 = 34
update table_4 set column10 = 438551 where column1 = 82
update table_4 set column8 = 704707 where column1 = 54
update table_1 set column10 = 538739 where column1 = 90
update table_3 set column16 = 301462 where column1 = 58
update table_2 set column2 = 618138 where column1 = 19
update table_8 set column14 = 894787 where column1 = 74
update table_6 set column2 = 541103 where column1 = 94
update table_2 set column11 = 863459 where column1 = 44
update table_6 set column8 = 480056 where column1 = 92
update table_6 set column18 = 56883 where column1 = 2
update table_4 set column11 = 794691 where column1 = 77
update table_2 set column10 = 867937 where column1 = 14
update table_7 set column4 = 377992 where column1 = 35
update table_9 set column20 = 536308 where column1 = 70
update table_1 set column15 = 967134 where column1 = 4
update table_1 set column8 = 630070 where column1 = 40
update table_9 set column4 = 465781 where column1 = 81
update table_6 set column4 = 843068 where column1 = 77
update table_6 set column12 = 449200 where column1 = 68
update table_9 set column19 = 796417 where column1 = 36
update table_9 set column16 = 159952 where column1 = 19
update table_8 set column12 = 386056 where column1 = 80
update table_6 set column8 = 707572 where column1 = 31
update table_1 set column9 = 707821 where column1 = 66
update table_0 set column19 = 895500 where column1 = 81
update table_5 set column16 = 588792 where column1 = 37
update table_9 set column8 = 510919 where column1 = 75
update table_7 set column9 = 873712 where column1 = 9
update table_7 set column14 = 750144 where column1 = 72
update table_3 set column6 = 321726 where column1 = 96
update table_2 set column2 = 941185 where column1 = 79
update table_4 set column19 = 808234 where column1 = 69
update table_5 set column7 = 676562 where column1 = 82
update table_9 set column5 = 283919 where column1 = 40
update table_0 set column8 = 470038 where column1 = 73
update table_5 set column20 = 352770 where column1 = 37
update table_6 set column4 = 28167 where column1 = 91
update table_7 set column8 = 28288 where column1 = 22
update table_9 set column5 = 13178 where column1 = 4
update table_6 set column10 = 950608 where column1 = 72
update table_6 set column7 = 894391 where column1 = 33
update table_6 set column14 = 36002 where column1 = 31
update table_0 set column13 = 360381 where column1 = 94
update table_9 set column10 = 206550 where column1 = 40
update table_0 set column4 = 79200 where column1 = 62
update table_9 set column18 = 383131 where column1 = 68
update table_3 set column2 = 904781 where column1 = 51
update table_8 set column4 = 651273 where column1 = 2
update table_2 set column19 = 251758 where column1 = 25
update table_9 set column16 = 453075 where column1 = 90
update table_8 set column7 = 78185 where column1 = 92
update table_2 set column16 = 572920 where column1 = 73
update table_9 set column8 = 340880 where column1 = 97
update table_4 set column6 = 511719 where column1 = 28
update table_1 set column9 = 899975 where column1 = 3
update table_5 set column3 = 177200 where column1 = 60
update table_1 set column20 = 456694 where column1 = 68
update table_5 set column4 = 885308 where column1 = 98
update table_2 set column12 = 792267 where column1 = 89
update table_6 set column13 = 313708 where column1 = 37
update table_4 set column5 = 93670 where column1 = 79
update table_2 set column18 = 811764 where column1 = 14
update table_8 set column6 = 130038 where column1 = 50
update table_0 set column19 = 475202 where column1 = 41
update table_5 set column6 = 881884 where column1 = 99
update table_2 set column10 = 906422 where column1 = 1
update table_5 set column4 = 782006 where column1 = 28
update table_5 set column4 = 304124 where column1 = 51
update table_3 set column17 = 73974 where column1 = 2
update table_9 set column19 = 140101 where column1 = 56
update table_0 set column7 = 66789 where column1 = 8
update table_2 set column13 = 827869 where column1 = 20
update table_6 set column15 = 139959 where column1 = 58
update table_6 set column11 = 881510 where column1 = 50
update table_0 set column4 = 843125 where column1 = 98
update table_7 set column13 = 512678 where column1 = 34
update table_7 set column12 = 829520 where column1 = 64
update table_6 set column6 = 163533 where column1 = 45
update table_3 set column20 = 230309 where column1 = 51
update table_3 set column10 = 444693 where column1 = 27
update table_2 set column18 = 293132 where column1 = 48
update table_2 set column17 = 823094 where column1 = 17
update table_8 set column12 = 382483 where column1 = 32
update table_5 set column12 = 970864 where column1 = 8
update table_2 set column5 = 105955 where column1 = 88
update table_4 set column19 = 82684 where column1 = 84
update table_2 set column14 = 269800 where column1 = 96
update table_7 set column16 = 503937 where column1 = 5
update table_1 set column3 = 52299 where column1 = 94
update table_4 set column3 = 685202 where column1 = 20
update table_5 set column14 = 109809 where column1 = 74
update table_1 set column20 = 851093 where column1 = 45
update table_0 set column13 = 883526 where column1 = 17
update table_8 set column19 = 317421 where column1 = 10
update table_6 set column7 = 766988 where column1 = 84
update table_4 set column6 = 489713 where column1 = 83
update table_1 set column9 = 352523 where column1 = 99
update table_7 set column19 = 586255 where column1 = 44
update table_6 set column7 = 558939 where column1 = 48
update table_8 set column15 = 924975 where column1 = 27
update table_9 set column16 = 565243 where column1 = 3
update table_1 set column20 = 286005 where column1 = 74
update table_5 set column18 = 680027 where column1 = 96
update table_0 set column6 = 370141 where column1 = 4
update table_9 set column6 = 345572 where column1 = 63
update table_7 set column13 = 818090 where column1 = 15
update table_3 set column8 = 270652 where column1 = 67
update table_2 set column16 = 750983 where column1 = 15
update table_5 set column19 = 38696 where column1 = 20
update table_9 set column3 = 758506 where column1 = 64
update table_1 set column12 = 382678 where column1 = 87
update table_9 set column19 = 950617 where column1 = 38
update table_0 set column17 = 296508 where column1 = 50
update table_6 set column15 = 580495 where column1 = 34
update table_8 set column4 = 850520 where column1 = 96
update table_9 set column7 = 339996 where column1 = 38
update table_8 set column3 = 468913 where column1 = 99
update table_1 set column20 = 657618 where column1 = 46
update table_4 set column19 = 476942 where column1 = 52
update table_3 set column14 = 453468 where column1 = 13
update table_8 set column20 = 824315 where column1 = 29
update table_0 set column19 = 31748 where column1 = 73
update table_7 set column11 = 36933 where column1 = 92
update table_5 set column19 = 230978 where column1 = 74
update table_8 set column2 = 338529 where column1 = 26
update table_0 set column8 = 219748 where column1 = 20
update table_6 set column14 = 820734 where column1 = 45
update table_4 set column18 = 492897 where column1 = 51
update table_0 set column5 = 144376 where column1 = 57
update table_2 set column19 = 12799 where column1 = 3
update table_6 set column14 = 400950 where column1 = 26
update table_3 set column19 = 458838 where column1 = 53
update table_0 set column19 = 217301 where column1 = 73
update table_8 set column15 = 18031 where column1 = 47
update table_7 set column5 = 438413 where column1 = 98
update table_8 set column20 = 680702 where column1 = 71
update table_7 set column7 = 371670 where column1 = 27
update table_2 set column20 = 376946 where column1 = 66
update table_1 set column20 = 636291 where column1 = 30
update table_0 set column2 = 683163 where column1 = 42
update table_6 set column3 = 887084 where column1 = 57
update table_8 set column19 = 17742 where column1 = 42
update table_3 set column16 = 138326 where column1 = 94
update table_6 set column3 = 910233 where column1 = 74
update table_4 set column6 = 574442 where column1 = 1
update table_9 set column12 = 95196 where column1 = 4
update table_3 set column7 = 541375 where column1 = 16
update table_1 set column5 = 710862 where column1 = 11
update table_2 set column20 = 21199 where column1 = 60
update table_8 set column13 = 212702 where column1 = 89
update table_8 set column18 = 929196 where column1 = 52
update table_8 set column17 = 69166 where column1 = 28
update table_0 set column3 = 825043 where column1 = 95
update table_4 set column4 = 586928 where column1 = 2
update table_1 set column6 = 282020 where column1 = 84
update table_3 set column4 = 87768 where column1 = 6
update table_0 set column8 = 866374 where column1 = 2
update table_2 set column15 = 391391 where column1 = 35
update table_4 set column19 = 480553 where column1 = 86
update table_2 set column3 = 836540 where column1 = 18
update table_4 set column2 = 311157 where column1 = 1
update table_4 set column14 = 715397 where column1 = 42
update table_7 set column14 = 871004 where column1 = 33
update table_4 set column4 = 986624 where column1 = 59
update table_0 set column2 = 722466 where column1 = 12
update table_2 set column6 = 908861 where column1 = 76
update table_0 set column17 = 48374 where column1 = 53
update table_8 set column14 = 295149 where column1 = 87
update table_8 set column20 = 680610 where column1 = 50
update table_2 set column14 = 354657 where column1 = 64
update table_6 set column5 = 904837 where column1 = 58
update table_7 set column7 = 176398 where column1 = 92
update table_2 set column11 = 141070 where column1 = 52
update table_3 set column10 = 109979 where column1 = 29
update table_4 set column15 = 564477 where column1 = 62
update table_5 set column12 = 30485 where column1 = 82
update table_7 set column14 = 776432 where column1 = 92
update table_8 set column7 = 941024 where column1 = 17
update table_6 set column8 = 319946 where column1 = 30
update table_7 set column8 = 388711 where column1 = 56
update table_7 set column16 = 983745 where column1 = 38
update table_3 set column11 = 543385 where column1 = 44
update table_7 set column16 = 882411 where column1 = 67
update table_6 set column16 = 966818 where column1 = 25
update table_5 set column15 = 287526 where column1 = 3
update table_4 set column17 = 560521 where column1 = 68
update table_6 set column2 = 81952 where column1 = 36
update table_9 set column16 = 563616 where column1 = 17
update table_9 set column2 = 906671 where column1 = 95
update table_7 set column13 = 473177 where column1 = 4
update table_7 set column10 = 78467 where column1 = 39
update table_4 set column15 = 435102 where column1 = 11
update table_1 set column2 = 1928 where column1 = 47
update table_8 set column18 = 916495 where column1 = 59
update table_8 set column16 = 475854 where column1 = 81
update table_9 set column2 = 638397 where column1 = 30
update table_2 set column12 = 469699 where column1 = 86
update table_2 set column11 = 34150 where column1 = 86
update table_7 set column10 = 516746 where column1 = 15
update table_7 set column14 = 190875 where column1 = 80
update table_5 set column5 = 107718 where column1 = 49
update table_3 set column11 = 190850 where column1 = 32
update table_2 set column15 = 42100 where column1 = 33
update table_5 set column10 = 269556 where column1 = 29
update table_3 set column10 = 769763 where column1 = 74
update table_4 set column11 = 606853 where column1 = 93
update table_8 set column18 = 199503 where column1 = 90
update table_4 set column10 = 273105 where column1 = 43
update table_6 set column8 = 789114 where column1 = 59
update table_7 set column12 = 843042 where column1 = 45
update table_0 set column9 = 637252 where column1 = 21
update table_7 set column15 = 880046 where column1 = 40
update table_8 set column19 = 11851 where column1 = 99
update table_0 set column5 = 671577 where column1 = 23
update table_2 set column19 = 935164 where column1 = 89
update table_9 set column2 = 375098 where column1 = 62
update table_6 set column4 = 728921 where column1 = 25
update table_1 set column9 = 997612 where column1 = 35
update table_0 set column10 = 340528 where column1 = 99
update table_9 set column20 = 3835 where column1 = 56
update table_1 set column2 = 670660 where column1 = 5
update table_4 set column11 = 408170 where column1 = 12
update table_3 set column19 = 262750 where column1 = 34
update table_9 set column5 = 582714 where column1 = 63
update table_6 set column15 = 959592 where column1 = 23
update table_8 set column11 = 16320 where column1 = 14
update table_0 set column3 = 967974 where column1 = 77
update table_2 set column3 = 206452 where column1 = 60
update table_5 set column6 = 62781 where column1 = 39
update table_3 set column4 = 813491 where column1 = 64
update table_1 set column12 = 503461 where column1 = 31
update table_3 set column20 = 491393 where column1 = 48
update table_7 set column14 = 784068 where column1 = 45
update table_1 set column20 = 79476 where column1 = 16
update table_8 set column13 = 891898 where column1 = 82
update table_1 set column2 = 805547 where column1 = 43
update table_4 set column18 = 950375 where column1 = 53
update table_6 set column16 = 215078 where column1 = 68
update table_8 set column11 = 578057 where column1 = 44
update table_2 set column18 = 413745 where column1 = 26
update table_0 set column16 = 158276 where column1 = 91
update table_6 set column19 = 175746 where column1 = 35
update table_5 set column15 = 926379 where column1 = 86
update table_6 set column15 = 734244 where column1 = 92
update table_5 set column4 = 310702 where column1 = 33
update table_5 set column6 = 233650 where column1 = 23
update table_0 set column16 = 374041 where column1 = 38
update table_5 set column5 = 75496 where column1 = 62
update table_7 set column7 = 417232 where column1 = 46
update table_2 set column2 = 395790 where column1 = 8
update table_9 set column19 = 562083 where column1 = 90
update table_1 set column9 = 381647 where column1 = 41
update table_5 set column16 = 933120 where column1 = 42
update table_3 set column19 = 844254 where column1 = 69
update table_3 set column20 = 221441 where column1 = 64
update table_4 set column20 = 142544 where column1 = 89
update table_2 set column10 = 196485 where column1 = 25
update table_2 set column2 = 449412 where column1 = 50
update table_6 set column6 = 438456 where column1 = 62
update table_2 set column20 = 400908 where column1 = 13
update table_8 set column10 = 851663 where column1 = 0
update table_9 set column12 = 208037 where column1 = 17
update table_5 set column11 = 731530 where column1 = 27
update table_3 set column19 = 158650 where column1 = 17
update table_4 set column2 = 722183 where column1 = 16
update table_0 set column6 = 234787 where column1 = 80
update table_3 set column15 = 40440 where column1 = 46
update table_0 set column7 = 7112 where column1 = 67
update table_2 set column11 = 692524 where column1 = 52
update table_6 set column16 = 877262 where column1 = 51
update table_0 set column16 = 369502 where column1 = 74
update table_2 set column9 = 308862 where column1 = 43
update table_0 set column10 = 93736 where column1 = 31
update table_3 set column7 = 434195 where column1 = 48
update table_2 set column2 = 205486 where column1 = 69
update table_5 set column9 = 500116 where column1 = 46
update table_8 set column7 = 859529 where column1 = 75
update table_7 set column7 = 415925 where column1 = 45
update table_9 set column17 = 166956 where column1 = 57
update table_7 set column11 = 499642 where column1 = 6
update table_8 set column3 = 835077 where column1 = 69
update table_0 set column8 = 203679 where column1 = 64
update table_5 set column6 = 324210 where column1 = 2
update table_3 set column2 = 149703 where column1 = 61
update table_0 set column13 = 989544 where column1 = 3
update table_0 set column13 = 289277 where column1 = 36
update table_0 set column17 = 836631 where column1 = 6
update table_5 set column7 = 709937 where column1 = 12
update table_5 set column5 = 411976 where column1 = 1
update table_9 set column6 = 336526 where column1 = 95
update table_8 set column7 = 380775 where column1 = 63
update table_7 set column20 = 454090 where column1 = 3
update table_0 set column12 = 668485 where column1 = 28
update table_2 set column5 = 731877 where column1 = 37
update table_3 set column13 = 944137 where column1 = 55
update table_2 set column14 = 850398 where column1 = 26
update table_6 set column17 = 56788 where column1 = 24
update table_5 set column10 = 925454 where column1 = 67
update table_8 set column5 = 893994 where column1 = 47
update table_4 set column13 = 536895 where column1 = 18
update table_9 set column15 = 362426 where column1 = 78
update table_8 set column19 = 787396 where column1 = 3
update table_5 set column18 = 925132 where column1 = 19
update table_6 set column10 = 183252 where column1 = 97
update table_5 set column16 = 790743 where column1 = 5
update table_0 set column2 = 34560 where column1 = 71
update table_4 set column12 = 3548 where column1 = 30
update table_9 set column19 = 652869 where column1 = 3
update table_8 set column14 = 971376 where column1 = 31
update table_7 set column3 = 805487 where column1 = 78
update table_1 set column10 = 408599 where column1 = 72
update table_4 set column15 = 180724 where column1 = 91
update table_6 set column12 = 223292 where column1 = 42
update table_6 set column20 = 809097 where column1 = 72
update table_0 set column7 = 586119 where column1 = 71
update table_3 set column2 = 644870 where column1 = 83
update table_2 set column19 = 394833 where column1 = 16
update table_8 set column2 = 337898 where column1 = 31
update table_6 set column11 = 464225 where column1 = 62
update table_3 set column15 = 848800 where column1 = 44
update table_1 set column3 = 750577 where column1 = 22
update table_1 set column17 = 451256 where column1 = 77
update table_4 set column9 = 300207 where column1 = 80
update table_1 set column15 = 745379 where column1 = 2
update table_3 set column12 = 347836 where column1 = 2
update table_8 set column2 = 202849 where column1 = 79
update table_9 set column18 = 324455 where column1 = 43
update table_4 set column17 = 921389 where column1 = 74
update table_6 set column6 = 3709 where column1 = 13
update table_9 set column2 = 294399 where column1 = 91
update table_3 set column6 = 625431 where column1 = 51
update table_1 set column7 = 806299 where column1 = 19
update table_2 set column8 = 922684 where column1 = 67
update table_1 set column15 = 941575 where column1 = 34
update table_3 set column20 = 532099 where column1 = 6
update table_9 set column12 = 640596 where column1 = 45
update table_2 set column19 = 565364 where column1 = 69
update table_9 set column8 = 449184 where column1 = 65
update table_6 set column12 = 626150 where column1 = 80
update table_3 set column14 = 191218 where column1 = 17
update table_7 set column15 = 957130 where column1 = 84
update table_9 set column4 = 417006 where column1 = 97
update table_7 set column4 = 96873 where column1 = 63
update table_5 set column8 = 31221 where column1 = 66
update table_3 set column11 = 160718 where column1 = 16
update table_1 set column16 = 224002 where column1 = 12
update table_5 set column7 = 331407 where column1 = 84
update table_2 set column14 = 60400 where column1 = 96
update table_5 set column6 = 282045 where column1 = 18
update table_7 set column2 = 948357 where column1 = 87
update table_5 set column10 = 392895 where column1 = 83
update table_0 set column5 = 404606 where column1 = 23
update table_8 set column3 = 861406 where column1 = 72
update table_4 set column4 = 360949 where column1 = 92
update table_0 set column3 = 811945 where column1 = 4
update table_7 set column19 = 440927 where column1 = 89
update table_0 set column8 = 813100 where column1 = 58
update table_0 set column9 = 226870 where column1 = 80
update table_5 set column17 = 62303 where column1 = 44
update table_9 set column6 = 303546 where column1 = 97
update table_4 set column14 = 821850 where column1 = 53
update table_2 set column14 = 50529 where column1 = 65
update table_2 set column7 = 962006 where column1 = 25
update table_9 set column2 = 961162 where column1 = 61
update table_7 set column7 = 407878 where column1 = 20
update table_8 set column9 = 638597 where column1 = 6
update table_7 set column13 = 804277 where column1 = 46
update table_0 set column2 = 26569 where column1 = 7
update table_6 set column11 = 170473 where column1 = 24
update table_7 set column15 = 927550 where column1 = 5
update table_5 set column8 = 202365 where column1 = 34
update table_9 set column3 = 485694 where column1 = 45
update table_7 set column13 = 442712 where column1 = 34
update table_3 set column6 = 924409 where column1 = 51
update table_9 set column17 = 568170 where column1 = 52
update table_6 set column7 = 958495 where column1 = 6
update table_4 set column19 = 264482 where column1 = 22
update table_1 set column17 = 997246 where column1 = 84
update table_9 set column15 = 768127 where column1 = 17
update table_7 set column6 = 64707 where column1 = 9
update table_9 set column17 = 690318 where column1 = 43
update table_6 set column13 = 386516 where column1 = 9
update table_8 set column4 = 761243 where column1 = 30
update table_8 set column11 = 833426 where column1 = 99
update table_2 set column16 = 83312 where column1 = 36
update table_3 set column20 = 580496 where column1 = 92
update table_7 set column18 = 240269 where column1 = 16
update table_6 set column19 = 431280 where column1 = 13
update table_3 set column8 = 10862 where column1 = 71
update table_8 set column10 = 606812 where column1 = 54
update table_9 set column10 = 750762 where column1 = 8
update table_0 set column7 = 761544 where column1 = 89
update table_9 set column11 = 839343 where column1 = 32
update table_7 set column11 = 484035 where column1 = 76
update table_0 set column5 = 903462 where column1 = 72
update table_8 set column17 = 166937 where column1 = 58
update table_0 set column14 = 56345 where column1 = 25
update table_2 set column3 = 57274 where column1 = 74
update table_9 set column5 = 398880 where column1 = 45
update table_8 set column7 = 900524 where column1 = 80
update table_1 set column7 = 968647 where column1 = 18
update table_4 set column16 = 576047 where column1 = 27
update table_7 set column6 = 970004 where column1 = 81
update table_1 set column12 = 642028 where column1 = 64
update table_7 set column2 = 692667 where column1 = 35
update table_8 set column4 = 666247 where column1 = 56
update table_1 set column9 = 200185 where column1 = 48
update table_2 set column20 = 184158 where column1 = 17
update table_8 set column16 = 254485 where column1 = 68
update table_3 set column16 = 595661 where column1 = 95
update table_7 set column4 = 380533 where column1 = 97
update table_9 set column8 = 262471 where column1 = 93
update table_7 set column20 = 351027 where column1 = 88
update table_3 set column8 = 848811 where column1 = 59
update table_2 set column16 = 751412 where column1 = 34
update table_0 set column15 = 827831 where column1 = 5
update table_6 set column11 = 768496 where column1 = 76
update table_2 set column20 = 170463 where column1 = 30
update table_5 set column7 = 274235 where column1 = 25
update table_0 set column2 = 846675 where column1 = 50
update table_8 set column18 = 666009 where column1 = 23
update table_7 set column17 = 884414 where column1 = 93
update table_3 set column3 = 522478 where column1 = 22
update table_4 set column12 = 659748 where column1 = 38
update table_7 set column9 = 478885 where column1 = 33
update table_3 set column10 = 499523 where column1 = 41
update table_2 set column4 = 921917 where column1 = 13
update table_2 set column18 = 432412 where column1 = 45
update table_1 set column8 = 242606 where column1 = 24
update table_0 set column18 = 115548 where column1 = 21
update table_7 set column7 = 534374 where column1 = 96
update table_5 set column7 = 782513 where column1 = 14
update table_4 set column17 = 488505 where column1 = 16
update table_6 set column3 = 108068 where column1 = 35
update table_1 set column9 = 306881 where column1 = 95
update table_7 set column20 = 381822 where column1 = 74
update table_5 set column2 = 457715 where column1 = 87
update table_4 set column19 = 204350 where column1 = 31
update table_1 set column16 = 909661 where column1 = 84
update table_1 set column3 = 771412 where column1 = 72
update table_3 set column10 = 842674 where column1 = 8
update table_1 set column20 = 185755 where column1 = 57
update table_6 set column13 = 74667 where column1 = 57
update table_6 set column6 = 509361 where column1 = 55
update table_4 set column9 = 652362 where column1 = 41
update table_4 set column13 = 17521 where column1 = 89
update table_9 set column9 = 466349 where column1 = 45
update table_1 set column11 = 237282 where column1 = 75
update table_9 set column14 = 750932 where column1 = 77
update table_8 set column20 = 698396 where column1 = 55
update table_7 set column19 = 213830 where column1 = 55
update table_5 set column8 = 439604 where column1 = 53
update table_4 set column9 = 342248 where column1 = 83
update table_7 set column7 = 222638 where column1 = 17
update table_2 set column17 = 301353 where column1 = 91
update table_8 set column13 = 747725 where column1 = 72
update table_3 set column8 = 392272 where column1 = 94
update table_5 set column19 = 130575 where column1 = 18
update table_8 set column9 = 125815 where column1 = 70
update table_3 set column18 = 432472 where column1 = 84
update table_0 set column20 = 821688 where column1 = 9
update table_8 set column7 = 112549 where column1 = 88
update table_6 set column15 = 623150 where column1 = 28
update table_0 set column10 = 74714 where column1 = 97
update table_5 set column11 = 333753 where column1 = 42
update table_1 set column18 = 842618 where column1 = 88
update table_8 set column16 = 133109 where column1 = 59
update table_3 set column14 = 407786 where column1 = 36
update table_4 set column6 = 822602 where column1 = 84
update table_1 set column10 = 535398 where column1 = 28
update table_0 set column8 = 797110 where column1 = 87
update table_1 set column8 = 251663 where column1 = 40
update table_8 set column11 = 298903 where column1 = 48
update table_2 set column20 = 289618 where column1 = 47
update table_5 set column17 = 876554 where column1 = 85
update table_6 set column7 = 30497 where column1 = 57
update table_1 set column13 = 873431 where column1 = 19
update table_9 set column18 = 994903 where column1 = 84
update table_2 set column10 = 266548 where column1 = 68
update table_9 set column18 = 594840 where column1 = 35
update table_6 set column13 = 783165 where column1 = 31
update table_3 set column16 = 604837 where column1 = 27
update table_7 set column5 = 345564 where column1 = 12
update table_5 set column8 = 899211 where column1 = 23
update table_8 set column18 = 788542 where column1 = 52
update table_6 set column5 = 952062 where column1 = 7
update table_9 set column9 = 857449 where column1 = 76
update table_3 set column9 = 980164 where column1 = 92
update table_7 set column13 = 360676 where column1 = 63
update table_0 set column17 = 852124 where column1 = 14
update table_5 set column19 = 799074 where column1 = 58
update table_4 set column19 = 990983 where column1 = 59
update table_0 set column2 = 651051 where column1 = 21
update table_1 set column7 = 571778 where column1 = 8
update table_2 set column16 = 284709 where column1 = 5
update table_6 set column15 = 20837 where column1 = 40
update table_6 set column10 = 269949 where column1 = 20
update table_1 set column12 = 23033 where column1 = 12
update table_1 set column16 = 272450 where column1 = 93
update table_7 set column3 = 539020 where column1 = 31
update table_4 set column17 = 173770 where column1 = 37
update table_5 set column15 = 27856 where column1 = 1
update table_2 set column14 = 745312 where column1 = 96
update table_2 set column17 = 757261 where column1 = 73
update table_8 set column14 = 56305 where column1 = 9
update table_1 set column19 = 148925 where column1 = 26
update table_7 set column14 = 579637 where column1 = 24
update table_9 set column18 = 988428 where column1 = 68
update table_2 set column17 = 502420 where column1 = 23
update table_1 set column17 = 766906 where column1 = 16
update table_1 set column20 = 349557 where column1 = 14
update table_0 set column18 = 918454 where column1 = 78
update table_9 set column19 = 99344 where column1 = 40
update table_6 set column6 = 55969 where column1 = 82
update table_9 set column3 = 963256 where column1 = 40
update table_8 set column5 = 347498 where column1 = 91
update table_8 set column20 = 854462 where column1 = 22
update table_8 set column12 = 396797 where column1 = 12
update table_9 set column8 = 622579 where column1 = 62
update table_7 set column2 = 868507 where column1 = 25
update table_7 set column11 = 44315 where column1 = 46
update table_8 set column8 = 284166 where column1 = 14
update table_6 set column20 = 502517 where column1 = 89
update table_9 set column3 = 9285 where column1 = 16
update table_7 set column19 = 465796 where column1 = 13
update table_5 set column17 = 427059 where column1 = 61
update table_4 set column14 = 764759 where column1 = 52
update table_3 set column8 = 887829 where column1 = 17
update table_0 set column10 = 884566 where column1 = 85
update table_9 set column6 = 797195 where column1 = 75
update table_5 set column5 = 757741 where column1 = 66
update table_9 set column6 = 158294 where column1 = 66
update table_2 set column13 = 229752 where column1 = 40
update table_0 set column15 = 214209 where column1 = 93
update table_7 set column12 = 397960 where column1 = 60
update table_0 set column8 = 712884 where column1 = 71
update table_6 set column7 = 996767 where column1 = 80
update table_7 set column20 = 690655 where column1 = 0
update table_5 set column5 = 65574 where column1 = 19
update table_5 set column6 = 31518 where column1 = 5
update table_0 set column15 = 627965 where column1 = 9
update table_7 set column18 = 736521 where column1 = 87
update table_3 set column15 = 979876 where column1 = 62
update table_1 set column3 = 996383 where column1 = 97
update table_4 set column17 = 808601 where column1 = 84
update table_5 set column20 = 358891 where column1 = 10
update table_4 set column13 = 598679 where column1 = 14
update table_9 set column7 = 708780 where column1 = 38
update table_6 set column19 = 195222 where column1 = 48
update table_2 set column8 = 174284 where column1 = 23
update table_4 set column15 = 187058 where column1 = 16
update table_8 set column11 = 940781 where column1 = 90
update table_6 set column2 = 825754 where column1 = 0
update table_6 set column3 = 160876 where column1 = 62
update table_5 set column4 = 950591 where column1 = 11
update table_2 set column8 = 570960 where column1 = 41
update table_7 set column7 = 675180 where column1 = 20
update table_1 set column2 = 886864 where column1 = 22
update table_6 set column10 = 60295 where column1 = 25
update table_7 set column15 = 486338 where column1 = 89
update table_3 set column16 = 278397 where column1 = 5
update table_5 set column20 = 249394 where column1 = 91
update table_4 set column11 = 119473 where column1 = 58
update table_6 set column5 = 698921 where column1 = 99
update table_0 set column12 = 287020 where column1 = 17
update table_7 set column3 = 153776 where column1 = 21
update table_4 set column14 = 134920 where column1 = 60
update table_0 set column9 = 46569 where column1 = 54
update table_2 set column12 = 444909 where column1 = 93
update table_0 set column9 = 52385 where column1 = 74
update table_5 set column16 = 517819 where column1 = 20
update table_8 set column16 = 870179 where column1 = 51
update table_3 set column3 = 582136 where column1 = 53
update table_8 set column12 = 588244 where column1 = 7
update table_2 set column3 = 623688 where column1 = 5
update table_1 set column9 = 227809 where column1 = 7
update table_7 set column5 = 200688 where column1 = 69
update table_8 set column6 = 543853 where column1 = 87
update table_0 set column2 = 779329 where column1 = 74
update table_1 set column5 = 23046 where column1 = 1
update table_2 set column12 = 426929 where column1 = 72
update table_1 set column5 = 689162 where column1 = 65
update table_3 set column7 = 962387 where column1 = 1
update table_9 set column3 = 169243 where column1 = 87
update table_4 set column14 = 720129 where column1 = 57
update table_0 set column12 = 466685 where column1 = 11
update table_4 set column8 = 406421 where column1 = 47
update table_0 set column6 = 219566 where column1 = 86
update table_2 set column3 = 411638 where column1 = 13
update table_7 set column13 = 693233 where column1 = 8
update table_0 set column17 = 704692 where column1 = 75
update table_7 set column14 = 365407 where column1 = 87
update table_6 set column12 = 626443 where column1 = 53
update table_8 set column15 = 103565 where column1 = 53
update table_7 set column16 = 494524 where column1 = 53
update table_6 set column4 = 340799 where column1 = 49
update table_2 set column15 = 619022 where column1 = 13
update table_6 set column7 = 698219 where column1 = 39
update table_7 set column5 = 195021 where column1 = 14
update table_9 set column15 = 663881 where column1 = 11
update table_4 set column7 = 884628 where column1 = 20
update table_7 set column14 = 507454 where column1 = 67
update table_4 set column17 = 319665 where column1 = 2
update table_8 set column13 = 398304 where column1 = 96
update table_4 set column12 = 616811 where column1 = 83
update table_8 set column13 = 714560 where column1 = 80
update table_9 set column16 = 618074 where column1 = 47
update table_6 set column11 = 230644 where column1 = 21
update table_4 set column17 = 48989 where column1 = 79
update table_1 set column15 = 71937 where column1 = 8
update table_0 set column3 = 176283 where column1 = 85
update table_3 set column18 = 723552 where column1 = 70
update table_6 set column18 = 558516 where column1 = 78
update table_1 set column4 = 768999 where column1 = 96
update table_9 set column20 = 346378 where column1 = 42
update table_4 set column18 = 855274 where column1 = 59
update table_8 set column3 = 764100 where column1 = 4
update table_1 set column15 = 675105 where column1 = 74
update table_2 set column4 = 182214 where column1 = 53
update table_6 set column6 = 753342 where column1 = 93
update table_2 set column13 = 947580 where column1 = 7
update table_9 set column8 = 149720 where column1 = 43
update table_8 set column17 = 9509 where column1 = 19
update table_8 set column8 = 201491 where column1 = 7
update table_7 set column4 = 559786 where column1 = 0
update table_8 set column19 = 221322 where column1 = 82
update table_7 set column6 = 948483 where column1 = 60
update table_3 set column16 = 533832 where column1 = 78
update table_9 set column9 = 392224 where column1 = 62
update table_8 set column2 = 730165 where column1 = 43
update table_2 set column18 = 618859 where column1 = 47
update table_7 set column10 = 167946 where column1 = 83
update table_3 set column3 = 224085 where column1 = 8
update table_6 set column12 = 816500 where column1 = 6
update table_7 set column16 = 587500 where column1 = 66
update table_8 set column14 = 462504 where column1 = 87
update table_2 set column16 = 696529 where column1 = 81
update table_2 set column18 = 716176 where column1 = 26
update table_9 set column12 = 12587 where column1 = 11
update table_5 set column12 = 65748 where column1 = 63
update table_1 set column12 = 222521 where column1 = 91
update table_0 set column14 = 474732 where column1 = 33
update table_6 set column9 = 701292 where column1 = 9
update table_5 set column20 = 154057 where column1 = 8
update table_1 set column15 = 966887 where column1 = 69
update table_3 set column15 = 44044 where column1 = 91
update table_6 set column7 = 92441 where column1 = 97
update table_8 set column9 = 788906 where column1 = 98
update table_0 set column9 = 772753 where column1 = 83
update table_8 set column11 = 853405 where column1 = 64
update table_2 set column11 = 294714 where column1 = 96
update table_0 set column14 = 738034 where column1 = 31
update table_7 set column19 = 767529 where column1 = 23
update table_6 set column8 = 899445 where column1 = 0
update table_0 set column19 = 730467 where column1 = 67
update table_0 set column15 = 75729 where column1 = 6
update table_9 set column7 = 681352 where column1 = 67
update table_1 set column10 = 689756 where column1 = 17
update table_8 set column15 = 498788 where column1 = 38
update table_4 set column2 = 702654 where column1 = 5
update table_5 set column18 = 257664 where column1 = 80
update table_0 set column6 = 566720 where column1 = 23
update table_3 set column10 = 535509 where column1 = 82
update table_5 set column10 = 932109 where column1 = 56
update table_1 set column17 = 594409 where column1 = 35
update table_2 set column17 = 375498 where column1 = 4
update table_0 set column10 = 729392 where column1 = 91
update table_0 set column12 = 42808 where column1 = 68
update table_8 set column13 = 232306 where column1 = 72
update table_2 set column6 = 740265 where column1 = 29
update table_3 set column15 = 968502 where column1 = 85
update table_6 set column6 = 821842 where column1 = 23
update table_2 set column10 = 776002 where column1 = 73
update table_1 set column3 = 922941 where column1 = 13
update table_9 set column9 = 520156 where column1 = 69
update table_9 set column4 = 379816 where column1 = 72
update table_2 set column3 = 811485 where column1 = 9
update table_8 set column15 = 58655 where column1 = 64
update table_5 set column4 = 519478 where column1 = 36
update table_2 set column14 = 611325 where column1 = 88
update table_9 set column12 = 721476 where column1 = 69
update table_4 set column17 = 946876 where column1 = 12
update table_6 set column3 = 584126 where column1 = 22
update table_4 set column9 = 782175 where column1 = 68
update table_2 set column16 = 847010 where column1 = 35
update table_6 set column16 = 707250 where column1 = 66
update table_3 set column8 = 989376 where column1 = 15
update table_9 set column8 = 396407 where column1 = 39
update table_8 set column4 = 790924 where column1 = 76
update table_9 set column3 = 202094 where column1 = 78
update table_3 set column14 = 41996 where column1 = 64
update table_4 set column16 = 932619 where column1 = 71
update table_1 set column3 = 732542 where column1 = 34
update table_3 set column4 = 629898 where column1 = 78
update table_9 set column14 = 610521 where column1 = 41
update table_1 set column18 = 43129 where column1 = 4
update table_7 set column7 = 700303 where column1 = 59
update table_2 set column7 = 962145 where column1 = 50
update table_8 set column2 = 132037 where column1 = 69
update table_2 set column6 = 937286 where column1 = 31
update table_7 set column18 = 375698 where column1 = 77
update table_4 set column11 = 822731 where column1 = 91
update table_7 set column13 = 416055 where column1 = 71
update table_3 set column16 = 239244 where column1 = 16
update table_3 set column10 = 246650 where column1 = 55
update table_0 set column11 = 305422 where column1 = 5
update table_6 set column7 = 598903 where column1 = 47
update table_2 set column2 = 272552 where column1 = 92
update table_8 set column4 = 904796 where column1 = 48
update table_6 set column19 = 548013 where column1 = 80
update table_3 set column6 = 793570 where column1 = 41
update table_2 set column14 = 510237 where column1 = 94
update table_2 set column8 = 932972 where column1 = 69
update table_1 set column10 = 135390 where column1 = 24
update table_3 set column6 = 497892 where column1 = 31
update table_6 set column20 = 746362 where column1 = 59
update table_5 set column4 = 389118 where column1 = 47
update table_6 set column16 = 179360 where column1 = 76
update table_6 set column4 = 255266 where column1 = 42
update table_7 set column3 = 762535 where column1 = 83
update table_4 set column19 = 202610 where column1 = 3
update table_4 set column12 = 131616 where column1 = 84
update table_2 set column7 = 13414 where column1 = 55
update table_9 set column13 = 926192 where column1 = 59
update table_8 set column15 = 576642 where column1 = 7
update table_8 set column2 = 40301 where column1 = 21
update table_6 set column10 = 690987 where column1 = 34
update table_8 set column6 = 290771 where column1 = 79
update table_2 set column8 = 55097 where column1 = 11
update table_3 set column7 = 632847 where column1 = 7
update table_5 set column6 = 474744 where column1 = 31
update table_0 set column15 = 40309 where column1 = 69
update table_6 set column18 = 888897 where column1 = 3
update table_0 set column7 = 690771 where column1 = 94
update table_7 set column8 = 858921 where column1 = 52
update table_1 set column10 = 685806 where column1 = 9
update table_8 set column5 = 214587 where column1 = 95
update table_0 set column15 = 50172 where column1 = 90
update table_7 set column6 = 474303 where column1 = 8
update table_5 set column19 = 647337 where column1 = 62
update table_9 set column2 = 875635 where column1 = 29
update table_4 set column10 = 974090 where column1 = 77
update table_7 set column5 = 596229 where column1 = 88
update table_2 set column7 = 916997 where column1 = 43
update table_7 set column9 = 67618 where column1 = 36
update table_1 set column19 = 581781 where column1 = 2
update table_7 set column11 = 360074 where column1 = 52
update table_4 set column6 = 579695 where column1 = 70
update table_6 set column20 = 459766 where column1 = 16
update table_0 set column5 = 113637 where column1 = 79
update table_3 set column7 = 902373 where column1 = 97
update table_2 set column3 = 307111 where column1 = 30
update table_5 set column8 = 681018 where column1 = 82
update table_1 set column19 = 40835 where column1 = 6
update table_0 set column17 = 263396 where column1 = 81
update table_5 set column3 = 956234 where column1 = 60
update table_3 set column20 = 455546 where column1 = 85
update table_1 set column10 = 37472 where column1 = 43
update table_7 set column17 = 728803 where column1 = 73
update table_8 set column12 = 96885 where column1 = 78
update table_1 set column7 = 843588 where column1 = 0
update table_9 set column3 = 938011 where column1 = 80
update table_6 set column11 = 136723 where column1 = 9
update table_6 set column18 = 430364 where column1 = 60
update table_3 set column12 = 832440 where column1 = 98
update table_2 set column13 = 163212 where column1 = 7
update table_8 set column13 = 496617 where column1 = 29
update table_3 set column12 = 289376 where column1 = 82
update table_0 set column19 = 905005 where column1 = 71
update table_6 set column11 = 343072 where column1 = 38
update table_5 set column5 = 528295 where column1 = 73
update table_2 set column2 = 439616 where column1 = 13
update table_6 set column8 = 136735 where column1 = 78
update table_9 set column12 = 290096 where column1 = 17
update table_3 set column17 = 26881 where column1 = 95
update table_5 set column5 = 571323 where column1 = 77
update table_9 set column7 = 585540 where column1 = 21
update table_3 set column14 = 777171 where column1 = 61
update table_4 set column13 = 448726 where column1 = 39
update table_3 set column13 = 404513 where column1 = 24
update table_5 set column4 = 926738 where column1 = 85
update table_3 set column5 = 732415 where column1 = 26
update table_5 set column18 = 740151 where column1 = 29
update table_4 set column16 = 320327 where column1 = 90
update table_6 set column9 = 186317 where column1 = 60
update table_8 set column2 = 11911 where column1 = 13
update table_6 set column6 = 843712 where column1 = 52
update table_6 set column17 = 173880 where column1 = 35
update table_4 set column15 = 145074 where column1 = 49
update table_0 set column18 = 87453 where column1 = 78
update table_4 set column8 = 587685 where column1 = 60
update table_9 set column4 = 910015 where column1 = 1
update table_6 set column15 = 290311 where column1 = 69
update table_7 set column2 = 927858 where column1 = 36
update table_2 set column17 = 181158 where column1 = 11
update table_9 set column18 = 472531 where column1 = 90
update table_6 set column10 = 772040 where column1 = 79
update table_7 set column19 = 507667 where column1 = 40
update table_6 set column14 = 863351 where column1 = 99
update table_8 set column9 = 368903 where column1 = 87
update table_6 set column9 = 711763 where column1 = 66
update table_6 set column19 = 228768 where column1 = 2
update table_3 set column15 = 625164 where column1 = 1
update table_7 set column2 = 934244 where column1 = 88
update table_8 set column2 = 189642 where column1 = 75
update table_8 set column14 = 98431 where column1 = 11
update table_6 set column17 = 306210 where column1 = 98
update table_9 set column16 = 240565 where column1 = 80
update table_3 set column10 = 746518 where column1 = 85
update table_1 set column13 = 768548 where column1 = 30
update table_1 set column9 = 759798 where column1 = 73
update table_3 set column10 = 975879 where column1 = 24
update table_3 set column6 = 217929 where column1 = 70
update table_1 set column3 = 810567 where column1 = 93
update table_2 set column18 = 623499 where column1 = 76
update table_0 set column17 = 675540 where column1 = 51
update table_7 set column7 = 202355 where column1 = 58
update table_4 set column2 = 494258 where column1 = 63
update table_4 set column2 = 778157 where column1 = 0
update table_1 set column12 = 814203 where column1 = 69
update table_2 set column18 = 797358 where column1 = 55
update table_9 set column7 = 453465 where column1 = 55
update table_7 set column6 = 550913 where column1 = 63
update table_5 set column8 = 154812 where column1 = 1
update table_5 set column14 = 400713 where column1 = 64
update table_6 set column18 = 375093 where column1 = 29
update table_2 set column15 = 841802 where column1 = 47
update table_0 set column10 = 848296 where column1 = 63
update table_2 set column9 = 497001 where column1 = 98
update table_5 set column14 = 435048 where column1 = 42
update table_6 set column10 = 409646 where column1 = 52
update table_6 set column20 = 216782 where column1 = 29
update table_3 set column20 = 264927 where column1 = 74
update table_5 set column2 = 702254 where column1 = 17
update table_2 set column17 = 984561 where column1 = 66
update table_1 set column18 = 244551 where column1 = 44
update table_7 set column13 = 535214 where column1 = 45
update table_9 set column13 = 625308 where column1 = 91
update table_2 set column16 = 491449 where column1 = 33
update table_0 set column3 = 967270 where column1 = 0
update table_9 set column17 = 523776 where column1 = 4
update table_1 set column7 = 658192 where column1 = 90
update table_4 set column3 = 172909 where column1 = 96
update table_8 set column19 = 168367 where column1 = 30
update table_9 set column17 = 477079 where column1 = 33
update table_8 set column18 = 794529 where column1 = 90
update table_4 set column9 = 568366 where column1 = 4
update table_7 set column15 = 401003 where column1 = 7
update table_8 set column14 = 179451 where column1 = 17
update table_2 set column7 = 489365 where column1 = 95
update table_6 set column7 = 323889 where column1 = 44
update table_7 set column6 = 115557 where column1 = 30
update table_8 set column11 = 757762 where column1 = 95
update table_4 set column16 = 49203 where column1 = 90
update table_5 set column6 = 347496 where column1 = 80
update table_5 set column20 = 443301 where column1 = 55
update table_3 set column4 = 680550 where column1 = 91
update table_6 set column7 = 738716 where column1 = 33
update table_1 set column9 = 780627 where column1 = 65
update table_0 set column8 = 653904 where column1 = 55
update table_6 set column11 = 182926 where column1 = 13
update table_7 set column16 = 275917 where column1 = 30
update table_0 set column14 = 561359 where column1 = 10
update table_3 set column10 = 967256 where column1 = 24
update table_0 set column9 = 464185 where column1 = 26
update table_4 set column4 = 457471 where column1 = 3
update table_1 set column16 = 111517 where column1 = 62
update table_4 set column17 = 767257 where column1 = 13
update table_1 set column16 = 248233 where column1 = 59
update table_8 set column12 = 645856 where column1 = 68
update table_0 set column9 = 853097 where column1 = 50
update table_3 set column2 = 339932 where column1 = 32
update table_5 set column16 = 204331 where column1 = 23
update table_7 set column11 = 237815 where column1 = 20
update table_9 set column19 = 489053 where column1 = 25
update table_8 set column15 = 945010 where column1 = 90
update table_9 set column18 = 865495 where column1 = 20
update table_4 set column4 = 408606 where column1 = 79
update table_2 set column15 = 16454 where column1 = 9
update table_1 set column11 = 626806 where column1 = 54
update table_6 set column11 = 591922 where column1 = 51
update table_7 set column11 = 619308 where column1 = 55
update table_9 set column3 = 324204 where column1 = 10
update table_7 set column10 = 694910 where column1 = 17
update table_6 set column19 = 663536 where column1 = 6
update table_7 set column5 = 241358 where column1 = 69
update table_7 set column4 = 475365 where column1 = 89
update table_9 set column10 = 814464 where column1 = 6
update table_9 set column6 = 339534 where column1 = 64
update table_6 set column17 = 991711 where column1 = 71
update table_5 set column7 = 990344 where column1 = 3
update table_3 set column17 = 17621 where column1 = 28
update table_9 set column12 = 78432 where column1 = 15
update table_2 set column8 = 652295 where column1 = 56
update table_2 set column6 = 381618 where column1 = 27
update table_7 set column9 = 417104 where column1 = 95
update table_5 set column8 = 365422 where column1 = 14
update table_3 set column8 = 825730 where column1 = 12
update table_2 set column4 = 846742 where column1 = 75
update table_0 set column10 = 211875 where column1 = 7
update table_0 set column9 = 956957 where column1 = 74
update table_7 set column20 = 714096 where column1 = 29
update table_5 set column4 = 670071 where column1 = 20
update table_7 set column6 = 185776 where column1 = 89
update table_6 set column14 = 475210 where column1 = 14
update table_0 set column17 = 35452 where column1 = 92
update table_0 set column11 = 738854 where column1 = 97
update table_9 set column12 = 388622 where column1 = 4
update table_3 set column6 = 104187 where column1 = 93
update table_8 set column2 = 327085 where column1 = 76
update table_2 set column11 = 320375 where column1 = 66
update table_3 set column15 = 380805 where column1 = 5
update table_4 set column15 = 233443 where column1 = 8
update table_0 set column8 = 322721 where column1 = 97
update table_2 set column9 = 661672 where column1 = 78
update table_4 set column2 = 932103 where column1 = 42
update table_2 set column19 = 140657 where column1 = 94
update table_8 set column19 = 1204 where column1 = 93
update table_7 set column7 = 777341 where column1 = 33
update table_4 set column15 = 45152 where column1 = 59
update table_5 set column8 = 155296 where column1 = 73
update table_8 set column19 = 768493 where column1 = 5
update table_9 set column2 = 962918 where column1 = 63
update table_1 set column2 = 714273 where column1 = 18
update table_8 set column11 = 817339 where column1 = 23
update table_6 set column7 = 925891 where column1 = 35
update table_1 set column14 = 512090 where column1 = 29
update table_5 set column13 = 171831 where column1 = 37
update table_9 set column2 = 370171 where column1 = 48
update table_4 set column12 = 37532 where column1 = 65
update table_9 set column13 = 467014 where column1 = 52
update table_1 set column2 = 764684 where column1 = 70
update table_9 set column17 = 51203 where column1 = 5
update table_3 set column5 = 933546 where column1 = 65
update table_1 set column3 = 689995 where column1 = 69
update table_4 set column4 = 840138 where column1 = 28
update table_1 set column6 = 623913 where column1 = 26
update table_7 set column7 = 14205 where column1 = 52
update table_6 set column8 = 721172 where column1 = 43
update table_0 set column2 = 726713 where column1 = 70
update table_2 set column12 = 202415 where column1 = 88
update table_1 set column4 = 677119 where column1 = 73
update table_8 set column12 = 82873 where column1 = 62
update table_7 set column11 = 685937 where column1 = 79
update table_8 set column13 = 303477 where column1 = 67
update table_8 set column10 = 21693 where column1 = 17
update table_2 set column9 = 759289 where column1 = 82
update table_5 set column12 = 429059 where column1 = 49
update table_8 set column9 = 12279 where column1 = 25
update table_8 set column18 = 508832 where column1 = 76
update table_9 set column17 = 695674 where column1 = 11
update table_5 set column17 = 189915 where column1 = 46
update table_3 set column4 = 363317 where column1 = 81
update table_2 set column3 = 115922 where column1 = 12
update table_4 set column8 = 22688 where column1 = 19
update table_9 set column18 = 888013 where column1 = 82
update table_8 set column19 = 233939 where column1 = 20
update table_1 set column10 = 76390 where column1 = 66
update table_3 set column16 = 435290 where column1 = 87
update table_1 set column18 = 180600 where column1 = 64
update table_7 set column15 = 658215 where column1 = 29
update table_8 set column4 = 225282 where column1 = 96
update table_4 set column19 = 78923 where column1 = 40
update table_4 set column9 = 184218 where column1 = 70
update table_3 set column13 = 269161 where column1 = 30
update table_3 set column6 = 123578 where column1 = 40
update table_6 set column18 = 259445 where column1 = 84
update table_8 set column12 = 206381 where column1 = 40
update table_3 set column6 = 291120 where column1 = 66
update table_5 set column5 = 57925 where column1 = 4
update table_2 set column20 = 790165 where column1 = 20
update table_1 set column7 = 498248 where column1 = 11
update table_6 set column20 = 942097 where column1 = 69
update table_8 set column20 = 391651 where column1 = 53
update table_9 set column9 = 752493 where column1 = 68
update table_1 set column9 = 559938 where column1 = 25
update table_0 set column8 = 446527 where column1 = 41
update table_3 set column4 = 989555 where column1 = 76
update table_7 set column5 = 742127 where column1 = 32
update table_8 set column19 = 610350 where column1 = 28
update table_0 set column2 = 255026 where column1 = 39
update table_5 set column12 = 636409 where column1 = 17
update table_4 set column18 = 901695 where column1 = 21
update table_9 set column16 = 936543 where column1 = 64
update table_1 set column6 = 773006 where column1 = 45
update table_5 set column16 = 412432 where column1 = 16
update table_5 set column12 = 951360 where column1 = 65
update table_9 set column3 = 894221 where column1 = 98
update table_6 set column14 = 394749 where column1 = 17
update table_7 set column3 = 446301 where column1 = 96
update table_2 set column16 = 420076 where column1 = 87
update table_0 set column15 = 916170 where column1 = 48
update table_6 set column16 = 489263 where column1 = 57
update table_5 set column2 = 814361 where column1 = 23
update table_0 set column5 = 664194 where column1 = 11
update table_6 set column14 = 865150 where column1 = 98
update table_6 set column10 = 74728 where column1 = 40
update table_1 set column11 = 45795 where column1 = 72
update table_6 set column9 = 261363 where column1 = 64
update table_1 set column8 = 576584 where column1 = 47
update table_9 set column19 = 737228 where column1 = 16
update table_1 set column4 = 945737 where column1 = 18
update table_4 set column13 = 592101 where column1 = 63
update table_1 set column7 = 771496 where column1 = 46
update table_7 set column6 = 675126 where column1 = 81
update table_1 set column12 = 178121 where column1 = 35
update table_9 set column12 = 546799 where column1 = 94
update table_9 set column16 = 327171 where column1 = 69
update table_3 set column16 = 889777 where column1 = 84
update table_6 set column2 = 467241 where column1 = 88
update table_4 set column15 = 562907 where column1 = 67
update table_1 set column4 = 212228 where column1 = 57
update table_7 set column9 = 453444 where column1 = 91
update table_9 set column15 = 621159 where column1 = 7
update table_2 set column2 = 990796 where column1 = 92
update table_0 set column9 = 459685 where column1 = 35
update table_1 set column7 = 555885 where column1 = 38
update table_0 set column13 = 324405 where column1 = 3
update table_2 set column15 = 158950 where column1 = 12
update table_9 set column10 = 955670 where column1 = 42
update table_4 set column6 = 429348 where column1 = 84
update table_0 set column19 = 729305 where column1 = 88
update table_5 set column18 = 158237 where column1 = 87
update table_0 set column7 = 1764 where column1 = 60
update table_4 set column12 = 766722 where column1 = 26
update table_7 set column18 = 371960 where column1 = 37
update table_8 set column8 = 837954 where column1 = 81
update table_3 set column19 = 286546 where column1 = 76
update table_5 set column3 = 31400 where column1 = 34
update table_4 set column19 = 657953 where column1 = 73
update table_4 set column20 = 40349 where column1 = 6
update table_9 set column15 = 656033 where column1 = 88
update table_4 set column14 = 135491 where column1 = 64
update table_9 set column10 = 655454 where column1 = 49
update table_0 set column11 = 186927 where column1 = 83
update table_1 set column10 = 545420 where column1 = 58
update table_1 set column12 = 962582 where column1 = 34
update table_8 set column11 = 841658 where column1 = 90
update table_2 set column6 = 25652 where column1 = 31
update table_9 set column10 = 706143 where column1 = 63
update table_8 set column7 = 303219 where column1 = 41
update table_8 set column11 = 496279 where column1 = 76
update table_1 set column4 = 209589 where column1 = 11
update table_1 set column10 = 406407 where column1 = 72
update table_1 set column7 = 991205 where column1 = 45
update table_7 set column12 = 884203 where column1 = 5
update table_4 set column9 = 632151 where column1 = 95
update table_9 set column20 = 817714 where column1 = 28
update table_0 set column19 = 792437 where column1 = 80
update table_1 set column20 = 841230 where column1 = 70
update table_9 set column6 = 855299 where column1 = 14
update table_1 set column17 = 29052 where column1 = 37
update table_9 set column5 = 909816 where column1 = 2
update table_0 set column10 = 377441 where column1 = 23
update table_2 set column5 = 941411 where column1 = 90
update table_3 set column15 = 93392 where column1 = 4
update table_9 set column15 = 550131 where column1 = 47
update table_2 set column17 = 973173 where column1 = 33
update table_4 set column5 = 169157 where column1 = 1
update table_5 set column2 = 556767 where column1 = 62
update table_3 set column8 = 615327 where column1 = 59
update table_7 set column8 = 757718 where column1 = 78
update table_2 set column17 = 915201 where column1 = 49
update table_1 set column2 = 834582 where column1 = 38
update table_8 set column10 = 479984 where column1 = 63
update table_0 set column7 = 411185 where column1 = 20
update table_1 set column12 = 717487 where column1 = 44
update table_0 set column4 = 8802 where column1 = 88
update table_3 set column15 = 439374 where column1 = 23
update table_6 set column13 = 548483 where column1 = 9
update table_8 set column4 = 550816 where column1 = 22
update table_1 set column18 = 766569 where column1 = 68
update table_0 set column8 = 657040 where column1 = 35
update table_8 set column3 = 987907 where column1 = 15
update table_5 set column4 = 558866 where column1 = 44
update table_9 set column7 = 982883 where column1 = 87
update table_6 set column3 = 723530 where column1 = 23
update table_4 set column17 = 896569 where column1 = 57
update table_2 set column4 = 204527 where column1 = 30
update table_9 set column5 = 445900 where column1 = 53
update table_6 set column20 = 96447 where column1 = 22
update table_6 set column8 = 649473 where column1 = 57
update table_9 set column10 = 828569 where column1 = 98
update table_7 set column20 = 29747 where column1 = 2
update table_6 set column2 = 133757 where column1 = 64
update table_2 set column12 = 497141 where column1 = 11
update table_7 set column10 = 413736 where column1 = 15
update table_1 set column3 = 940149 where column1 = 9
update table_0 set column13 = 283310 where column1 = 74
update table_2 set column3 = 553722 where column1 = 71
update table_9 set column15 = 46142 where column1 = 39
update table_2 set column5 = 214064 where column1 = 8
update table_0 set column16 = 601448 where column1 = 20
update table_6 set column5 = 334443 where column1 = 25
update table_9 set column17 = 831115 where column1 = 43
update table_3 set column16 = 730273 where column1 = 5
update table_0 set column2 = 206462 where column1 = 48
update table_2 set column10 = 970548 where column1 = 32
update table_2 set column15 = 631785 where column1 = 48
update table_9 set column12 = 620253 where column1 = 72
update table_4 set column7 = 761213 where column1 = 16
update table_0 set column19 = 520440 where column1 = 8
update table_2 set column4 = 653751 where column1 = 97
update table_4 set column20 = 208320 where column1 = 37
update table_8 set column3 = 338959 where column1 = 31
update table_0 set column5 = 493185 where column1 = 47
update table_6 set column2 = 803570 where column1 = 88
update table_3 set column15 = 53886 where column1 = 71
update table_5 set column15 = 673934 where column1 = 84
update table_3 set column3 = 35725 where column1 = 23
update table_8 set column17 = 680937 where column1 = 7
update table_6 set column10 = 614648 where column1 = 73
update table_4 set column4 = 27591 where column1 = 50
update table_2 set column14 = 890488 where column1 = 42
update table_7 set column7 = 256228 where column1 = 27
update table_0 set column11 = 892154 where column1 = 9
update table_7 set column5 = 831031 where column1 = 60
update table_8 set column3 = 12437 where column1 = 52
update table_4 set column5 = 287698 where column1 = 80
update table_2 set column18 = 287511 where column1 = 51
update table_9 set column9 = 449079 where column1 = 32
update table_8 set column8 = 388202 where column1 = 25
update table_9 set column12 = 860013 where column1 = 17
update table_5 set column6 = 243517 where column1 = 99
update table_4 set column12 = 337787 where column1 = 8
update table_2 set column10 = 929288 where column1 = 57
update table_4 set column19 = 429864 where column1 = 97
update table_0 set column4 = 331805 where column1 = 72
update table_2 set column12 = 801996 where column1 = 65
update table_4 set column11 = 98256 where column1 = 25
update table_2 set column20 = 414104 where column1 = 58
update table_5 set column6 = 899671 where column1 = 78
update table_0 set column3 = 122701 where column1 = 20
update table_6 set column17 = 346928 where column1 = 69
update table_6 set column6 = 769268 where column1 = 50
update table_9 set column18 = 217238 where column1 = 55
update table_7 set column16 = 136265 where column1 = 44
update table_5 set column11 = 708565 where column1 = 47
update table_7 set column4 = 226030 where column1 = 90
update table_3 set column12 = 653969 where column1 = 62
update table_5 set column15 = 58864 where column1 = 63
update table_8 set column2 = 66389 where column1 = 60
update table_3 set column16 = 75209 where column1 = 4
update table_2 set column5 = 967011 where column1 = 79
update table_4 set column18 = 104363 where column1 = 65
update table_1 set column20 = 205194 where column1 = 85
update table_7 set column20 = 700446 where column1 = 84
update table_5 set column15 = 123063 where column1 = 30
update table_3 set column19 = 498377 where column1 = 95
update table_6 set column2 = 779588 where column1 = 92
update table_1 set column15 = 380087 where column1 = 96
update table_8 set column8 = 784094 where column1 = 9
update table_9 set column10 = 492663 where column1 = 30
update table_0 set column19 = 143979 where column1 = 51
update table_7 set column17 = 812683 where column1 = 68
update table_1 set column4 = 586101 where column1 = 36
update table_8 set column19 = 548673 where column1 = 98
update table_9 set column2 = 983842 where column1 = 68
update table_5 set column5 = 785115 where column1 = 60
update table_3 set column15 = 428824 where column1 = 20
update table_5 set column20 = 776770 where column1 = 61
update table_7 set column10 = 555600 where column1 = 81
update table_8 set column3 = 278395 where column1 = 61
update table_7 set column7 = 168919 where column1 = 62
update table_4 set column15 = 118440 where column1 = 9
update table_4 set column11 = 618357 where column1 = 80
update table_1 set column14 = 837222 where column1 = 46
update table_9 set column13 = 33488 where column1 = 5
update table_0 set column12 = 286486 where column1 = 3
update table_8 set column15 = 459480 where column1 = 75
update table_5 set column6 = 653621 where column1 = 84
update table_0 set column19 = 471756 where column1 = 62
update table_7 set column6 = 471277 where column1 = 32
update table_5 set column9 = 5458 where column1 = 0
update table_3 set column9 = 939857 where column1 = 37
update table_2 set column12 = 599424 where column1 = 85
update table_2 set column10 = 390166 where column1 = 29
update table_4 set column13 = 615459 where column1 = 0
update table_6 set column3 = 467751 where column1 = 90
update table_0 set column10 = 311859 where column1 = 63
update table_0 set column5 = 153138 where column1 = 58
update table_2 set column7 = 817178 where column1 = 28
update table_6 set column11 = 240461 where column1 = 12
update table_9 set column18 = 417626 where column1 = 48
update table_4 set column7 = 606433 where column1 = 21
update table_1 set column14 = 450208 where column1 = 49
update table_8 set column4 = 171868 where column1 = 91
update table_0 set column13 = 297909 where column1 = 61
update table_0 set column14 = 931782 where column1 = 53
update table_5 set column15 = 353401 where column1 = 96
update table_4 set column2 = 680798 where column1 = 7
update table_1 set column17 = 431484 where column1 = 41
update table_7 set column3 = 305746 where column1 = 74
update table_6 set column6 = 797571 where column1 = 77
update table_8 set column9 = 832826 where column1 = 5
update table_5 set column4 = 712699 where column1 = 14
update table_5 set column15 = 848788 where column1 = 95
update table_9 set column10 = 281929 where column1 = 3
update table_1 set column8 = 197520 where column1 = 28
update table_7 set column17 = 207041 where column1 = 16
update table_9 set column14 = 942117 where column1 = 94
update table_3 set column7 = 349619 where column1 = 9
update table_0 set column19 = 832597 where column1 = 76
update table_0 set column12 = 907400 where column1 = 45
update table_5 set column9 = 625538 where column1 = 73
update table_2 set column11 = 908759 where column1 = 52
update table_6 set column9 = 95028 where column1 = 2
update table_9 set column4 = 385772 where column1 = 26
update table_8 set column20 = 721568 where column1 = 66
update table_8 set column16 = 923354 where column1 = 25
update table_9 set column19 = 810286 where column1 = 28
update table_1 set column4 = 652980 where column1 = 99
update table_3 set column12 = 546272 where column1 = 26
update table_3 set column7 = 166744 where column1 = 30
update table_9 set column11 = 505673 where column1 = 97
update table_5 set column13 = 502109 where column1 = 17
update table_7 set column9 = 275044 where column1 = 83
update table_9 set column19 = 226664 where column1 = 77
update table_9 set column7 = 778348 where column1 = 74
update table_5 set column18 = 743526 where column1 = 80
update table_9 set column5 = 293267 where column1 = 82
update table_6 set column9 = 665464 where column1 = 82
update table_7 set column9 = 518785 where column1 = 3
update table_8 set column7 = 268142 where column1 = 93
update table_0 set column15 = 916748 where column1 = 58
update table_6 set column10 = 254032 where column1 = 10
update table_1 set column20 = 187958 where column1 = 64
update table_1 set column11 = 730726 where column1 = 55
update table_5 set column2 = 872415 where column1 = 95
update table_0 set column12 = 507618 where column1 = 45
update table_3 set column2 = 872231 where column1 = 80
update table_9 set column14 = 15379 where column1 = 27
update table_2 set column10 = 282951 where column1 = 62
update table_9 set column2 = 855344 where column1 = 27
update table_6 set column18 = 445313 where column1 = 72
update table_0 set column16 = 860911 where column1 = 64
update table_8 set column15 = 757132 where column1 = 73
update table_2 set column16 = 196526 where column1 = 69
update table_7 set column7 = 335081 where column1 = 84
update table_2 set column3 = 858588 where column1 = 49
update table_1 set column6 = 396516 where column1 = 99
update table_9 set column9 = 814305 where column1 = 10
update table_2 set column11 = 970285 where column1 = 47
update table_4 set column2 = 965163 where column1 = 94
update table_5 set column7 = 932021 where column1 = 95
update table_9 set column7 = 251502 where column1 = 67
update table_0 set column6 = 10819 where column1 = 78
update table_6 set column13 = 18236 where column1 = 65
update table_7 set column17 = 94098 where column1 = 43
update table_8 set column5 = 509249 where column1 = 6
update table_2 set column18 = 170082 where column1 = 69
update table_1 set column7 = 337268 where column1 = 6
update table_2 set column16 = 820947 where column1 = 19
update table_6 set column11 = 168396 where column1 = 0
update table_0 set column15 = 59654 where column1 = 75
update table_7 set column8 = 889120 where column1 = 28
update table_2 set column7 = 234504 where column1 = 91
update table_4 set column6 = 717416 where column1 = 87
update table_9 set column11 = 65542 where column1 = 0
update table_2 set column9 = 4233 where column1 = 42
update table_0 set column13 = 577664 where column1 = 39
update table_1 set column10 = 86074 where column1 = 76
update table_9 set column10 = 59362 where column1 = 81
update table_7 set column11 = 89316 where column1 = 34
update table_7 set column20 = 30655 where column1 = 8
update table_8 set column17 = 292205 where column1 = 59
update table_2 set column20 = 687402 where column1 = 60
update table_3 set column3 = 235778 where column1 = 69
update table_7 set column4 = 458199 where column1 = 51
update table_0 set column6 = 285447 where column1 = 61
update table_1 set column3 = 957244 where column1 = 9
update table_6 set column5 = 96472 where column1 = 78
update table_7 set column17 = 657139 where column1 = 18
update table_9 set column16 = 637795 where column1 = 92
update table_8 set column10 = 464422 where column1 = 0
update table_0 set column10 = 568362 where column1 = 67
update table_5 set column8 = 344278 where column1 = 39
update table_0 set column10 = 361152 where column1 = 98
update table_1 set column18 = 104564 where column1 = 27
update table_7 set column9 = 284509 where column1 = 86
update table_3 set column17 = 700063 where column1 = 71
update table_2 set column7 = 226449 where column1 = 24
update table_0 set column8 = 10605 where column1 = 44
update table_0 set column2 = 784192 where column1 = 96
update table_9 set column2 = 519962 where column1 = 1
update table_9 set column20 = 768870 where column1 = 0
update table_2 set column18 = 764488 where column1 = 39
update table_5 set column9 = 353839 where column1 = 12
update table_6 set column12 = 978493 where column1 = 54
update table_0 set column14 = 651134 where column1 = 92
update table_3 set column13 = 759379 where column1 = 27
update table_7 set column14 = 834458 where column1 = 29
update table_9 set column5 = 162781 where column1 = 5
update table_2 set column8 = 555367 where column1 = 44
update table_1 set column10 = 571015 where column1 = 89
update table_7 set column8 = 795204 where column1 = 56
update table_3 set column2 = 469665 where column1 = 40
update table_8 set column5 = 584107 where column1 = 30
update table_3 set column14 = 625294 where column1 = 89
update table_0 set column14 = 337924 where column1 = 38
update table_4 set column11 = 788433 where column1 = 90
update table_6 set column16 = 221044 where column1 = 78
update table_5 set column8 = 965451 where column1 = 45
update table_3 set column18 = 986525 where column1 = 11
update table_0 set column19 = 861834 where column1 = 97
update table_6 set column12 = 117789 where column1 = 76
update table_3 set column14 = 382683 where column1 = 46
update table_1 set column3 = 229616 where column1 = 69
update table_9 set column17 = 129347 where column1 = 58
update table_8 set column13 = 143474 where column1 = 7
update table_5 set column18 = 581738 where column1 = 74
update table_4 set column20 = 884900 where column1 = 17
update table_5 set column6 = 772346 where column1 = 20
update table_4 set column15 = 694370 where column1 = 55
update table_9 set column2 = 742002 where column1 = 95
update table_7 set column8 = 651537 where column1 = 74
update table_1 set column19 = 496297 where column1 = 40
update table_2 set column10 = 553356 where column1 = 45
update table_2 set column5 = 321696 where column1 = 79
update table_6 set column18 = 905126 where column1 = 73
update table_4 set column2 = 250025 where column1 = 35
update table_2 set column10 = 599502 where column1 = 53
update table_3 set column6 = 456807 where column1 = 64
update table_0 set column20 = 991860 where column1 = 63
update table_3 set column8 = 691233 where column1 = 47
update table_5 set column14 = 259407 where column1 = 6
update table_1 set column2 = 422663 where column1 = 34
update table_6 set column17 = 893480 where column1 = 67
update table_5 set column3 = 189645 where column1 = 13
update table_6 set column7 = 205414 where column1 = 37
update table_6 set column17 = 722725 where column1 = 84
update table_3 set column9 = 690748 where column1 = 1
update table_3 set column6 = 529760 where column1 = 72
update table_1 set column17 = 427443 where column1 = 89
update table_2 set column9 = 542802 where column1 = 73
update table_6 set column20 = 910264 where column1 = 47
update table_3 set column9 = 917704 where column1 = 38
update table_1 set column4 = 263081 where column1 = 53
update table_2 set column3 = 113808 where column1 = 52
update table_1 set column4 = 564164 where column1 = 2
update table_2 set column9 = 131870 where column1 = 2
update table_8 set column14 = 296726 where column1 = 6
update table_4 set column7 = 559443 where column1 = 84
update table_2 set column4 = 295316 where column1 = 83
update table_3 set column8 = 916902 where column1 = 2
update table_5 set column17 = 46115 where column1 = 25
update table_6 set column3 = 230165 where column1 = 34
update table_5 set column20 = 710774 where column1 = 20
update table_4 set column13 = 353157 where column1 = 7
update table_0 set column18 = 182021 where column1 = 25
update table_4 set column2 = 341971 where column1 = 72
update table_4 set column13 = 587450 where column1 = 68
update table_8 set column18 = 964780 where column1 = 51
update table_7 set column4 = 148618 where column1 = 10
update table_6 set column18 = 581556 where column1 = 13
update table_6 set column8 = 565264 where column1 = 16
update table_6 set column3 = 146669 where column1 = 14
update table_6 set column15 = 858631 where column1 = 87
update table_2 set column15 = 592602 where column1 = 45
update table_2 set column2 = 956808 where column1 = 84
update table_7 set column8 = 919821 where column1 = 18
update table_6 set column20 = 110924 where column1 = 98
update table_8 set column13 = 234412 where column1 = 43
update table_7 set column7 = 101066 where column1 = 41
update table_9 set column15 = 399978 where column1 = 70
update table_0 set column16 = 498460 where column1 = 17
update table_3 set column2 = 215447 where column1 = 45
update table_9 set column15 = 696624 where column1 = 63
update table_6 set column3 = 495363 where column1 = 83
update table_0 set column14 = 558694 where column1 = 55
update table_7 set column3 = 770403 where column1 = 36
update table_3 set column17 = 33914 where column1 = 6
update table_1 set column13 = 764142 where column1 = 93
update table_6 set column19 = 803138 where column1 = 41
update table_4 set column17 = 694096 where column1 = 45
update table_9 set column17 = 153225 where column1 = 91
update table_9 set column8 = 336676 where column1 = 35
update table_2 set column10 = 62834 where column1 = 54
update table_1 set column4 = 277453 where column1 = 35
update table_9 set column18 = 348102 where column1 = 84
update table_4 set column8 = 445839 where column1 = 44
update table_4 set column8 = 989145 where column1 = 68
update table_8 set column6 = 477478 where column1 = 36
update table_6 set column18 = 145690 where column1 = 13
update table_0 set column7 = 487848 where column1 = 80
update table_3 set column11 = 445793 where column1 = 81
update table_6 set column16 = 687728 where column1 = 24
update table_7 set column13 = 712588 where column1 = 50
update table_5 set column17 = 690540 where column1 = 30
update table_1 set column20 = 715774 where column1 = 96
update table_0 set column12 = 74828 where column1 = 15
update table_8 set column14 = 568576 where column1 = 2
update table_2 set column11 = 836660 where column1 = 88
update table_4 set column18 = 831676 where column1 = 68
update table_7 set column17 = 424610 where column1 = 77
update table_8 set column9 = 486286 where column1 = 40
update table_4 set column16 = 270152 where column1 = 36
update table_2 set column11 = 17309 where column1 = 71
update table_0 set column5 = 812994 where column1 = 52
update table_7 set column9 = 636763 where column1 = 25
update table_1 set column12 = 704616 where column1 = 11
update table_5 set column3 = 16664 where column1 = 20
update table_8 set column16 = 917477 where column1 = 5
update table_9 set column16 = 482666 where column1 = 97
update table_9 set column18 = 254280 where column1 = 95
update table_3 set column4 = 886278 where column1 = 81
update table_8 set column20 = 267834 where column1 = 12
update table_1 set column6 = 235479 where column1 = 96
update table_8 set column3 = 515146 where column1 = 14
update table_6 set column19 = 193592 where column1 = 65
update table_3 set column20 = 796138 where column1 = 68
update table_7 set column12 = 855489 where column1 = 47
update table_5 set column9 = 675174 where column1 = 13
update table_7 set column7 = 598083 where column1 = 44
update table_1 set column9 = 145408 where column1 = 59
update table_2 set column15 = 116290 where column1 = 48
update table_0 set column4 = 206820 where column1 = 15
update table_5 set column4 = 750055 where column1 = 36
update table_4 set column15 = 540806 where column1 = 18
update table_0 set column13 = 574389 where column1 = 40
update table_7 set column18 = 113579 where column1 = 16
update table_1 set column16 = 841579 where column1 = 87
update table_1 set column6 = 453100 where column1 = 21
update table_8 set column2 = 518635 where column1 = 29
update table_7 set column3 = 753095 where column1 = 92
update table_8 set column14 = 85103 where column1 = 11
update table_6 set column19 = 765148 where column1 = 78
update table_2 set column13 = 577544 where column1 = 64
update table_0 set column3 = 954230 where column1 = 72
update table_1 set column7 = 796795 where column1 = 15
update table_0 set column18 = 237703 where column1 = 83
update table_2 set column19 = 479938 where column1 = 62
update table_2 set column9 = 294540 where column1 = 56
update table_7 set column3 = 382853 where column1 = 37
update table_3 set column4 = 471388 where column1 = 63
update table_7 set column11 = 260004 where column1 = 11
update table_7 set column5 = 676236 where column1 = 99
update table_0 set column6 = 507765 where column1 = 14
update table_8 set column11 = 804346 where column1 = 48
update table_7 set column19 = 219729 where column1 = 94
update table_1 set column20 = 207361 where column1 = 51
update table_9 set column19 = 268444 where column1 = 46
update table_1 set column16 = 749529 where column1 = 71
update table_6 set column14 = 380003 where column1 = 58
update table_5 set column4 = 415493 where column1 = 87
update table_1 set column11 = 927604 where column1 = 39
update table_8 set column18 = 135723 where column1 = 75
update table_7 set column17 = 413126 where column1 = 85
update table_4 set column5 = 554608 where column1 = 81
update table_9 set column8 = 328116 where column1 = 16
update table_9 set column19 = 21686 where column1 = 86
update table_1 set column7 = 915803 where column1 = 45

--========================================
print 'Creating transaction log backup #2'
--========================================

-- Create tlog backup
DECLARE @BackupLocation NVARCHAR(100)
EXEC master..xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',  
	@key = 'Software\Microsoft\MSSQLServer\MSSQLServer',  
	@value_name = 'BackupDirectory', @BackupLocation = @BackupLocation OUTPUT ;  
SET @BackupLocation = @BackupLocation + '\ApexSQLLogDEMOtlog2.bak'
BACKUP LOG ApexSQLLogDEMO TO DISK = @BackupLocation WITH INIT
GO

update table_6 set column5 = 693218 where column1 = 82
update table_6 set column14 = 292560 where column1 = 5
update table_3 set column18 = 944668 where column1 = 32
update table_7 set column13 = 834663 where column1 = 31
update table_3 set column13 = 630324 where column1 = 73
update table_5 set column18 = 734813 where column1 = 97
update table_1 set column3 = 860288 where column1 = 84
update table_5 set column8 = 874830 where column1 = 84
update table_6 set column11 = 999243 where column1 = 77
update table_0 set column8 = 313648 where column1 = 22
update table_5 set column3 = 269980 where column1 = 32
update table_5 set column17 = 516438 where column1 = 39
update table_2 set column14 = 418265 where column1 = 95
update table_6 set column20 = 40949 where column1 = 88
update table_6 set column4 = 988953 where column1 = 84
update table_4 set column10 = 796150 where column1 = 0
update table_5 set column4 = 847840 where column1 = 9
update table_8 set column18 = 472148 where column1 = 59
update table_0 set column4 = 857090 where column1 = 38
update table_5 set column14 = 794375 where column1 = 1
update table_0 set column14 = 880888 where column1 = 82
update table_7 set column8 = 598588 where column1 = 47
update table_0 set column18 = 378733 where column1 = 65
update table_6 set column7 = 292296 where column1 = 7
update table_0 set column11 = 699282 where column1 = 20
update table_6 set column19 = 318867 where column1 = 97
update table_7 set column6 = 623555 where column1 = 33
update table_7 set column6 = 272866 where column1 = 54
update table_4 set column13 = 675276 where column1 = 22
update table_6 set column13 = 14165 where column1 = 96
update table_6 set column17 = 370072 where column1 = 76
update table_2 set column12 = 918227 where column1 = 97
update table_4 set column19 = 237566 where column1 = 65
update table_7 set column8 = 801101 where column1 = 5
update table_2 set column19 = 741305 where column1 = 16
update table_4 set column6 = 753052 where column1 = 51
update table_9 set column15 = 888956 where column1 = 88
update table_0 set column6 = 776160 where column1 = 80
update table_0 set column2 = 841203 where column1 = 84
update table_6 set column12 = 304537 where column1 = 84
update table_6 set column19 = 516835 where column1 = 44
update table_0 set column18 = 483542 where column1 = 35
update table_7 set column4 = 454210 where column1 = 71
update table_2 set column5 = 777231 where column1 = 50
update table_2 set column17 = 946761 where column1 = 65
update table_6 set column18 = 132717 where column1 = 2
update table_0 set column13 = 911168 where column1 = 80
update table_6 set column14 = 40431 where column1 = 57
update table_4 set column2 = 135235 where column1 = 7
update table_3 set column8 = 995697 where column1 = 75
update table_2 set column11 = 600782 where column1 = 74
update table_7 set column17 = 73951 where column1 = 98
update table_0 set column2 = 820526 where column1 = 49
update table_6 set column3 = 894098 where column1 = 84
update table_3 set column8 = 91255 where column1 = 98
update table_7 set column4 = 819065 where column1 = 71
update table_6 set column13 = 573753 where column1 = 31
update table_0 set column2 = 375724 where column1 = 80
update table_8 set column17 = 42683 where column1 = 85
update table_4 set column4 = 23955 where column1 = 10
update table_9 set column4 = 639129 where column1 = 58
update table_5 set column9 = 951496 where column1 = 66
update table_1 set column2 = 67796 where column1 = 0
update table_3 set column11 = 848773 where column1 = 63
update table_8 set column2 = 469211 where column1 = 96
update table_6 set column9 = 255204 where column1 = 97
update table_7 set column19 = 52951 where column1 = 95
update table_1 set column17 = 907991 where column1 = 68
update table_7 set column14 = 990699 where column1 = 48
update table_1 set column15 = 338727 where column1 = 24
update table_7 set column17 = 701788 where column1 = 89
update table_3 set column12 = 749407 where column1 = 4
update table_2 set column14 = 912464 where column1 = 65
update table_0 set column3 = 591960 where column1 = 28
update table_6 set column7 = 351295 where column1 = 36
update table_4 set column6 = 699883 where column1 = 47
update table_1 set column18 = 455258 where column1 = 19
update table_7 set column13 = 494481 where column1 = 30
update table_9 set column3 = 380863 where column1 = 52
update table_8 set column2 = 866610 where column1 = 43
update table_9 set column9 = 652719 where column1 = 76
update table_1 set column11 = 802901 where column1 = 37
update table_0 set column18 = 962515 where column1 = 9
update table_5 set column11 = 793067 where column1 = 63
update table_6 set column3 = 91775 where column1 = 71
update table_6 set column15 = 789673 where column1 = 71
update table_9 set column15 = 179491 where column1 = 29
update table_1 set column9 = 813600 where column1 = 85
update table_0 set column16 = 112835 where column1 = 16
update table_1 set column11 = 455182 where column1 = 15
update table_6 set column11 = 432252 where column1 = 76
update table_1 set column7 = 542766 where column1 = 97
update table_3 set column11 = 356304 where column1 = 87
update table_0 set column7 = 174090 where column1 = 67
update table_9 set column8 = 464418 where column1 = 49
update table_8 set column16 = 579010 where column1 = 20
update table_4 set column5 = 679352 where column1 = 10
update table_8 set column17 = 359518 where column1 = 24
update table_6 set column9 = 865162 where column1 = 59
update table_7 set column8 = 259177 where column1 = 48
update table_9 set column2 = 341525 where column1 = 77
update table_0 set column14 = 52594 where column1 = 86
update table_6 set column10 = 143968 where column1 = 40
update table_5 set column3 = 825531 where column1 = 35
update table_0 set column10 = 838257 where column1 = 46
update table_1 set column5 = 173578 where column1 = 83
update table_3 set column7 = 156157 where column1 = 76
update table_0 set column5 = 48423 where column1 = 17
update table_8 set column19 = 303587 where column1 = 72
update table_1 set column5 = 907361 where column1 = 1
update table_6 set column14 = 449296 where column1 = 44
update table_8 set column20 = 256167 where column1 = 43
update table_9 set column5 = 833857 where column1 = 16
update table_5 set column15 = 181224 where column1 = 74
update table_6 set column16 = 840044 where column1 = 48
update table_5 set column2 = 477351 where column1 = 62
update table_2 set column14 = 90526 where column1 = 35
update table_0 set column9 = 877142 where column1 = 95
update table_6 set column17 = 621734 where column1 = 57
update table_1 set column19 = 379581 where column1 = 47
update table_4 set column19 = 361720 where column1 = 42
update table_5 set column18 = 256393 where column1 = 4
update table_9 set column11 = 510293 where column1 = 38
update table_8 set column15 = 176496 where column1 = 15
update table_7 set column8 = 602115 where column1 = 77
update table_2 set column20 = 385156 where column1 = 47
update table_4 set column18 = 848617 where column1 = 24
update table_7 set column2 = 444962 where column1 = 8
update table_8 set column19 = 44128 where column1 = 71
update table_9 set column7 = 207990 where column1 = 73
update table_7 set column17 = 106873 where column1 = 39
update table_5 set column9 = 434203 where column1 = 76
update table_0 set column17 = 319437 where column1 = 16
update table_6 set column13 = 597048 where column1 = 72
update table_1 set column17 = 327470 where column1 = 75
update table_4 set column20 = 889490 where column1 = 21
update table_9 set column20 = 866504 where column1 = 77
update table_9 set column4 = 931546 where column1 = 64
update table_5 set column19 = 379302 where column1 = 4
update table_4 set column6 = 457106 where column1 = 5
update table_5 set column17 = 612572 where column1 = 97
update table_0 set column12 = 381782 where column1 = 92
update table_8 set column18 = 52139 where column1 = 9
update table_9 set column12 = 574622 where column1 = 21
update table_4 set column20 = 614118 where column1 = 16
update table_3 set column18 = 685346 where column1 = 3
update table_1 set column17 = 563910 where column1 = 67
update table_8 set column11 = 496571 where column1 = 94
update table_6 set column11 = 139110 where column1 = 7
update table_1 set column19 = 886475 where column1 = 39
update table_9 set column20 = 518073 where column1 = 63
update table_1 set column16 = 359113 where column1 = 63
update table_6 set column13 = 508767 where column1 = 24
update table_0 set column8 = 779790 where column1 = 72
update table_9 set column13 = 92842 where column1 = 25
update table_7 set column18 = 886355 where column1 = 83
update table_7 set column5 = 416073 where column1 = 69
update table_0 set column13 = 81326 where column1 = 68
update table_9 set column12 = 57715 where column1 = 2
update table_0 set column16 = 585527 where column1 = 72
update table_9 set column13 = 644981 where column1 = 21
update table_1 set column20 = 496854 where column1 = 99
update table_2 set column5 = 983890 where column1 = 22
update table_7 set column4 = 326779 where column1 = 8
update table_6 set column4 = 330661 where column1 = 41
update table_6 set column12 = 411069 where column1 = 99
update table_4 set column5 = 756777 where column1 = 18
update table_1 set column4 = 432671 where column1 = 55
update table_5 set column2 = 854431 where column1 = 13
update table_6 set column19 = 19677 where column1 = 8
update table_5 set column15 = 730528 where column1 = 93
update table_5 set column12 = 724439 where column1 = 42
update table_2 set column19 = 672978 where column1 = 78
update table_2 set column15 = 966539 where column1 = 54
update table_9 set column4 = 272609 where column1 = 71
update table_0 set column4 = 209672 where column1 = 15
update table_3 set column18 = 356465 where column1 = 33
update table_5 set column17 = 818272 where column1 = 88
update table_5 set column12 = 373658 where column1 = 27
update table_2 set column19 = 557463 where column1 = 64
update table_3 set column6 = 272080 where column1 = 96
update table_5 set column7 = 84194 where column1 = 54
update table_3 set column19 = 676282 where column1 = 42
update table_7 set column6 = 233821 where column1 = 41
update table_5 set column18 = 472012 where column1 = 72
update table_4 set column11 = 864796 where column1 = 38
update table_5 set column5 = 203124 where column1 = 97
update table_8 set column6 = 270917 where column1 = 86
update table_7 set column19 = 139249 where column1 = 75
update table_3 set column16 = 705142 where column1 = 41
update table_0 set column2 = 949931 where column1 = 17
update table_3 set column18 = 847261 where column1 = 48
update table_6 set column13 = 171784 where column1 = 79
update table_9 set column11 = 230789 where column1 = 23
update table_7 set column19 = 585198 where column1 = 76
update table_7 set column20 = 723527 where column1 = 43
update table_5 set column17 = 740672 where column1 = 66
update table_9 set column12 = 83466 where column1 = 54
update table_0 set column16 = 557489 where column1 = 34
update table_4 set column17 = 656301 where column1 = 31
update table_8 set column19 = 990806 where column1 = 13
update table_4 set column14 = 636441 where column1 = 31
update table_3 set column4 = 786923 where column1 = 46
update table_1 set column8 = 675902 where column1 = 6
update table_3 set column19 = 969702 where column1 = 17
update table_9 set column4 = 157410 where column1 = 53
update table_8 set column6 = 386572 where column1 = 53
update table_6 set column2 = 470104 where column1 = 47
update table_5 set column15 = 674603 where column1 = 13
update table_9 set column3 = 416683 where column1 = 80
update table_8 set column9 = 508689 where column1 = 12
update table_3 set column13 = 693726 where column1 = 32
update table_9 set column6 = 377570 where column1 = 92
update table_0 set column18 = 547536 where column1 = 7
update table_7 set column20 = 805070 where column1 = 23
update table_4 set column6 = 628911 where column1 = 62
update table_0 set column14 = 528631 where column1 = 14
update table_0 set column18 = 714343 where column1 = 30
update table_1 set column18 = 852819 where column1 = 70
update table_7 set column15 = 963454 where column1 = 37
update table_1 set column7 = 106682 where column1 = 49
update table_7 set column16 = 273897 where column1 = 75
update table_4 set column6 = 937565 where column1 = 61
update table_7 set column12 = 882870 where column1 = 65
update table_2 set column18 = 936867 where column1 = 68
update table_6 set column8 = 970878 where column1 = 48
update table_9 set column14 = 643641 where column1 = 49
update table_3 set column16 = 889110 where column1 = 51
update table_5 set column6 = 337652 where column1 = 63
update table_1 set column14 = 784569 where column1 = 24
update table_5 set column5 = 527775 where column1 = 14
update table_9 set column17 = 990481 where column1 = 74
update table_9 set column7 = 489544 where column1 = 75
update table_4 set column16 = 737860 where column1 = 98
update table_7 set column3 = 405578 where column1 = 40
update table_9 set column13 = 385641 where column1 = 31
update table_3 set column19 = 82446 where column1 = 79
update table_1 set column2 = 212070 where column1 = 32
update table_8 set column10 = 815001 where column1 = 83
update table_4 set column5 = 545694 where column1 = 94
update table_6 set column14 = 725118 where column1 = 50
update table_9 set column15 = 151816 where column1 = 63
update table_0 set column9 = 82685 where column1 = 64
update table_8 set column15 = 227487 where column1 = 59
update table_6 set column10 = 535423 where column1 = 21
update table_6 set column3 = 528323 where column1 = 90
update table_6 set column5 = 772648 where column1 = 11
update table_2 set column4 = 699533 where column1 = 4
update table_9 set column10 = 465310 where column1 = 23
update table_7 set column20 = 333314 where column1 = 46
update table_2 set column5 = 424908 where column1 = 19
update table_7 set column16 = 277276 where column1 = 79
update table_8 set column20 = 928323 where column1 = 48
update table_4 set column2 = 618305 where column1 = 3
update table_0 set column11 = 526797 where column1 = 53
update table_8 set column9 = 326308 where column1 = 8
update table_5 set column8 = 275902 where column1 = 10
update table_2 set column3 = 501498 where column1 = 36
update table_5 set column12 = 143053 where column1 = 53
update table_2 set column10 = 323621 where column1 = 27
update table_5 set column12 = 817109 where column1 = 6
update table_7 set column16 = 320249 where column1 = 42
update table_6 set column11 = 666042 where column1 = 25
update table_5 set column7 = 864729 where column1 = 10
update table_9 set column2 = 532058 where column1 = 20
update table_8 set column7 = 915722 where column1 = 10
update table_6 set column7 = 725437 where column1 = 48
update table_5 set column19 = 200963 where column1 = 75
update table_9 set column11 = 97358 where column1 = 52
update table_7 set column6 = 986976 where column1 = 3
update table_6 set column3 = 295202 where column1 = 52
update table_6 set column20 = 42267 where column1 = 70
update table_3 set column8 = 340900 where column1 = 9
update table_5 set column16 = 371737 where column1 = 71
update table_5 set column7 = 266477 where column1 = 49
update table_1 set column6 = 767311 where column1 = 4
update table_0 set column3 = 709227 where column1 = 4
update table_2 set column18 = 336735 where column1 = 7
update table_3 set column12 = 924883 where column1 = 31
update table_6 set column16 = 125732 where column1 = 48
update table_1 set column4 = 24615 where column1 = 29
update table_1 set column3 = 848543 where column1 = 8
update table_6 set column6 = 131724 where column1 = 67
update table_2 set column8 = 769263 where column1 = 42
update table_6 set column16 = 53097 where column1 = 74
update table_4 set column19 = 954946 where column1 = 62
update table_0 set column20 = 557777 where column1 = 44
update table_4 set column4 = 619349 where column1 = 51
update table_5 set column4 = 162934 where column1 = 8
update table_9 set column7 = 144033 where column1 = 24
update table_8 set column18 = 416632 where column1 = 15
update table_7 set column7 = 8504 where column1 = 26
update table_5 set column4 = 929835 where column1 = 27
update table_0 set column8 = 658377 where column1 = 4
update table_1 set column14 = 802760 where column1 = 83
update table_7 set column18 = 90313 where column1 = 59
update table_8 set column6 = 319076 where column1 = 14
update table_8 set column20 = 844971 where column1 = 99
update table_4 set column2 = 683084 where column1 = 77
update table_9 set column12 = 286134 where column1 = 40
update table_4 set column13 = 588006 where column1 = 50
update table_2 set column13 = 847698 where column1 = 84
update table_2 set column16 = 268569 where column1 = 64
update table_3 set column16 = 122839 where column1 = 2
update table_9 set column6 = 264325 where column1 = 33
update table_3 set column11 = 42332 where column1 = 46
update table_2 set column10 = 330110 where column1 = 97
update table_6 set column10 = 23025 where column1 = 24
update table_4 set column19 = 279876 where column1 = 37
update table_4 set column7 = 374482 where column1 = 68
update table_6 set column4 = 614666 where column1 = 0
update table_8 set column7 = 641970 where column1 = 39
update table_7 set column9 = 712334 where column1 = 88
update table_3 set column9 = 936494 where column1 = 65
update table_5 set column15 = 293712 where column1 = 67
update table_0 set column20 = 950033 where column1 = 49
update table_5 set column2 = 651552 where column1 = 67
update table_3 set column14 = 137910 where column1 = 2
update table_9 set column18 = 139133 where column1 = 82
update table_7 set column17 = 188918 where column1 = 30
update table_5 set column3 = 212985 where column1 = 77
update table_6 set column13 = 950406 where column1 = 97
update table_6 set column15 = 666489 where column1 = 1
update table_9 set column13 = 387303 where column1 = 27
update table_2 set column19 = 683867 where column1 = 26
update table_7 set column9 = 529454 where column1 = 96
update table_9 set column4 = 479662 where column1 = 89
update table_5 set column15 = 733436 where column1 = 77
update table_3 set column13 = 30647 where column1 = 36
update table_7 set column6 = 370668 where column1 = 33
update table_0 set column5 = 687349 where column1 = 97
update table_7 set column6 = 343516 where column1 = 36
update table_5 set column13 = 856185 where column1 = 45
update table_1 set column8 = 888297 where column1 = 73
update table_7 set column10 = 644485 where column1 = 58
update table_7 set column19 = 749807 where column1 = 24
update table_9 set column13 = 697566 where column1 = 98
update table_2 set column10 = 380041 where column1 = 44
update table_5 set column7 = 747478 where column1 = 99
update table_3 set column18 = 42467 where column1 = 68
update table_3 set column19 = 105115 where column1 = 96
update table_7 set column3 = 337165 where column1 = 17
update table_5 set column16 = 175472 where column1 = 85
update table_5 set column12 = 188262 where column1 = 37
update table_7 set column12 = 924008 where column1 = 93
update table_4 set column2 = 938793 where column1 = 36
update table_4 set column13 = 717637 where column1 = 70
update table_5 set column13 = 620139 where column1 = 72
update table_3 set column16 = 49305 where column1 = 82
update table_6 set column9 = 292076 where column1 = 78
update table_5 set column20 = 376005 where column1 = 19
update table_6 set column18 = 7003 where column1 = 57
update table_7 set column19 = 479174 where column1 = 60
update table_8 set column20 = 835317 where column1 = 2
update table_8 set column4 = 901700 where column1 = 43
update table_5 set column7 = 189065 where column1 = 81
update table_8 set column10 = 668371 where column1 = 40
update table_6 set column4 = 337168 where column1 = 83
update table_4 set column16 = 97884 where column1 = 73
update table_6 set column3 = 577702 where column1 = 26
update table_0 set column17 = 14304 where column1 = 75
update table_7 set column3 = 103561 where column1 = 83
update table_0 set column17 = 672957 where column1 = 58
update table_5 set column15 = 215816 where column1 = 24
update table_1 set column9 = 69705 where column1 = 43
update table_2 set column8 = 305849 where column1 = 2
update table_1 set column10 = 74015 where column1 = 32
update table_7 set column10 = 505598 where column1 = 19
update table_5 set column19 = 690855 where column1 = 99
update table_9 set column6 = 760260 where column1 = 40
update table_7 set column18 = 995392 where column1 = 86
update table_3 set column15 = 995935 where column1 = 9
update table_3 set column17 = 803599 where column1 = 63
update table_5 set column15 = 275195 where column1 = 29
update table_6 set column11 = 734824 where column1 = 9
update table_1 set column10 = 863934 where column1 = 92
update table_8 set column12 = 366165 where column1 = 59
update table_4 set column17 = 166687 where column1 = 11
update table_7 set column15 = 114566 where column1 = 78
update table_3 set column3 = 70175 where column1 = 7
update table_3 set column20 = 621756 where column1 = 32
update table_2 set column12 = 674285 where column1 = 80
update table_5 set column9 = 195799 where column1 = 55
update table_9 set column15 = 49681 where column1 = 70
update table_8 set column5 = 857142 where column1 = 84
update table_2 set column20 = 926572 where column1 = 16
update table_2 set column19 = 596303 where column1 = 22
update table_7 set column2 = 365189 where column1 = 26
update table_8 set column19 = 776837 where column1 = 23
update table_2 set column3 = 597618 where column1 = 84
update table_0 set column3 = 959652 where column1 = 50
update table_1 set column8 = 594687 where column1 = 19
update table_1 set column4 = 804181 where column1 = 77
update table_3 set column14 = 514422 where column1 = 90
update table_6 set column15 = 104914 where column1 = 79
update table_2 set column4 = 145821 where column1 = 50
update table_4 set column7 = 89248 where column1 = 74
update table_5 set column2 = 398429 where column1 = 80
update table_4 set column19 = 932131 where column1 = 89
update table_4 set column14 = 288233 where column1 = 13
update table_1 set column12 = 794556 where column1 = 15
update table_7 set column17 = 493798 where column1 = 65
update table_1 set column3 = 55156 where column1 = 12
update table_1 set column18 = 659420 where column1 = 20
update table_4 set column3 = 610361 where column1 = 27
update table_4 set column20 = 563852 where column1 = 52
update table_4 set column16 = 972835 where column1 = 83
update table_5 set column3 = 568625 where column1 = 95
update table_7 set column2 = 965866 where column1 = 70
update table_1 set column13 = 572571 where column1 = 13
update table_5 set column5 = 997266 where column1 = 4
update table_1 set column2 = 347440 where column1 = 71
update table_4 set column8 = 857636 where column1 = 77
update table_7 set column12 = 169554 where column1 = 54
update table_0 set column12 = 593518 where column1 = 16
update table_2 set column7 = 501587 where column1 = 55
update table_3 set column5 = 188638 where column1 = 19
update table_5 set column13 = 739616 where column1 = 75
update table_4 set column14 = 487614 where column1 = 55
update table_7 set column20 = 42067 where column1 = 21
update table_3 set column5 = 446954 where column1 = 42
update table_7 set column9 = 373576 where column1 = 47
update table_6 set column16 = 61471 where column1 = 62
update table_6 set column16 = 272822 where column1 = 53
update table_4 set column6 = 808662 where column1 = 74
update table_9 set column14 = 440239 where column1 = 71
update table_4 set column7 = 867513 where column1 = 31
update table_7 set column14 = 642570 where column1 = 84
update table_3 set column12 = 499811 where column1 = 41
update table_8 set column6 = 675605 where column1 = 67
update table_6 set column4 = 718465 where column1 = 79
update table_4 set column16 = 214420 where column1 = 84
update table_5 set column8 = 765409 where column1 = 68
update table_9 set column20 = 440971 where column1 = 81
update table_7 set column18 = 268050 where column1 = 1
update table_0 set column3 = 729130 where column1 = 6
update table_6 set column20 = 869767 where column1 = 44
update table_0 set column15 = 195690 where column1 = 81
update table_4 set column14 = 665727 where column1 = 10
update table_3 set column6 = 717873 where column1 = 27
update table_4 set column8 = 214908 where column1 = 82
update table_9 set column16 = 48332 where column1 = 30
update table_2 set column9 = 67107 where column1 = 59
update table_5 set column14 = 412244 where column1 = 80
update table_3 set column2 = 727869 where column1 = 93
update table_8 set column8 = 350427 where column1 = 62
update table_9 set column2 = 351317 where column1 = 65
update table_8 set column12 = 666747 where column1 = 12
update table_2 set column16 = 204378 where column1 = 9
update table_7 set column17 = 702052 where column1 = 62
update table_5 set column8 = 532286 where column1 = 66
update table_0 set column12 = 357162 where column1 = 76
update table_6 set column4 = 998132 where column1 = 11
update table_3 set column19 = 769088 where column1 = 17
update table_2 set column13 = 43803 where column1 = 92
update table_8 set column5 = 132348 where column1 = 69
update table_3 set column7 = 935982 where column1 = 18
update table_2 set column16 = 584345 where column1 = 52
update table_2 set column11 = 754072 where column1 = 9
update table_6 set column13 = 191583 where column1 = 21
update table_1 set column14 = 792694 where column1 = 13
update table_5 set column18 = 662433 where column1 = 79
update table_4 set column4 = 621350 where column1 = 18
update table_4 set column9 = 915106 where column1 = 35
update table_2 set column11 = 593288 where column1 = 62
update table_1 set column8 = 501324 where column1 = 38
update table_8 set column20 = 538577 where column1 = 83
update table_0 set column11 = 182572 where column1 = 78
update table_0 set column8 = 251146 where column1 = 61
update table_3 set column2 = 107011 where column1 = 77
update table_8 set column19 = 392174 where column1 = 48
update table_2 set column10 = 536946 where column1 = 63
update table_0 set column13 = 938889 where column1 = 66
update table_3 set column15 = 598720 where column1 = 95
update table_6 set column7 = 800736 where column1 = 63
update table_7 set column9 = 69985 where column1 = 92
update table_8 set column11 = 78475 where column1 = 12
update table_1 set column12 = 934311 where column1 = 94
update table_2 set column5 = 172272 where column1 = 18
update table_5 set column12 = 219385 where column1 = 83
update table_3 set column12 = 123343 where column1 = 84
update table_8 set column14 = 860996 where column1 = 87
update table_5 set column5 = 997240 where column1 = 92
update table_5 set column10 = 354976 where column1 = 28
update table_3 set column6 = 500407 where column1 = 65
update table_9 set column17 = 770680 where column1 = 84
update table_0 set column7 = 17744 where column1 = 23
update table_2 set column8 = 155455 where column1 = 1
update table_5 set column14 = 985893 where column1 = 61
update table_6 set column19 = 96713 where column1 = 73
update table_8 set column8 = 580990 where column1 = 49
update table_8 set column16 = 443230 where column1 = 19
update table_8 set column3 = 740772 where column1 = 88
update table_2 set column15 = 784038 where column1 = 78
update table_5 set column7 = 916630 where column1 = 78
update table_9 set column9 = 448162 where column1 = 9
update table_4 set column19 = 746000 where column1 = 2
update table_5 set column2 = 711170 where column1 = 59
update table_0 set column15 = 114239 where column1 = 56
update table_1 set column16 = 609141 where column1 = 20
update table_1 set column5 = 747711 where column1 = 43
update table_2 set column12 = 491149 where column1 = 60
update table_0 set column11 = 287208 where column1 = 58
update table_5 set column14 = 308851 where column1 = 15
update table_9 set column8 = 60884 where column1 = 91
update table_3 set column8 = 140307 where column1 = 6
update table_1 set column11 = 835367 where column1 = 69
update table_0 set column13 = 655812 where column1 = 98
update table_4 set column4 = 590880 where column1 = 50
update table_9 set column16 = 265701 where column1 = 90
update table_3 set column18 = 630022 where column1 = 92
update table_8 set column20 = 587330 where column1 = 59
update table_4 set column17 = 9060 where column1 = 25
update table_9 set column15 = 268512 where column1 = 82
update table_8 set column7 = 23533 where column1 = 93
update table_9 set column11 = 681847 where column1 = 48
update table_7 set column9 = 474526 where column1 = 80
update table_2 set column10 = 848955 where column1 = 0
update table_0 set column18 = 704234 where column1 = 7
update table_7 set column13 = 54760 where column1 = 22
update table_0 set column3 = 956756 where column1 = 26
update table_7 set column16 = 628943 where column1 = 0
update table_6 set column11 = 675109 where column1 = 5
update table_9 set column3 = 511401 where column1 = 87
update table_1 set column10 = 82932 where column1 = 28
update table_9 set column2 = 446178 where column1 = 73
update table_7 set column17 = 948690 where column1 = 9
update table_4 set column5 = 369307 where column1 = 81
update table_1 set column3 = 424079 where column1 = 13
update table_3 set column6 = 312461 where column1 = 31
update table_8 set column16 = 459342 where column1 = 88
update table_9 set column20 = 28479 where column1 = 90
update table_4 set column15 = 995113 where column1 = 21
update table_8 set column5 = 44822 where column1 = 99
update table_7 set column7 = 521151 where column1 = 63
update table_7 set column8 = 857478 where column1 = 10
update table_5 set column3 = 799256 where column1 = 10
update table_3 set column15 = 113895 where column1 = 76
update table_4 set column13 = 227093 where column1 = 60
update table_9 set column12 = 256280 where column1 = 39
update table_1 set column12 = 413715 where column1 = 29
update table_9 set column13 = 815380 where column1 = 48
update table_2 set column12 = 528818 where column1 = 80
update table_3 set column9 = 75439 where column1 = 81
update table_1 set column2 = 723621 where column1 = 5
update table_3 set column20 = 959234 where column1 = 97
update table_6 set column14 = 484567 where column1 = 56
update table_3 set column13 = 436983 where column1 = 90
update table_8 set column20 = 868533 where column1 = 96
update table_5 set column20 = 399942 where column1 = 49
update table_8 set column7 = 752393 where column1 = 29
update table_8 set column20 = 809644 where column1 = 16
update table_7 set column14 = 6410 where column1 = 18
update table_0 set column13 = 66521 where column1 = 9
update table_3 set column6 = 347388 where column1 = 74
update table_4 set column8 = 928438 where column1 = 3
update table_1 set column9 = 127747 where column1 = 67
update table_4 set column5 = 814742 where column1 = 79
update table_4 set column13 = 376612 where column1 = 92
update table_0 set column9 = 63354 where column1 = 16
update table_2 set column20 = 401718 where column1 = 35
update table_8 set column17 = 935052 where column1 = 5
update table_7 set column5 = 609768 where column1 = 15
update table_1 set column4 = 721208 where column1 = 16
update table_4 set column18 = 996315 where column1 = 44
update table_8 set column6 = 376695 where column1 = 40
update table_9 set column11 = 586328 where column1 = 65
update table_9 set column15 = 63416 where column1 = 84
update table_1 set column20 = 580948 where column1 = 57
update table_1 set column16 = 281091 where column1 = 27
update table_2 set column4 = 902127 where column1 = 24
update table_6 set column13 = 455377 where column1 = 81
update table_3 set column11 = 82191 where column1 = 41
update table_6 set column5 = 316156 where column1 = 83
update table_5 set column4 = 283935 where column1 = 91
update table_4 set column11 = 15145 where column1 = 71
update table_3 set column13 = 301068 where column1 = 28
update table_0 set column20 = 7360 where column1 = 58
update table_0 set column5 = 224719 where column1 = 44
update table_1 set column2 = 471948 where column1 = 2
update table_9 set column13 = 527962 where column1 = 38
update table_8 set column7 = 564564 where column1 = 51
update table_0 set column11 = 540566 where column1 = 47
update table_1 set column15 = 663408 where column1 = 47
update table_0 set column10 = 483853 where column1 = 35
update table_9 set column17 = 62851 where column1 = 24
update table_1 set column20 = 246928 where column1 = 94
update table_1 set column14 = 548711 where column1 = 48
update table_2 set column15 = 518940 where column1 = 58
update table_2 set column4 = 542666 where column1 = 79
update table_8 set column18 = 794979 where column1 = 34
update table_3 set column11 = 694545 where column1 = 99
update table_6 set column7 = 295157 where column1 = 59
update table_8 set column16 = 405385 where column1 = 38
update table_3 set column15 = 623952 where column1 = 94
update table_7 set column11 = 223805 where column1 = 96
update table_7 set column11 = 30877 where column1 = 37
update table_4 set column3 = 393521 where column1 = 31
update table_4 set column5 = 791685 where column1 = 28
update table_1 set column18 = 255706 where column1 = 8
update table_3 set column5 = 483116 where column1 = 81
update table_0 set column17 = 102518 where column1 = 98
update table_4 set column19 = 855045 where column1 = 95
update table_3 set column6 = 422270 where column1 = 23
update table_7 set column4 = 435096 where column1 = 44
update table_2 set column16 = 347271 where column1 = 19
update table_8 set column7 = 578332 where column1 = 17
update table_0 set column2 = 329276 where column1 = 68
update table_8 set column15 = 817671 where column1 = 63
update table_2 set column2 = 982141 where column1 = 23
update table_1 set column18 = 83637 where column1 = 28
update table_5 set column16 = 260944 where column1 = 62
update table_0 set column8 = 255048 where column1 = 22
update table_5 set column7 = 760630 where column1 = 80
update table_1 set column7 = 623472 where column1 = 58
update table_0 set column14 = 122281 where column1 = 35
update table_6 set column11 = 89379 where column1 = 4
update table_7 set column9 = 925623 where column1 = 88
update table_0 set column6 = 156021 where column1 = 77
update table_1 set column2 = 8356 where column1 = 85
update table_6 set column15 = 59422 where column1 = 76
update table_3 set column2 = 628192 where column1 = 49
update table_1 set column15 = 471263 where column1 = 89
update table_9 set column6 = 936039 where column1 = 63
update table_5 set column10 = 398962 where column1 = 2
update table_5 set column4 = 671618 where column1 = 68
update table_0 set column14 = 841981 where column1 = 47
update table_6 set column6 = 122989 where column1 = 4
update table_8 set column3 = 751399 where column1 = 26
update table_8 set column5 = 641126 where column1 = 71
update table_7 set column19 = 858097 where column1 = 90
update table_1 set column12 = 902445 where column1 = 6
update table_6 set column6 = 794368 where column1 = 59
update table_8 set column12 = 634313 where column1 = 11
update table_7 set column16 = 786612 where column1 = 41
update table_4 set column15 = 78682 where column1 = 59
update table_0 set column11 = 265419 where column1 = 0
update table_2 set column10 = 227274 where column1 = 20
update table_1 set column6 = 673769 where column1 = 48
update table_1 set column6 = 950314 where column1 = 85
update table_9 set column3 = 614030 where column1 = 29
update table_5 set column10 = 506039 where column1 = 72
update table_7 set column6 = 495391 where column1 = 83
update table_6 set column12 = 219153 where column1 = 5
update table_2 set column2 = 62378 where column1 = 51
update table_6 set column11 = 630292 where column1 = 43
update table_2 set column5 = 402608 where column1 = 94
update table_9 set column20 = 330553 where column1 = 14
update table_5 set column16 = 654266 where column1 = 6
update table_4 set column4 = 844888 where column1 = 56
update table_3 set column11 = 45759 where column1 = 10
update table_8 set column16 = 383416 where column1 = 5
update table_3 set column4 = 414638 where column1 = 5
update table_8 set column5 = 106480 where column1 = 76
update table_3 set column11 = 354643 where column1 = 94
update table_4 set column3 = 608470 where column1 = 27
update table_1 set column10 = 209344 where column1 = 55
update table_7 set column3 = 848743 where column1 = 98
update table_0 set column20 = 419538 where column1 = 79
update table_8 set column4 = 882028 where column1 = 23
update table_9 set column18 = 20333 where column1 = 97
update table_1 set column8 = 702251 where column1 = 13
update table_3 set column2 = 64080 where column1 = 42
update table_4 set column9 = 840796 where column1 = 5
update table_2 set column20 = 978263 where column1 = 28
update table_1 set column5 = 1309 where column1 = 50
update table_8 set column8 = 359799 where column1 = 25
update table_0 set column20 = 593161 where column1 = 20
update table_9 set column16 = 16034 where column1 = 4
update table_0 set column19 = 141159 where column1 = 53
update table_9 set column6 = 506472 where column1 = 54
update table_8 set column15 = 593792 where column1 = 3
update table_8 set column3 = 77046 where column1 = 42
update table_6 set column17 = 341493 where column1 = 72
update table_7 set column3 = 815693 where column1 = 52
update table_9 set column17 = 98779 where column1 = 23
update table_4 set column4 = 39976 where column1 = 25
update table_5 set column7 = 977578 where column1 = 25
update table_9 set column14 = 607751 where column1 = 97
update table_4 set column10 = 637142 where column1 = 62
update table_4 set column4 = 131125 where column1 = 20
update table_7 set column18 = 888846 where column1 = 7
update table_6 set column8 = 379216 where column1 = 75
update table_4 set column4 = 549372 where column1 = 47
update table_4 set column7 = 115532 where column1 = 87
update table_9 set column18 = 62099 where column1 = 14
update table_7 set column20 = 434180 where column1 = 25
update table_3 set column5 = 45730 where column1 = 0
update table_4 set column17 = 122458 where column1 = 42
update table_3 set column10 = 424935 where column1 = 67
update table_9 set column15 = 285635 where column1 = 92
update table_9 set column3 = 931665 where column1 = 32
update table_2 set column18 = 668960 where column1 = 36
update table_4 set column2 = 711268 where column1 = 36
update table_9 set column16 = 855120 where column1 = 25
update table_3 set column3 = 99990 where column1 = 89
update table_3 set column18 = 102852 where column1 = 96
update table_7 set column20 = 811965 where column1 = 89
update table_0 set column19 = 622167 where column1 = 2
update table_7 set column19 = 743906 where column1 = 11
update table_0 set column20 = 672448 where column1 = 35
update table_8 set column8 = 142833 where column1 = 17
update table_5 set column12 = 591344 where column1 = 84
update table_1 set column4 = 873884 where column1 = 18
update table_4 set column10 = 405398 where column1 = 56
update table_0 set column4 = 174068 where column1 = 10
update table_6 set column7 = 782082 where column1 = 16
update table_4 set column10 = 343935 where column1 = 89
update table_1 set column4 = 290390 where column1 = 23
update table_7 set column19 = 529881 where column1 = 60
update table_2 set column7 = 282850 where column1 = 98
update table_8 set column3 = 190052 where column1 = 32
update table_0 set column12 = 131937 where column1 = 18
update table_5 set column5 = 77960 where column1 = 66
update table_3 set column16 = 175998 where column1 = 30
update table_0 set column10 = 569461 where column1 = 30
update table_8 set column9 = 84194 where column1 = 17
update table_1 set column13 = 513993 where column1 = 11
update table_4 set column17 = 787695 where column1 = 79
update table_4 set column10 = 100337 where column1 = 32
update table_6 set column11 = 687472 where column1 = 67
update table_1 set column11 = 480640 where column1 = 59
update table_2 set column11 = 815393 where column1 = 78
update table_1 set column7 = 327890 where column1 = 34
update table_9 set column8 = 371289 where column1 = 24
update table_7 set column11 = 112802 where column1 = 25
update table_2 set column20 = 126995 where column1 = 51
update table_2 set column9 = 654385 where column1 = 71
update table_2 set column15 = 818878 where column1 = 6
update table_7 set column19 = 651147 where column1 = 52
update table_6 set column19 = 18205 where column1 = 99
update table_2 set column16 = 262048 where column1 = 17
update table_3 set column2 = 297779 where column1 = 77
update table_3 set column20 = 728161 where column1 = 3
update table_5 set column6 = 688051 where column1 = 80
update table_4 set column9 = 212381 where column1 = 80
update table_4 set column4 = 592918 where column1 = 80
update table_8 set column11 = 981335 where column1 = 94
update table_2 set column18 = 593269 where column1 = 29
update table_4 set column6 = 591129 where column1 = 7
update table_0 set column11 = 818110 where column1 = 0
update table_2 set column8 = 729840 where column1 = 54
update table_7 set column19 = 442127 where column1 = 30
update table_7 set column11 = 566961 where column1 = 11
update table_5 set column2 = 505845 where column1 = 50
update table_0 set column9 = 202625 where column1 = 40
update table_1 set column15 = 555504 where column1 = 19
update table_3 set column12 = 972692 where column1 = 22
update table_7 set column6 = 219429 where column1 = 62
update table_4 set column15 = 555968 where column1 = 81
update table_1 set column2 = 46176 where column1 = 75
update table_6 set column13 = 604917 where column1 = 4
update table_5 set column4 = 777920 where column1 = 13
update table_0 set column4 = 180671 where column1 = 85
update table_9 set column12 = 461782 where column1 = 96
update table_6 set column15 = 688859 where column1 = 42
update table_6 set column12 = 475400 where column1 = 69
update table_7 set column17 = 828287 where column1 = 37
update table_2 set column3 = 474912 where column1 = 35
update table_0 set column12 = 834573 where column1 = 41
update table_3 set column20 = 294021 where column1 = 28
update table_3 set column19 = 686151 where column1 = 59
update table_5 set column7 = 513226 where column1 = 80
update table_1 set column18 = 516511 where column1 = 41
update table_2 set column9 = 389192 where column1 = 42
update table_7 set column5 = 610930 where column1 = 81
update table_7 set column6 = 854594 where column1 = 4
update table_7 set column2 = 50352 where column1 = 52
update table_7 set column8 = 255683 where column1 = 9
update table_3 set column18 = 891980 where column1 = 88
update table_1 set column9 = 720945 where column1 = 92
update table_9 set column3 = 415935 where column1 = 84
update table_1 set column3 = 789986 where column1 = 75
update table_6 set column7 = 530152 where column1 = 30
update table_0 set column14 = 19874 where column1 = 54
update table_1 set column5 = 738999 where column1 = 6
update table_4 set column19 = 908204 where column1 = 43
update table_7 set column13 = 193374 where column1 = 84
update table_1 set column9 = 605850 where column1 = 28
update table_2 set column4 = 361513 where column1 = 11
update table_7 set column8 = 180584 where column1 = 16
update table_2 set column10 = 139154 where column1 = 85
update table_3 set column2 = 488229 where column1 = 26
update table_1 set column5 = 400374 where column1 = 20
update table_0 set column12 = 189428 where column1 = 98
update table_9 set column3 = 523196 where column1 = 79
update table_3 set column4 = 754375 where column1 = 66
update table_3 set column3 = 126776 where column1 = 28
update table_2 set column7 = 61863 where column1 = 78
update table_4 set column6 = 716394 where column1 = 25
update table_4 set column6 = 315296 where column1 = 28
update table_1 set column10 = 995826 where column1 = 99
update table_5 set column6 = 680117 where column1 = 17
update table_3 set column16 = 912873 where column1 = 78
update table_9 set column4 = 761653 where column1 = 69
update table_4 set column3 = 545454 where column1 = 29
update table_2 set column12 = 905596 where column1 = 94
update table_0 set column16 = 127096 where column1 = 28
update table_6 set column19 = 697112 where column1 = 16
update table_1 set column11 = 550046 where column1 = 47
update table_7 set column7 = 398318 where column1 = 14
update table_0 set column19 = 283867 where column1 = 10
update table_8 set column2 = 959999 where column1 = 72
update table_6 set column6 = 937117 where column1 = 58
update table_5 set column13 = 657250 where column1 = 29
update table_0 set column18 = 757622 where column1 = 64
update table_3 set column9 = 461930 where column1 = 67
update table_2 set column15 = 890707 where column1 = 37
update table_7 set column7 = 206819 where column1 = 23
update table_3 set column14 = 899874 where column1 = 72
update table_2 set column6 = 559724 where column1 = 44
update table_4 set column3 = 918072 where column1 = 94
update table_0 set column18 = 21406 where column1 = 24
update table_0 set column18 = 227981 where column1 = 83
update table_2 set column2 = 164267 where column1 = 93
update table_9 set column11 = 710716 where column1 = 92
update table_9 set column20 = 295180 where column1 = 13
update table_3 set column4 = 565619 where column1 = 81
update table_3 set column4 = 549908 where column1 = 67
update table_0 set column4 = 680907 where column1 = 98
update table_2 set column4 = 736222 where column1 = 48
update table_5 set column2 = 757156 where column1 = 9
update table_7 set column15 = 460932 where column1 = 75
update table_6 set column8 = 282248 where column1 = 60
update table_6 set column6 = 590637 where column1 = 11
update table_8 set column9 = 931743 where column1 = 83
update table_8 set column9 = 671157 where column1 = 42
update table_0 set column7 = 951339 where column1 = 8
update table_8 set column4 = 348058 where column1 = 44
update table_2 set column8 = 236307 where column1 = 15
update table_1 set column20 = 26325 where column1 = 58
update table_3 set column19 = 871087 where column1 = 4
update table_8 set column3 = 455849 where column1 = 94
update table_9 set column15 = 379291 where column1 = 85
update table_1 set column15 = 177399 where column1 = 40
update table_8 set column7 = 27210 where column1 = 29
update table_6 set column6 = 693422 where column1 = 95
update table_6 set column5 = 408150 where column1 = 58
update table_2 set column7 = 341132 where column1 = 50
update table_4 set column9 = 938884 where column1 = 40
update table_4 set column4 = 993686 where column1 = 7
update table_5 set column13 = 742854 where column1 = 3
update table_0 set column7 = 558240 where column1 = 20
update table_5 set column9 = 483068 where column1 = 38
update table_6 set column10 = 793595 where column1 = 46
update table_8 set column14 = 968277 where column1 = 67
update table_7 set column13 = 532801 where column1 = 28
update table_3 set column3 = 131339 where column1 = 62
update table_0 set column19 = 436743 where column1 = 97
update table_4 set column12 = 363347 where column1 = 21
update table_4 set column19 = 189045 where column1 = 49
update table_2 set column19 = 492248 where column1 = 60
update table_5 set column14 = 577069 where column1 = 15
update table_7 set column8 = 933584 where column1 = 62
update table_5 set column15 = 440316 where column1 = 8
update table_3 set column4 = 341832 where column1 = 71
update table_8 set column5 = 446277 where column1 = 15
update table_7 set column8 = 813640 where column1 = 84
update table_3 set column6 = 402658 where column1 = 25
update table_1 set column19 = 408602 where column1 = 55
update table_6 set column13 = 60079 where column1 = 62
update table_3 set column19 = 80848 where column1 = 33
update table_0 set column9 = 515757 where column1 = 41
update table_3 set column10 = 296626 where column1 = 75
update table_9 set column18 = 740690 where column1 = 69
update table_1 set column15 = 979369 where column1 = 49
update table_3 set column17 = 297823 where column1 = 81
update table_7 set column12 = 411768 where column1 = 74
update table_2 set column4 = 190700 where column1 = 11
update table_1 set column20 = 60611 where column1 = 72
update table_7 set column5 = 810953 where column1 = 73
update table_0 set column16 = 835323 where column1 = 36
update table_8 set column14 = 445362 where column1 = 87
update table_5 set column14 = 528714 where column1 = 57
update table_0 set column10 = 234289 where column1 = 89
update table_6 set column20 = 60448 where column1 = 47
update table_9 set column19 = 148544 where column1 = 76
update table_2 set column16 = 744608 where column1 = 65
update table_4 set column17 = 563265 where column1 = 36
update table_4 set column8 = 659424 where column1 = 21
update table_9 set column18 = 134543 where column1 = 82
update table_4 set column15 = 224792 where column1 = 9
update table_5 set column14 = 142431 where column1 = 47
update table_2 set column5 = 990577 where column1 = 1
update table_7 set column17 = 953670 where column1 = 28
update table_7 set column7 = 870952 where column1 = 48
update table_1 set column8 = 15905 where column1 = 25
update table_6 set column8 = 182528 where column1 = 61
update table_1 set column11 = 669972 where column1 = 55
update table_0 set column9 = 211634 where column1 = 49
update table_4 set column6 = 118617 where column1 = 67
update table_8 set column6 = 245886 where column1 = 86
update table_0 set column9 = 604500 where column1 = 77
update table_7 set column14 = 466967 where column1 = 97
update table_3 set column2 = 862578 where column1 = 94
update table_7 set column15 = 322390 where column1 = 35
update table_7 set column3 = 364816 where column1 = 72
update table_4 set column9 = 167810 where column1 = 6
update table_5 set column13 = 494837 where column1 = 19
update table_4 set column15 = 307807 where column1 = 83
update table_2 set column6 = 41174 where column1 = 72
update table_9 set column17 = 492710 where column1 = 20
update table_1 set column18 = 831693 where column1 = 88
update table_5 set column12 = 449445 where column1 = 80
update table_8 set column12 = 948098 where column1 = 17
update table_9 set column12 = 862354 where column1 = 73
update table_1 set column10 = 717043 where column1 = 50
update table_4 set column13 = 929798 where column1 = 68
update table_3 set column19 = 906597 where column1 = 89
update table_6 set column2 = 854576 where column1 = 35
update table_1 set column10 = 574496 where column1 = 83
update table_5 set column4 = 155888 where column1 = 90
update table_9 set column10 = 367322 where column1 = 73
update table_6 set column6 = 967310 where column1 = 12
update table_4 set column6 = 592313 where column1 = 6
update table_3 set column4 = 803365 where column1 = 36
update table_3 set column18 = 741346 where column1 = 88
update table_2 set column13 = 61950 where column1 = 95
update table_5 set column7 = 937552 where column1 = 69
update table_7 set column9 = 178176 where column1 = 70
update table_6 set column6 = 491762 where column1 = 98
update table_8 set column20 = 143988 where column1 = 61
update table_3 set column4 = 992975 where column1 = 40
update table_1 set column18 = 612020 where column1 = 79
update table_5 set column19 = 60178 where column1 = 45
update table_6 set column20 = 293607 where column1 = 93
update table_6 set column8 = 285957 where column1 = 82
update table_3 set column17 = 755866 where column1 = 5
update table_6 set column19 = 364335 where column1 = 81
update table_4 set column20 = 297406 where column1 = 31
update table_8 set column8 = 941723 where column1 = 22
update table_7 set column15 = 804786 where column1 = 44
update table_2 set column17 = 568611 where column1 = 75
update table_6 set column9 = 422587 where column1 = 9
update table_8 set column15 = 336183 where column1 = 20
update table_1 set column11 = 165051 where column1 = 50
update table_7 set column2 = 409349 where column1 = 31
update table_0 set column5 = 645773 where column1 = 9
update table_5 set column10 = 380595 where column1 = 98
update table_8 set column7 = 505760 where column1 = 79
update table_6 set column8 = 172735 where column1 = 50
update table_1 set column17 = 897250 where column1 = 0
update table_3 set column11 = 821977 where column1 = 13
update table_3 set column16 = 857628 where column1 = 77
update table_4 set column13 = 689190 where column1 = 47
update table_7 set column11 = 341923 where column1 = 41
update table_6 set column14 = 550021 where column1 = 96
update table_7 set column6 = 548494 where column1 = 39
update table_6 set column13 = 384334 where column1 = 17
update table_7 set column7 = 46177 where column1 = 70
update table_6 set column3 = 179079 where column1 = 48
update table_8 set column13 = 33005 where column1 = 18
update table_4 set column16 = 563656 where column1 = 12
update table_6 set column7 = 923126 where column1 = 96
update table_2 set column5 = 570339 where column1 = 33
update table_7 set column13 = 396309 where column1 = 5
update table_9 set column20 = 204611 where column1 = 48
update table_2 set column16 = 121452 where column1 = 38
update table_1 set column9 = 501021 where column1 = 53
update table_4 set column12 = 46387 where column1 = 54
update table_8 set column16 = 899948 where column1 = 78
update table_5 set column16 = 295590 where column1 = 36
update table_0 set column15 = 988614 where column1 = 75
update table_4 set column20 = 231771 where column1 = 24
update table_9 set column8 = 780611 where column1 = 16
update table_6 set column8 = 90440 where column1 = 22
update table_3 set column10 = 519272 where column1 = 42
update table_9 set column3 = 991908 where column1 = 11
update table_2 set column3 = 203051 where column1 = 6
update table_6 set column8 = 46571 where column1 = 63
update table_0 set column2 = 361322 where column1 = 84
update table_3 set column8 = 750531 where column1 = 34
update table_8 set column20 = 248930 where column1 = 33
update table_6 set column20 = 751459 where column1 = 24
update table_2 set column15 = 674647 where column1 = 94
update table_7 set column12 = 643802 where column1 = 87
update table_7 set column13 = 42263 where column1 = 63
update table_5 set column12 = 83407 where column1 = 78
update table_3 set column19 = 113720 where column1 = 93
update table_7 set column20 = 260743 where column1 = 54
update table_9 set column5 = 498788 where column1 = 14
update table_6 set column11 = 64361 where column1 = 91
update table_3 set column13 = 315101 where column1 = 37
update table_2 set column14 = 631190 where column1 = 8
update table_2 set column8 = 169765 where column1 = 48
update table_5 set column9 = 707538 where column1 = 9
update table_9 set column9 = 10951 where column1 = 83
update table_3 set column8 = 881085 where column1 = 42
update table_2 set column13 = 444198 where column1 = 67
update table_1 set column16 = 633080 where column1 = 2
update table_0 set column2 = 729156 where column1 = 84
update table_5 set column18 = 240515 where column1 = 51
update table_0 set column14 = 861164 where column1 = 44
update table_0 set column16 = 70236 where column1 = 71
update table_0 set column7 = 986656 where column1 = 16
update table_6 set column2 = 245944 where column1 = 33
update table_4 set column16 = 705510 where column1 = 32
update table_4 set column16 = 865037 where column1 = 69
update table_4 set column11 = 977547 where column1 = 47
update table_2 set column5 = 943060 where column1 = 21
update table_2 set column13 = 720695 where column1 = 12
update table_9 set column2 = 768851 where column1 = 47
update table_7 set column17 = 431837 where column1 = 98
update table_6 set column4 = 674912 where column1 = 56
update table_8 set column13 = 241697 where column1 = 52
update table_1 set column13 = 518360 where column1 = 9
update table_8 set column7 = 740495 where column1 = 59
update table_5 set column2 = 131075 where column1 = 59
update table_3 set column15 = 143523 where column1 = 59
update table_7 set column7 = 722111 where column1 = 60
update table_3 set column11 = 693305 where column1 = 30
update table_8 set column3 = 550995 where column1 = 39
update table_3 set column8 = 591569 where column1 = 56
update table_9 set column15 = 890883 where column1 = 5
update table_8 set column7 = 877085 where column1 = 36
update table_7 set column20 = 813912 where column1 = 0
update table_3 set column11 = 606397 where column1 = 23
update table_2 set column15 = 508591 where column1 = 53
update table_6 set column4 = 596631 where column1 = 83
update table_8 set column17 = 976786 where column1 = 82
update table_6 set column5 = 817608 where column1 = 82
update table_2 set column15 = 256172 where column1 = 47
update table_0 set column16 = 133220 where column1 = 8
update table_3 set column14 = 187672 where column1 = 16
update table_3 set column8 = 31671 where column1 = 0
update table_2 set column10 = 955729 where column1 = 62
update table_1 set column20 = 498041 where column1 = 78
update table_4 set column6 = 94794 where column1 = 1
update table_8 set column16 = 275131 where column1 = 97
update table_9 set column10 = 319936 where column1 = 85
update table_2 set column5 = 539049 where column1 = 6
update table_5 set column3 = 426276 where column1 = 11
update table_9 set column14 = 745324 where column1 = 73
update table_4 set column14 = 529148 where column1 = 71
update table_0 set column18 = 201206 where column1 = 10
update table_4 set column14 = 160403 where column1 = 22
update table_1 set column14 = 951724 where column1 = 42
update table_6 set column4 = 347822 where column1 = 56
update table_0 set column16 = 695959 where column1 = 44
update table_6 set column20 = 464501 where column1 = 21
update table_2 set column11 = 537446 where column1 = 50
update table_7 set column14 = 14042 where column1 = 6
update table_4 set column13 = 368606 where column1 = 4
update table_8 set column16 = 987472 where column1 = 51
update table_6 set column6 = 28651 where column1 = 89
update table_4 set column20 = 637161 where column1 = 85
update table_8 set column11 = 627251 where column1 = 33
update table_9 set column20 = 575048 where column1 = 54
update table_7 set column16 = 782338 where column1 = 16
update table_9 set column15 = 522221 where column1 = 76
update table_2 set column15 = 968377 where column1 = 53
update table_7 set column9 = 982698 where column1 = 66
update table_5 set column8 = 923792 where column1 = 39
update table_8 set column12 = 21946 where column1 = 50
update table_9 set column13 = 242244 where column1 = 6
update table_8 set column4 = 321822 where column1 = 44
update table_6 set column7 = 935832 where column1 = 18
update table_9 set column12 = 451832 where column1 = 56
update table_3 set column7 = 905779 where column1 = 11
update table_4 set column7 = 343145 where column1 = 87
update table_2 set column13 = 281766 where column1 = 81
update table_8 set column17 = 185613 where column1 = 95
update table_4 set column9 = 449626 where column1 = 65
update table_7 set column8 = 573210 where column1 = 63
update table_6 set column3 = 362868 where column1 = 24
update table_3 set column15 = 411638 where column1 = 66
update table_5 set column18 = 591406 where column1 = 96
update table_3 set column18 = 363566 where column1 = 22
update table_4 set column15 = 264131 where column1 = 82
update table_1 set column15 = 935488 where column1 = 23
update table_6 set column18 = 923656 where column1 = 39
update table_3 set column3 = 388141 where column1 = 40
update table_5 set column5 = 189663 where column1 = 52
update table_7 set column2 = 777970 where column1 = 87
update table_5 set column20 = 754688 where column1 = 93
update table_4 set column2 = 681389 where column1 = 74
update table_5 set column2 = 517449 where column1 = 93
update table_2 set column6 = 28254 where column1 = 61
update table_5 set column19 = 373127 where column1 = 8
update table_8 set column8 = 240924 where column1 = 1
update table_0 set column18 = 354264 where column1 = 81
update table_8 set column5 = 778813 where column1 = 1
update table_9 set column17 = 130748 where column1 = 60
update table_6 set column20 = 419857 where column1 = 76
update table_4 set column17 = 515527 where column1 = 10
update table_2 set column13 = 202453 where column1 = 38
update table_5 set column5 = 608820 where column1 = 51
update table_6 set column2 = 816080 where column1 = 61
update table_5 set column16 = 251897 where column1 = 37
update table_1 set column19 = 326627 where column1 = 49
update table_7 set column17 = 951153 where column1 = 52
update table_2 set column12 = 218105 where column1 = 91
update table_6 set column4 = 549170 where column1 = 31
update table_5 set column7 = 918801 where column1 = 12
update table_7 set column14 = 164726 where column1 = 51
update table_8 set column16 = 747180 where column1 = 27
update table_3 set column17 = 636909 where column1 = 6
update table_0 set column20 = 141597 where column1 = 20
update table_0 set column13 = 607621 where column1 = 60
update table_4 set column8 = 591237 where column1 = 54
update table_0 set column6 = 687563 where column1 = 16
update table_6 set column18 = 731804 where column1 = 28
update table_3 set column5 = 50424 where column1 = 62
update table_1 set column7 = 8852 where column1 = 21
update table_7 set column10 = 325642 where column1 = 22
update table_1 set column20 = 420511 where column1 = 57
update table_9 set column15 = 671689 where column1 = 6
update table_3 set column6 = 924617 where column1 = 32
update table_0 set column8 = 72948 where column1 = 56
update table_8 set column11 = 970260 where column1 = 82
update table_3 set column16 = 331291 where column1 = 2
update table_0 set column2 = 576264 where column1 = 94
update table_9 set column4 = 821735 where column1 = 51
update table_1 set column8 = 493187 where column1 = 75
update table_9 set column9 = 811644 where column1 = 75
update table_6 set column13 = 41435 where column1 = 7
update table_7 set column15 = 14193 where column1 = 26
update table_2 set column20 = 89466 where column1 = 44
update table_2 set column13 = 716841 where column1 = 28
update table_7 set column14 = 369143 where column1 = 69
update table_5 set column11 = 714359 where column1 = 25
update table_9 set column16 = 526219 where column1 = 62
update table_7 set column15 = 97586 where column1 = 87
update table_5 set column3 = 146534 where column1 = 50
update table_7 set column7 = 690997 where column1 = 63
update table_1 set column14 = 500197 where column1 = 66
update table_7 set column14 = 757904 where column1 = 8
update table_6 set column6 = 961805 where column1 = 27
update table_8 set column10 = 678791 where column1 = 91
update table_1 set column7 = 142503 where column1 = 11
update table_2 set column9 = 64934 where column1 = 14
update table_7 set column20 = 194568 where column1 = 36
update table_3 set column13 = 879140 where column1 = 5
update table_8 set column5 = 956562 where column1 = 93
update table_0 set column18 = 847629 where column1 = 74
update table_6 set column13 = 621674 where column1 = 92
update table_0 set column17 = 177523 where column1 = 31
update table_5 set column7 = 656393 where column1 = 69
update table_7 set column12 = 544429 where column1 = 55
update table_4 set column16 = 161954 where column1 = 19
update table_5 set column6 = 216360 where column1 = 19
update table_9 set column3 = 471439 where column1 = 50
update table_5 set column6 = 404397 where column1 = 87
update table_7 set column2 = 234067 where column1 = 34
update table_8 set column16 = 689327 where column1 = 9
update table_3 set column9 = 739378 where column1 = 84
update table_5 set column7 = 66048 where column1 = 63
update table_1 set column4 = 534345 where column1 = 30
update table_6 set column13 = 459143 where column1 = 55
update table_9 set column9 = 550158 where column1 = 10
update table_2 set column13 = 922252 where column1 = 39
update table_5 set column19 = 894117 where column1 = 61
update table_8 set column8 = 947889 where column1 = 50
update table_7 set column5 = 96098 where column1 = 48
update table_3 set column3 = 419432 where column1 = 30
update table_1 set column19 = 376321 where column1 = 58
update table_5 set column12 = 946473 where column1 = 29
update table_4 set column11 = 198855 where column1 = 50
update table_4 set column4 = 788370 where column1 = 93
update table_1 set column14 = 846573 where column1 = 28
update table_9 set column19 = 24556 where column1 = 71
update table_7 set column14 = 392382 where column1 = 97
update table_0 set column3 = 91578 where column1 = 47
update table_1 set column2 = 761296 where column1 = 17
update table_9 set column8 = 403122 where column1 = 66
update table_4 set column7 = 487397 where column1 = 7
update table_2 set column9 = 249933 where column1 = 6
update table_4 set column13 = 832897 where column1 = 88
update table_1 set column16 = 622178 where column1 = 15
update table_2 set column5 = 869854 where column1 = 96
update table_2 set column18 = 420985 where column1 = 5
update table_5 set column3 = 471729 where column1 = 10
update table_5 set column14 = 362426 where column1 = 14
update table_0 set column14 = 186799 where column1 = 72
update table_4 set column19 = 90345 where column1 = 29
update table_2 set column14 = 41944 where column1 = 96
update table_1 set column9 = 824279 where column1 = 30
update table_8 set column7 = 6574 where column1 = 11
update table_6 set column20 = 18619 where column1 = 70
update table_6 set column6 = 625290 where column1 = 98
update table_4 set column11 = 572733 where column1 = 3
update table_5 set column8 = 394130 where column1 = 49
update table_5 set column12 = 382240 where column1 = 27
update table_3 set column15 = 465336 where column1 = 32
update table_1 set column6 = 303360 where column1 = 3
update table_6 set column15 = 254418 where column1 = 92
update table_7 set column15 = 871501 where column1 = 75
update table_3 set column9 = 811530 where column1 = 23
update table_3 set column5 = 322934 where column1 = 50
update table_9 set column16 = 71924 where column1 = 38
update table_9 set column12 = 852217 where column1 = 30
update table_9 set column20 = 194266 where column1 = 92
update table_0 set column20 = 563758 where column1 = 55
update table_1 set column18 = 760998 where column1 = 13
update table_7 set column2 = 263463 where column1 = 80
update table_4 set column4 = 126019 where column1 = 80
update table_4 set column7 = 133472 where column1 = 42
update table_8 set column18 = 204049 where column1 = 43
update table_5 set column9 = 442495 where column1 = 2
update table_0 set column5 = 634982 where column1 = 87
update table_6 set column15 = 103373 where column1 = 72
update table_3 set column13 = 346420 where column1 = 34
update table_2 set column3 = 2587 where column1 = 93
update table_6 set column16 = 210516 where column1 = 35
update table_4 set column8 = 393348 where column1 = 22
update table_2 set column7 = 59999 where column1 = 28
update table_5 set column15 = 204401 where column1 = 46
update table_0 set column13 = 844391 where column1 = 56
update table_7 set column4 = 346219 where column1 = 56
update table_0 set column3 = 44085 where column1 = 59
update table_5 set column4 = 481439 where column1 = 76
update table_3 set column19 = 676959 where column1 = 94
update table_1 set column6 = 173531 where column1 = 68
update table_8 set column5 = 329934 where column1 = 88
update table_4 set column17 = 974602 where column1 = 5
update table_8 set column13 = 200108 where column1 = 2
update table_8 set column4 = 994271 where column1 = 66
update table_8 set column8 = 94072 where column1 = 19
update table_5 set column16 = 428907 where column1 = 16
update table_5 set column13 = 363159 where column1 = 44
update table_0 set column16 = 98495 where column1 = 82
update table_4 set column15 = 6031 where column1 = 13
update table_0 set column17 = 324854 where column1 = 99
update table_0 set column3 = 176177 where column1 = 97
update table_1 set column20 = 797001 where column1 = 78
update table_4 set column15 = 669771 where column1 = 94
update table_9 set column13 = 942074 where column1 = 37
update table_0 set column2 = 73453 where column1 = 17
update table_1 set column7 = 693076 where column1 = 69
update table_5 set column18 = 828141 where column1 = 56
update table_2 set column14 = 944971 where column1 = 94
update table_5 set column6 = 651786 where column1 = 43
update table_5 set column17 = 751460 where column1 = 71
update table_4 set column9 = 176025 where column1 = 93
update table_9 set column18 = 280178 where column1 = 28
update table_6 set column15 = 354761 where column1 = 26
update table_4 set column4 = 238744 where column1 = 32
update table_3 set column9 = 747723 where column1 = 87
update table_4 set column5 = 718898 where column1 = 42
update table_4 set column4 = 773287 where column1 = 50
update table_2 set column18 = 418413 where column1 = 85
update table_4 set column12 = 280148 where column1 = 45
update table_6 set column2 = 309302 where column1 = 19
update table_1 set column9 = 856575 where column1 = 29
update table_0 set column8 = 274994 where column1 = 1
update table_0 set column4 = 364692 where column1 = 2
update table_1 set column2 = 520808 where column1 = 67
update table_2 set column18 = 222531 where column1 = 99
update table_9 set column6 = 600070 where column1 = 21
update table_6 set column3 = 969540 where column1 = 31
update table_1 set column2 = 839878 where column1 = 15
update table_2 set column14 = 589765 where column1 = 59
update table_4 set column2 = 552966 where column1 = 32
update table_6 set column15 = 583064 where column1 = 17
update table_7 set column15 = 235196 where column1 = 93
update table_3 set column11 = 63827 where column1 = 18
update table_2 set column13 = 8437 where column1 = 13
update table_6 set column3 = 778853 where column1 = 6
update table_4 set column8 = 282000 where column1 = 69
update table_7 set column5 = 419189 where column1 = 19
update table_1 set column14 = 338460 where column1 = 79
update table_7 set column3 = 34899 where column1 = 28
update table_6 set column10 = 544676 where column1 = 70
update table_1 set column14 = 708197 where column1 = 53
update table_3 set column11 = 731788 where column1 = 26
update table_1 set column2 = 788858 where column1 = 14
update table_7 set column13 = 900 where column1 = 21
update table_5 set column4 = 52988 where column1 = 71
update table_2 set column15 = 323136 where column1 = 31
update table_4 set column10 = 412333 where column1 = 28
update table_7 set column15 = 374 where column1 = 34
update table_2 set column5 = 696554 where column1 = 59
update table_0 set column3 = 602378 where column1 = 50
update table_0 set column4 = 476642 where column1 = 38
update table_1 set column2 = 429139 where column1 = 20
update table_8 set column2 = 386313 where column1 = 18
update table_1 set column5 = 684782 where column1 = 16
update table_7 set column5 = 782986 where column1 = 42
update table_4 set column18 = 591121 where column1 = 99
update table_5 set column16 = 406345 where column1 = 89
update table_4 set column4 = 219792 where column1 = 86
update table_8 set column19 = 303534 where column1 = 7
update table_7 set column5 = 479039 where column1 = 65
update table_0 set column18 = 816852 where column1 = 34
update table_8 set column6 = 133764 where column1 = 66
update table_3 set column2 = 42329 where column1 = 87
update table_3 set column5 = 838715 where column1 = 93
update table_4 set column4 = 29859 where column1 = 73
update table_6 set column9 = 308505 where column1 = 21
update table_3 set column20 = 101228 where column1 = 54
update table_7 set column4 = 98229 where column1 = 18
update table_8 set column18 = 451121 where column1 = 22
update table_2 set column20 = 592559 where column1 = 38
update table_8 set column7 = 198627 where column1 = 25
update table_8 set column16 = 987686 where column1 = 89
update table_3 set column20 = 914739 where column1 = 2
update table_1 set column3 = 867504 where column1 = 91
update table_1 set column8 = 234509 where column1 = 46
update table_4 set column11 = 7586 where column1 = 9
update table_0 set column8 = 668476 where column1 = 36
update table_7 set column7 = 527902 where column1 = 93
update table_1 set column9 = 268838 where column1 = 34
update table_3 set column13 = 595807 where column1 = 32
update table_4 set column10 = 810913 where column1 = 78
update table_5 set column14 = 220665 where column1 = 19
update table_6 set column4 = 806617 where column1 = 75
update table_1 set column13 = 639130 where column1 = 9
update table_4 set column2 = 556204 where column1 = 41
update table_1 set column5 = 220427 where column1 = 13
update table_9 set column15 = 881946 where column1 = 89
update table_0 set column20 = 782534 where column1 = 80
update table_5 set column2 = 275150 where column1 = 92
update table_9 set column10 = 546632 where column1 = 14
update table_5 set column19 = 427005 where column1 = 68
update table_2 set column7 = 733426 where column1 = 72
update table_1 set column12 = 113714 where column1 = 49
update table_4 set column9 = 354587 where column1 = 8
update table_1 set column17 = 559115 where column1 = 8
update table_4 set column10 = 733003 where column1 = 19
update table_7 set column19 = 924564 where column1 = 15
update table_5 set column18 = 216047 where column1 = 52
update table_3 set column17 = 854694 where column1 = 9
update table_1 set column6 = 991682 where column1 = 89
update table_8 set column4 = 125954 where column1 = 80
update table_6 set column11 = 315997 where column1 = 2
update table_3 set column9 = 979852 where column1 = 26
update table_3 set column19 = 53400 where column1 = 59
update table_9 set column14 = 543635 where column1 = 71
update table_8 set column19 = 307809 where column1 = 8
update table_0 set column13 = 764405 where column1 = 85
update table_7 set column14 = 177807 where column1 = 18
update table_2 set column3 = 907745 where column1 = 73
update table_8 set column16 = 752835 where column1 = 86
update table_1 set column13 = 378349 where column1 = 67
update table_4 set column11 = 159531 where column1 = 60
update table_1 set column2 = 200955 where column1 = 12
update table_8 set column5 = 838248 where column1 = 79
update table_5 set column11 = 857676 where column1 = 95
update table_5 set column10 = 647532 where column1 = 55
update table_0 set column8 = 256502 where column1 = 78
update table_3 set column2 = 517753 where column1 = 67
update table_3 set column10 = 375693 where column1 = 81
update table_8 set column10 = 231772 where column1 = 81
update table_0 set column15 = 950871 where column1 = 46
update table_3 set column18 = 571679 where column1 = 46
update table_1 set column5 = 688311 where column1 = 80
update table_9 set column15 = 474488 where column1 = 3
update table_2 set column17 = 97177 where column1 = 80
update table_6 set column13 = 995876 where column1 = 5
update table_8 set column14 = 330454 where column1 = 69
update table_8 set column18 = 964211 where column1 = 85
update table_2 set column14 = 637741 where column1 = 28
update table_9 set column7 = 617490 where column1 = 23
update table_2 set column13 = 687756 where column1 = 56
update table_7 set column12 = 751263 where column1 = 31
update table_8 set column2 = 201463 where column1 = 42
update table_7 set column3 = 868206 where column1 = 0
update table_7 set column17 = 257517 where column1 = 75
update table_7 set column7 = 229390 where column1 = 68
update table_1 set column18 = 744622 where column1 = 21
update table_9 set column11 = 312263 where column1 = 89
update table_0 set column7 = 704420 where column1 = 59
update table_6 set column12 = 105135 where column1 = 37
update table_2 set column13 = 216898 where column1 = 6
update table_4 set column3 = 210971 where column1 = 88
update table_4 set column19 = 618429 where column1 = 65
update table_1 set column8 = 731512 where column1 = 24
update table_6 set column6 = 104601 where column1 = 30
update table_2 set column6 = 173356 where column1 = 33
update table_9 set column18 = 753670 where column1 = 32
update table_8 set column16 = 957001 where column1 = 32
update table_5 set column20 = 589136 where column1 = 86
update table_8 set column12 = 702924 where column1 = 58
update table_6 set column14 = 310015 where column1 = 26
update table_5 set column6 = 346259 where column1 = 23
update table_0 set column9 = 480968 where column1 = 89
update table_5 set column13 = 849189 where column1 = 67
update table_0 set column2 = 892319 where column1 = 84
update table_1 set column5 = 645855 where column1 = 10
update table_1 set column9 = 923797 where column1 = 75
update table_8 set column14 = 481467 where column1 = 20
update table_4 set column11 = 928597 where column1 = 70
update table_8 set column13 = 780908 where column1 = 94
update table_6 set column8 = 419650 where column1 = 79
update table_8 set column11 = 67897 where column1 = 8
update table_8 set column11 = 611053 where column1 = 41
update table_2 set column3 = 624232 where column1 = 19
update table_9 set column16 = 130948 where column1 = 92
update table_0 set column5 = 514468 where column1 = 37
update table_6 set column9 = 970336 where column1 = 86
update table_9 set column8 = 262178 where column1 = 65
update table_2 set column6 = 172968 where column1 = 38
update table_9 set column12 = 599907 where column1 = 37
update table_7 set column19 = 618913 where column1 = 90
update table_7 set column14 = 225282 where column1 = 24
update table_9 set column19 = 985375 where column1 = 16
update table_9 set column9 = 754428 where column1 = 72
update table_4 set column15 = 697713 where column1 = 24
update table_2 set column6 = 566711 where column1 = 21
update table_5 set column9 = 811716 where column1 = 44
update table_9 set column3 = 692277 where column1 = 82
update table_0 set column2 = 779368 where column1 = 40
update table_7 set column10 = 120654 where column1 = 62
update table_1 set column5 = 368774 where column1 = 68
update table_3 set column18 = 549518 where column1 = 33
update table_8 set column3 = 874987 where column1 = 37
update table_2 set column17 = 745188 where column1 = 60
update table_3 set column16 = 688101 where column1 = 30
update table_6 set column2 = 416354 where column1 = 18
update table_7 set column7 = 488341 where column1 = 73
update table_9 set column19 = 54825 where column1 = 65
update table_8 set column10 = 828164 where column1 = 44
update table_5 set column18 = 830246 where column1 = 26
update table_1 set column4 = 559365 where column1 = 63
update table_2 set column3 = 677312 where column1 = 44
update table_0 set column12 = 792267 where column1 = 3
update table_8 set column11 = 985309 where column1 = 97
update table_7 set column4 = 834818 where column1 = 23
update table_1 set column8 = 502054 where column1 = 22
update table_9 set column11 = 34671 where column1 = 4
update table_3 set column17 = 618709 where column1 = 39
update table_4 set column18 = 981333 where column1 = 43
update table_1 set column6 = 662880 where column1 = 22
update table_1 set column13 = 597505 where column1 = 72
update table_9 set column15 = 101119 where column1 = 60
update table_3 set column15 = 383386 where column1 = 36
update table_4 set column2 = 671408 where column1 = 39
update table_4 set column11 = 885393 where column1 = 19
update table_0 set column12 = 46009 where column1 = 92
update table_5 set column16 = 74257 where column1 = 79
update table_2 set column18 = 311958 where column1 = 25
update table_8 set column6 = 675585 where column1 = 92
update table_7 set column6 = 468607 where column1 = 89
update table_0 set column6 = 559116 where column1 = 28
update table_7 set column16 = 364180 where column1 = 78
update table_1 set column20 = 172970 where column1 = 96
update table_2 set column17 = 415644 where column1 = 56
update table_0 set column14 = 999178 where column1 = 80
update table_2 set column20 = 881000 where column1 = 22
update table_0 set column20 = 397277 where column1 = 16
update table_4 set column17 = 517149 where column1 = 3
update table_8 set column5 = 503060 where column1 = 97
update table_2 set column10 = 81428 where column1 = 19
update table_6 set column7 = 23638 where column1 = 75
update table_8 set column17 = 736650 where column1 = 35
update table_2 set column17 = 80253 where column1 = 27
update table_9 set column5 = 919607 where column1 = 85
update table_4 set column13 = 742600 where column1 = 79
update table_9 set column14 = 426800 where column1 = 47
update table_1 set column20 = 725255 where column1 = 33
update table_0 set column3 = 387699 where column1 = 67
update table_8 set column18 = 288155 where column1 = 34
update table_2 set column17 = 55389 where column1 = 1
update table_3 set column13 = 358853 where column1 = 41
update table_8 set column18 = 145911 where column1 = 19
update table_3 set column6 = 915453 where column1 = 33
update table_1 set column12 = 52077 where column1 = 67
update table_9 set column8 = 606911 where column1 = 6
update table_7 set column9 = 175293 where column1 = 28
update table_1 set column17 = 633008 where column1 = 40
update table_0 set column20 = 705884 where column1 = 99
update table_4 set column8 = 322342 where column1 = 34
update table_5 set column4 = 555853 where column1 = 32
update table_3 set column10 = 223794 where column1 = 94
update table_6 set column18 = 284056 where column1 = 33
update table_0 set column6 = 737556 where column1 = 58
update table_3 set column7 = 932059 where column1 = 76
update table_2 set column5 = 815857 where column1 = 41
update table_0 set column16 = 180425 where column1 = 61
update table_2 set column15 = 326045 where column1 = 1
update table_7 set column11 = 822880 where column1 = 91
update table_7 set column9 = 98051 where column1 = 5
update table_0 set column12 = 479817 where column1 = 57
update table_2 set column11 = 615056 where column1 = 39
update table_2 set column9 = 977030 where column1 = 22
update table_6 set column7 = 826652 where column1 = 51
update table_5 set column5 = 11888 where column1 = 11
update table_3 set column19 = 755141 where column1 = 85
update table_4 set column12 = 488080 where column1 = 74
update table_1 set column13 = 915431 where column1 = 34
update table_0 set column10 = 905792 where column1 = 93
update table_7 set column18 = 941347 where column1 = 39
update table_4 set column4 = 416773 where column1 = 2
update table_1 set column17 = 874705 where column1 = 74
update table_9 set column12 = 817623 where column1 = 91
update table_5 set column3 = 231120 where column1 = 68
update table_3 set column5 = 495569 where column1 = 70
update table_4 set column10 = 137365 where column1 = 39
update table_0 set column2 = 675578 where column1 = 49
update table_0 set column16 = 150682 where column1 = 19
update table_0 set column16 = 688307 where column1 = 67
update table_8 set column11 = 538234 where column1 = 52
update table_7 set column14 = 986954 where column1 = 17
update table_0 set column13 = 916278 where column1 = 81
update table_0 set column20 = 904216 where column1 = 0
update table_1 set column11 = 427990 where column1 = 86
update table_5 set column18 = 276256 where column1 = 13
update table_0 set column3 = 185965 where column1 = 1
update table_5 set column8 = 575448 where column1 = 70
update table_7 set column11 = 177020 where column1 = 22
update table_3 set column2 = 251023 where column1 = 51
update table_2 set column19 = 593477 where column1 = 3
update table_7 set column19 = 967355 where column1 = 51
update table_0 set column4 = 870836 where column1 = 97
update table_8 set column11 = 611273 where column1 = 3
update table_0 set column17 = 429938 where column1 = 49
update table_5 set column15 = 68664 where column1 = 49
update table_5 set column15 = 813226 where column1 = 72
update table_8 set column2 = 117767 where column1 = 88
update table_1 set column5 = 551248 where column1 = 38
update table_2 set column14 = 169870 where column1 = 21
update table_9 set column16 = 509710 where column1 = 86
update table_1 set column11 = 258190 where column1 = 46
update table_0 set column16 = 148626 where column1 = 36
update table_7 set column13 = 430259 where column1 = 37
update table_7 set column2 = 242313 where column1 = 83
update table_6 set column5 = 868268 where column1 = 3
update table_4 set column5 = 336485 where column1 = 95
update table_9 set column10 = 207804 where column1 = 91
update table_8 set column8 = 887154 where column1 = 79
update table_1 set column13 = 785428 where column1 = 34
update table_6 set column7 = 320118 where column1 = 81
update table_1 set column16 = 945420 where column1 = 11
update table_8 set column11 = 387088 where column1 = 8
update table_0 set column11 = 388288 where column1 = 25
update table_2 set column19 = 550146 where column1 = 44
update table_2 set column2 = 753117 where column1 = 84
update table_8 set column11 = 616018 where column1 = 61
update table_7 set column6 = 702129 where column1 = 67
update table_8 set column7 = 724398 where column1 = 23
update table_4 set column7 = 127366 where column1 = 51
update table_1 set column19 = 698085 where column1 = 61
update table_5 set column9 = 232855 where column1 = 24
update table_2 set column20 = 255656 where column1 = 95
update table_1 set column17 = 8532 where column1 = 35
update table_9 set column9 = 479976 where column1 = 6
update table_3 set column13 = 2002 where column1 = 77
update table_1 set column20 = 514282 where column1 = 71
update table_0 set column2 = 347187 where column1 = 30
update table_9 set column8 = 618329 where column1 = 20
update table_5 set column8 = 957790 where column1 = 9
update table_0 set column7 = 159405 where column1 = 80
update table_3 set column17 = 192089 where column1 = 93
update table_6 set column7 = 39597 where column1 = 64
update table_9 set column16 = 634937 where column1 = 96
update table_0 set column9 = 994015 where column1 = 4
update table_0 set column17 = 695688 where column1 = 75
update table_4 set column13 = 407803 where column1 = 86
update table_1 set column6 = 325385 where column1 = 18
update table_1 set column3 = 168043 where column1 = 2
update table_3 set column6 = 534319 where column1 = 80
update table_5 set column6 = 456853 where column1 = 48
update table_4 set column13 = 161304 where column1 = 52
update table_2 set column8 = 933430 where column1 = 44
update table_5 set column18 = 655737 where column1 = 34
update table_5 set column19 = 812059 where column1 = 22
update table_2 set column9 = 572333 where column1 = 78
update table_1 set column5 = 716536 where column1 = 43
update table_2 set column4 = 947265 where column1 = 58
update table_8 set column18 = 580865 where column1 = 12
update table_4 set column19 = 478032 where column1 = 84
update table_7 set column10 = 567283 where column1 = 34
update table_7 set column17 = 967522 where column1 = 81
update table_8 set column7 = 59058 where column1 = 11
update table_1 set column8 = 287312 where column1 = 52
update table_0 set column7 = 367122 where column1 = 55
update table_9 set column14 = 127934 where column1 = 75
update table_2 set column7 = 951946 where column1 = 7
update table_6 set column9 = 618840 where column1 = 90
update table_7 set column4 = 113056 where column1 = 44
update table_1 set column6 = 814332 where column1 = 42
update table_2 set column7 = 949218 where column1 = 84
update table_6 set column19 = 748089 where column1 = 83
update table_7 set column20 = 273241 where column1 = 6
update table_2 set column13 = 54138 where column1 = 43
update table_8 set column16 = 68765 where column1 = 80
update table_2 set column14 = 45640 where column1 = 20
update table_8 set column13 = 154108 where column1 = 22
update table_5 set column3 = 792363 where column1 = 66
update table_4 set column3 = 465973 where column1 = 27
update table_4 set column16 = 41263 where column1 = 37
update table_8 set column13 = 757490 where column1 = 85
update table_7 set column17 = 977643 where column1 = 7
update table_5 set column8 = 68315 where column1 = 83
update table_2 set column17 = 924635 where column1 = 61
update table_5 set column15 = 310412 where column1 = 7
update table_7 set column14 = 616076 where column1 = 9
update table_0 set column14 = 926828 where column1 = 51
update table_2 set column6 = 724 where column1 = 2
update table_6 set column5 = 34825 where column1 = 3
update table_3 set column8 = 832724 where column1 = 16
update table_4 set column18 = 697030 where column1 = 41
update table_5 set column9 = 27195 where column1 = 80
update table_5 set column9 = 134627 where column1 = 26
update table_4 set column14 = 809878 where column1 = 50
update table_9 set column6 = 461807 where column1 = 64
update table_3 set column13 = 555977 where column1 = 66
update table_7 set column5 = 214928 where column1 = 68
update table_4 set column3 = 236313 where column1 = 50
update table_8 set column18 = 948299 where column1 = 19
update table_6 set column14 = 107443 where column1 = 18
update table_1 set column7 = 292771 where column1 = 23
update table_2 set column18 = 360616 where column1 = 0
update table_5 set column7 = 247219 where column1 = 26
update table_1 set column7 = 57916 where column1 = 92
update table_4 set column20 = 998687 where column1 = 83
update table_5 set column4 = 302068 where column1 = 24
update table_0 set column19 = 814531 where column1 = 33
update table_3 set column10 = 533056 where column1 = 60
update table_9 set column11 = 856410 where column1 = 85
update table_1 set column7 = 448615 where column1 = 98
update table_9 set column13 = 628350 where column1 = 52
update table_2 set column2 = 766159 where column1 = 0
update table_2 set column5 = 698857 where column1 = 75
update table_1 set column17 = 416196 where column1 = 98
update table_2 set column3 = 752953 where column1 = 93
update table_0 set column9 = 387332 where column1 = 55
update table_0 set column11 = 394517 where column1 = 2
update table_5 set column8 = 969403 where column1 = 88
update table_6 set column7 = 460714 where column1 = 28
update table_6 set column3 = 183760 where column1 = 82
update table_1 set column10 = 345805 where column1 = 12
update table_5 set column17 = 640603 where column1 = 66
update table_9 set column12 = 835027 where column1 = 68
update table_4 set column19 = 410594 where column1 = 39
update table_2 set column15 = 845170 where column1 = 60
update table_8 set column8 = 548097 where column1 = 62
update table_8 set column10 = 747323 where column1 = 51
update table_5 set column2 = 725170 where column1 = 32
update table_8 set column19 = 875957 where column1 = 54
update table_0 set column4 = 756149 where column1 = 30
update table_6 set column16 = 762650 where column1 = 23
update table_5 set column7 = 538894 where column1 = 97
update table_4 set column4 = 542102 where column1 = 10
update table_7 set column16 = 86146 where column1 = 29
update table_0 set column13 = 803191 where column1 = 86
update table_5 set column18 = 164640 where column1 = 32
update table_2 set column15 = 500575 where column1 = 32
update table_0 set column3 = 862598 where column1 = 79
update table_5 set column18 = 224672 where column1 = 49
update table_4 set column19 = 876688 where column1 = 77
update table_2 set column2 = 855596 where column1 = 98
update table_7 set column20 = 130053 where column1 = 84
update table_1 set column17 = 946466 where column1 = 74
update table_4 set column17 = 342033 where column1 = 93
update table_7 set column8 = 416257 where column1 = 96
update table_6 set column3 = 773969 where column1 = 26
update table_1 set column13 = 721465 where column1 = 81
update table_8 set column3 = 362592 where column1 = 91
update table_4 set column2 = 363650 where column1 = 31
update table_6 set column4 = 898412 where column1 = 11
update table_2 set column13 = 404632 where column1 = 5
update table_4 set column4 = 827538 where column1 = 5
update table_4 set column7 = 500999 where column1 = 70
update table_4 set column17 = 57147 where column1 = 3
update table_6 set column6 = 270117 where column1 = 22
update table_5 set column7 = 847923 where column1 = 77
update table_3 set column18 = 677752 where column1 = 7
update table_0 set column14 = 780174 where column1 = 47
update table_4 set column13 = 216831 where column1 = 99
update table_0 set column14 = 446020 where column1 = 1
update table_5 set column20 = 223061 where column1 = 52
update table_0 set column7 = 654302 where column1 = 47
update table_7 set column15 = 89054 where column1 = 75
update table_3 set column7 = 899661 where column1 = 26
update table_2 set column15 = 628625 where column1 = 92
update table_6 set column20 = 853013 where column1 = 32
update table_1 set column7 = 857451 where column1 = 75
update table_9 set column14 = 407721 where column1 = 31
update table_8 set column7 = 479847 where column1 = 71
update table_3 set column7 = 17055 where column1 = 39
update table_6 set column4 = 734990 where column1 = 49
update table_2 set column4 = 698174 where column1 = 12
update table_3 set column2 = 886037 where column1 = 41
update table_0 set column20 = 174944 where column1 = 29
update table_3 set column12 = 444825 where column1 = 18
update table_6 set column6 = 167676 where column1 = 87
update table_2 set column4 = 333039 where column1 = 28
update table_5 set column12 = 366899 where column1 = 63
update table_1 set column12 = 624070 where column1 = 67
update table_4 set column12 = 421441 where column1 = 43
update table_7 set column4 = 66958 where column1 = 89
update table_7 set column7 = 863389 where column1 = 23
update table_1 set column14 = 277380 where column1 = 11
update table_5 set column12 = 625159 where column1 = 34
update table_3 set column19 = 430064 where column1 = 90
update table_3 set column11 = 858440 where column1 = 23
update table_9 set column11 = 890626 where column1 = 60
update table_5 set column8 = 692650 where column1 = 50
update table_0 set column6 = 830901 where column1 = 33
update table_1 set column18 = 536153 where column1 = 62
update table_9 set column10 = 360795 where column1 = 99
update table_9 set column3 = 304025 where column1 = 18
update table_2 set column10 = 622962 where column1 = 77
update table_5 set column9 = 384630 where column1 = 69
update table_7 set column7 = 783263 where column1 = 87
update table_1 set column18 = 541828 where column1 = 46
update table_8 set column20 = 264547 where column1 = 65
update table_0 set column16 = 142358 where column1 = 33
update table_6 set column20 = 583775 where column1 = 17
update table_8 set column6 = 982107 where column1 = 54
update table_1 set column5 = 539563 where column1 = 87
update table_9 set column17 = 471851 where column1 = 43
update table_0 set column15 = 14566 where column1 = 9
update table_9 set column14 = 396123 where column1 = 93
update table_0 set column2 = 868474 where column1 = 36
update table_2 set column14 = 377836 where column1 = 71
update table_8 set column4 = 687084 where column1 = 87
update table_2 set column9 = 124598 where column1 = 36
update table_7 set column2 = 434703 where column1 = 14
update table_2 set column20 = 83629 where column1 = 68
update table_7 set column12 = 616018 where column1 = 67
update table_2 set column20 = 598394 where column1 = 5
update table_0 set column15 = 452684 where column1 = 93
update table_9 set column16 = 250422 where column1 = 48
update table_2 set column19 = 152057 where column1 = 46
update table_8 set column3 = 297713 where column1 = 46
update table_4 set column10 = 656604 where column1 = 32
update table_2 set column10 = 387151 where column1 = 96
update table_5 set column11 = 365169 where column1 = 48
update table_9 set column4 = 376558 where column1 = 59
update table_0 set column2 = 248028 where column1 = 16
update table_0 set column6 = 484943 where column1 = 98
update table_4 set column5 = 732644 where column1 = 30
update table_9 set column17 = 188651 where column1 = 96
update table_4 set column15 = 384531 where column1 = 57
update table_9 set column13 = 307350 where column1 = 72
update table_8 set column8 = 179146 where column1 = 8
update table_8 set column15 = 417038 where column1 = 17
update table_1 set column15 = 325646 where column1 = 33
update table_9 set column13 = 457003 where column1 = 95
update table_6 set column3 = 469949 where column1 = 5
update table_9 set column10 = 956912 where column1 = 46
update table_7 set column9 = 162029 where column1 = 6
update table_9 set column10 = 717295 where column1 = 13
update table_3 set column16 = 157178 where column1 = 55
update table_2 set column14 = 920941 where column1 = 18
update table_2 set column10 = 680268 where column1 = 85
update table_8 set column11 = 389761 where column1 = 98
update table_3 set column8 = 975005 where column1 = 51
update table_7 set column11 = 703147 where column1 = 67
update table_1 set column12 = 787669 where column1 = 18
update table_6 set column19 = 536590 where column1 = 79
update table_5 set column3 = 775092 where column1 = 40
update table_6 set column20 = 302048 where column1 = 32
update table_2 set column14 = 693096 where column1 = 57
update table_3 set column14 = 594353 where column1 = 91
update table_9 set column5 = 981543 where column1 = 85
update table_1 set column16 = 846387 where column1 = 40
update table_9 set column7 = 301278 where column1 = 22
update table_3 set column11 = 287753 where column1 = 19
update table_5 set column3 = 998796 where column1 = 16
update table_5 set column11 = 392635 where column1 = 55
update table_5 set column10 = 869336 where column1 = 55
update table_5 set column7 = 703983 where column1 = 95
update table_7 set column7 = 575680 where column1 = 99
update table_0 set column12 = 951598 where column1 = 33
update table_6 set column20 = 276473 where column1 = 15
update table_7 set column14 = 857564 where column1 = 5
update table_6 set column15 = 123552 where column1 = 47
update table_6 set column2 = 697813 where column1 = 82
update table_2 set column4 = 844320 where column1 = 2
update table_7 set column3 = 532563 where column1 = 76
update table_0 set column9 = 638421 where column1 = 95
update table_9 set column14 = 965471 where column1 = 70
update table_4 set column13 = 551222 where column1 = 28
update table_1 set column17 = 289366 where column1 = 17
update table_3 set column10 = 917101 where column1 = 29
update table_2 set column7 = 911198 where column1 = 52
update table_9 set column16 = 966105 where column1 = 37
update table_3 set column12 = 112592 where column1 = 22
update table_8 set column10 = 503677 where column1 = 70
update table_8 set column2 = 64308 where column1 = 99
update table_8 set column2 = 870349 where column1 = 54
update table_4 set column20 = 461498 where column1 = 89
update table_9 set column5 = 837503 where column1 = 35
update table_4 set column3 = 67990 where column1 = 73
update table_2 set column14 = 256162 where column1 = 59
update table_6 set column19 = 507293 where column1 = 13
update table_8 set column15 = 975917 where column1 = 4
update table_9 set column3 = 594196 where column1 = 6
update table_2 set column16 = 867378 where column1 = 79
update table_2 set column6 = 804459 where column1 = 46
update table_2 set column3 = 675894 where column1 = 20
update table_0 set column10 = 258584 where column1 = 16
update table_7 set column17 = 589958 where column1 = 66
update table_9 set column2 = 713474 where column1 = 22
update table_6 set column11 = 312685 where column1 = 42
update table_0 set column10 = 457045 where column1 = 46
update table_7 set column3 = 266540 where column1 = 72
update table_6 set column5 = 449115 where column1 = 84
update table_8 set column5 = 93208 where column1 = 7
update table_7 set column6 = 755892 where column1 = 80
update table_6 set column10 = 700543 where column1 = 77
update table_8 set column17 = 522277 where column1 = 22
update table_4 set column6 = 854405 where column1 = 93
update table_8 set column7 = 585719 where column1 = 16
update table_4 set column9 = 973325 where column1 = 25
update table_4 set column17 = 304036 where column1 = 5
update table_6 set column5 = 678301 where column1 = 78
update table_1 set column7 = 246183 where column1 = 77
update table_0 set column13 = 304738 where column1 = 99
update table_5 set column13 = 808249 where column1 = 17
update table_9 set column11 = 971102 where column1 = 52
update table_6 set column11 = 135899 where column1 = 63
update table_1 set column18 = 890784 where column1 = 96
update table_8 set column8 = 130374 where column1 = 94
update table_3 set column5 = 155532 where column1 = 66
update table_2 set column3 = 893459 where column1 = 10
update table_2 set column12 = 167739 where column1 = 18
update table_8 set column7 = 845808 where column1 = 81
update table_7 set column11 = 64648 where column1 = 1
update table_0 set column10 = 225149 where column1 = 13
update table_1 set column4 = 664035 where column1 = 46
update table_6 set column6 = 700070 where column1 = 93
update table_2 set column20 = 259142 where column1 = 95
update table_5 set column17 = 9726 where column1 = 66
update table_9 set column7 = 271783 where column1 = 38
update table_0 set column5 = 2470 where column1 = 36
update table_1 set column20 = 308853 where column1 = 26
update table_4 set column13 = 326886 where column1 = 54
update table_4 set column7 = 551840 where column1 = 28
update table_2 set column17 = 668157 where column1 = 94
update table_0 set column13 = 582340 where column1 = 61
update table_7 set column11 = 488633 where column1 = 97
update table_8 set column11 = 898137 where column1 = 44
update table_9 set column12 = 100561 where column1 = 69
update table_7 set column2 = 871667 where column1 = 48
update table_7 set column9 = 488779 where column1 = 4
update table_1 set column2 = 44115 where column1 = 56
update table_1 set column13 = 865581 where column1 = 75
update table_0 set column4 = 125870 where column1 = 41
update table_8 set column3 = 801364 where column1 = 56
update table_3 set column11 = 989050 where column1 = 51
update table_4 set column3 = 644980 where column1 = 97
update table_6 set column17 = 95662 where column1 = 96
update table_4 set column14 = 587040 where column1 = 42
update table_6 set column20 = 105381 where column1 = 29
update table_2 set column13 = 736777 where column1 = 67
update table_8 set column7 = 925227 where column1 = 97
update table_6 set column11 = 906310 where column1 = 83
update table_0 set column17 = 794115 where column1 = 43
update table_5 set column12 = 202829 where column1 = 51
update table_8 set column18 = 537808 where column1 = 10
update table_4 set column18 = 587103 where column1 = 55
update table_6 set column20 = 319059 where column1 = 95
update table_5 set column19 = 965944 where column1 = 59
update table_7 set column19 = 485378 where column1 = 42
update table_1 set column19 = 980751 where column1 = 13
update table_8 set column12 = 19722 where column1 = 56
update table_5 set column18 = 113618 where column1 = 46
update table_4 set column17 = 5863 where column1 = 9
update table_1 set column13 = 27024 where column1 = 53
update table_4 set column14 = 804772 where column1 = 81
update table_9 set column7 = 462485 where column1 = 58
update table_0 set column2 = 668518 where column1 = 9
update table_3 set column11 = 528116 where column1 = 63
update table_1 set column20 = 382965 where column1 = 81
update table_1 set column8 = 240857 where column1 = 85
update table_8 set column15 = 911617 where column1 = 9
update table_4 set column20 = 607748 where column1 = 35
update table_3 set column19 = 242779 where column1 = 59
update table_2 set column13 = 437061 where column1 = 58
update table_5 set column13 = 693648 where column1 = 55
update table_8 set column8 = 994939 where column1 = 8
update table_7 set column4 = 49860 where column1 = 45
update table_0 set column6 = 114724 where column1 = 88
update table_4 set column19 = 48195 where column1 = 39
update table_0 set column12 = 430435 where column1 = 41
update table_5 set column2 = 206684 where column1 = 69
update table_7 set column20 = 957464 where column1 = 0
update table_9 set column8 = 275555 where column1 = 10
update table_5 set column20 = 624420 where column1 = 25
update table_1 set column13 = 57499 where column1 = 25
update table_3 set column11 = 202412 where column1 = 87
update table_2 set column9 = 762404 where column1 = 23
update table_3 set column10 = 658160 where column1 = 38
update table_1 set column7 = 969631 where column1 = 90
update table_5 set column5 = 553705 where column1 = 70
update table_6 set column18 = 851808 where column1 = 93
update table_7 set column12 = 656971 where column1 = 40
update table_8 set column13 = 85828 where column1 = 34
update table_8 set column9 = 535344 where column1 = 38
update table_2 set column18 = 928480 where column1 = 44
update table_7 set column2 = 597051 where column1 = 77
update table_6 set column6 = 802121 where column1 = 79
update table_8 set column5 = 946835 where column1 = 9
update table_2 set column6 = 669934 where column1 = 99
update table_7 set column16 = 418920 where column1 = 98
update table_7 set column14 = 848133 where column1 = 38
update table_0 set column15 = 543474 where column1 = 99
update table_2 set column5 = 893213 where column1 = 14
update table_4 set column4 = 287889 where column1 = 57
update table_0 set column18 = 777810 where column1 = 15
update table_6 set column6 = 607784 where column1 = 18
update table_4 set column3 = 264918 where column1 = 7
update table_9 set column14 = 764684 where column1 = 34
update table_0 set column3 = 98358 where column1 = 36
update table_8 set column4 = 597673 where column1 = 13
update table_4 set column18 = 613084 where column1 = 19
update table_0 set column16 = 121488 where column1 = 0
update table_0 set column8 = 593460 where column1 = 70
update table_1 set column14 = 322972 where column1 = 31
update table_3 set column19 = 8867 where column1 = 47
update table_5 set column4 = 436780 where column1 = 90
update table_4 set column5 = 31785 where column1 = 58
update table_6 set column10 = 639863 where column1 = 5
update table_8 set column17 = 565878 where column1 = 80
update table_2 set column3 = 734037 where column1 = 91
update table_5 set column6 = 498903 where column1 = 58
update table_5 set column12 = 315910 where column1 = 18
update table_6 set column17 = 280416 where column1 = 47
update table_3 set column5 = 990597 where column1 = 24
update table_6 set column13 = 251969 where column1 = 56
update table_3 set column18 = 295344 where column1 = 90
update table_8 set column6 = 425850 where column1 = 20
update table_9 set column5 = 202478 where column1 = 10
update table_6 set column7 = 818713 where column1 = 11
update table_8 set column10 = 800487 where column1 = 30
update table_2 set column15 = 929612 where column1 = 73
update table_5 set column19 = 500365 where column1 = 37
update table_3 set column4 = 920163 where column1 = 44
update table_6 set column15 = 980642 where column1 = 62
update table_8 set column5 = 706912 where column1 = 77
update table_3 set column9 = 244335 where column1 = 35
update table_9 set column10 = 712753 where column1 = 15
update table_0 set column10 = 260453 where column1 = 78
update table_6 set column8 = 373596 where column1 = 19
update table_3 set column11 = 672231 where column1 = 22
update table_1 set column20 = 768793 where column1 = 62
update table_6 set column20 = 431068 where column1 = 99
update table_9 set column2 = 271960 where column1 = 70
update table_4 set column9 = 415223 where column1 = 58
update table_1 set column13 = 767011 where column1 = 74
update table_7 set column6 = 90768 where column1 = 34
update table_1 set column6 = 76212 where column1 = 75
update table_0 set column12 = 599299 where column1 = 50
update table_7 set column12 = 618906 where column1 = 6
update table_8 set column2 = 522251 where column1 = 34
update table_0 set column3 = 342331 where column1 = 68
update table_2 set column18 = 74980 where column1 = 98
update table_1 set column9 = 529261 where column1 = 63
update table_4 set column6 = 308416 where column1 = 76
update table_0 set column2 = 340026 where column1 = 9
update table_4 set column11 = 613873 where column1 = 83
update table_3 set column12 = 419876 where column1 = 9
update table_3 set column8 = 430216 where column1 = 23
update table_0 set column20 = 664122 where column1 = 18
update table_0 set column12 = 731803 where column1 = 95
update table_8 set column19 = 113857 where column1 = 89
update table_0 set column5 = 626050 where column1 = 55
update table_4 set column5 = 450205 where column1 = 37
update table_4 set column6 = 802111 where column1 = 89
update table_6 set column20 = 692627 where column1 = 11
update table_5 set column18 = 659798 where column1 = 94
update table_8 set column18 = 65233 where column1 = 53
update table_8 set column8 = 745436 where column1 = 19
update table_0 set column20 = 85041 where column1 = 25
update table_8 set column11 = 382000 where column1 = 11
update table_3 set column10 = 873424 where column1 = 95
update table_5 set column17 = 86134 where column1 = 92
update table_1 set column20 = 251695 where column1 = 57
update table_3 set column5 = 608985 where column1 = 99
update table_0 set column6 = 515515 where column1 = 5
update table_9 set column11 = 888120 where column1 = 7
update table_2 set column11 = 831228 where column1 = 92
update table_4 set column8 = 222692 where column1 = 73
update table_7 set column8 = 897544 where column1 = 28
update table_0 set column16 = 228315 where column1 = 83
update table_0 set column2 = 514746 where column1 = 21
update table_3 set column2 = 734385 where column1 = 76
update table_4 set column10 = 740730 where column1 = 54
update table_6 set column10 = 306906 where column1 = 88
update table_4 set column3 = 567741 where column1 = 46
update table_8 set column16 = 207459 where column1 = 77
update table_2 set column9 = 882130 where column1 = 91
update table_1 set column13 = 974648 where column1 = 30
update table_9 set column5 = 816554 where column1 = 17
update table_7 set column18 = 387707 where column1 = 17
update table_5 set column3 = 529336 where column1 = 46
update table_4 set column10 = 514296 where column1 = 50
update table_4 set column8 = 564507 where column1 = 51
update table_6 set column11 = 240195 where column1 = 37
update table_0 set column3 = 803029 where column1 = 91
update table_8 set column7 = 724860 where column1 = 31
update table_9 set column17 = 56754 where column1 = 97
update table_9 set column15 = 297279 where column1 = 74
update table_0 set column20 = 826523 where column1 = 71
update table_3 set column7 = 312869 where column1 = 70
update table_7 set column8 = 674426 where column1 = 56
update table_7 set column8 = 640911 where column1 = 8
update table_4 set column18 = 583414 where column1 = 99
update table_2 set column13 = 806272 where column1 = 68
update table_1 set column13 = 233708 where column1 = 96
update table_6 set column5 = 950911 where column1 = 93
update table_0 set column11 = 395285 where column1 = 23
update table_6 set column11 = 203218 where column1 = 23
update table_2 set column15 = 245037 where column1 = 95
update table_1 set column11 = 971652 where column1 = 2
update table_4 set column20 = 183317 where column1 = 93
update table_2 set column4 = 167679 where column1 = 30
update table_5 set column8 = 652549 where column1 = 99
update table_2 set column14 = 986894 where column1 = 80
update table_2 set column19 = 960872 where column1 = 70
update table_2 set column7 = 648971 where column1 = 84
update table_8 set column6 = 560456 where column1 = 37
update table_6 set column14 = 324224 where column1 = 5
update table_6 set column10 = 543387 where column1 = 31
update table_0 set column11 = 877087 where column1 = 92
update table_7 set column6 = 772201 where column1 = 13
update table_8 set column14 = 600983 where column1 = 96
update table_8 set column10 = 212049 where column1 = 82
update table_7 set column15 = 530637 where column1 = 45
update table_9 set column15 = 527169 where column1 = 49
update table_1 set column11 = 256767 where column1 = 89
update table_3 set column20 = 312599 where column1 = 63
update table_2 set column19 = 122926 where column1 = 41
update table_5 set column5 = 924362 where column1 = 75
update table_5 set column8 = 332535 where column1 = 82
update table_8 set column6 = 324722 where column1 = 13
update table_6 set column3 = 377635 where column1 = 14
update table_1 set column12 = 301370 where column1 = 73
update table_9 set column14 = 833307 where column1 = 13
update table_4 set column15 = 344104 where column1 = 98
update table_0 set column18 = 256597 where column1 = 76
update table_7 set column9 = 993394 where column1 = 4
update table_1 set column5 = 880211 where column1 = 2
update table_3 set column5 = 251702 where column1 = 90
update table_6 set column3 = 15644 where column1 = 56
update table_1 set column10 = 504442 where column1 = 44
update table_2 set column14 = 556678 where column1 = 3
update table_9 set column14 = 533307 where column1 = 96
update table_6 set column13 = 258965 where column1 = 85
update table_3 set column3 = 877391 where column1 = 84
update table_9 set column5 = 757730 where column1 = 71
update table_0 set column11 = 308875 where column1 = 95
update table_5 set column20 = 698804 where column1 = 23
update table_1 set column16 = 539942 where column1 = 67
update table_3 set column3 = 296122 where column1 = 80
update table_4 set column4 = 356595 where column1 = 87
update table_1 set column4 = 411382 where column1 = 1
update table_0 set column10 = 466451 where column1 = 27
update table_7 set column6 = 102245 where column1 = 38
update table_2 set column9 = 381975 where column1 = 18
update table_5 set column13 = 112450 where column1 = 79
update table_5 set column20 = 25134 where column1 = 28
update table_9 set column9 = 656407 where column1 = 19
update table_3 set column13 = 225805 where column1 = 46
update table_1 set column13 = 127322 where column1 = 29
update table_4 set column20 = 942583 where column1 = 96
update table_9 set column8 = 167330 where column1 = 41
update table_7 set column15 = 544315 where column1 = 29
update table_4 set column10 = 562138 where column1 = 65
update table_9 set column6 = 495656 where column1 = 57
update table_6 set column15 = 935551 where column1 = 77
update table_6 set column19 = 70268 where column1 = 42
update table_9 set column6 = 701113 where column1 = 96
update table_9 set column7 = 453105 where column1 = 8
update table_8 set column19 = 195072 where column1 = 9
update table_7 set column9 = 231721 where column1 = 16
update table_9 set column10 = 264009 where column1 = 77
update table_3 set column3 = 28833 where column1 = 35
update table_5 set column16 = 404371 where column1 = 88
update table_0 set column6 = 120991 where column1 = 72
update table_8 set column6 = 769972 where column1 = 15
update table_0 set column17 = 551699 where column1 = 30
update table_1 set column3 = 602521 where column1 = 12
update table_6 set column5 = 229816 where column1 = 24
update table_3 set column19 = 497892 where column1 = 22
update table_8 set column8 = 630093 where column1 = 81
update table_9 set column18 = 565309 where column1 = 70
update table_2 set column5 = 60626 where column1 = 38
update table_6 set column15 = 33969 where column1 = 29
update table_0 set column19 = 866829 where column1 = 56
update table_6 set column12 = 966070 where column1 = 5
update table_9 set column6 = 536959 where column1 = 60
update table_2 set column10 = 651742 where column1 = 7
update table_1 set column14 = 731723 where column1 = 84
update table_2 set column13 = 692445 where column1 = 54
update table_9 set column8 = 92971 where column1 = 56
update table_9 set column15 = 966289 where column1 = 90
update table_0 set column9 = 121840 where column1 = 13
update table_2 set column19 = 144141 where column1 = 69
update table_7 set column16 = 933633 where column1 = 90
update table_6 set column15 = 749775 where column1 = 79
update table_2 set column8 = 386821 where column1 = 51
update table_2 set column20 = 699434 where column1 = 0
update table_6 set column5 = 714638 where column1 = 23
update table_6 set column17 = 322442 where column1 = 71
update table_6 set column18 = 23314 where column1 = 44
update table_4 set column19 = 60820 where column1 = 14
update table_1 set column3 = 5744 where column1 = 27
update table_2 set column19 = 478394 where column1 = 20
update table_7 set column9 = 861433 where column1 = 28
update table_8 set column17 = 730037 where column1 = 80
update table_5 set column3 = 614132 where column1 = 90
update table_7 set column9 = 617385 where column1 = 98
update table_1 set column15 = 92465 where column1 = 53
update table_3 set column13 = 807342 where column1 = 99
update table_5 set column8 = 965500 where column1 = 45
update table_4 set column20 = 127428 where column1 = 19
update table_0 set column10 = 395121 where column1 = 77
update table_5 set column4 = 303103 where column1 = 2
update table_3 set column10 = 429620 where column1 = 36
update table_1 set column15 = 600925 where column1 = 77
update table_8 set column14 = 773461 where column1 = 58
update table_5 set column11 = 166117 where column1 = 32
update table_1 set column2 = 474108 where column1 = 10
update table_5 set column13 = 844728 where column1 = 45
update table_5 set column13 = 183367 where column1 = 33
update table_2 set column7 = 491590 where column1 = 57
update table_7 set column5 = 211438 where column1 = 59
update table_1 set column11 = 907088 where column1 = 56
update table_0 set column6 = 264199 where column1 = 3
update table_9 set column7 = 612468 where column1 = 10
update table_0 set column15 = 469311 where column1 = 33
update table_2 set column13 = 792500 where column1 = 47
update table_5 set column8 = 75799 where column1 = 49
update table_1 set column16 = 433345 where column1 = 53
update table_3 set column9 = 714472 where column1 = 1
update table_6 set column12 = 34312 where column1 = 64
update table_7 set column8 = 467800 where column1 = 73
update table_2 set column20 = 424373 where column1 = 11
update table_5 set column8 = 467266 where column1 = 70
update table_7 set column9 = 13321 where column1 = 24
update table_9 set column10 = 235360 where column1 = 5
update table_1 set column10 = 102632 where column1 = 17
update table_6 set column11 = 574252 where column1 = 10
update table_8 set column13 = 543871 where column1 = 66
update table_7 set column10 = 282929 where column1 = 39
update table_0 set column4 = 395573 where column1 = 34
update table_5 set column7 = 990740 where column1 = 26
update table_2 set column20 = 622868 where column1 = 19
update table_6 set column12 = 149009 where column1 = 94
update table_3 set column12 = 820416 where column1 = 20
update table_6 set column8 = 26049 where column1 = 31
update table_0 set column10 = 478286 where column1 = 22
update table_2 set column2 = 325449 where column1 = 21
update table_0 set column17 = 459083 where column1 = 21
update table_5 set column5 = 3647 where column1 = 51
update table_7 set column16 = 903025 where column1 = 4
update table_1 set column19 = 671391 where column1 = 45
update table_5 set column11 = 18043 where column1 = 19
update table_4 set column13 = 429171 where column1 = 85
update table_9 set column13 = 942572 where column1 = 2
update table_4 set column2 = 671114 where column1 = 86
update table_8 set column7 = 665703 where column1 = 10
update table_0 set column9 = 762177 where column1 = 49
update table_1 set column10 = 111026 where column1 = 83
update table_2 set column8 = 508645 where column1 = 10
update table_0 set column10 = 361385 where column1 = 97
update table_1 set column6 = 64243 where column1 = 75
update table_5 set column8 = 344340 where column1 = 55
update table_9 set column12 = 385625 where column1 = 66
update table_9 set column15 = 23465 where column1 = 38
update table_8 set column17 = 188323 where column1 = 34
update table_7 set column13 = 531745 where column1 = 10
update table_9 set column17 = 309512 where column1 = 10
update table_5 set column17 = 313206 where column1 = 30
update table_7 set column12 = 437805 where column1 = 12
update table_3 set column16 = 46188 where column1 = 3
update table_5 set column2 = 318971 where column1 = 9
update table_0 set column20 = 47280 where column1 = 76
update table_1 set column9 = 730169 where column1 = 30
update table_6 set column15 = 640666 where column1 = 96
update table_9 set column7 = 235289 where column1 = 85
update table_3 set column10 = 848870 where column1 = 44
update table_3 set column19 = 575610 where column1 = 7
update table_5 set column20 = 412410 where column1 = 78
update table_0 set column19 = 685042 where column1 = 47
update table_6 set column2 = 367133 where column1 = 55
update table_0 set column8 = 517738 where column1 = 33
update table_3 set column2 = 796459 where column1 = 74
update table_8 set column13 = 408906 where column1 = 26
update table_2 set column12 = 28640 where column1 = 3
update table_6 set column9 = 746191 where column1 = 21
update table_4 set column4 = 742563 where column1 = 13
update table_9 set column18 = 733588 where column1 = 0
update table_8 set column17 = 115698 where column1 = 58
update table_7 set column7 = 127935 where column1 = 67
update table_7 set column10 = 815766 where column1 = 46
update table_0 set column14 = 854254 where column1 = 58
update table_1 set column8 = 111856 where column1 = 94
update table_7 set column19 = 538479 where column1 = 52
update table_5 set column14 = 792685 where column1 = 15
update table_8 set column12 = 322925 where column1 = 14
update table_6 set column4 = 527943 where column1 = 28
update table_9 set column4 = 173437 where column1 = 56
update table_1 set column6 = 944215 where column1 = 0
update table_9 set column14 = 88373 where column1 = 61
update table_4 set column10 = 387220 where column1 = 63
update table_7 set column9 = 435037 where column1 = 9
update table_9 set column10 = 471706 where column1 = 10
update table_4 set column14 = 828259 where column1 = 53
update table_7 set column13 = 906062 where column1 = 48
update table_8 set column8 = 8348 where column1 = 73
update table_7 set column20 = 793536 where column1 = 70
update table_7 set column5 = 783080 where column1 = 15
update table_0 set column5 = 999397 where column1 = 24
update table_7 set column3 = 156747 where column1 = 83
update table_3 set column2 = 504945 where column1 = 68
update table_1 set column5 = 775965 where column1 = 21
update table_3 set column17 = 143651 where column1 = 59
update table_0 set column4 = 685014 where column1 = 80
update table_1 set column6 = 639259 where column1 = 2
update table_4 set column11 = 562859 where column1 = 32
update table_5 set column19 = 277524 where column1 = 81
update table_3 set column7 = 81624 where column1 = 47
update table_1 set column7 = 760507 where column1 = 36
update table_6 set column2 = 61897 where column1 = 87
update table_9 set column14 = 575157 where column1 = 34
update table_8 set column6 = 595992 where column1 = 63
update table_5 set column14 = 448481 where column1 = 80
update table_1 set column14 = 623185 where column1 = 90
update table_3 set column9 = 508026 where column1 = 77
update table_4 set column4 = 145495 where column1 = 80
update table_0 set column16 = 388788 where column1 = 58
update table_5 set column18 = 166772 where column1 = 75
update table_5 set column13 = 397536 where column1 = 20
update table_9 set column14 = 936636 where column1 = 19
update table_6 set column11 = 610865 where column1 = 17
update table_3 set column16 = 999397 where column1 = 99
update table_3 set column8 = 343344 where column1 = 42
update table_0 set column8 = 732019 where column1 = 6
update table_3 set column13 = 339872 where column1 = 6
update table_4 set column6 = 879193 where column1 = 79
update table_3 set column11 = 301346 where column1 = 64
update table_3 set column2 = 152279 where column1 = 42
update table_1 set column10 = 802933 where column1 = 99
update table_1 set column14 = 446846 where column1 = 5
update table_9 set column16 = 436692 where column1 = 6
update table_6 set column17 = 659295 where column1 = 44
update table_3 set column10 = 63663 where column1 = 78
update table_8 set column5 = 616421 where column1 = 13
update table_6 set column19 = 518170 where column1 = 12
update table_9 set column17 = 440814 where column1 = 51
update table_7 set column13 = 690477 where column1 = 13
update table_5 set column14 = 373829 where column1 = 64
update table_7 set column10 = 549912 where column1 = 71
update table_8 set column6 = 677548 where column1 = 32
update table_2 set column19 = 835193 where column1 = 42
update table_7 set column4 = 372456 where column1 = 91
update table_1 set column5 = 312781 where column1 = 54
update table_9 set column15 = 680206 where column1 = 37
update table_2 set column8 = 495529 where column1 = 28
update table_5 set column19 = 502596 where column1 = 22
update table_1 set column8 = 62122 where column1 = 88
update table_7 set column2 = 139410 where column1 = 29
update table_9 set column15 = 524326 where column1 = 40
update table_6 set column2 = 381452 where column1 = 34
update table_7 set column13 = 356847 where column1 = 59
update table_4 set column16 = 257105 where column1 = 94
update table_5 set column13 = 296985 where column1 = 98
update table_0 set column9 = 340805 where column1 = 36
update table_8 set column11 = 544030 where column1 = 17
update table_4 set column7 = 358546 where column1 = 45
update table_9 set column2 = 227497 where column1 = 44
update table_8 set column16 = 676131 where column1 = 46
update table_7 set column5 = 621538 where column1 = 13
update table_0 set column7 = 356078 where column1 = 89
update table_9 set column5 = 786160 where column1 = 1
update table_0 set column6 = 202351 where column1 = 9
update table_0 set column6 = 997075 where column1 = 13
update table_8 set column9 = 390115 where column1 = 31
update table_2 set column14 = 466995 where column1 = 25
update table_4 set column16 = 176004 where column1 = 46
update table_6 set column12 = 459877 where column1 = 35
update table_9 set column10 = 831492 where column1 = 60
update table_4 set column7 = 73344 where column1 = 16
update table_8 set column12 = 24388 where column1 = 71
update table_3 set column6 = 182523 where column1 = 34
update table_7 set column19 = 676018 where column1 = 95
update table_4 set column13 = 28569 where column1 = 6
update table_9 set column10 = 478990 where column1 = 17
update table_1 set column15 = 618264 where column1 = 39
update table_9 set column20 = 371173 where column1 = 92
update table_2 set column7 = 644199 where column1 = 78
update table_9 set column19 = 184883 where column1 = 50
update table_8 set column15 = 618866 where column1 = 11
update table_9 set column20 = 135995 where column1 = 54
update table_5 set column7 = 12818 where column1 = 88
update table_7 set column6 = 663794 where column1 = 3
update table_7 set column17 = 345482 where column1 = 23
update table_6 set column17 = 501312 where column1 = 32
update table_0 set column7 = 708534 where column1 = 85
update table_2 set column15 = 549793 where column1 = 85
update table_3 set column12 = 240637 where column1 = 56
update table_1 set column7 = 64704 where column1 = 28
update table_6 set column5 = 723855 where column1 = 22
update table_7 set column2 = 862614 where column1 = 55
update table_8 set column20 = 639780 where column1 = 14
update table_2 set column10 = 728965 where column1 = 11
update table_4 set column9 = 246618 where column1 = 56
update table_5 set column8 = 977337 where column1 = 69
update table_7 set column10 = 945389 where column1 = 76
update table_5 set column15 = 327011 where column1 = 62
update table_2 set column16 = 62907 where column1 = 83
update table_0 set column13 = 17435 where column1 = 54
update table_9 set column18 = 153903 where column1 = 23
update table_6 set column3 = 688273 where column1 = 7
update table_9 set column5 = 500545 where column1 = 23
update table_7 set column6 = 696113 where column1 = 52
update table_3 set column8 = 324950 where column1 = 23
update table_4 set column17 = 28706 where column1 = 59
update table_3 set column9 = 525126 where column1 = 77
update table_4 set column19 = 860968 where column1 = 22
update table_1 set column8 = 438346 where column1 = 79
update table_5 set column19 = 734985 where column1 = 72
update table_3 set column17 = 266067 where column1 = 49
update table_7 set column6 = 784303 where column1 = 21
update table_0 set column17 = 532119 where column1 = 47
update table_7 set column7 = 8725 where column1 = 21
update table_5 set column10 = 55554 where column1 = 3
update table_9 set column10 = 633735 where column1 = 44
update table_3 set column4 = 873045 where column1 = 52
update table_6 set column4 = 736621 where column1 = 19
update table_7 set column10 = 101996 where column1 = 15
update table_7 set column14 = 415424 where column1 = 78
update table_8 set column17 = 881933 where column1 = 68
update table_8 set column4 = 292021 where column1 = 88
update table_5 set column12 = 868178 where column1 = 66
update table_6 set column19 = 710605 where column1 = 94
update table_0 set column19 = 625435 where column1 = 79
update table_9 set column15 = 106962 where column1 = 36
update table_2 set column13 = 80013 where column1 = 24
update table_7 set column14 = 708823 where column1 = 63
update table_9 set column4 = 973570 where column1 = 66
update table_0 set column16 = 648998 where column1 = 24
update table_0 set column3 = 443201 where column1 = 95
update table_4 set column7 = 840323 where column1 = 54
update table_5 set column20 = 581886 where column1 = 60
update table_0 set column20 = 270789 where column1 = 75
update table_4 set column6 = 210208 where column1 = 56
update table_4 set column14 = 755728 where column1 = 8
update table_8 set column13 = 471644 where column1 = 45
update table_7 set column6 = 116483 where column1 = 0
update table_8 set column6 = 899388 where column1 = 72
update table_4 set column15 = 536133 where column1 = 48
update table_7 set column18 = 542734 where column1 = 75
update table_6 set column6 = 291113 where column1 = 46
update table_9 set column10 = 795963 where column1 = 58
update table_0 set column13 = 32086 where column1 = 58
update table_7 set column10 = 618914 where column1 = 59
update table_3 set column8 = 18140 where column1 = 62
update table_5 set column8 = 309340 where column1 = 86
update table_5 set column20 = 204313 where column1 = 56
update table_1 set column16 = 92869 where column1 = 36
update table_8 set column7 = 650244 where column1 = 5
update table_1 set column14 = 872331 where column1 = 0
update table_3 set column7 = 426402 where column1 = 20
update table_8 set column10 = 930580 where column1 = 35
update table_9 set column17 = 689255 where column1 = 5
update table_3 set column13 = 766401 where column1 = 39
update table_7 set column18 = 705512 where column1 = 70
update table_5 set column14 = 365678 where column1 = 4
update table_5 set column17 = 397972 where column1 = 31
update table_8 set column16 = 150966 where column1 = 39
update table_1 set column9 = 352857 where column1 = 93
update table_1 set column16 = 350107 where column1 = 40
update table_2 set column3 = 389842 where column1 = 43
update table_0 set column7 = 287361 where column1 = 17
update table_7 set column16 = 580020 where column1 = 45
update table_4 set column20 = 131300 where column1 = 67
update table_9 set column20 = 783505 where column1 = 90
update table_3 set column9 = 994883 where column1 = 11
update table_4 set column6 = 378589 where column1 = 24
update table_4 set column2 = 75608 where column1 = 23
update table_8 set column19 = 313677 where column1 = 69
update table_0 set column14 = 480840 where column1 = 61
update table_0 set column17 = 481938 where column1 = 67
update table_9 set column2 = 537183 where column1 = 37
update table_6 set column16 = 219929 where column1 = 47
update table_3 set column5 = 758366 where column1 = 0
update table_2 set column15 = 202150 where column1 = 40
update table_3 set column19 = 32086 where column1 = 11
update table_0 set column17 = 651540 where column1 = 16
update table_5 set column3 = 810929 where column1 = 76
update table_1 set column3 = 775724 where column1 = 6
update table_3 set column7 = 215874 where column1 = 20
update table_0 set column17 = 201870 where column1 = 47
update table_1 set column19 = 617355 where column1 = 57
update table_4 set column5 = 562081 where column1 = 2
update table_4 set column16 = 335163 where column1 = 86
update table_8 set column6 = 661943 where column1 = 27
update table_0 set column3 = 328658 where column1 = 14
update table_4 set column12 = 227237 where column1 = 18
update table_6 set column11 = 17792 where column1 = 59
update table_8 set column16 = 589757 where column1 = 92
update table_0 set column16 = 420372 where column1 = 44
update table_9 set column17 = 28473 where column1 = 0
update table_4 set column3 = 660465 where column1 = 67
update table_9 set column20 = 180325 where column1 = 95
update table_0 set column12 = 578744 where column1 = 29
update table_0 set column16 = 750046 where column1 = 14
update table_0 set column15 = 238552 where column1 = 16
update table_8 set column8 = 825480 where column1 = 97
update table_3 set column11 = 974360 where column1 = 77
update table_6 set column7 = 955877 where column1 = 40
update table_5 set column13 = 771691 where column1 = 51
update table_8 set column11 = 804491 where column1 = 41
update table_0 set column10 = 340239 where column1 = 75
update table_7 set column10 = 376261 where column1 = 72
update table_7 set column6 = 922315 where column1 = 3
update table_5 set column12 = 217553 where column1 = 84
update table_2 set column9 = 432782 where column1 = 61
update table_8 set column5 = 241781 where column1 = 91
update table_6 set column4 = 572514 where column1 = 92
update table_9 set column14 = 459819 where column1 = 92
update table_7 set column5 = 106137 where column1 = 25
update table_9 set column13 = 828499 where column1 = 28
update table_1 set column6 = 887209 where column1 = 7
update table_1 set column7 = 698620 where column1 = 26
update table_5 set column16 = 481634 where column1 = 93
update table_5 set column15 = 707400 where column1 = 92
update table_4 set column5 = 217193 where column1 = 90
update table_7 set column11 = 2606 where column1 = 70
update table_2 set column20 = 903899 where column1 = 3
update table_5 set column3 = 835850 where column1 = 97
update table_4 set column2 = 407507 where column1 = 99
update table_1 set column9 = 755299 where column1 = 72
update table_8 set column11 = 239387 where column1 = 44
update table_8 set column17 = 507781 where column1 = 97
update table_7 set column15 = 457963 where column1 = 7
update table_7 set column8 = 228561 where column1 = 3
update table_9 set column8 = 498586 where column1 = 52
update table_7 set column13 = 820007 where column1 = 31
update table_6 set column4 = 241675 where column1 = 40
update table_4 set column12 = 79969 where column1 = 41
update table_2 set column8 = 396582 where column1 = 29
update table_0 set column9 = 138897 where column1 = 34
update table_1 set column14 = 137731 where column1 = 57
update table_9 set column9 = 438757 where column1 = 89
update table_6 set column15 = 85335 where column1 = 92
update table_2 set column16 = 970126 where column1 = 50
update table_8 set column18 = 439846 where column1 = 69
update table_9 set column2 = 551112 where column1 = 18
update table_4 set column13 = 40251 where column1 = 62
update table_4 set column20 = 717309 where column1 = 18
update table_8 set column9 = 410009 where column1 = 0
update table_6 set column4 = 650569 where column1 = 69
update table_4 set column18 = 824815 where column1 = 14
update table_4 set column15 = 877456 where column1 = 77
update table_2 set column13 = 510125 where column1 = 72
update table_4 set column11 = 119749 where column1 = 32
update table_2 set column15 = 999746 where column1 = 44
update table_9 set column6 = 85414 where column1 = 50
update table_9 set column6 = 967792 where column1 = 75
update table_2 set column2 = 96717 where column1 = 90
update table_6 set column20 = 463087 where column1 = 0
update table_0 set column20 = 223169 where column1 = 46
update table_5 set column7 = 70612 where column1 = 66
update table_6 set column12 = 636891 where column1 = 60
update table_9 set column5 = 63231 where column1 = 43
update table_4 set column19 = 30006 where column1 = 3
update table_0 set column13 = 408769 where column1 = 27
update table_5 set column13 = 614034 where column1 = 94
update table_7 set column3 = 690097 where column1 = 99
update table_0 set column15 = 898084 where column1 = 15
update table_4 set column20 = 279540 where column1 = 0
update table_0 set column5 = 824833 where column1 = 24
update table_0 set column12 = 646491 where column1 = 10
update table_2 set column16 = 107663 where column1 = 4
update table_8 set column11 = 100978 where column1 = 0
update table_2 set column11 = 130557 where column1 = 89
update table_0 set column3 = 673782 where column1 = 57
update table_5 set column7 = 310381 where column1 = 23
update table_2 set column15 = 522297 where column1 = 2
update table_6 set column20 = 862989 where column1 = 20
update table_0 set column14 = 517251 where column1 = 64
update table_5 set column14 = 808636 where column1 = 54
update table_3 set column11 = 945355 where column1 = 80
update table_3 set column18 = 276833 where column1 = 15
update table_9 set column7 = 244485 where column1 = 64
update table_8 set column3 = 132513 where column1 = 43
update table_7 set column11 = 661906 where column1 = 52
update table_2 set column18 = 997309 where column1 = 54
update table_5 set column20 = 387533 where column1 = 82
update table_7 set column5 = 703370 where column1 = 45
update table_9 set column20 = 661000 where column1 = 22
update table_7 set column2 = 517949 where column1 = 81
update table_3 set column10 = 479576 where column1 = 97
update table_8 set column3 = 578632 where column1 = 79
update table_4 set column4 = 759386 where column1 = 37
update table_5 set column18 = 303100 where column1 = 62
update table_5 set column7 = 82389 where column1 = 53
update table_2 set column9 = 280317 where column1 = 84
update table_6 set column5 = 425223 where column1 = 6
update table_8 set column16 = 914157 where column1 = 51
update table_8 set column7 = 919841 where column1 = 8
update table_8 set column19 = 302597 where column1 = 61
update table_6 set column16 = 780223 where column1 = 16
update table_5 set column10 = 125208 where column1 = 36
update table_2 set column18 = 824257 where column1 = 61
update table_4 set column9 = 151609 where column1 = 94
update table_0 set column3 = 601421 where column1 = 11
update table_8 set column11 = 17682 where column1 = 14
update table_5 set column2 = 589335 where column1 = 45
update table_3 set column11 = 466128 where column1 = 51
update table_7 set column16 = 856054 where column1 = 45
update table_7 set column19 = 387421 where column1 = 48
GO

USE [ApexSQLLogDEMO]
GO

/****** Object:  Table [dbo].[table_8]    Script Date: 05-Nov-14 22:55:43 ******/
DROP TABLE [dbo].[table_9]
GO

USE [ApexSQLLogDEMO]
GO

/****** Object:  Table [dbo].[table_8]    Script Date: 05-Nov-14 21:58:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[table_9_2](
	[column1] [int] IDENTITY(1,1) NOT NULL,
	[column2] [int] NULL,
	[column3] [int] NULL,
	[column4] [int] NULL,
	[column5] [int] NULL,
	[column6] [int] NULL,
	[column7] [int] NULL,
	[column8] [int] NULL,
	[column9] [int] NULL,
	[column10] [int] NULL,
	[column11] [int] NULL,
	[column12] [int] NULL,
	[column13] [int] NULL,
	[column14] [int] NULL,
	[column15] [int] NULL,
	[column16] [int] NULL,
	[column17] [int] NULL,
	[column18] [int] NULL,
	[column19] [int] NULL,
	[column20] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[column1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO





