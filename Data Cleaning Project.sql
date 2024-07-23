/*
Cleaning data in sql Queries 

*/

SELECT * 
FROM Nashville

---------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM Nashville

ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------

-- Populate Property Address Data

SELECT PropertyAddress
FROM Nashville
WHERE PropertyAddress IS NULL

/* THERE ARE 29 NULL */

SELECT *
FROM Nashville
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
	ON a.ParcelID = b.ParcelID AND
	a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
	ON a.ParcelID = b.ParcelID AND
	a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- (29 rows affected)

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT
TRIM(SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) - 1)) as Address,
TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))) as City
FROM Nashville

ALTER TABLE Nashville
ADD PropertySplitAddress nvarchar(255);

UPDATE Nashville
SET PropertySplitAddress = TRIM(SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) - 1)) 

ALTER TABLE Nashville
ADD PropertySplitCity nvarchar(255);

UPDATE Nashville
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)))


--- OWNER ADDRESS

select *
from Nashville

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville

ALTER TABLE Nashville
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Nashville
ADD OwnerSplitCity nvarchar(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville
ADD OwnerSplitState nvarchar(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
from Nashville
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Yeses' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM Nashville
	
UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Yeses' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNUM_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID) row_num
FROM Nashville
--ORDER BY ParcelID
)

DELETE  
FROM RowNUM_CTE
WHERE row_num > 1
--order by ParcelID

-- DELETED 104 DUPLICATED ROWS


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



