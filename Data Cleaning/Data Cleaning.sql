/*Cleaning Data in SQL


*/


Select *
From PortfolioProject.dbo.NashVilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------Standarize Data Format---------------------------------

--Date is currently in a data-time Format. Data will be converted into a date format


---Seeing potential conversion
Select Saledate, Convert(Date, SaleDate)
From PortfolioProject.dbo.NashVilleHousing

---Adding new column
ALTER TABLE NashVilleHousing
Add SaleDateConverted Date;

--Updating NashVilleHousing table with new column. SaleDateConverted to Date Format
Update NashVilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

---------------------------------Populate Property Address Data---------------------------------

--Seeing what fields are null in The "Property Address"
Select *
From PortfolioProject.dbo.NashVilleHousing
Where PropertyAddress is null 
order by parcelID



--Based on the previous code above, we can see that the Propertyaddress field is associated to the OwnerAddress field as they always match. In addition, we can see that sometimes more then one PropertyAddress is associated to the parcelID. 
--Joined the same tables together to determine that if two parcelIDs match, then the PropertyAddress should be updated accordingly 
Select a.parcelID,a.PropertyAddress,b.parcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID]
--Where a.PropertyAddress is null 



--If a.PropertyAddress is null then it will update with b.PropertyAddress
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

--Seeing what current PropertyAddress field looks like 
Select PropertyAddress
From PortfolioProject.dbo.NashVilleHousing


--Breaking up street address and city from PropertyAddress Field (View)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--Adds table "PropertySplitAddress" value
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

--Updates address split 
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--Adds table "PropertySplitCity" value
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

--Updates city 
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--View
Select *
From PortfolioProject.dbo.NashvilleHousing

--View
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

/* 
---------------------------------Alternative Method Using PARSENAME---------------------------------

--As PARSENAME only looks for periods, updated from comma's to period to parse data

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



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



Select *
From PortfolioProject.dbo.NashvilleHousing
*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant


--Writting out Case statement prior to update
Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing


--Updating using Case statement 
Update NashVilleHousing
Set SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict 

--Delting PropertyAddress due previously creating more percise columns with address, city and State.
--TaxDistrict and SaleDate have no value to data
