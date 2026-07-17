/*

Cleaning Data in SQL Queries


*/

select *
from PortfolioProject.dbo.NashvilleHousing


---------------------------------------

-- Standardize data format

select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)



--------------------------------------------------------

-- Populate Property Address Data

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null -- <> means not equal

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null


---------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, city, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) 

-- see the table

select PropertySplitAddress, PropertySplitCity
from PortfolioProject..NashvilleHousing

select OwnerAddress
from PortfolioProject..NashvilleHousing

select OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
, PARSENAME(Replace(OwnerAddress, ',','.'), 2)
, PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)


select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject..NashvilleHousing


------------------------------------------------------
-- change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from ..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from ..NashvilleHousing


update NashvilleHousing
set	SoldAsVacant = 
case 
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

---------------------------------------------------

-- Remove Duplicates
select *
from ..NashvilleHousing


WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num



from ..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1









-------------------------------------

-- Deleted Unused Columns

Select *
from ..NashvilleHousing


ALTER TABLE ..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ..NashvilleHousing
DROP COLUMN saleDate

