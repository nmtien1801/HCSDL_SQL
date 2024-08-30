--1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục
--T:\backup\adv2008back.bak 
go
exec sp_addumpdevice 'disk','adv2008back', 'D:\adv2008back.bak '
EXEC sp_dropdevice 'adv2008back'

go
--2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, rồi
--thực hiện full backup vào thiết bị backup vừa tạo
use [AdventureWorks2008R2]		
alter database [AdventureWorks2008R2] set recovery full
go

backup database AdventureWorks2008R2
to adv2008back							--t = 1
with format
go
--3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe
--đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp
--hơn 60%.
go
select * from Production.Product
select * from Production.ProductCategory
select * from Production.ProductSubcategory
select * from Production.Product p join Production.ProductSubcategory ps
	on p.ProductSubcategoryID = ps.ProductSubcategoryID
where p.ProductSubcategoryID = 1

select sum(StandardCost) from Production.Product p join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
		join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID
	where pc.ProductCategoryID in (1)

select sum(StandardCost) from Production.Product where ProductNumber like 'BK%'

update Production.Product
set ListPrice = 15
where ProductSubcategoryID = 1

-----------
go
set xact_abort on
begin tran
	declare @sum money
	select @sum = 0.6*sum(StandardCost) from Production.Product p join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
		join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID
	where pc.ProductCategoryID in (1)

	declare @xedap money
	select @xedap = sum(StandardCost) from Production.Product p join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
		join Production.ProductCategory pc on pc.ProductCategoryID = ps.ProductCategoryID
	where pc.ProductCategoryID in (1)
	if exists(select * from Production.Product where @sum <= @xedap)
	begin
		update Production.Product
		set StandardCost = StandardCost * 0.85
		where StandardCost >= 0
	end
commit
go
select * from Production.Product
--4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu
--vào thiết bị backup vừa tạo
--a. Tạo 1 differential backup
backup database [AdventureWorks2008R2]	
to adv2008back						--t = 2
with differential

go
--b. Tạo 1 transaction log backup
backup log [AdventureWorks2008R2]	
to adv2008back							--t = 3
--5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6).
--Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup
go
select * from [Person].[EmailAddress]
delete from [Person].[EmailAddress]
go
backup log [AdventureWorks2008R2]	
to adv2008back			--t = 4

--6. Thực hiện lệnh:
--a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như sau:
--INSERT INTO Person.PersonPhone VALUES (10000,'123-456-7890',1,GETDATE())
	INSERT INTO Person.PersonPhone VALUES (10000,'123-456-7890',1,GETDATE())
--b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị
--backup vừa tạo.
	backup database [AdventureWorks2008R2]
	to adv2008back					-- t =5
	with differential 
--c. Chú ý giờ hệ thống của máy.
--Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem
	delete from Sales.ShoppingCartItem
go
	backup log [AdventureWorks2008R2]
	to adv2008back					-- t = 6
--7. Xóa CSDL AdventureWorks2008
use QLBH
drop database [AdventureWorks2008R2]

restore database [AdventureWorks2008R2]
from adv2008back
with file = 1 , norecovery 

restore log [AdventureWorks2008R2]
from adv2008back
with file = 3 , recovery 
--8. Để khôi phục lại CSDL:
--a. Như lúc ban đầu (trước câu 3) thì phải restore thế nào?
use QLBH
drop database [AdventureWorks2008R2]

restore database [AdventureWorks2008R2]
from adv2008back
with file = 1 , recovery
--b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn
--còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
use QLBH
drop database [AdventureWorks2008R2]

restore database [AdventureWorks2008R2]
from adv2008back
with file = 1 , norecovery

restore database [AdventureWorks2008R2]
from adv2008back
with file = 2 , recovery 
--c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL
--AdventureWorks2008 ra sao?

