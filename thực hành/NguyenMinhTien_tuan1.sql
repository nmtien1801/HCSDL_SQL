create database sales
use sales


ON PRIMARY
(
	name = 'sale_mdf', filename = 'C:\Users\DNCO\Desktop\HCSDL\Tuan_1\sale.mdf',
	size = 10mb, maxsize = 50mb, filegrowth = 2mb
)

log on
(
	name = 'sale_log', filename = 'C:\Users\DNCO\Desktop\HCSDL\Tuan_1\sale_log.ldf',
	size = 10mb, maxsize = 50mb, filegrowth = 2mb
)
 -- cau 1
 exec sp_addtype moTa, 'nvarchar(40)', 'null'
 exec sp_addtype idKH, 'char(10)', 'not null'
 exec sp_addtype dt, 'char(12)', 'null'

 --cau 2
create table SanPham(
	maSP char(6),
	tenSP varchar(20),
	ngayNhap date,
	DVT char(10),
	soLuongTon int,
	donGiaNhap money
)

create table hoaDon(
	maHD char (10),
	ngayLap date,
	ngayGiao date,
	maKH char(10),
	dienGiai nvarchar(40)
)
create table khachHang(
	maKH char(10),
	tenKH nvarchar(30),
	diaChi nvarchar(40),
	dienThoai char(12)
)
create table chiTietHD(
	maHD char(10),
	maSP char(6),
	soLuong int
)

-- cau 3
alter table hoaDon alter column dienGiai nvarchar(100)
-- cau 4
alter table hoaDon add tyLeHoaHong float
-- cau 5
alter table sanPham drop column ngayNhap


--cau 6
alter table hoaDon alter column maHD char(10) not null
alter table hoaDon add constraint maHD_pk primary key (maHD)
alter table hoaDon add constraint maHD_fk foreign key (maKH) references khachHang (maKH)

alter table khachHang alter column maKH char(10) not null
alter table khachHang add constraint maKH_pk primary key (maKH)

alter table chiTietHD alter column maHD char(10) not null
alter table chiTietHD add constraint maCTHD_pk primary key (maHD)
alter table chiTietHD add constraint maCTHD_fk foreign key (maHD) references hoaDon (maHD)
alter table chiTietHD add constraint masp_fk foreign key (maSP) references sanPham (maSP)

alter table sanPham alter column maSP char(10) not null
alter table sanPham add constraint maSP_pk primary key (maSP)

-- 7. Thêm vào bảng HoaDon các ràng buộc sau:
--NgayGiao >= NgayLap
-- MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
--Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
alter table hoaDon add constraint HD_chk check (ngayGiao >= ngayLap)
alter table hoaDon ADD CONSTRAINT Ngay_DF DEFAULT Getdate() FOR ngayLap

--8. Thêm vào bảng Sản phẩm các ràng buộc sau:
--SoLuongTon chỉ nhập từ 0 đến 500
--DonGiaNhap lớn hơn 0
--Giá trị mặc định cho NgayNhap là ngày hiện hành
--DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’

alter table sanPham ADD CONSTRAINT sp_chk check ((soLuongTon >= 0 and soLuongTon <=500) 
and donGiaNhap > 0 and DVT in ('KG', 'Thùng', 'Hộp', 'Cái'))
alter table sanPham add ngayNhap date 
alter table sanPham ADD CONSTRAINT sp_DF DEFAULT Getdate() FOR ngayNhap

--cau 9.
insert into [dbo].[SanPham](tenSP,DVT,soLuongTon,donGiaNhap,maSP) values(
	'but','Cái','100','3000','1'
)

insert into [dbo].[khachHang](maKH,tenKH,diaChi,dienThoai) values(
	'1',N'tho',N'bien hoa','0151'
)

insert into [dbo].[hoaDon] (maHD,ngayGiao,maKH,dienGiai) values(
	'1','2023-6-3','1',N'abc'
)
insert into [dbo].[chiTietHD] (maHD,maSP,soLuong) values(
	'1','1',1
)