
--Data Cleaning by SQL Queries-------------------------------------------------------------------------------------------------------------------------------

select * 
from PortfolioProject..NashvilleHousing

--Standardize Date format------------------------------------------------------------------------------------------------------------------------------------

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date

select SaleDate, SaleDateConverted
from PortfolioProject..NashvilleHousing

--Populate Property address data-------------------------------------------------------------------------------------------------------------------------------

select *
from PortfolioProject..NashvilleHousing
where  PropertyAddress is NULL
ORDER BY ParcelID

Select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

select *
from PortfolioProject..NashvilleHousing
where  PropertyAddress is NULL  

--Breaking out Address into individual columns(Address, City, State)-------------------------------------------------------------------------------------------
--Using SUBSTRING() and CHARINDEX()

select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

-- Owner Address using PARSENAME() and REPLACE()

Select OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in 'SoldAsVacant' field-------------------------------------------------------------------------------------------------------

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
set SoldAsVacant = 
CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
END

--Remove Duplicates----------------------------------------------------------------------------------------------------------------------------------------
--Using CTE, Partition By and window function ROW_NUMBER()

With Row_numCTE AS 
(
Select * , 
ROW_NUMBER() over( Partition By 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order By UniqueID) AS ROW_NUM
from PortfolioProject..NashvilleHousing
)
Delete from Row_numCTE
where ROW_NUM > 1

--Delete Unused Columns-------------------------------------------------------------------------------------------------------------------------------------

Alter table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

Select * from PortfolioProject..NashvilleHousing
