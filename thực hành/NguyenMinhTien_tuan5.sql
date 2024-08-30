--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
--thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
go 
create procedure pr_tongThu @maKH int, @thang int , @nam int
as
declare @totalDue money 
set @totalDue = ( select Sum(TotalDue)
from sales.SalesOrderHeader
where CustomerID = @maKH and YEAR(OrderDate) = @nam and month(OrderDate) = @thang
group by CustomerID )

print 'tong doanh thu cua khach hang ' + convert(char(10),@makh) + ' trong thang '+ convert(char(10),@thang)
	+' nam ' + convert(char(10),@nam) + ' la '+ convert(char(10),@totaldue)
go
exec pr_tongThu 14324,3,2007
drop proc pr_tongThu
go
--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
--@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục

select * from sales.SalesPerson
go
create proc pr_doanThu @salesPerson int, @salesYTD money OUTPUT
as
begin
	select @salesYTD = SalesYTD
	from [Sales].[SalesPerson]
	where @salesPerson = BusinessEntityID
	print concat('doanh thu cua nhan vien ',@salesPerson,' la ',@salesYTD)
end
go

declare @salesYTD money
exec pr_doanThu 281,@salesYTD OUTPUT
go
drop proc pr_doanThu
go
--3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).

go
create proc pr_giaSP @maxPrice money
as
begin
	select ProductID, ListPrice
	from Production.Product
	where ListPrice <= @maxPrice
end
go
exec pr_giaSP 10000000

go
drop proc pr_giaSP
go
--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--SumOfSubTotal =sum(SubTotal)
--NewBonus = Bonus+ sum(SubTotal)*0.01

select *
from Sales.SalesPerson
go
select *
from sales.SalesOrderHeader
go
create proc pr_thuongMoi @manv int 
as
select SalesPersonID , Bonus , SumOfSubTotal =sum(TotalDue) , newbonus = (Bonus+ sum(TotalDue)*0.01)
from Sales.SalesOrderHeader oh join Sales.SalesPerson sp 
	on oh.SalesPersonID = sp.BusinessEntityID
where @manv = SalesPersonID
group by SalesPersonID , Bonus

go 
exec pr_thuongMoi 284
go 
drop proc pr_thuongMoi
go
--* 5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)
select *
from Production.ProductSubcategory
select *
from Production.Product
select *
from Sales.SalesOrderDetail
go

select pc.ProductCategoryID, sum(OrderQty), year(SellStartDate)
from Production.Product p join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	join Sales.SalesOrderDetail od on od.ProductID = p.ProductID join Production.ProductCategory pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.ProductCategoryID, year(SellStartDate)
go

create proc pr_thongTin @nam int 
as
	select top 1 pc.ProductCategoryID, sum(OrderQty)
	from Production.Product p join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
		join Sales.SalesOrderDetail od on od.ProductID = p.ProductID join Production.ProductCategory pc on ps.ProductCategoryID = pc.ProductCategoryID
		where @nam > YEAR(SellStartDate) and @nam < year(SellEndDate)
	group by pc.ProductCategoryID
	order by sum(OrderQty) desc
go

exec pr_thongTin 2006
--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.
go
create proc pr_TongThu @manv int, @total money output
as
begin
	select @total = sum(LineTotal)
	from sales.SalesOrderHeader oh join sales.SalesOrderDetail od
		on od.SalesOrderID = oh.SalesOrderID
	where @manv = SalesPersonID 
	
	if(@total > 0) return 0
	else return 1
end
go
declare @total money
exec pr_TongThu 29825, @total output


drop proc pr_TongThu
go
--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
--năm đã cho.
select *
from Sales.Customer
where CustomerID = 29672
--* 8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not
--null và các field là khóa ngoại.


select *
from Production.Product
go
--'Adjustable Race',	'AR-5381'	,0	,0	,NULL	1000	750	0.00	0.00	NULL	NULL	NULL	NULL	0	NULL	NULL	NULL	NULL	NULL	2008-04-30 00:00:00.000	NULL	NULL	694215B7-08F7-4C0D-ACB1-D734BA44C0C8	2014-02-08 10:01:36.827
--1	Adjustable Race	AR-5381	0	0	NULL	1000	750	0.00	0.00	NULL	NULL	NULL	NULL	0	NULL	NULL	NULL	NULL	NULL	2008-04-30 00:00:00.000	NULL	NULL	694215B7-08F7-4C0D-ACB1-D734BA44C0C8	2014-02-08 10:01:36.827

go
sp_help 'Production.product'		--xem tt not null, default, identiti de kh chen
go
insert Production.product([Name] , [ProductNumber] ,[SafetyStockLevel], [ReorderPoint] ,
 [StandardCost],[ListPrice],[DaysToManufacture],[SellStartDate])
values ( N'Adjustable RaceAAAAA',N'AR-531',2,2,7500,6000,3,GETDATE())
go

create proc pr_InsertProduct  @name nvarchar(50), @productnumber nvarchar(25), @SafetyStockLevel  smallint,
						@ReorderPoint smallint, @StandardCost money, @ListPrice money, @DaysToManufacture int, @SellStartDate datetime
as
insert Production.product ([Name] , [ProductNumber] ,[SafetyStockLevel], [ReorderPoint] ,
	[StandardCost],[ListPrice],[DaysToManufacture],[SellStartDate])
	values ( @name, @productnumber , @SafetyStockLevel  ,
						@ReorderPoint , @StandardCost , @ListPrice , @DaysToManufacture , @SellStartDate )
go

exec pr_InsertProduct N'Adjustable RaceAAAAA',N'AR-531',2,2,7500,6000,3,GETDATE()


--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong
--Sales.SalesOrderDetail.
select *
from sales.SalesOrderHeader
go
select *
from sales.SalesOrderDetail
go
sp_help 'sales.SalesOrderDetail'
go
--delete sales.SalesOrderDetail		--vi co cascade nen khong phai xoa
--where SalesOrderID = 43659
go
delete sales.SalesOrderHeader
where SalesOrderID = 43659
go

create proc pr_xoaHD @mahd int 
as
	delete sales.SalesOrderHeader
	where SalesOrderID = @mahd
	
go
exec pr_xoaHD 43659
go
drop proc pr_xoaHD

--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice
--lên 10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm
--này

go
select *
from Production.Product
go
update Production.Product
	set ListPrice = ListPrice*1.1
	where ProductID = 1
go
create proc  Sp_Update_Product  @productid int
	as
	if exists ( select * from Production.Product where ProductID = @productid)
		update Production.Product
			set ListPrice = ListPrice*1.1
			where ProductID = @productid
	else
		print concat(' khong co sp ' , @productid)
go
exec Sp_Update_Product  1
exec Sp_Update_Product  1000
go
drop proc Sp_Update_Product

--7