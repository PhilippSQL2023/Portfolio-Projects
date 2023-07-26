/*

Data clearing project

*/


Select *
From [Portfolio Project]..NashvilleHousing


-- Standardize date format

SELECT SaleDateConverted, CONVERT(Date,Saledate)
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate property address data

SELECT *
FROM [Portfolio Project]..NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
	JOIN [Portfolio Project]..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
	JOIN [Portfolio Project]..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- seperating PropertyAdress into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address


FROM [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT*
FROM [Portfolio Project]..NashvilleHousing


-- same for OwnerAddress but with different querie

SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change of Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END


-- Removal of duplicates


WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM [Portfolio Project]..NashvilleHousing
)


--DELETE
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Delete unused columns (for example in self-created views)

SELECT*
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



