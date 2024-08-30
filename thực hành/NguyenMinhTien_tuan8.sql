--1)  Đăng nhập vào  SQL  bằng SQL  Server authentication, tài khoản sa.  Sử dụng TSQL.
--2)  Tạo hai login SQL server Authentication User2 và  User3
create login sinhvien2 with password = '123'
create login sinhvien3 with password = '123'

drop login sinhvien

--3)  Tạo một database user User2 ứng với login User2 và một database user User3
--ứng với login User3 trên CSDL AdventureWorks2008. 
use [AdventureWorks2008R2]
create user user2 for login sinhvien2
drop user user2 

use [AdventureWorks2008R2]
create user user3 for login sinhvien3

--4)  Tạo 2 kết nối đến server thông qua login  User2  và  User3, sau đó thực hiện các 
--thao tác truy cập CSDL  của 2 user  tương ứng (VD: thực hiện  câu Select). Có thực 
--hiện được không?
	print 'khong ket noi duoc do chua duoc table do chua duoc cap quyen'
--5)  Gán quyền select trên Employee cho User2, kiểm tra kết quả.  Xóa quyền select 
--trên Employee cho User2. Ngắt 2 kết nối của User2 và  User3
grant select
on HumanResources.Employee
to user2
 
go
revoke select
on HumanResources.Employee
to user2
go
--6)  Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên 
--CSDL  AdventureWorks2008,  sau  đó  gán  các  quyền  Select,  Update,  Delete  cho 
--Employee_Role.
sp_helprole
go
create role Employee_Role

go
grant select, update, delete
on HumanResources.Employee
to Employee_Role		--user role

go
drop role Employee_Role

DENY SELECT 
on HumanResources.Employee		--khong dc select trong user role Employee_Role
to Employee_Role

go						--hoặc dùng
sp_addrolemember 'db_datareader' , Employee_Role

--7)  Thêm các  User2  và  User3  vào  Employee_Role.  Tạo  lại  2  kết  nối  đến  server  thông 
--qua login User2 và User3 thực hiện các thao tác  sau:
	--a)  Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng 
	--Employee
	go
	sp_addrolemember 'Employee_Role', user2
	go
	sp_addrolemember 'Employee_Role', user3
	go
	sp_droprolemember 'Employee_Role', user2
	sp_droprolemember 'Employee_Role', user3

	--b)  Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của  nhân 
	--viên có BusinessEntityID=1

	--c)  Tại kết nối User2, dùng câu lệnh Select xem lại kết  quả.
		print 'cập nhật bên user3 đã được cập nhập bên user 2'
	--d)  Xóa role Employee_Role, (quá trình xóa role    ra sao ?)
	drop role Employee_Role
		print 'role phải không có phần tử mới xoá đc'

		------------------------------------------------------------

--Ví dụ 5: Cấp quyền đọc trên table sales.salesorderheader cho user sinhvien 
-- và sinhvien có thể cấp quyền này cho user khác 
--begin
GRANT  SELECT 
ON  sales.SalesOrderHeader
TO  user2  WITH GRANT OPTION 	

-- thu hồi quyền đã cấp cho sinhvien và quyền mà sinhvien đã cấp cho các user khác
REVOKE  SELECT
ON sales.salesorderheader
TO  user2 CASCADE


---------------------------------------TRANSACTION------------------------------------------------
