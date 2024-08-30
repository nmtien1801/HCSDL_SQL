--1. Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
go
create view vw_Products
as 
select pp.ProductID, Name, Color, Size, Style, pp.StandardCost, EndDate, StartDate
from Production.Product pp join Production.ProductCostHistory chp on pp.ProductID = chp.ProductID

select * from vw_Products


--2. Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal.
 go
 create view vw_List_Product_View
 as 
 select pp.ProductID,Product_Name = name, CountOfOrderID = count(ohs.SalesOrderID), SubTotal =sum(UnitPrice*OrderQty*(1-UnitPriceDiscount))
 from [Sales].[SalesOrderHeader] ohs join [Sales].[SalesOrderDetail] ods on ohs.SalesOrderID = ods.SalesOrderID
	join [Production].[Product] pp on pp.ProductID = ods.ProductID
 where datepart(qq,OrderDate) = 1 and year(OrderDate)=2008
 group by pp.ProductID,name
 having sum(LineTotal) > 10000 and count(ohs.SalesOrderID) > 500

 select * from vw_List_Product_View

 --3. Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
--OrderMonth, SUM(TotalDue).

go
create view vw_CustomerTotals
as 
select Cs.CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) as total
from [Sales].[Customer] cs join [Sales].[SalesOrderHeader] ohs on cs.CustomerID = ohs.CustomerID
group by  Cs.CustomerID, YEAR(OrderDate) , MONTH(OrderDate)

select * from vw_CustomerTotals

--4. Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty

go
create view vw_Total_Quantit
as
select SalesPersonID, OrderYear = year(OrderDate), sumOfOrderQty = sum(SalesOrderID)
from [Sales].[SalesOrderHeader] 
group by SalesPersonID, year(OrderDate)

select * from vw_Total_Quantit
go

--5. Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).

go
create view vw_ListCustomer_view
as
select PersonID, FirstName +' '+ LastName as FullName, CountOfOrders = count(SalesOrderID)
from [Sales].[SalesOrderHeader] ohs join [Sales].[Customer] cs on cs.CustomerID = ohs.CustomerID
	join Person.Person pp on pp.BusinessEntityID = cs.PersonID
where YEAR(OrderDate) in (2007,2008)
group by PersonID, FirstName +' '+ LastName
having count(SalesOrderID) >25

select * from vw_ListCustomer_view

--6. Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
--tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
--Production.Product)

go 
create view vw_ListProduct_view
as  
SELECT pp.ProductID, pp.Name, SumOfOrderQty = sum(OrderQty), Year(OrderDate) as year
FROM     Production.Product pp JOIN
                  Sales.SalesOrderDetail od ON pp.ProductID = od.ProductID INNER JOIN
                  Sales.SalesOrderHeader oh ON oh.SalesOrderID = od.SalesOrderID
				  join Production.ProductSubcategory psc on psc.ProductSubcategoryID =pp.ProductSubcategoryID
where (psc.Name like 'Bike%') or psc.name like 'Sport%'
group by pp.ProductID, pp.Name, Year(OrderDate)
having sum(OrderQty) > 50
go
select * from vw_ListProduct_view 
go
--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].
create view vw_List_department_View
as
select dp.DepartmentID, Name, AvgOfRate = avg(Rate)
from HumanResources.Department dp join HumanResources.EmployeeDepartmentHistory  dph
	on dp.DepartmentID = dph.DepartmentID join HumanResources.Employee emp 
	on emp.BusinessEntityID = dph.BusinessEntityID join HumanResources.EmployeePayHistory emph
	on emph.BusinessEntityID = emp.BusinessEntityID
group by dp.DepartmentID, Name
having avg(rate) > 30

--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này **
go
create view vw_Sales_vw_OrderSummary
WITH ENCRYPTION			-- ngan kh cho NSD xem cau len dinh nghia
as 
select OrderYear = year(OrderDate) , OrderMonth = month(OrderDate), OrderTotal = sum(LineTotal)
from sales.SalesOrderHeader oh join sales.SalesOrderDetail od 
	on oh.SalesOrderID = od.SalesOrderID
group by year(OrderDate) , month(OrderDate)

select * from vw_Sales_vw_OrderSummary

--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
--Product. Có xóa được không? Vì sao?

go
create view vw_Production_vwProducts
WITH SCHEMABINDING			
as
select pp.ProductID, Name, StartDate,EndDate,ListPrice
from Production.Product pp join Production.ProductCostHistory pch 
	on pch.ProductID = pp.ProductID

alter view vw_Production_vwProducts			--khong the xoa hoac cap nhap
DROP COLUMN ListPrice


go

--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
go
create view vw_view_Department
as 
select DepartmentID, Name, GroupName
from HumanResources.Department
where GroupName like 'Manufacturing' or GroupName like 'Quality Assurance' 
WITH CHECK OPTION			--Kiểm tra nếu một dòng dữ liệu không
						--thuộc vào view nữa thì sẽ không được cập nhật dữ liệu thông qua view.
--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--chèn được không? Giải thích.
insert into vw_view_Department(DepartmentID, Name, GroupName)
values (9, N'Production2', N'Manufacturing')	
		--khong chen duoc vi co with check option

--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
--phòng thuộc nhóm “Quality Assurance”.
--c. Dùng câu lệnh Select xem kết quả trong bảng Department.
select * from vw_view_Department