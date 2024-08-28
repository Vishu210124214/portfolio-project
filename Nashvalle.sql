select*
from[portfolio project].[dbo].[ sheet1$]


--Standardise date format

select saledateConverted, convert(date, saledate)
from [portfolio project].[dbo].[ sheet1$]

update [portfolio project].[dbo].[ sheet1$]
set saledate = convert (date,saledate)

alter table  [portfolio project].[dbo].[ sheet1$]
add SaleDateConverted date;

update [portfolio project].[dbo].[ sheet1$]
Set SaleDateConverted = convert(date, saledate)

--populate property address data

select *
from[portfolio project].[dbo].[ sheet1$]
where propertyaddress is null
--order by parcelId


select a.ParcelID, a.propertyAddress, b.ParcelID, b.propertyAddress, isnull(a.propertyaddress, b.propertyaddress)
from[portfolio project].[dbo].[ sheet1$] [a]
join [portfolio project].[dbo].[ sheet1$ ] [b]
  on a.ParcelID = b.ParcelID
  AND a.[UniqueId]<> b.[UniqueId]
  where a.propertyAddress is null

update a
Set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from[portfolio project].[dbo].[ sheet1$] [a]
join [portfolio project].[dbo].[ sheet1$ ] [b]
  on a.ParcelID = b.ParcelID
  AND a.[UniqueId]<> b.[UniqueId]
  where a.propertyAddress is null

--breaking out address into individual columns(Address, city, state)

select propertyaddress
from[portfolio project].[dbo].[ sheet1$]
--where propertyaddress is null
--order by parcelId

select
substring (propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
, substring (propertyaddress,  CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as Address
from[portfolio project].[dbo].[ sheet1$]

alter table  [portfolio project].[dbo].[ sheet1$]
add PropertySplitAddress Nvarchar(255);

update [portfolio project].[dbo].[ sheet1$]
Set PropertySplitAddress = substring (propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

alter table  [portfolio project].[dbo].[ sheet1$]
add PropertySplitCity Nvarchar(255);

update [portfolio project].[dbo].[ sheet1$]
Set PropertySplitCity = substring (propertyaddress,  CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

select*
from[portfolio project].[dbo].[ sheet1$]


--owneraddress

Select ownerAddress
from[portfolio project].[dbo].[ sheet1$]

select
parsename(Replace(owneraddress, ',', '.'), 3),
parsename(Replace(owneraddress, ',', '.'), 2),
parsename(Replace(owneraddress, ',', '.'), 1)
from[portfolio project].[dbo].[ sheet1$]

alter table  [portfolio project].[dbo].[ sheet1$]
add ownerSplitAddress Nvarchar(255);

update [portfolio project].[dbo].[ sheet1$]
Set ownerSplitAddress = parsename(Replace(owneraddress, ',', '.'), 3)

alter table  [portfolio project].[dbo].[ sheet1$]
add ownerSplitCity Nvarchar(255);

update [portfolio project].[dbo].[ sheet1$]
Set ownerSplitCity = parsename(Replace(owneraddress, ',', '.'), 2)

alter table  [portfolio project].[dbo].[ sheet1$]
add ownerSplitState Nvarchar(255);

update [portfolio project].[dbo].[ sheet1$]
Set ownerSplitState = parsename(Replace(owneraddress, ',', '.'), 1)

select*
from[portfolio project].[dbo].[ sheet1$]

--Change Y and N to Yes and No in "Sold as vacant" feild

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from[portfolio project].[dbo].[ sheet1$]
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
  case when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
       else SoldAsVacant
       End
from[portfolio project].[dbo].[ sheet1$]

Update [portfolio project].[dbo].[ sheet1$]
Set SoldAsVacant =  case when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
       else SoldAsVacant
       End

--Remove Duplicates

With RowNumCTE AS(
Select*,
Row_Number() over(
partition by 
parcelID,
propertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by
   UniqueId
   )Row_num

from[portfolio project].[dbo].[ sheet1$]
--order by ParcelID
)

Select*
from RowNumCTE
Where row_num > 1
--order by propertyAddress


--Delete Unused columns


select*
from[portfolio project].[dbo].[ sheet1$]

Alter table [portfolio project].[dbo].[ sheet1$]
Drop Column ownerAddress, TaxDistrict, PropertyAddress

Alter table [portfolio project].[dbo].[ sheet1$]
Drop Column SaleDate