--NGUYEN MINH TIEN
--21044611

--CAU 1:
--a.  Vi ết  th ủ  tục  tên MaSV_Total   trả về tổng  trị giá các hóa đơn đã xuất 
--bán    thuộc  về  một  TerritoryID   trong một tháng,  năm  (tương  ứng  với 
--các tham số đầu vào). Thủ tục trả về giá trị qua tham số OUTPUT.
select * from Sales.SalesTerritory
select * from Sales.SalesOrderHeader

select o.SalesOrderID , sum(TotalDue) 
from Sales.SalesOrderHeader o join Sales.SalesTerritory st 
	on o.TerritoryID = st.TerritoryID
group by o.SalesOrderID

-----------------------------------------------
select TerritoryID, thang = month(OrderDate), nam = YEAR(OrderDate), sum(TotalDue)
from sales.SalesOrderHeader
where month(OrderDate) = 5 and  YEAR(OrderDate) = 2007
group by TerritoryID, month(OrderDate) ,  YEAR(OrderDate) 
---------------
go 
create proc MaSV_Total @materri int,@thang int ,@nam int ,@total money output
as
	--select o.SalesOrderID , sum(TotalDue) 
	--from Sales.SalesOrderHeader o join Sales.SalesTerritory st 
	--	on o.TerritoryID = st.TerritoryID
	--where @materri = st.TerritoryID
	--group by o.SalesOrderID
	select sum(TotalDue)
	from sales.SalesOrderHeader
	where month(OrderDate) = @thang and  YEAR(OrderDate) = @nam and TerritoryID = @materri
	group by TerritoryID, month(OrderDate) ,  YEAR(OrderDate) 

go
declare @total money
exec MaSV_Total 5,5,2007, @total output
go
select * from sys.procedures

--b.  Viết  batch  gọi  thủ tục   với tham số  @TerritoryID=10  ,  @thang 5 , 
--@nam=  2011,  và  xuất ra thông báo  ‘ Tổng trị giá các hóa đơn  thuộc 
--vùng Territorry có tên ….  là …’  
--(Gợi ý :  Name trong Sales.SalesTerritory)

select * from Sales.SalesTerritory
select * from Sales.SalesOrderHeader

go 
declare @TerritoryID int 
set @TerritoryID = 10  
declare @thang int 
set @thang = 5 
declare @nam int 
set @nam =  2011
declare @name char
declare @total int
select @name = name , @total = SalesYTD from Sales.SalesOrderHeader o join Sales.SalesTerritory st 
	on o.TerritoryID = st.TerritoryID
where @nam = year(OrderDate) and  @thang = month(orderdate) and st.TerritoryID = @TerritoryID

print concat('tong gia tri hoa don thuoc vung ',@TerritoryID, ' co ten la ', @name,' la ',@total)
go


--Câu 2: (5đ) 
--c.  Hãy  viết  hàm  dạng  table_valued  function  có  tên  MaSV_ThongKe 
--cho  bi ết  Sản phẩm   có tổng số l ượng bán cao nhất trong năm bất kỳ
--(@nam là tham số truyền vào). Thông tin hiển thị bao gồm :  Mã sản 
--phẩm , Tổng số l ượng bán 
select * from sales.SalesOrderHeader oh join sales.SalesOrderDetail od on od.SalesOrderID = oh.SalesOrderID
select * from  sales.SalesOrderDetail 
select * from  Production.Product
go
create function  MaSV_ThongKe(@nam int)
returns table
as
return(
	select top 1 p.ProductID, total = sum(OrderQty)
	from Production.Product p join Sales.SalesOrderDetail od
		on p.ProductID = od.ProductID join Sales.SalesOrderHeader o
		on od.SalesOrderID = o.SalesOrderID
		where @nam = year(OrderDate)
	group by p.ProductID 
)

go
select * from dbo.MaSV_ThongKe(2005)
--d.  Thực thi   hàm  với tham số @nam=  2011
select * from dbo.MaSV_ThongKe(2011)
