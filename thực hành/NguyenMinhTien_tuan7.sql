--1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
-- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:
create table M_Department
(
	DepartmentID int not null primary key,
	Name nvarchar(50),
	GroupName nvarchar(50)
)
create table M_Employees
(
	EmployeeID int not null primary key,
	Firstname nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	DepartmentID int foreign key references M_Department(DepartmentID)
)

		-- Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID,
		--FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa
		--trên 2 bảng M_Employees và M_Department
go
create view EmpDepart_View
as
select EmployeeID,FirstName, MiddleName, LastName, d.DepartmentID, Name, GroupName
from M_Employees e join M_Department d on e.DepartmentID = d.DepartmentID

go
select * from EmpDepart_View
go
		--Tạo một trigger tên InsteadOf_Trigger thực hiện trên view
		--EmpDepart_View, dùng để chèn dữ liệu vào các bảng M_Employees và
		--M_Department khi chèn một record mới thông qua view EmpDepart_View. 
create trigger InsteadOf_Trigger
ON EmpDepart_View
INSTEAD OF INSERT 
as
	declare @EmployeeID int,@FirstName nvarchar(10),@MiddleName nvarchar(10),@LastName nvarchar(10),
			@DepartmentID int,@Name nvarchar(10),@GroupName nvarchar(10)
	select @EmployeeID = EmployeeID,@FirstName = Firstname,@MiddleName = MiddleName,@LastName = LastName,
			@DepartmentID = DepartmentID,@Name = name,@GroupName = GroupName
	from inserted

	insert M_Department(DepartmentID,Name,GroupName)
	values(@DepartmentID,@Name,@GroupName)
	insert into M_Employees(EmployeeID,Firstname,MiddleName,LastName,DepartmentID)
	values(@EmployeeID,@Firstname,@MiddleName,@LastName,@DepartmentID)
go

insert into EmpDepart_View (EmployeeID,FirstName,MiddleName,LastName,DepartmentID,Name,GroupName)
values(001,N'nguyễn',N'minh',N'tiến',01,N'KT1',N'kĩ thuật')

select * from M_Department
select * from M_Employees
drop trigger InsteadOf_Trigger
drop table M_Department

--2. Tạo một trigger thực hiện trên bảng MSalesOrders có chức năng thiết lập độ ưu
--tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác Insert,
--Update và Delete trên bảng MSalesOrders theo điều kiện như sau:
create table MCustomer
(
	CustomerID int not null primary key,
	CustPriority int
)
create table MSalesOrders
(
	SalesOrderID int not null primary key,
	OrderDate date,
	SubTotal money,
	CustomerID int foreign key references MCustomer(CustomerID) 
)
	--Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer,
	--nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho
	--giá trị null
go
select CustomerID from Sales.Customer
where CustomerID > 30100 and CustomerID < 30118

insert MCustomer(CustomerID) 
select CustomerID from Sales.Customer
where CustomerID > 30100 and CustomerID < 30118

sp_help 'MCustomer'
select * from MCustomer
go

--Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
--Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng
--khách hàng.
go
insert MSalesOrders(SalesOrderID,OrderDate,SubTotal,CustomerID)
select SalesOrderID,OrderDate,SubTotal,c.CustomerID from Sales.SalesOrderHeader o
	join  MCustomer c on o.CustomerID = c.CustomerID

	--Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted
create trigger cau2
on MSalesOrders
after insert, update, delete
as
	declare @total money, @cusID int
	select @total = SubTotal from inserted
	select @cusID = CustomerID from inserted
	
	--Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của
	--khách hàng (CustPriority) là 3
	if(@total < 10000)
	begin
		update MCustomer
		set CustPriority = 3
		where CustomerID = @cusID
	end
	--Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $
	--thì độ ưu tiên của khách hàng (CustPriority) là 2
	if(@total >= 10000 and @total <50000)
	begin
		update MCustomer
		set CustPriority = 2
		where CustomerID = @cusID
	end
	--Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên thì độ ưu tiên
	--của khách hàng (CustPriority) là 1
	if(@total >= 50000)
	begin
		update MCustomer
		set CustPriority = 1
		where CustomerID = @cusID
	end
	--Viết câu lệnh kiểm tra việc thực thi của trigger vừa tạo bằng cách chèn thêm hoặc
	--xóa hoặc update một record trên bảng MSalesOrders
	
go
	update  MSalesOrders
	set SubTotal = 15000
	where CustomerID = 30101

go
select * from MCustomer
select * from MSalesOrders
drop table MCustomer
	

-- 3.Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực
--hiện chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập
--nhật số nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng
--số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì
--hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:

		--Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc sau:
drop table MEmployees
drop table MDepartment
create table MDepartment
(
	DepartmentID int not null primary key,
	Name nvarchar(50),
	NumOfEmployee int
)
create table MEmployees
(
	EmployeeID int not null,
	FirstName nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	DepartmentID int foreign key references MDepartment(DepartmentID),
	constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)
	--	Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột
	--NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng
	--EmployeeDepartmentHistory
	go
	insert into MDepartment(DepartmentID,Name)
	select DepartmentID,Name from HumanResources.Department

	insert MEmployees
	select BusinessEntityID,FirstName ,MiddleName ,LastName ,DepartmentID
	from HumanResources.vEmployeeDepartment
	go

	select * from MDepartment
	select * from MEmployees
	drop table MEmployees
	--Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger
go
create trigger cau3
on MEmployees
after insert
as
	declare @NumOfEmployee int, @id int, @deparID int
	select @NumOfEmployee = NumOfEmployee from MDepartment
	select @deparID = DepartmentID from inserted

	if exists (select * from MDepartment where @NumOfEmployee <= 200 and DepartmentID = @deparID)
	begin
		update MDepartment
		set NumOfEmployee = NumOfEmployee + 1
		where DepartmentID = @deparID 
	end
	else
		print 'kh du nhan vien'
		rollback
go
insert MEmployees(EmployeeID,FirstName ,MiddleName ,LastName ,DepartmentID)
values (1,N'a',N'b',N'c',1)

--cau 4 . Bảng [Purchasing].[Vendor], chứa thông tin của nhà cung cấp, thuộc tính
--CreditRating hiển thị thông tin đánh giá mức tín dụng, có các giá trị:
		--1 = Superior
		--2 = Excellent
		--3 = Above average
		--4 = Average
		--5 = Below average
--Viết một trigger nhằm đảm bảo khi chèn thêm một record mới vào bảng
--[Purchasing].[PurchaseOrderHeader], nếu Vender có CreditRating=5 thì hiển thị
--thông báo không cho phép chèn và đồng thời hủy giao tác
select * from Purchasing.Vendor
select * from Purchasing.PurchaseOrderHeader
go
create trigger cau4
on [Purchasing].[PurchaseOrderHeader]
after insert 
as 
	declare @CreditRating int , @venID int
	select @venID = VendorID 
	from inserted

	select @CreditRating = CreditRating 
	from inserted i join Purchasing.Vendor v
		on i.VendorID = v.BusinessEntityID
	where @venID = i.VendorID
	
	if(@CreditRating = 5)
	begin
		print 'khong duoc chen'
		rollback
	end

go
drop trigger cau4

select CreditRating , i.VendorID
	from [Purchasing].[PurchaseOrderHeader] i join Purchasing.Vendor v
		on i.VendorID = v.BusinessEntityID
	where i.VendorID = v.BusinessEntityID

sp_help '[Purchasing].[PurchaseOrderHeader]'
INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status,
EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt,
Freight) VALUES ( 2 ,3, 261, 1550, 4 ,GETDATE() ,GETDATE() , 44594.55,
3567.564 ,1114.8638 )
go
--cau 5. Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượng  sản phẩm trong kho). 
--Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail  với số lượng xác định trong   field
--OrderQty, nếu số lượng trong kho Quantity> OrderQty thì cập nhật 
--lại  số   lượng   trong   kho Quantity=  Quantity-  OrderQty, 
--ngược lại nếu Quantity=0 thì xuất thông báo “Kho hết hàng” và đồng 
--thời hủy giao  tác.
												-----------------------------------
go
select *from Sales.SalesOrderDetail 
select * from Production.ProductInventory
go 
sp_help 'Sales.SalesOrderDetail'

go
delete Sales.SalesOrderDetail where SalesOrderID=43659 and SalesOrderDetailID = 121320
go

insert Sales.SalesOrderDetail(SalesOrderID,OrderQty,ProductID,SpecialOfferID,UnitPrice)
values (43660, 300, 707,1,  100 )
select * from Sales.SpecialOfferProduct where ProductID = 316

go
select * from Production.ProductInventory where ProductID = 707

go 
select * from Production.ProductInventory i join Sales.SpecialOfferProduct s
on i.ProductID = s.ProductID

go
create trigger  cau5
on Sales.SalesOrderDetail
after insert
as
declare @productid int, @qty smallint  , @locationid int
select  @qty= OrderQty,  @productid = ProductID
from inserted

if exists (select * from  Production.ProductInventory where ProductID = @productid 
						and Quantity >= @qty)
begin
	select  top 1 @locationid=  LocationID
	from  Production.ProductInventory where ProductID = @productid and Quantity >= @qty

	update Production.ProductInventory
	set	Quantity = Quantity - @qty
	where ProductID = @productid  and @locationid=  LocationID
end

else
begin
	print N'Kho ....hết hàng'
	rollback
end
			--3. kieu trigger : after , instead of


--cau 6.
--Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson,  khi 
--người  dùng  chèn thêm một  record mới  trên  bảng  SalesOrderHeader,  theo  quy  định 
--như sau: Nếu tổng tiền bán được của nhân  viên có hóa  đơn  mới  nhập vào bảng 
--SalesOrderHeader  có giá trị >10000000 thì tăng tiền thưởng lên  10% của  mức 
--thưởng hiện tại. Cách thực  hiện:
--  Tạo hai bảng mới M_SalesPerson và  M_SalesOrderHeader
		create table M_SalesPerson 
		(
			SalePSID int not null primary key, 
			TerritoryID int,
			BonusPS money
		)
		create table M_SalesOrderHeader 
		(
			SalesOrdID int not null primary key, 
			OrderDate date,
			SubTotalOrd money,
			SalePSID int foreign key references M_SalesPerson(SalePSID)
		)
		--  Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn 
		--những field tương ứng với 2 bảng mới  tạo.
go
sp_help 'M_SalesPerson'
go
sp_help 'M_SalesOrderHeader'

go

select * from sales.SalesOrderHeader
insert M_SalesOrderHeader(SalesOrdID,OrderDate,SubTotalOrd,SalePSID)
select SalesOrderID,OrderDate,TotalDue, SalesPersonID from sales.SalesOrderHeader
select * from M_SalesOrderHeader
go

select * from sales.SalesPerson
insert M_SalesPerson(SalePSID,TerritoryID,BonusPS)
select BusinessEntityID,TerritoryID,Bonus from sales.SalesPerson
select * from M_SalesPerson

go
delete M_SalesPerson where SalePSID = 1
go
		--  Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger 
		--thực thi thì dữ liệu trong bảng M_SalesPerson được cập  nhật.

create trigger cau6
on M_SalesOrderHeader
after insert 
as
begin
	 -- Lấy tổng tiền bán được của nhân viên có hóa đơn mới thêm vào
  DECLARE @SalesPersonID INT
  DECLARE @TotalSales MONEY
  
  SELECT @SalesPersonID = inserted.SalePSID, @TotalSales = SUM(inserted.SubTotalOrd)
  FROM inserted JOIN M_SalesOrderHeader ON inserted.SalePSID = M_SalesOrderHeader.SalePSID
  GROUP BY inserted.SalePSID
  
  -- Kiểm tra nếu tổng tiền bán được > 10000000
  IF @TotalSales > 10000000
  BEGIN
    -- Tăng tiền thưởng lên 10% của mức thưởng hiện tại
    DECLARE @CurrentBonus MONEY
    DECLARE @NewBonus MONEY
    
    SELECT @CurrentBonus = BonusPS
    FROM M_SalesPerson
    WHERE SalePSID = @SalesPersonID
    
    SET @NewBonus = @CurrentBonus * 1.1
    
    -- Cập nhật tiền thưởng mới cho nhân viên
    UPDATE M_SalesPerson
    SET BonusPS = @NewBonus
    WHERE SalePSID = @SalesPersonID
  END
end


go
drop trigger cau6
go

