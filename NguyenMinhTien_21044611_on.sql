
--1a. Tạo  các  login;  tạo  các  user  khai  thác  CSDL  AdventureWorks2008R2  cho  các  nhân  viên  (tên 
--login  trùng  tên user)
create login userNV with password = '123'
create login userTN with password = '123'
create login userQL with password = '123'

go 
use [AdventureWorks2008R2]
create user userNV for login userNV
create user userTN for login userTN
create user userQL for login userQL


--1b.Phân   quy ền  để  các  nhân  viên  hoàn  thành  nhi ệm  vụ   được  phân  công   (như  đã  nêu  trên).  Admin 
--ch ỉ   cấp qu y ền  cho  trưởng  nhóm   và qu ản lý

grant select, delete, update,insert
on [HumanResources].[EmployeeDepartmentHistory]
to userNV

grant select, delete, update,insert
on [HumanResources].[EmployeeDepartmentHistory]
to userTN

sp_addrolemember  'db_datareader' , userQL


--1d*.Nhân viên  NV  nghỉ   vi ệc,  trưởng  nhóm  hãy  thu  h ồi quy ền  cấp  cho  NV  này.  Vi ết  l ệnh  ki ểm  tra 
--quy ền  trên cửa sổ query  củ a NV

revoke select, delete, update,insert
on [HumanResources].[EmployeeDepartmentHistory]
to userNV


--1e*.Nhóm  nhân  viên  hoàn  thành  dự  án,  admin  hãy  vô  hi ệu  hóa  các  hoạt  động  củ a  nhóm  này  trên 
--CSDL. V i ết l ệnh  ki ểm  tra quyền  trên cửa sổ query  củ a các nhân  viên
drop user userNV

--2a.Tạo cột  NumEmp ch ứa  số  nhân  viên làm  vi ệc  ca ngày   củ a phòng  ban , trong  bảng   Department

select * from  [HumanResources].[Department]
select * from [HumanResources].[EmployeeDepartmentHistory]
select * from [HumanResources].[Shift]

go
alter table [HumanResources].[Department] add NumEmp int 
alter table [HumanResources].[Department] drop column NumEmp
UPDATE [HumanResources].[Department]
SET NumEmp = (
    SELECT COUNT(*) 
    FROM [HumanResources].[EmployeeDepartmentHistory]
    WHERE [DepartmentID] = [Department].[DepartmentID] AND [ShiftID] = 1 and EndDate is null
)


--2b.Vi ết  trigger    tensv_DepHistory  trên  bảng  EmployeeDepartmentHistory  sao  cho  khi  cập  nh ật 
--EndDate  củ a 1 nhân viên  củ a 1 phòng ban nào đó  thì tính l ại  số  nhân viên   (NumEmp)    làm  vi ệc 
--ca ngày  (Shift.Name=‘ Day’)  củ a phòng  ban  đó 


go
create trigger cau2b
on [HumanResources].[EmployeeDepartmentHistory]
after update
as
	update HumanResources.Department
	set NumEmp = (SELECT COUNT(*) 
			FROM [HumanResources].[EmployeeDepartmentHistory]
			WHERE [DepartmentID] = [Department].[DepartmentID] AND [ShiftID] = 1 and EndDate is null)


go
drop trigger cau2b
SELECT * FROM sys.triggers;

--c
update [HumanResources].[EmployeeDepartmentHistory]
set EndDate = GETDATE()
where BusinessEntityID = 16 and DepartmentID =4

--phan2
--a.
EXEC sp_addumpdevice 'disk', 'adv2008back', 't:\NguyenMinhTien.bak';

alter database [AdventureWorks2008R2] set recovery full

backup database [AdventureWorks2008R2] 
to adv2008back								--t = 1
with format
--c
delete from [Production].[ProductCostHistory]

backup database [AdventureWorks2008R2] 
to adv2008back								--t = 2
with differential 

--d
select * from [Person].[PersonPhone]
go
insert [Person].[PersonPhone] (BusinessEntityID,PhoneNumber,PhoneNumberTypeID)
values (10001,123,1)
go
backup log [AdventureWorks2008R2] 
to adv2008back								--t = 3



--e
use master
drop database [AdventureWorks2008R2] 

go
restore [AdventureWorks2008R2] 
from adv2008back
with file = 1 , norecovery

restore [AdventureWorks2008R2] 
from adv2008back
with file = 2 , recovery

go
select * from [Production].[ProductCostHistory]