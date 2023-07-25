/*
Data Cleaning in SQL Queries
*/ 
--Show Table with all rows and columns
Select * 
From PortfolioProject..NashvilleHousing

--Standarized Date Format
Select SaleDateConverted, CONVERT(date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

--Populate Property Address data

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing as a
JOIN NashvilleHousing as b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing as a
JOIN NashvilleHousing as b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is Null


--Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where a.PropertyAddress is Null

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As Address

FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select * 
FROM NashvilleHousing

--Split OwnerAddress
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
, PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1) as State
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1)

Select * 
FROM NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" Fields

Select Distinct(SoldAsVacant)
FROM NashvilleHousing

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
Order by 2

Select SoldAsVacant
, Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	END



--Remove Duplicates

WITH RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
						) row_num

FROM NashvilleHousing
--ORDER BY ParcelID
)
Select *
FROM RowNumCTE
WHERE row_num >1
ORDER BY ParcelID

Select *
FROM NashvilleHousing


--Delete Unused Columns

Select *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerName, TaxDistrict, SaleDate