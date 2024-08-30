sp_help 'HumanResources.EmployeeDepartmentHistory'

select * from HumanResources.EmployeeDepartmentHistory

go 
--Vi ết batch (hoặc thủ  tục) thực hiện  tác vụ  chuyển nhân viên A từ  phòng ban X sang phòng ban Y  từ  ngày 
--D (  bảng HumanResources.EmployeeDepartmentHistory  )
--Tác vụ  chuyển nhân viên gồm 2 thao tác :   insert 1 dòng vào  bảng, và update cột EndDate là ngày D.  Yêu 
--cầu : hoặc cả 2 thao tác thực hiện thành công, hoặc cả  2 không thực hiện.

declare @maNV int , @maPBx int , @maPBy int, @enddate date
select @maNV = 1, @maPBx = 16, @maPBy = 1, @enddate ='2023-03-14' 
set xact_abort on
begin tran
	update HumanResources.EmployeeDepartmentHistory
	set EndDate = @enddate
	where @maNV = BusinessEntityID and @maPBx = DepartmentID

	insert HumanResources.EmployeeDepartmentHistory([BusinessEntityID],[DepartmentID],[ShiftID],[StartDate])
	values(@maNV,@maPBy,1,DATEADD(day,1,@enddate))
commit


go
select * from HumanResources.EmployeeDepartmentHistory
where BusinessEntityID = 1