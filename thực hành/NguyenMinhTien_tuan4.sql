--1)  Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của  sản phẩm 
--có ProductID=’778’;  nếu  @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên  500  đơn  hàng”,  ngược  lại  thì  in  ra  chuỗi  “Sản  phẩm  778  có  ít  đơn  đặt
--hàng”
go
select * from Production.Product

go 
declare  @tongsoHD int 

select @tongsoHD = count(SalesOrderID)
from Sales.SalesOrderDetail
where ProductID = 778
if(@tongsoHD > 500)
	print concat('san pham 778 co tren 500 don', ' ', @tongsoHD)
else
	print concat('san pham 778 co duoi 500 don',' ', @tongsohd)

go
--2)  Viết  một  đoạn  Batch  với  tham  số  @makh  và  @n  chứa  số  hóa  đơn  của  khách 
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008),    nếu
--@n>0  thì  in  ra  chuỗi:  “Khách  hàng  @makh  có  @n  hóa  đơn  trong  năm  2008” 
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng  @makh không có hóa đơn nào 
--trong năm 2008”

GO
declare @makh int 
declare @n int 
declare @nam int
set @nam = 2008
set @makh = 29580

select @n = count(SalesOrderID)
from Sales.SalesOrderHeader
where year(OrderDate) = @nam and CustomerID = @makh
if(@n > 0)
	print concat('khach hang ', @makh, ' co ',@n,' hoa don trong nam 2008')
else
	print concat('khach hang ',@makh,' khong co don hang nao trong nam 2008' )
	
go
--3)  Viết  một  batch  tính  số  tiền  giảm  cho  những  hóa  đơn  (SalesOrderID)  có  tổng 
--tiền>100000,  thông  tin  gồm  [SalesOrderID],  SubTotal=SUM([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như  sau:
--  Những hóa đơn có SubTotal<100000 thì không  giảm,
--  SubTotal từ 100000 đến <120000 thì giảm 5% của  SubTotal
--  SubTotal từ 120000 đến <150000 thì giảm 10% của  SubTotal
--  SubTotal từ 150000 trở lên thì giảm 15% của  SubTotal
go
--declare @ma int 
--declare @discount money
--declare @tongtien money 
--set @ma = 43660
--set @tongtien = (select SUM([LineTotal]) from Sales.SalesOrderDetail 
--					where SalesOrderID = @ma)
--if(@tongtien < 100000)
--	set @discount = @tongtien * 0
--else if(@tongtien < 120000)
--	 set @discount = @tongtien * 0.05
--else if(@tongtien < 150000)
--	set @discount = @tongtien * 0.1
--else 
--	set @discount = @tongtien * 0.15

--print cast(@discount as varchar)

go


select SalesOrderID , total = sum(LineTotal), discount = case
when sum(LineTotal) < 100000 then 0
when sum(LineTotal) < 120000 then sum(LineTotal) * 0.05
when sum(LineTotal) < 150000 then sum(LineTotal) * 0.1
else sum(LineTotal) * 0.15 
end
from Sales.SalesOrderDetail
group by SalesOrderID

--4)  Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của 
--các  field  [ProductID],[BusinessEntityID],[OnOrderQty],  với  giá  trị  truyền  cho 
--các biến @mancc,  @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc,   nếu
--@soluongcc trả về giá  trị là null  thì in  ra chuỗi  “Nhà cung  cấp 1650  không cung 
--cấp sản phẩm  4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
--cung cấp sản phẩm 4 với số lượng là  5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])

select * from [Purchasing].[ProductVendor]
select * from Purchasing.Vendor
go
declare @mancc int 
declare @masp int 
declare @soluongcc int 

set @mancc = 1650
set @masp = 4
set @soluongcc =(select OnOrderQty 
				from Purchasing.ProductVendor 
				where ProductID = @masp and BusinessEntityID = @mancc) 
if(@soluongcc is null)
	print concat('nha cung cap ' , @mancc , ' khong cung cap san pham ' , @masp)
else
	print concat('Nhà cung cấp ' , @mancc , ' cung cấp sản phẩm ', @masp, ' với số lượng là ' , @soluongcc)
go
--5)  Viết  một  batch  thực  hiện  tăng  lương  giờ  (Rate)  của  nhân  viên  trong 
--[HumanResources].[EmployeePayHistory]  theo  điều  kiện  sau:  Khi  tổng  lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì  dừng

go
declare @tongLuong int

set @tongLuong = (select sum(Rate)
			from [HumanResources].[EmployeePayHistory] )
select BusinessEntityID , Rate, luong = case
	when @tongLuong < 6000 then rate * 1.1
	when @tongLuong < 6000 and Rate*1.1>150 then 150
	end
from [HumanResources].[EmployeePayHistory]

	
go