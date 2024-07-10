USE PortfolioProjects;
GO
/*

Cleaning Data in SQL Queries

*/

--------------------------------------------------------------------------------------------------------------------------

SELECT * from PortfolioProjects..NashvilleHousing;
-- Standardize Date Format


-- If it doesn't Update properly




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT *
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress is NULL;
order by ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress is NULL;
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address
FROM PortfolioProjects..NashvilleHousing;

ALTER TABLE NashvilleHousing 
ADD PropertySpiltAddress Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE NashvilleHousing 
ADD PropertySplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT * FROM PortfolioProjects..NashvilleHousing;





SELECT OwnerAddress 
FROM PortfolioProjects..NashvilleHousing;


SELECT 
PARSENAME(Replace(OwnerAddress,',', '.' ),3)
, PARSENAME(Replace(OwnerAddress,',', '.' ),2)
, PARSENAME(Replace(OwnerAddress,',', '.' ),1)
FROM PortfolioProjects..NashvilleHousing;


ALTER TABLE NashvilleHousing 
ADD OwnerSpiltAddress Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(Replace(OwnerAddress,',', '.' ),3);


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.' ),2);


ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.' ),1)

--------------------------------------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant) 
FROM PortfolioProjects..NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From PortfolioProjects..NashvilleHousing;

Update NashvilleHousing 
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From PortfolioProjects..NashvilleHousing;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE As(

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             ORDER BY
             UniqueID)
             row_num
from PortfolioProjects..NashvilleHousing
)

--order by ParcelID

SELECT *
FROM RowNumCTE
where row_num > 1
ORDER by PropertyAddress;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM PortfolioProjects..NashvilleHousing;


ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProjects..nashvilleHousing
DROP COLUMN SaleDate






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









