/*
Cleaning Data in SQL Queries
*/

Select *
From MyPortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------

-- Standarize Data Format

Select SaleDataConverted, SaleDate, CONVERT(date,SaleDate)
From MyPortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDataConverted Date;

Update NashvilleHousing
SET SaleDataConverted = CONVERT(date, SaleDate)

---------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From MyPortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress IS NULL
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From MyPortfolioProject.dbo.NashvilleHousing a
JOIN MyPortfolioProject.dbo.NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ]<> b.[UniqueID ] 


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From MyPortfolioProject.dbo.NashvilleHousing a
JOIN MyPortfolioProject.dbo.NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ]<> b.[UniqueID ] 

--------------------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From MyPortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress IS NULL
--Order By ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From MyPortfolioProject.dbo.NashvilleHousing

ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update MyPortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update MyPortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From MyPortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From MyPortfolioProject.dbo.NashvilleHousing
Where OwnerAddress is not null

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
     , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
     , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From MyPortfolioProject.dbo.NashvilleHousing
Where OwnerAddress is not null


ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update MyPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update MyPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update MyPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From MyPortfolioProject.dbo.NashvilleHousing
where OwnerAddress IS NOT NULL


---------------------------------------------------------------------------------------------------

--Change Y and N to yes and No in "So ld as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From MyPortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select Distinct(SoldAsVacant)
, Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From MyPortfolioProject.dbo.NashvilleHousing

Update MyPortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
				   When SoldAsVacant = 'N' Then 'No'
				   Else SoldAsVacant
				   End

---------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as
(
Select *, ROW_NUMBER() OVER (
          PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		  Order By UniqueId) row_num

From MyPortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)
Delete
From RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From MyPortfolioProject.dbo.NashvilleHousing

Alter Table MyPortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table MyPortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate




