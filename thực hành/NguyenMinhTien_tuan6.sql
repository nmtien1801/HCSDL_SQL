--1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb,
--giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong
--phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
--phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
--Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--(Dữ liệu lấy từ bảng
--[HumanResources].[EmployeeDepartmentHistory] và
--[HumanResources].[Department])
go
select * from [HumanResources].[EmployeeDepartmentHistory]
select * from [HumanResources].[Department]

select d.[DepartmentID],Name, countOfEmp= Count(BusinessEntityID) 
from [HumanResources].[Department] d join [HumanResources].[EmployeeDepartmentHistory] ed 
		on d.DepartmentID = ed.DepartmentID
group by d.[DepartmentID],Name

go
create function CountOfEmployees(@mapb int ) 
returns table
as
	return (
		select d.[DepartmentID],Name, countOfEmp= Count(BusinessEntityID) 
		from [HumanResources].[Department] d join [HumanResources].[EmployeeDepartmentHistory] ed 
			on d.DepartmentID = ed.DepartmentID
		where @mapb = d.[DepartmentID]
		group by d.[DepartmentID],Name
	)
go
select * from CountOfEmployees(7)
go
drop function CountOfEmployees
go
--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])
go
select * from Production.ProductInventory
select ProductID,Quantity from Production.ProductInventory
go
create function InventoryProd(@ProductID int, @LocationID int)
returns int
as
begin
	declare @slTon int 
	select @slTon = sum(Quantity)
	from Production.ProductInventory
	group by ProductID
	return @slTon
end
go
select dbo.InventoryProd(1,1) 
go
drop function InventoryProd
go
--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
go
select * from [Sales].[SalesOrderHeader]

go
create function SubTotalOfEmp(@EmplID int, @MonthOrder int, @YearOrder int)	
returns int	
as
begin
	declare @tong int
	select @tong = sum(TotalDue) 
	from [Sales].[SalesOrderHeader]
	where SalesPersonID = @EmplID and MONTH(OrderDate) = @MonthOrder and YEAR(OrderDate) = @YearOrder
	return @tong
end
go
select total = dbo.SubTotalOfEmp(279,7,2005)
go
drop function SubTotalOfEmp
go
	


--4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
select * from sales.SalesOrderDetail
select * from sales.SalesOrderHeader

select od.SalesOrderID ,OrderDate, sum(LineTotal) 
from sales.SalesOrderDetail od join sales.SalesOrderHeader o 
	on od.SalesOrderID = o.SalesOrderID
group by od.SalesOrderID,OrderDate
having sum(LineTotal) > 70000

go
create function SumOfOrder(@thang int , @nam int)
returns table
as
	return (
		select od.SalesOrderID , OrderDate, total = sum(LineTotal) 
		from sales.SalesOrderDetail od join sales.SalesOrderHeader o 
			on od.SalesOrderID = o.SalesOrderID
		where month(OrderDate) = @thang and year(OrderDate) = @nam
		group by od.SalesOrderID, OrderDate
		having sum(LineTotal) > 70000
	)
go
select * from dbo.SumOfOrder(8,2005)
go
drop function dbo.SumOfOrder
go
--5**) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01

select * from sales.SalesOrderDetail
select * from sales.SalesOrderHeader
select * from sales.SalesPerson

select oh.SalesPersonID, SumOfSubTotal = sum(SubTotal) , newBonus = bonus + sum(SubTotal) * 0.01  
	from Sales.SalesOrderHeader oh join sales.SalesPerson sp 
		on oh.SalesPersonID = sp.BusinessEntityID
	where 274 = SalesPersonID
	group by oh.SalesPersonID, bonus
go
create function NewBonus(@ma int)
returns table
as
return (
	select oh.SalesPersonID, SumOfSubTotal = sum(SubTotal) , newBonus = bonus + sum(SubTotal) * 0.01  
	from Sales.SalesOrderHeader oh join sales.SalesPerson sp 
		on oh.SalesPersonID = sp.BusinessEntityID
	where @ma = SalesPersonID
	group by oh.SalesPersonID,Bonus
)
go
select * from NewBonus(284)
go
drop function dbo.NewBonus
go
--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID)hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader]
--và [Purchasing].[PurchaseOrderDetail])
select * from [Purchasing].[Vendor]
select * from [Purchasing].[PurchaseOrderHeader]
select * from [Purchasing].[PurchaseOrderDetail]

select ProductID, SumOfProduct = sum(OrderQty), SumOfSubTotal = sum(SubTotal)
from [Purchasing].[Vendor] v join [Purchasing].[PurchaseOrderHeader] o 
		on v.BusinessEntityID = o.VendorID 
		join [Purchasing].[PurchaseOrderDetail]od on od.PurchaseOrderID = o.PurchaseOrderID
group by ProductID

go
create function SumOfProduct(@mancc int)
returns table
as
	return(
		select ProductID, SumOfProduct = sum(OrderQty), SumOfSubTotal = sum(SubTotal)
		from [Purchasing].[Vendor] v join [Purchasing].[PurchaseOrderHeader] o 
				on v.BusinessEntityID = o.VendorID 
				join [Purchasing].[PurchaseOrderDetail]od on od.PurchaseOrderID = o.PurchaseOrderID
		where @mancc = o.VendorID
		group by ProductID
	)
go
select * from dbo.SumOfProduct(1492)
go
--7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID),
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
select * from sales.SalesOrderHeader

select SalesOrderID, SubTotal, Discount = case
	when SubTotal < 1000 then 0
	when SubTotal >= 1000 and SubTotal < 5000 then SubTotal*0.05
	when SubTotal >= 5000 and SubTotal < 10000 then SubTotal*0.1
	when SubTotal >= 10000  then SubTotal*0.15
	end
from sales.SalesOrderHeader

go 
create function Discount_Func()
returns @table table(SalesOrderID int , SubTotal money , Discount money)
as
begin
	insert @table
	select SalesOrderID, SubTotal, Discount = case
		when SubTotal < 1000 then 0
		when SubTotal >= 1000 and SubTotal < 5000 then SubTotal*0.05
		when SubTotal >= 5000 and SubTotal < 10000 then SubTotal*0.1
		when SubTotal >= 10000  then SubTotal*0.15
		end
	from sales.SalesOrderHeader
	return 
end
go
select * from Discount_Func()
go
drop function Discount_Func
go
--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
--Total=Sum([SubTotal])
-- Multi-statement Table Valued Functions:
select * from sales.SalesOrderHeader

select SalesPersonID , sum(SubTotal) 
from sales.SalesOrderHeader
group by SalesPersonID

go
create function TotalOfEmp(@thang int , @nam int)
returns @table table(SalesPersonID int , total money)
as
begin
	insert @table 
	select SalesPersonID , sum(SubTotal) 
	from sales.SalesOrderHeader
	where @thang = month(OrderDate) and @nam = year(OrderDate)
	group by SalesPersonID
	return 
end
go
select * from TotalOfEmp(7,2005)
go
drop function TotalOfEmp
-------------------9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function---------------------

--5.2) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01
select * from sales.SalesOrderDetail
select * from sales.SalesOrderHeader
select * from sales.SalesPerson

select oh.SalesPersonID, SumOfSubTotal = sum(SubTotal) , newBonus = bonus + sum(SubTotal) * 0.01  
	from Sales.SalesOrderHeader oh join sales.SalesPerson sp 
		on oh.SalesPersonID = sp.BusinessEntityID
	where 274 = SalesPersonID
	group by oh.SalesPersonID, bonus

go
create function NewBonus()
returns @table table(ma int,total money, newBonus money)
as
begin
	insert @table
	select oh.SalesPersonID, SumOfSubTotal = sum(SubTotal) , newBonus = bonus + sum(SubTotal) * 0.01  
	from Sales.SalesOrderHeader oh join sales.SalesPerson sp 
		on oh.SalesPersonID = sp.BusinessEntityID
	group by oh.SalesPersonID, bonus
	return
end
go
select * from NewBonus()
go
drop function NewBonus

--6.2) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID)hàm dùng để tính tổng số lượng (SumOfQty) 
--và tổng trị giá (SumOfSubTotal)
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader]
--và [Purchasing].[PurchaseOrderDetail])
select * from [Purchasing].[Vendor]
select * from [Purchasing].[PurchaseOrderHeader]
select * from [Purchasing].[PurchaseOrderDetail]

select ProductID, SumOfProduct = sum(OrderQty), SumOfSubTotal = sum(SubTotal)
from [Purchasing].[Vendor] v join [Purchasing].[PurchaseOrderHeader] o 
		on v.BusinessEntityID = o.VendorID 
		join [Purchasing].[PurchaseOrderDetail]od on od.PurchaseOrderID = o.PurchaseOrderID
group by ProductID

go
create function SumOfProduct(@mancc int)
returns @table table(ProductID int , SumOfProduct int, SumOfSubTotal money)
as
begin
	insert @table
	select ProductID, SumOfProduct = sum(OrderQty), SumOfSubTotal = sum(SubTotal)
	from [Purchasing].[Vendor] v join [Purchasing].[PurchaseOrderHeader] o 
			on v.BusinessEntityID = o.VendorID 
			join [Purchasing].[PurchaseOrderDetail]od on od.PurchaseOrderID = o.PurchaseOrderID
	where @mancc = o.VendorID
	group by ProductID
	return
end
select * from SumOfProduct(1580)  
go
drop function SumOfProduct


go
--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
-- Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết
--quả là bảng lương của nhân viên đó.

select * from Person.Person
select * from HumanResources.Employee
select * from HumanResources.EmployeePayHistory

select p.BusinessEntityID, FName = FirstName, LName = LastName, Salary = rate
from Person.Person p join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID
	join HumanResources.EmployeePayHistory eh on eh.BusinessEntityID = e.BusinessEntityID
go
create function SalaryOfEmp(@manv int)
returns table
as
	return (	
		select p.BusinessEntityID, FName = FirstName, LName = LastName, Salary = rate
		from Person.Person p join HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID
			join HumanResources.EmployeePayHistory eh on eh.BusinessEntityID = e.BusinessEntityID
		where @manv = p.BusinessEntityID
	)


go
select * from SalaryOfEmp(1)
go
drop function SalaryOfEmp
