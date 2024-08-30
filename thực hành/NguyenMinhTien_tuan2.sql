--1. Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng  6  năm 2008  có 
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate,  SubTotal,  trong đó 
--SubTotal  =SUM(OrderQty*UnitPrice)


select  sod.SalesOrderID, OrderDate,   SUM(OrderQty*UnitPrice) as SubTotal  
from [Sales].[SalesOrderDetail] sod join [Sales].[SalesOrderHeader] soh on sod.SalesOrderID = soh.SalesOrderID  
where (month(OrderDate) = 6 and year(OrderDate) = 2008)
group by sod.SalesOrderID, Orderdate
having SUM(OrderQty*UnitPrice) >70000

--2.Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia 
--có  mã  vùng  là  US  (lấy  thông  tin  từ  các  bảng  Sales.SalesTerritory, 
--Sales.Customer,  Sales.SalesOrderHeader,  Sales.SalesOrderDetail).  Thông  tin 
--bao  gồm  TerritoryID,  tổng  số  khách  hàng  (CountOfCust),  tổng  tiền 
--(SubTotal) với  SubTotal = SUM(OrderQty*UnitPrice)

select COUNT(*) as CountOfCust,SubTotal = SUM(OrderQty*UnitPrice) 
from [Sales].[SalesOrderDetail] sod join [Sales].[SalesOrderHeader] soh on sod.SalesOrderID = soh.SalesOrderID
		join sales.Customer sc on sc.CustomerID = soh.CustomerID join [Sales].[SalesTerritory] st on st.TerritoryID = sc.TerritoryID
where st.CountryRegionCode = 'US'

--3. Tính  tổng  trị  giá  của  những  hóa  đơn  với  Mã  theo  dõi  giao  hàng
--(CarrierTrackingNumber)  có  3  ký  tự  đầu  là  4BD,  thông  tin  bao  gồm 
--SalesOrderID, CarrierTrackingNumber,  SubTotal=SUM(OrderQty*UnitPrice)

select SalesOrderID, CarrierTrackingNumber,  SubTotal=SUM(OrderQty*UnitPrice)
from Sales.SalesOrderDetail
where CarrierTrackingNumber like '4BD%'
group by SalesOrderID, CarrierTrackingNumber

--4. Liệt  kê  các  sản  phẩm  (Product)  có  đơn  giá  (UnitPrice)<25  và  số  lượng  bán 
--trung bình >5, thông tin gồm ProductID, Name,  AverageOfQty.

select p.ProductID, Name,  AverageOfQty = AVG(OrderQty)
from Sales.SalesOrderDetail sod join [Production].[Product] p on sod.ProductID = p.ProductID
where (UnitPrice)<25
group by p.ProductID, Name
having AVG(OrderQty) >5

--5. Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm 
--JobTitle,  C ountOfPerson=Count(*)
 
select JobTitle,  countOfPerson = Count(*)
from [HumanResources].[Employee]
group by JobTitle 
having COUNT(*) > 20

--6. Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên 
--kết  thúc  bằng  ‘Bicycles’  và  tổng  trị  giá  >  800000,  thông  tin  gồm 
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty,  SubTotal
--(sử dụng các bảng [Purchasing].[Vendor] , [Purchasing].[PurchaseOrderHeader] và 
--[Purchasing].[PurchaseOrderDetail])

select BusinessEntityID, Name, ProductID, SumOfQty = sum(OrderQty),  SubTotal = sum(OrderQty * UnitPrice)
from [Purchasing].[PurchaseOrderDetail] pod join [Purchasing].[PurchaseOrderHeader] poh on pod.PurchaseOrderID = poh.PurchaseOrderID
		join [Purchasing].[Vendor] pv on pv.ModifiedDate = poh.ModifiedDate
where Name like '%Bicycles'
group by BusinessEntityID, Name, ProductID 
having sum(OrderQty * UnitPrice) >80000

--7. Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
--SubTotal		***

select pp.ProductID, Product_Name = Name , CountOfOrderID = COUNT(ohs.SalesOrderID) ,SubTotal = sum(OrderQty * UnitPrice)
from Production.Product pp join [Sales].[SalesOrderDetail] ods 
	on pp.ProductID = ods.ProductID
	join [Sales].[SalesOrderHeader] ohs on ohs.SalesOrderID =  ods.SalesOrderID
where datepart(QUARTER,OrderDate) = 1 and YEAR(OrderDate) = 2008 
group by pp.ProductID,  Name
having COUNT(ohs.SalesOrderID) > 500 and sum(OrderQty * UnitPrice) >10000 

--8.Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as FullName), Số hóa đơn (CountOfOrders)

select PersonID , fullname = FirstName +' ' +LastName, CountOfOrders = count(SalesOrderID)
from sales.SalesOrderHeader ohs join sales.Customer cs on cs.CustomerID = ohs.CustomerID
	join Person.Person pp on pp.BusinessEntityID = cs.PersonID
where year(OrderDate) in (2007 , 2008)
group by PersonID,FirstName +' ' +LastName
having count(SalesOrderID) >25


--9.Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
--Sales.SalesOrderDetail và Production.Product)

select pp.ProductID, Name,CountOfOrderQty=count(OrderQty) ,  year(OrderDate) as year
from Production.Product pp join sales.SalesOrderDetail ods on ods.ProductID = pp.ProductID
	join sales.SalesOrderHeader ohs on ohs.SalesOrderID = ods.SalesOrderID
where exists (
			select name
			from [Production].[ProductModel] pmp 
			where (name like 'Bike%' or name like 'Sport%') and pmp.ProductModelID =pp.ProductModelID
		)
group by pp.ProductID, Name, year(OrderDate) 
having count(OrderQty) > 500

--10. Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].

select d.DepartmentID, Name , AvgofRate = avg(Rate)
from HumanResources.EmployeeDepartmentHistory dh join HumanResources.Department d
	on dh.DepartmentID = d.DepartmentID
	join [HumanResources].[EmployeePayHistory] ep on ep.BusinessEntityID = dh.BusinessEntityID
group by d.DepartmentID, Name
having avg(Rate) > 30





--							SUBQUERY 
--1. Liệt kê các sản phẩm  gồm các thông tin  Product  Names  và  Product ID  có 
--trên 100 đơn đặt hàng trong tháng 7 năm  2008

select name, pp.ProductID
from [Production].[Product] pp join [Sales].[SalesOrderDetail] sod on sod.ProductID = pp.ProductID 
		join sales.SalesOrderHeader soh on soh.SalesOrderID = sod.SalesOrderID
where month(OrderDate) = 7 and year(OrderDate) = 2008
group by name, pp.ProductID
having sum(OrderQty) >100

--2.Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
--trong tháng 7/2008 *

select pp.ProductID, Name,sum(sod.OrderQty) as sum 
from [Production].[Product] pp join sales.SalesOrderDetail sod on pp.ProductID = sod.ProductID
	join sales.SalesOrderHeader odh on odh.SalesOrderID = sod.SalesOrderID
where month(OrderDate) = 7 and year(OrderDate)=2008
group by pp.ProductID, Name 
having sum(sod.OrderQty) = (
	select top 1 sum(sod.OrderQty) as sum 
	from [Production].[Product] pp join sales.SalesOrderDetail sod on pp.ProductID = sod.ProductID
		join sales.SalesOrderHeader odh on odh.SalesOrderID = sod.SalesOrderID
	where month(OrderDate) = 7 and year(OrderDate)=2008
	group by pp.ProductID, Name 
	order by sum(sod.OrderQty) desc
)

--3.Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
--CustomerID, Name, CountOfOrder

select CustomerID, Name = pp.FirstName + pp.LastName, CountOfOrder = count(CustomerID)
from sales.Customer cs join Person.Person pp on cs.PersonID = pp.BusinessEntityID
where cs.CustomerID = (
	select top 1 CustomerID
	from sales.SalesOrderHeader ohs join sales.SalesOrderDetail ods on ods.SalesOrderID = ohs.SalesOrderID
	group by CustomerID
	order by sum(orderQty) desc
)
group by CustomerID, pp.FirstName + pp.LastName

--4.Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
--bảng Production.Product và Production.ProductModel)

select *
from  Production.ProductModel pmp 
where pmp.Name in ('Long-Sleeve Logo Jersey%') and exists(
	select pp.ProductID, pp.Name
	from Production.Product pp 
	where pp.ProductID = pmp.ProductModelID 
)

--5.Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình.

	select pmp.ProductModelID 
	from [Production].[ProductModel] pmp join Production.Product pp 
		on pp.ProductModelID = pmp.ProductModelID
	group by pmp.ProductModelID
	having max(ListPrice) > avg(StandardCost)

 
 --6. Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
--đặt hàng > 5000 (dùng IN, EXISTS)

select pp.ProductID, Name
from Production.Product pp 
where   exists(
	select ProductID
	from [Sales].[SalesOrderDetail] ods
	where pp.productid = ods.productid
	group by ProductID
	having sum(OrderQty) > 5000
)  

--7. Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
--nhất trong bảng Sales.SalesOrderDetail

select pp.ProductID, UnitPrice
from Sales.SalesOrderDetail ods join Production.Product pp
	on pp.ProductID = ods.ProductID
where UnitPrice = (
	select top 1 UnitPrice
	from Sales.SalesOrderDetail ods join Production.Product pp
		on pp.ProductID = ods.ProductID
	order by UnitPrice desc
)

--8.Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
--Nam; dùng 3 cách Not in, Not exists và Left join.(*)

select pp.ProductID, Name
from Production.Product pp left join Sales.SalesOrderDetail ods
	on pp.ProductID = ods.ProductID 
where ods.SalesOrderDetailID is null

select pp.ProductID, Name
from Production.Product pp  
where not exists(
	select SalesOrderDetailID ods
	from Sales.SalesOrderDetail ods
	where  pp.ProductID = ods.ProductID
)

--9.Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
--EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
--HumanResources.Employees và Sales.SalesOrdersHeader)		**


	select *
	from [Sales].[SalesOrderHeader] ohs 

	where 
		 (ohs.OrderDate between '2008-5-2' and GETDATE())  

--10.Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.

select cs.CustomerID, FirstName , LastName 
from sales.Customer cs join Person.Person pp 
	on cs.PersonID = pp.BusinessEntityID 
	join sales.SalesOrderHeader ohs on ohs.CustomerID = cs.CustomerID
where year(OrderDate) = 2007