--aşağıdakı insert-i edə biləcəyimiz Category cədvəlinin yaradılması

create database [SQLHomeWork2]
use [SQLHomeWork2]
go

create table [dbo].[Category](
[Id] int primary key identity,
[Name] nvarchar(100) not null)
go

insert into [dbo].[Category] ([Name])
values (N'Audio,Video')
,(N'Komputer ve ofis avadanligi')
,(N'Plansetler')
,(N'Telefonlar, saatlar ve nomreler');
go

select * from [dbo].[Category]
go




--aşağıdakı inserti edə biləcəyimiz Product cədvəlini yaratmalı

create table [dbo].[Products](
[Id] int primary key identity,
[Name] nvarchar(100) not null,
[Description] nvarchar(100),
[CategoryId] int not null,
[CreatedDate] datetime default(getdate()) )
go

insert into [dbo].[Products](
[Name], [Description], [CategoryId], [CreatedDate])
values (N'Wonlex GW100 Pink', NULL, 4, '2019-09-15')
    ,(N'Wonlex Q50 Charisma BLACK', NULL, 4, '2019-09-15')
    ,(N'Samsung Galaxy S10 Dual (SM-G973) White', NULL, 4, '2019-09-15')
    ,(N'Xiaomi Mi A3 4/128GB White', NULL, 4, '2019-09-15')
    ,(N'Blackview BV1000 yellow', NULL, 4, '2019-09-15')
    ,(N'Huawei Y9 2019 4/64GB Red', NULL, 4, '2019-09-15')
    ,(N'FLY TS114 BLACK', NULL, 4, '2019-09-15')
    ,(N'Blackview BV5500 Pro yellow', NULL, 4, '2019-09-15')
    ,(N'Lenovo TB 7104I/3G -Wi-Fi/7 BLACK', NULL, 3, '2019-09-15')
    ,(N'Samsung Galaxy Tab A 8.0 (SM-T295) Black', NULL, 3, '2019-09-15')
    ,(N'Lenovo TAB E10 TB-X104F/10.1 BLACK', NULL, 3, '2019-09-15')
    ,(N'Lenovo TAB 4 10 LTE (TB-X304L) black', NULL, 3, '2019-09-15')
    ,(N'Samsung Galaxy Tab A (SM-T385) GOLD', NULL, 3, '2019-09-15')
    ,(N'Huawei M5 Lite 3+32 Space Grey', NULL, 3, '2019-09-15')
    ,(N'Apple MacBook Air 13″ MVFK2', NULL, 2, '2019-09-15')
    ,(N'Apple MacBook Air 13″ MVFH2', NULL, 2, '2019-09-15')
    ,(N'Monoblok HP ENVY 27-B170ur i7/16/nv4/1tb128/win10', NULL, 2, '2019-09-15')
    ,(N'Noutbuk Asus Tuf Gaming FX505DD BQ121 ', NULL, 2, '2019-09-15')
    ,(N'Noutbuk Acer Predator Helios 300 PH315-52-718G ', NULL, 2, '2019-09-15')
    ,(N'Musiqi merkezi SONY MHC-V82D', NULL, 1, '2019-09-15')
    ,(N'Speaker Sony SRS-XB21 Wireless', NULL, 1, '2019-09-15')
    ,(N'JBL Pulse 3 Black', NULL, 1, '2019-09-15');
	go

select * from [dbo].[Products]
go



--bir prosedur yazın product əlavə etmək üçün

create procedure dbo.spProductInsert
@productName nvarchar(100),
@productDescription nvarchar(100),
@categoryName nvarchar(100)

as
begin
set nocount on;

declare @categoryId int
select @categoryId=[Id] from [dbo].[Category] where [Name]=@categoryName;
if @categoryId is null

begin

insert into [dbo].[Category]([Name])
values (@categoryName)
set @categoryId = SCOPE_IDENTITY()
end

insert into [dbo].[Products]
([Name], [Description], [CategoryId])
values (@productName, @productDescription, @categoryId)

end

go


exec dbo.spProductInsert @productName='HTC', @productDescription=NULL, @categoryName='Plansetler'

exec dbo.spProductInsert @productName='Apple', @productDescription=NULL, @categoryName='Watch'

select * from [dbo].[Products]

select * from [dbo].[Category]

go


--prosedurda yoxlamaq lazımdır ki eyni adli product varsa yeniden insert etmek olmasın

alter procedure dbo.spProductInsert
@productName nvarchar(100),
@productDescription nvarchar(100),
@categoryName nvarchar(100)

as
begin
set nocount on;

declare @productId int
select @productId=[Id] from [dbo].[Products] where [Name]=@productName;
if @productId is null

begin

declare @categoryId int
select @categoryId=[Id] from [dbo].[Category] where [Name]=@categoryName;
if @categoryId is null

begin

insert into [dbo].[Category]([Name])
values (@categoryName)
set @categoryId = SCOPE_IDENTITY()
end

insert into [dbo].[Products]
([Name], [Description], [CategoryId])
values (@productName, @productDescription, @categoryId)

end
end

go

exec dbo.spProductInsert @productName='HTC', @productDescription=NULL, @categoryName='Plansetler'

exec dbo.spProductInsert @productName='Nokia', @productDescription=NULL, @categoryName='Watch'

select * from [dbo].[Products]

select * from [dbo].[Category]

go



--productun silinmesi ucun de bir prosedur yaradin, hansi ki product silinende arxive dussun silinme tarixi ile

create table [Archive].[Products](
[Id] int primary key,
[Name] nvarchar(100) not null,
[Description] nvarchar(100),
[CategoryId] int not null,
[ArchivedDate] datetime default(getdate()))
go



create procedure dbo.spDeleteProduct
@productId int
as
begin
set XACT_ABORT on;
set nocount on;

begin try
begin tran transaction_dbo_spDeleteProduct
insert into [Archive].[Products]([Id], [Name], [Description], [CategoryId])
select [Id], [Name], [Description], [CategoryId]
from [dbo].[Products] where Id=@productId

delete from [dbo].[Products] where Id=@productId

commit
end try

begin catch
rollback

select ERROR_MESSAGE() [Error Message], ERROR_LINE() [Error Line], ERROR_NUMBER() [Error Number]

end catch
end
go


execute dbo.spDeleteProduct @productId = 1

select * from [dbo].[Products]

select * from [dbo].[Category]




--productun update edilmesini de insert proseduruna oxsar bir prosedurla tamamlayin


alter procedure dbo.spUpdateProduct
@productId int,
@productName nvarchar(100),
@productDescription nvarchar(100),
@categoryName nvarchar(100)
as
begin
set XACT_ABORT on;
set nocount on;

begin try
begin tran transaction_dbo_spUpdateProduct
insert into [Archive].[Products]([Id], [Name], [Description], [CategoryId])
select [Id], [Name], [Description], [CategoryId]
from [dbo].[Products] where Id=@productId

--delete from [dbo].[Products] where Id=@productId

declare @categoryId int
select @categoryId=[Id] from [dbo].[Category] where [Name]=@categoryName;
if @categoryId is null

begin

insert into [dbo].[Category]([Name])
values (@categoryName)
set @categoryId = SCOPE_IDENTITY()
end

update [dbo].[Products]
set [Name]=@productName,
[Description]=@productDescription,
[CategoryId]=@categoryId
where [Id]=@productId



commit
end try

begin catch
rollback

select ERROR_MESSAGE() [Error Message], ERROR_LINE() [Error Line], ERROR_NUMBER() [Error Number]

end catch
end
go




execute dbo.spUpdateProduct @productId=3, @productName='Gurbantech', @productDescription='Null',@categoryName='Qabyuyan'

select * from [dbo].[Products]
select * from [dbo].[Category]
select * from [Archive].[Products]
go


create view dbo.[VwProducts]
as
select
p.Id
,p.[Name]
,p.[Description]
,p.[CategoryId]
,c.[Name] [CategoryName]
,p.[CreatedDate]

from [dbo].[Products] p
full outer join [dbo].[Category] c
on p.[Id]=c.[Id]


select * from [dbo].[VwProducts]