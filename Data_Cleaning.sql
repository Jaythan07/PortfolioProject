/*

Cleaning Data in SQL Queries

*/
SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT
	SaleDateConverted,
	CONVERT(DATE, SaleDate)
FROM 
	PortfolioProject1.dbo.NashvilleHousing


UPDATE PortfolioProject1.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- If it doesn't Update properly

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT
	*
FROM 
	PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
	PropertyAddress
FROM 
	PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM 
	PortfolioProject1.dbo.NashvilleHousing
	


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProject1.dbo.NashvilleHousing



Select 
	OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject1.dbo.NashvilleHousing



ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select 
	Distinct(SoldAsVacant),
	Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End
From PortfolioProject1.dbo.NashvilleHousing

Update PortfolioProject1.dbo.NashvilleHousing
Set SoldAsVacant = 
		Case When SoldAsVacant = 'Y' Then 'Yes'
			 When SoldAsVacant = 'N' Then 'No'
			 Else SoldAsVacant
			 End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num

From PortfolioProject1.dbo.NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject1.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate










-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


