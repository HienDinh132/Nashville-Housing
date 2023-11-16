------------------------------------------------------------------------------Data Cleaning------------------------------------------------------------------------------------------------------
-- Bỏ dấu '$' đầu mỗi dòng của cột SalePrice
Select * from [Nashville-Housing]
where left(SalePrice,1) = '$'

Update [Nashville-Housing]
Set SalePrice = replace(SalePrice,'$','')
Where UniqueID in (50606, 39467, 39539, 17845, 55748, 23307, 17651)

-- Bỏ dấu , trong mỗi dòng của cột SalePrice
Select UniqueID, CHARINDEX(',', SalePrice,1) 
From [Nashville-Housing]
Order by 2 desc

Update [Nashville-Housing]
Set SalePrice = replace(SalePrice,',','')
Where UniqueID in (8996, 17845, 39467, 23307, 1390, 17651, 50606, 39539, 25017, 26950, 57, 55748)

--Chuyển kiểu cột SalePrice từ varchar sang float
Alter Table [Nashville-Housing]
Add SalePriceConverted float

Update [Nashville-Housing]
Set SalePriceConverted = Convert(Float, SalePrice)

Alter Table [Nashville-Housing]
Drop column SalePrice

Alter Table [Nashville-Housing]
Add SalePrice float

Update [Nashville-Housing]
Set SalePrice = Convert(Float, SalePriceConverted)

Alter Table [Nashville-Housing]
Drop column SalePriceConverted

--- Thay thế các giá trị Null trong cột Property Address
Select * 
From [Nashville-Housing] as N
Where PropertyAddress is Null

Select n.ParcelID, N.PropertyAddress, m.ParcelID, m.PropertyAddress, Isnull(n.PropertyAddress, m.PropertyAddress) 
From [Nashville-Housing] as n
Inner Join [Nashville-Housing] as m
On n.ParcelID = m.ParcelID
And n.UniqueID != m.UniqueID
Where n.PropertyAddress is Null

Update n
Set PropertyAddress = Isnull(n.PropertyAddress, m.PropertyAddress) 
From [Nashville-Housing] as n
Inner Join [Nashville-Housing] as m
On n.ParcelID = m.ParcelID
And n.UniqueID != m.UniqueID
Where n.PropertyAddress is Null

--- Xử lý cột Property Address
Select * From [Nashville-Housing]

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as [Address],
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as [City]
From [Nashville-Housing]

Alter Table [Nashville-Housing]
Add [Address] varchar(max), [City] varchar(max)


Update [Nashville-Housing]
Set [Address] = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1), 
[City] = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))

-- Xử lý cột OwnerAddress
Select PARSENAME(Replace(OwnerAddress, ',', '.'),3),
PARSENAME(Replace(OwnerAddress, ',', '.'),2),
PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From [Nashville-Housing]

Alter Table [Nashville-Housing]
Add [Owner Address] varchar(max), [Owner City] varchar(max), [Owner State] varchar(max)

Update [Nashville-Housing]
Set [Owner Address] = PARSENAME(Replace(OwnerAddress, ',', '.'),3),
[Owner City] = PARSENAME(Replace(OwnerAddress, ',', '.'),2),
[Owner State] = PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From [Nashville-Housing]

--- Xử lý cột SoldAsVacant
Select SoldAsVacant,  Count(*) as Number
From [Nashville-Housing]
Group by SoldAsVacant

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
From [Nashville-Housing]

Update [Nashville-Housing]
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
From [Nashville-Housing]

--Xử lý cột SaleDate
Alter Table [Nashville-Housing]
Add SalDateConverted Date

Update [Nashville-Housing]
Set SalDateConverted = Convert(Date, SaleDate)

Alter Table [Nashville-Housing]
Drop Column SaleDate

Alter Table [Nashville-Housing]
Add SaleDate Date

Update [Nashville-Housing]
Set SaleDate= Convert(Date, SalDateConverted)

Alter Table [Nashville-Housing]
Drop Column SalDateConverted

-- Xử lý cột Owner State
Update [Nashville-Housing]
Set [Owner State] ='TN'
Where [Owner State] is Null

Update [Nashville-Housing]
Set [Owner State] ='TN'
Where [Owner State] =' TN'

--Remove Duplicate
Select UniqueID
From(
Select *
From(
Select *,
ROW_NUMBER() Over (Partition By ParcelID, [Owner Address], [Owner City], [Owner State], SalePrice, SaleDate, LegalReference Order by UniqueID) as row_num
From [Nashville-Housing] as n) as n1
Where row_num > 1)n2

Delete From [Nashville-Housing] 
Where UniqueID in 
(
Select UniqueID
From(
Select *
From(
Select *,
ROW_NUMBER() Over (Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference Order by UniqueID) as row_num
From [Nashville-Housing] as n) as n1
Where row_num > 1)n2
)

--Xóa cột không dùng
Select * From [Nashville-Housing]

Alter Table [Nashville-Housing]
Drop Column PropertyAddress, OwnerAddress

--- Xử lý cột OwnerName (có tên viết gần giống)
Select *
From (
Select OwnerName, [Owner Address], [Owner City], [Owner State],
Rank() Over(Partition By [Owner Address], [Owner City], [Owner State] Order By OwnerName) as [Rank]
From [Nashville-Housing]) as k1
Where [Rank] > 1

Select OwnerName, [Owner Address], [Owner City], [Owner State]
From [Nashville-Housing]
Where [Owner Address] = '0  54TH AVE N' and [Owner City] = ' NASHVILLE'
Order By SaleDate, UniqueID

Update [Nashville-Housing]
Set OwnerName = 'MONTGOMERY, KARL R. & LORI A.'
Where UniqueID = 41085

Update [Nashville-Housing]
Set OwnerName = 'URBAN HOME PROJECT, LLC'
Where UniqueID in (28144, 56027)

Update [Nashville-Housing]
Set OwnerName = '508 INVESTORS, LLC'
Where UniqueID in (45457, 45458)

Update [Nashville-Housing]
Set OwnerName = 'COLLINS, EUGENE'
Where UniqueID in (42588)

Update [Nashville-Housing]
Set OwnerName = 'JH103, LLC'
Where UniqueID in (25149)

Update [Nashville-Housing]
Set OwnerName = 'NORTHEAST DEVELOPMENT, LLC'
Where UniqueID in (50719)

Update [Nashville-Housing]
Set OwnerName = 'COOPER, JORDAN & GERALD SAUNDERS'
Where UniqueID in (6049)

--- Xử lý các giao dịch có cùng địa chỉ, LegalReference, OwnerName nhưng lại có các thông số căn nhà khác nhau (ưu tiên giữ lại giao dịch
--- có thông tin đầy đủ, diễn ra sớm hơn và có UniqueID nhỏ nhất
Select *
From (
Select [Address], [City], LegalReference, Acreage, TaxDistrict, LandValue, BuildingValue, YearBuilt, Bedrooms, FullBath, HalfBath,
Rank() Over(Partition By [Address], [City], LegalReference Order By Acreage, TaxDistrict, LandValue, BuildingValue, YearBuilt, Bedrooms, FullBath, HalfBath) as [Rank]
From [Nashville-Housing]) as k1
Where [Rank] > 1

Select UniqueID, city, Address, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, SaleDate, LegalReference, OwnerName
From [Nashville-Housing]
Where Address = 'PATTERSON ST' and City = 'NASHVILLE'
Order By SaleDate, UniqueID

Delete From [Nashville-Housing]
Where UniqueID in
(
37587, 37588, 25676, 22704, 26208, 41085, 41086, 41087, 8412, 4515, 29944, 37576, 37581, 36140, 3261, 3449, 48696, 53841, 48698, 48699, 48700, 48701, 48702, 48703,
54576, 52200, 53610, 51949, 51950, 40638, 40642, 34306, 14547, 14549, 45437, 17030, 27201, 34611, 50720, 50721, 28221, 29552, 31525, 41994, 19975, 38235, 6043,
6044, 9347, 50725, 50726, 9835, 29532, 46069, 49043, 33217, 40029, 6048, 3773, 8349, 37777, 9838, 43142, 24935, 41245, 6902, 52033, 52887, 56203, 5862, 5863,
41740, 14334, 42588
)
------------------------------------------------------------------------------Data Exploration------------------------------------------------------------------------------------------------------
--- Dữ liệu bất thường ở tháng 05, 12 năm 2019 vì chỉ có 1 giao dịch phát sinh trong tháng và trước đó rất lâu không phát sinh giao dịch, xem xét lại có phải là lỗi nhập liệu năm 2016 
--- thành 2019 hay không
Select * 
From [Nashville-Housing]
Where Year(SaleDate) = 2019 And Month(SaleDate) in (05, 12)

--- Truy vấn total sales theo factor group by bất kỳ với từng tháng cụ thể hoặc từng năm
Create or Alter Procedure house1
@year int = 2013, @factor varchar(max), @factor1 varchar(max), @month date = '2013-01-01', @factor2 varchar(max)  = 'SalePrice'
as
declare @sql varchar(max)
if @factor1 = 'M'
Begin
	Set @sql=
	'Select ' + @factor +' as ' +@factor+', Sum('+@factor2+') as ' +@factor2+'
	From [Nashville-Housing] as n
	Where DATEFROMPARTS(Year(SaleDate), Month(SaleDate), 1) = ''' + cast(@month as varchar(20)) +'''
	Group by ' + @factor
End
Else if @factor1 = 'Y'
Begin
	Set @sql=
	'Select ' + @factor +' as ' +@factor+', Sum('+@factor2+') as ' +@factor2+'
	From [Nashville-Housing] as n
	Where Year(SaleDate) = ' + cast(@year as varchar(20)) +'
	Group by ' + @factor
End
Exec(@sql)
go
exec house1 @month = '2014-08-01', @factor = '[LandUse]', @factor1 = 'Y', @year = 2015, @factor2 = '[LandValue]'

--- Truy vấn dữ liệu time series theo từng yếu tố và phương thức tùy ý
Create or Alter Procedure house2
@factor varchar(max), @factor1 varchar(10), @factor2 varchar(20)
as
declare @sql varchar(max)
Begin
	Set @sql =
	'Select ' +@factor+', SaleDate, '+@factor1+'('+@factor2+') as ' +@factor2+'
	From [Nashville-Housing]
	Where '+@factor+' is Not Null
	Group by '+@factor+', SaleDate
	Order by 1, 2'
End
Exec(@sql)
Go
Exec house2 @factor = '[City]', @factor1 = 'Avg', @factor2 = '[SalePrice]'

---Truy vấn dữ liệu Top N SalePrice theo từng City tại từng năm hoặc Top N trên toàn bộ dữ liệu
Create or Alter Procedure house3
@factor varchar(20) = 'Total', @year int = 2015, @factor1 int = 5, @rank int
as
declare @sql varchar(max)
If @factor = 'Total'
Begin
	Set @sql =
	'Select Top '+cast(@factor1 as varchar(5))+' City, Sum(SalePrice) as [Total Sale Price]
	From [Nashville-Housing]
	Group by City
	Order By Max(SalePrice)'
Exec(@sql)
End
Else If @factor = 'Non-Total'
Begin
	Select *
	From
	(
	Select City, SaleDate, Sum(SalePrice) as [Total Sale Price],
	Rank() Over(Partition by City Order By Sum(SalePrice), Min(SaleDate)) as [Rank]
	From [Nashville-Housing]
	Where Year(SaleDate) = @year
	Group By City, SaleDate
	) as t
	Where [Rank] <= @rank
End
Go
Exec house3 @factor = 'Non-Total', @year = 2016, @rank = 5, @factor1 = 3

--- Truy vấn dữ liệu nằm trong Top N theo nhân tố bất kỳ
Create or Alter procedure house4 @factor varchar(20), @rank int
as
If @factor in ('LandValue', 'BuildingValue', 'TotalValue', 'SalePrice')
Begin
	Select *
	From
	(
	Select *,
	Rank() Over(Order BY @factor, YearBuilt DESC, Acreage, SaleDate) as [Rank]
	From [Nashville-Housing]
	) as t
	Where [Rank] <= @rank
	Order by [Rank]
End
Else
Begin
	Print('@factor must be in (LandValue, BuildingValue, TotalValue, SalePrice)')
End
Go
Exec house4 @factor = 'BuildingValue', @rank = 5

----- Nhập vào số thứ tự trả lại City có xếp hạng tổng doanh thu bán nhà bằng số thứ tự đó
Create or Alter procedure house5 @rank int
as
Select *
From
(
Select *,
Rank() over (Order by Total_Sale desc) as [Rank]
From
(
Select n.City, Sum(SalePrice) as Total_Sale 
From [Nashville-Housing] as n
Group by n.City
) as t1
) as t2
Where Rank = @rank
Go 
Exec house5 @rank = 1

----- Truy vấn dữ liệu group by nhân tố bất kỳ trong 1 khoảng thời gian nhất định theo phương thức lựa chọn
Create or Alter procedure house6 @date1 date, @date2 date, @factor varchar(20), @factor1 varchar(15), @factor2 varchar(20)
as
declare @sql varchar(max)
Begin
	Set @sql =
	'Select '+@factor+', '+@factor1+'('+@factor2+') as '+@factor2+'
	From [Nashville-Housing]
	Where SaleDate between '''+Cast(@date1 as varchar(20))+''' and '''+Cast(@date2 as varchar(20))+'''
	Group by '+@factor
Exec(@sql)
End
Go
Exec house6 @date1 = '2013-05-08', @date2 = '2015-09-07', @factor = '[City]', @factor1 = 'Max', @factor2 = '[LandValue]'

--- Nhập tên vào 1 trong các cột sau (LandUse, SoldAsVacant, Acreage, TaxDistrict, City, Owner City) để group by dữ liệu theo cột đó theo thời gian là day, month hoặc year.
Create or Alter procedure house7 @factor varchar(max) = 'City', @time varchar(max) = 'D', @factor1 varchar(max), @factor2 varchar(max)
as
declare @sql varchar(max)
if @factor not in ('LandUse', 'SoldAsVacant', 'Acreage', 'TaxDistrict', 'City', 'Owner City')
Begin
	Print('Input must be LandUse, SoldAsVacant, Acreage, TaxDistrict, City, Owner City')
End
Else If @time = 'D'
Begin
	Set @sql =
	'Select '+@factor+', SaleDate, '+@factor2+'('+@factor1+') as '+@factor1+'
	From [Nashville-Housing]
	Group by '+@factor+', SaleDate
	Order by '+@factor+', SaleDate Asc'
End
Else if @time = 'M'
Begin
	Set @sql =
	'Select '+@factor+', DATEFROMPARTS(YEAR(SaleDate), Month(SaleDate), 1) as [Month] ,'+@factor2+'('+@factor1+') as '+@factor1+'
	From [Nashville-Housing]
	Group by '+@factor+', DATEFROMPARTS(Year(SaleDate), Month(SaleDate), 1)
	Order by '+@factor+', [Month]'
End
Else if @time = 'Y'
Begin
	Set @sql =
	'Select '+@factor+', Year(SaleDate) as [Year], '+@factor2+'('+@factor1+') as '+@factor1+'
	From [Nashville-Housing]
	Group by '+@factor+', Year(SaleDate)
	Order by '+@factor+', [Year] Asc'
End
Exec(@sql)
Go
Exec house7 @time = 'Y',@factor = 'City', @factor1 = 'LandValue', @factor2 = 'Max'

--- Tạo function truy xuất dữ liệu nhà có giá bán lớn hơn biến @sale tại năm @year và cột LandUse là @LandUse
Create or alter function
table1(@year int, @sales float, @LandUse nvarchar(50))
returns table as return
(Select n.City, sum(SalePrice) as [Total Sale], Count(UniqueID) as [No.Order]
from [Nashville-Housing] as n
where year(SaleDate) = @year
and SalePrice > @sales
and LandUse = @LandUse
group by n.City)
Go
Select * from dbo.table1(2015,500000, 'SINGLE FAMILY')
Order by 1

---Truy xuất số lượng đơn hàng có giá bán lớn hơn biến @sale
declare @sale float = 1000000
declare @order int
while @sale <= (Select Max(SalePrice) From [Nashville-Housing])
Begin
	Set @order = (Select COUNT(distinct UniqueID) From [Nashville-Housing]
					where SalePrice > @sale)
	print('Total order with sales >= ' + cast(@sale as varchar) + ': ' + cast(@order as varchar))
	Set @sale = @sale + 500000
End

--- Truy vấn dữ liệu số căn nhà bán được theo từng tháng
Create or Alter procedure house8 @rank int, @factor varchar(10)
as
declare @date date = (select Min(DATEFROMPARTS(Year(SaleDate), MONTH(SaleDate),1)) from [Nashville-Housing])
While @date <= (select Max(DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1)) from [Nashville-Housing])
Begin
	Select DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1) as [Month],
			Count(distinct UniqueID) as [No.Order], Sum(SalePrice) as [Total Sale]
	From [Nashville-Housing]
	where @date = DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1)
	group by DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1)
	;
	print('Succesfully get total orders of month ' + cast(@date as varchar))
	;
	set @date = DATEADD(month, 1, @date)
	;
	If @date > (select Max(DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1)) from [Nashville-Housing])
	Begin
	If @factor = 'Order'
		Begin
			Select *
			From
			(
			Select DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1) as [Month],
				Count(distinct UniqueID) as [No.Order], Sum(SalePrice) as [Total Sale],
				Rank() Over(Order BY Sum(SalePrice) Desc) as [Rank_sale],
				Rank() Over(Order BY Count(distinct UniqueID) Desc) as [Rank_order]
			From [Nashville-Housing]
			Group by DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1)
			) as t1
			Where [Rank_order] <= @rank
		End
	Else if @factor = 'Sale'
		Begin
			Select *
			From
			(
			Select DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1) as [Month],
				Count(distinct UniqueID) as [No.Order], Sum(SalePrice) as [Total Sale],
				Rank() Over(Order BY Count(distinct UniqueID) Desc) as [Rank_order],
				Rank() Over(Order BY Sum(SalePrice) Desc) as [Rank_sale]
			From [Nashville-Housing]
			Group by DATEFROMPARTS(year(SaleDate), MONTH(SaleDate),1)
			) as t1
			Where [Rank_sale] <= @rank
		End
	End
End
Go
Exec house8 @factor = 'order', @rank = 5

--- Tạo hàng loạt bảng lưu dữ liệu giao dịch theo từng tháng và xóa khi không dùng
declare @date date = (Select Min(Datefromparts(Year(SaleDate), month(SaleDate),1)) from [Nashville-Housing])
declare @tablename nvarchar(max)
declare @sql_create nvarchar(max)
declare @sql_delete nvarchar(max)

While @date <= (Select Max(Datefromparts(Year(SaleDate), month(SaleDate),1)) from [Nashville-Housing])
Begin
	Set @tablename = 'sales_data_sample_' + replace(cast(@date as nvarchar(50)), '-', '_')
	;
	Set @sql_create = 
	'Select * into '+ @tablename +' from
	(Select * from dbo.[Nashville-Housing]
	where DATEFROMPARTS(Year(SaleDate), Month(SaleDate),1) = '''+ cast(@date as nvarchar(50)) + ''') as t1'
	;
	Set @sql_delete = 'Drop table if exists ' + @tablename
	;
	Exec(@sql_create)
	;
	Set @date = DATEADD(month, 1, @date)
End

--- Tạo hàng loạt bảng lưu dữ liệu giao dịch theo từng city và xóa khi không dùng
declare @rownum int = 1
declare @table_name nvarchar(max)
declare @city nvarchar(max)
declare @sql_create nvarchar(max)
declare @sql_delete nvarchar(max)

While @rownum <= (Select Count(Distinct city) From [Nashville-Housing])
Begin
	Set @city =
	(Select City
	From
	(Select *,
	Rank() Over(order by City asc) as [Rank]
	From
	(Select Distinct City
	From [Nashville-Housing]) t1) t2
	Where [Rank] = @rownum)
	;
	Set @table_name = 'sales_data_sample_' + replace(lower(@city), ' ', '_')
	;
	Set @sql_create = 
	'Select * Into '+ @table_name +' From
	(Select * From [Nashville-Housing]
	Where City = '''+ @city +''') t1'
	;
	Set @sql_delete = 'Drop table if exists ' + @table_name
	;
	Exec(@sql_create)
	;
	Set @rownum = @rownum + 1
End

----- Truy vấn dữ liệu số lượng giao dịch mỗi tháng và tháng có số lượng giao dịch lớn hơn số lượng giao dịch (@number) cho trước
Create or Alter procedure house9 
@number int
as
declare @date date =
(Select Min(Datefromparts(Year(SaleDate), Month(SaleDate),1)) 
from [Nashville-Housing]
)
Declare @order int

while @date <=
(Select Max(Datefromparts(Year(SaleDate), Month(SaleDate),1))
from [Nashville-Housing]
)
begin
	set @order = 
				(select COUNT(distinct UniqueId) 
				from [Nashville-Housing]
				where Datefromparts(Year(SaleDate), Month(SaleDate),1) = @date)
	if @order <= @number
		print( 'Total order of month ' + cast(@date as nvarchar(20)) + ' is:' + cast(@order as nvarchar(20)))
	else
		print('Total order of month ' + cast(@date as nvarchar(20)) + ' is:' + cast(@order as nvarchar(20)) + '(Total order > '+Cast(@number as varchar(10))+')')

	set @date = DATEADD(MONTH, 1, @date)
end
Go
Exec house9 @number = 1700

-----So sánh số lượng đơn hàng của tháng hiện tại với tháng liền trước
Declare @date date =
(Select Min(Datefromparts(Year(SaleDate), Month(SaleDate),1)) 
From [Nashville-Housing])
Declare @order int
Declare @order_lastmonth int

While @date <=
(Select MAX(DATEFROMPARTS(Year(SaleDate), MONTH(SaleDate), 1))
From [Nashville-Housing]
)
Begin
	Set @order = 
				(Select COUNT(Distinct UniqueID)
				From [Nashville-Housing]
				Where DATEFROMPARTS(Year(SaleDate), MONTH(SaleDate), 1) = @date)
	Set @order_lastmonth = 
				(Select COUNT(Distinct UniqueID)
				From [Nashville-Housing]
				Where DATEFROMPARTS(Year(SaleDate), MONTH(SaleDate), 1) = DATEADD(MONTH, -1, @date))
	--1.@order > @order_lastmonth
	If @order > @order_lastmonth
		Print( 'Total order of month ' + Cast(@date as nvarchar(20)) + ' is:' + Cast(@order as nvarchar(20))
		+ ', more than last month: ' + Cast(@order - @order_lastmonth as nvarchar(50)))
	--2.@order > @order_lastmonth
	Else If @order < @order_lastmonth
		Print( 'Total order of month ' + Cast(@date as nvarchar(20)) + ' is:' + Cast(@order as nvarchar(20))
		+ ', less than last month: ' + Cast(@order_lastmonth - @order as nvarchar(50)))
	--3.@order = @order_lastmonth
	Else
		Print( 'Total order of month ' + Cast(@date as nvarchar(20)) + ' is:' + Cast(@order as nvarchar(20))
		+ ', equal last month ')
	Set @date = DATEADD(MONTH, 1, @date)
End

--- Truy vấn dữ liệu tổng giao dịch của từng tháng, với mỗi tháng trả lại ngày có số lượng giao dịch cao nhất của tháng
Declare @date date = (Select Min(DATEFROMPARTS(Year(SaleDate), Month(SaleDate),1)) From [Nashville-Housing])
Declare @order int
Declare @datemax date
Declare @ordermax int
while @date <= (Select Max(DATEFROMPARTS(YEAR(SaleDate), Month(SaleDate),1)) From [Nashville-Housing])
Begin
	--1. Nhận biến @order
	Set @order = 
	(Select Count(Distinct(UniqueID))
	From [Nashville-Housing]
	where DATEFROMPARTS(YEAR(SaleDate), Month(SaleDate),1) = @date)

	--2. @datemax
	Set @datemax = 
	(
	Select SaleDate 
	from (
	Select SaleDate, Row_number () over(order by NumberofOrder desc) as rank_num 
	from(
	Select SaleDate, Count(Distinct(UniqueID)) as NumberofOrder 
	from [Nashville-Housing]
	where DATEFROMPARTS(Year(SaleDate), Month(SaleDate),1) = @date
	group by SaleDate) as t1) as t2
	where rank_num = 1
	)

	--3. ordermax
	Set @ordermax =
	(
	Select COUNT(Distinct(UniqueID))
	from [Nashville-Housing]
	where SaleDate = @datemax
	)

	print('Total order of month ' + cast(@date as varchar(50)) + ' is: ' + cast(@order as varchar(50)) + ' . Date with max order is ' + cast(@datemax as varchar(50)) + ' : ' + cast(@ordermax as varchar(50)))

	Set @date = DATEADD(month,1,@date)
End

---Truy vấn dữ liệu trả lại tổng giao dịch của từng city theo thứ tự A-Z và đồng thời trả lại Landuse có số lượng sales cao nhất của từng City
declare @city nvarchar(max)
declare @rank int = 1
declare @sales float
declare @landuse_max nvarchar(max)
declare @sales_max float

While @rank <= (Select Count(Distinct City) From [Nashville-Housing])
Begin
	--1. gắn dữ liệu cho biến city
	Set @city = 
	(
	Select City
	From(
	Select * , Rank() over (order by City asc) as [Rank]
	From(
	Select Distinct City
	From [Nashville-Housing]) as t1) as t2
	where [Rank] = @rank
	)

	--2. tính tổng sales của city
	Set @sales =
	(
	Select Sum(SalePrice)
	From [Nashville-Housing]
	Where City = @city
	)

	--3. Tính landuse có số sale cao nhất
	Set  @landuse_max = 
	(
	Select LandUse
	From (
	Select Top 1 LandUse, Sum(SalePrice) as [Total Sale]
	From [Nashville-Housing]
	Where City = @city
	Group by LandUse
	Order by [Total Sale] desc) as t1
	)

	--4. Tính tổng sales của landuse có số sale cao nhất
	Set @sales_max = 
	(
	Select Sum(SalePrice) as [Total Sale]
	From [Nashville-Housing]
	Where City = @city And LandUse = @landuse_max
	Group by LandUse
	)

	print('Sales of city '+ @city + ' is ' + cast(@sales as nvarchar(max)) + '. Top 1 Landuse is ' + @landuse_max + ': ' + cast(@sales_max as varchar(max)))


	set @rank = @rank + 1
end

-----------------------------------------------------------------Power BI Star Schema----------------------------------------------------------------------
--- Xóa dữ liệu nghi ngờ nhập liệu sai
Delete From [Nashville-Housing]
Where UniqueID in
(
Select UniqueID 
From [Nashville-Housing]
Where Year(SaleDate) = 2019 And Month(SaleDate) in (05, 12)
)

----- Chuyển các giá trị Null trong các cột sang chữ N vì nếu NUll sẽ không Join các bảng với nhau tạo bảng Dim được
Update [Nashville-Housing]
Set [Ownername] = Isnull([Ownername],'N')

Update [Nashville-Housing]
Set [Owner City] = Isnull([Owner City],'N')

Update [Nashville-Housing]
Set [Owner Address] = Isnull([Owner Address],'N')

Update [Nashville-Housing]
Set [Owner State] = Isnull([Owner State],'N')

Update [Nashville-Housing]
Set [Acreage] = Isnull([Acreage],'N')

Update [Nashville-Housing]
Set [TaxDistrict] = Isnull([TaxDistrict],'N')

Update [Nashville-Housing]
Set [LandValue] = Isnull([LandValue],0)

Update [Nashville-Housing]
Set [BuildingValue] = Isnull([BuildingValue],0)

Update [Nashville-Housing]
Set [TotalValue] = Isnull([TotalValue],0)

Update [Nashville-Housing]
Set [YearBuilt] = Isnull([YearBuilt],0)

Update [Nashville-Housing]
Set [Bedrooms] = Isnull([Bedrooms],0)

Update [Nashville-Housing]
Set [FullBath] = Isnull([FullBath],0)

Update [Nashville-Housing]
Set [HalfBath] = Isnull([HalfBath],0)


----- Dim LandUse
Select *, ROW_NUMBER() Over (Order By LandUse) as [LanduseIndex]
From(
Select Distinct LandUse
From [Nashville-Housing]) as dimlanduse

----- Dim SoldasVacant
Select *,
Case When SoldAsVacant = 'No' Then 0
	 Else 1
End as [SoldasVacantIndex]
From(
Select Distinct SoldAsVacant
From [Nashville-Housing]) as dimsoldasvacant

--- Dim City
Select *, ROW_NUMBER() Over(Order by City) as [CityIndex]
From(
Select Distinct City
From [Nashville-Housing]
Union
Select Distinct [Owner City]
From [Nashville-Housing]) as dimcity

----- Dim Owner
With dimownera as
(
Select *,
ROW_NUMBER() Over(Order by OwnerName, [Owner Address], [Owner City], [Owner State]) as [OwnerIndex]
From(
Select Distinct OwnerName, [Owner Address], [Owner City], [Owner State]
From [Nashville-Housing]) as dimowner1),
dimownerb as
(Select *, ROW_NUMBER() Over(Order by City) as [CityIndex]
From(
Select Distinct City
From [Nashville-Housing]
Union
Select Distinct [Owner City]
From [Nashville-Housing]) as dimowner2)
Select dimownera.OwnerName, dimownera.[Owner Address], dimownerb.CityIndex, dimownera.[Owner State], dimownera.OwnerIndex
From dimownera Left Join dimownerb
On dimownera.[Owner City] = dimownerb.City

----- Dim Sub House
With dimsubhousea as
(Select *, ROW_NUMBER() Over(Order By Address, City) as AddressCityIndex
From(
Select Distinct Address, City From [Nashville-Housing]) as dimsubhouse1),
dimsubhouseb as
(Select *, ROW_NUMBER() Over(Order by City) as [CityIndex]
From(
Select Distinct City
From [Nashville-Housing]
Union
Select Distinct [Owner City]
From [Nashville-Housing]) as dimsubhouse2)
Select dimsubhousea.Address, dimsubhouseb.CityIndex, dimsubhousea.AddressCityIndex 
From dimsubhousea
Left Join dimsubhouseb
On dimsubhousea.City = dimsubhouseb.City

----- Dim House
With dimhousea as
(Select *, ROW_NUMBER() Over(Order By Address, City) as AddressCityIndex
From(
Select Distinct Address, City From [Nashville-Housing]) as dimhouse1),
dimhouseb as
(Select Distinct [Address], [City], Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath
From [Nashville-Housing]),
dimhousec as
(Select dimhousea.AddressCityIndex, dimhouseb.Acreage, dimhouseb.TaxDistrict, dimhouseb.LandValue, dimhouseb.BuildingValue, dimhouseb.TotalValue, 
dimhouseb.YearBuilt, dimhouseb.Bedrooms, dimhouseb.FullBath, dimhouseb.HalfBath
From dimhouseb Left Join dimhousea
On dimhouseb.Address = dimhousea.Address And dimhouseb.City = dimhousea.City)
Select *,
ROW_NUMBER() Over(Order By AddressCityIndex, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath) as HouseIndex
From dimhousec

----- Fact Sale

With fact1 as 
(
Select fact.*, dimcity1.CityIndex
From [Nashville-Housing] as fact
Left Join 
(Select *, ROW_NUMBER() Over(Order by City) as [CityIndex]
From(
Select Distinct City
From [Nashville-Housing]
Union
Select Distinct [Owner City]
From [Nashville-Housing]) as dimcity) as dimcity1
On fact.City = dimcity1.City
),
fact2 as
(
Select *, ROW_NUMBER() Over(Order by City) as [CityIndex]
From(
Select Distinct City
From [Nashville-Housing]
Union
Select Distinct [Owner City]
From [Nashville-Housing]) as dimcity
),
fact3 as
(
Select fact1.*, fact2.CityIndex as [OwnerCityIndex]
From fact1
Left Join fact2
On fact1.[Owner City] = fact2.City
),
fact4 as
(
Select *,
ROW_NUMBER() Over(Order by OwnerName, [Owner Address], [Owner City], [Owner State]) as [OwnerIndex]
From(
Select Distinct OwnerName, [Owner Address], [Owner City], [Owner State]
From [Nashville-Housing]) as dimowner1
),
fact5 as
(
Select *, ROW_NUMBER() Over(Order by City) as [CityIndex]
From(
Select Distinct City
From [Nashville-Housing]
Union
Select Distinct [Owner City]
From [Nashville-Housing]) as dimowner2
),
fact6 as
(
Select fact4.OwnerName, fact4.[Owner Address], fact5.CityIndex, fact4.[Owner State], fact4.OwnerIndex
From fact4 Left Join fact5
On fact4.[Owner City] = fact5.City
),
fact7 as
(
Select fact3.UniqueId, fact3.ParcelID, fact3.LandUse, fact3.LegalReference, fact3.SoldAsVacant, fact6.OwnerIndex,
fact3.Acreage, fact3.TaxDistrict, fact3.LandValue, fact3.BuildingValue, fact3.TotalValue, fact3.YearBuilt, fact3.Bedrooms,
fact3.FullBath, fact3.HalfBath, fact3.SalePrice, fact3.Address, fact3.CityIndex,fact3.SaleDate
From fact3
Left join fact6
On fact3.OwnerName = fact6.OwnerName
And (fact3.[Owner Address] = fact6.[Owner Address])
And (fact3.[Owner State] = fact6.[Owner State])
And (fact3.OwnerCityIndex = fact6.CityIndex)
),
fact8 as
(
Select *, ROW_NUMBER() Over(Order By Address, City) as AddressCityIndex
From(
Select Distinct Address, City From [Nashville-Housing]) as dimsubhouse1
),
fact9 as
(
Select *, ROW_NUMBER() Over(Order by City) as [CityIndex]
From(
Select Distinct City
From [Nashville-Housing]
Union
Select Distinct [Owner City]
From [Nashville-Housing]) as dimsubhouse2
),
fact10 as
(
Select fact8.Address, fact9.CityIndex, fact8.AddressCityIndex 
From fact8
Left Join fact9
On fact8.City = fact9.City),
fact11 as
(
Select fact7.*, fact10.AddressCityIndex 
From fact7
Left Join fact10
On fact7.Address = fact10.Address
And fact7.CityIndex = fact10.CityIndex),
fact12 as
(
Select *, ROW_NUMBER() Over(Order By Address, City) as AddressCityIndex
From(
Select Distinct Address, City From [Nashville-Housing]) as dimhouse1
),
fact13 as
(
Select Distinct [Address], [City], Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath
From [Nashville-Housing]
),
fact14 as
(
Select fact12.AddressCityIndex, fact13.Acreage, fact13.TaxDistrict, fact13.LandValue, fact13.BuildingValue, fact13.TotalValue, 
fact13.YearBuilt, fact13.Bedrooms, fact13.FullBath, fact13.HalfBath
From fact13 Left Join fact12
On fact13.Address = fact12.Address And fact13.City = fact12.City
),
fact15 as
(
Select *,
ROW_NUMBER() Over(Order By AddressCityIndex, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath) as HouseIndex
From fact14
),
fact16 as
(
Select fact11.UniqueID, fact11.ParcelID, fact11.LandUse, fact11.LegalReference, fact11.SoldAsVacant, fact11.SalePrice, fact11.SaleDate, fact11.OwnerIndex, fact15.HouseIndex
From fact11
Left Join fact15
On fact11.AddressCityIndex = fact15.AddressCityIndex
And fact11.Acreage = fact15.Acreage
And fact11.TaxDistrict = fact15.TaxDistrict
And fact11.LandValue = fact15.LandValue
And fact11.TotalValue = fact15.TotalValue
And fact11.YearBuilt = fact15.YearBuilt
And fact11.Bedrooms = fact15.Bedrooms
And fact11.FullBath = fact15.FullBath
And fact11.HalfBath = fact15.HalfBath
Where fact11.TotalValue <> 0 ----- Bỏ các dòng mà trên bảng Fact có giá trị TotalValue = 0 vì nếu TotalValue = 0 thì tính toán các KPI sẽ bị sai
),
fact17 as
(
Select *, ROW_NUMBER() Over (Order By LandUse) as [LanduseIndex]
From(
Select Distinct LandUse
From [Nashville-Housing]) as dimlanduse
),
fact18 as
(
Select fact16.UniqueId, fact16.ParcelId, fact17.LanduseIndex, fact16.LegalReference, fact16.SoldAsVacant, fact16.SalePrice, fact16.SaleDate, fact16.OwnerIndex, fact16.HouseIndex
From fact16
Left Join fact17
On fact16.LandUse = fact17.LandUse
),
fact19 as
(
Select *,
Case When SoldAsVacant = 'No' Then 0
	 Else 1
End as [SoldasVacantIndex]
From(
Select Distinct SoldAsVacant
From [Nashville-Housing]) as dimsoldasvacant
)
Select fact18.UniqueId,  fact18.ParcelId, fact18.LanduseIndex, fact18.LegalReference, fact19.SoldAsVacantIndex, fact18.SalePrice, fact18.SaleDate, fact18.OwnerIndex, fact18.HouseIndex
From fact18
Left Join fact19
On fact18.SoldAsVacant = fact19.SoldasVacant





