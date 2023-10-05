select * from Nashville
EXEC sp_rename 'Nashville.SplitCity', 'ProperySplitCity', 'COLUMN'


update Nashville
set SaleDate = convert(date, SaleDate) from Nashville


alter table Nashville
add SaleDateConvert date;

update Nashville
set SaleDateConvert = convert(date, SaleDate) from Nashville



-- filling the PropertuAddress that is NULL based on ParcelID
select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, isnull(n1.PropertyAddress, n2.PropertyAddress)
from Nashville n1
join Nashville n2
on n1.ParcelID = n2.ParcelID
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null

update n1
set PropertyAddress = isnull(n1.PropertyAddress, n2.PropertyAddress)
from Nashville n1
join Nashville n2
on n1.ParcelID = n2.ParcelID
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null



-- Splitting String PropertyAddress with the 1st variation
select PropertyAddress,
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from Nashville


alter table Nashville
add PropertySplitAddress nvarchar(255);

update Nashville
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

alter table Nashville
add PropertySplitCity nvarchar(255);

update Nashville
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



--Splitting string OwnerAddress with 2nd variation
select 
OwnerAddress, 
PARSENAME( REPLACE(OwnerAddress, ',','.'),3),
PARSENAME( REPLACE(OwnerAddress, ',','.'),2),
PARSENAME( REPLACE(OwnerAddress, ',','.'),1)
from Nashville


alter table Nashville
add OwnerSplitAddress nvarchar(255);

update Nashville
set OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress, ',','.'),3)

alter table Nashville
add OwnerSplitCity nvarchar(255);

update Nashville
set OwnerSplitCity = PARSENAME( REPLACE(OwnerAddress, ',','.'),2)

alter table Nashville
add OwnerSplitState nvarchar(255);

update Nashville
set OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',','.'),1)





-- Converting 'N' to 'No and 'Y' to 'Yes' for the SoldAsVacant column
select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville
group by SoldAsVacant
order by 2


select SoldAsVacant, 
case	WHEN SoldAsVacant = 'N' then 'No'
		when SoldAsVacant = 'Y' then 'Yes'
		else SoldAsVacant
		end as column_baru
from Nashville


update Nashville
set SoldAsVacant = case	WHEN SoldAsVacant = 'N' then 'No'
		when SoldAsVacant = 'Y' then 'Yes'
		else SoldAsVacant
		end 



-- Check for duplicates 1st variation
with dupes as(
select 
*, 
ROW_NUMBER() over (partition by ParcelID, PropertyAddress,SalePrice,SaleDate, Legalreference order by UniqueID) as Dupes_count
from Nashville
)

select *
from dupes
where Dupes_count >1

-- Check for duplicates 2nd variation
select*,x.Dupes_Count
from(
select 
*, 
ROW_NUMBER() over (partition by ParcelID,SalePrice,SaleDate, Legalreference order by UniqueID) as Dupes_Count
from Nashville
) x
where Dupes_Count >1



alter table nashville
drop column PropertyAddress, OwnerAddress, TaxDistrict