/*
Cleaning Data in SQL Queries
*/


Select *
From PORTFOLIOPROJECT.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- chnage the saledate, no need the time portion only require date



Select saleDateConverted, CONVERT(Date,SaleDate)
From PORTFOLIOPROJECT.dbo.NashvilleHousing   /* step 5 to check the added column*/


Update NashvilleHousing    /*step2*/
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing   /* step3 :adding column */
Add SaleDateConverted Date;

Update NashvilleHousing  /*step 4*/
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDate, CONVERT(Date,SaleDate)  /* step1: create the formate what we want. the column created after covo its need name */
From PORTFOLIOPROJECT.dbo.NashvilleHousing /* covert(date,sAaledate) new column */



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select  PropertyAddress  /* step 1: checking the propeertyaddress colomn */
From PORTFOLIOPROJECT.dbo.NashvilleHousing
Where PropertyAddress is null

Select *       /* step 2  some parcelid has same propertyaddress. those who have same parcel id but property value is none then user that property adrees of one parcel for another parcel */         
From PORTFOLIOPROJECT.dbo.NashvilleHousing /* so we have to join to table if this id has this then it will go for that */
--Where PropertyAddress is null
order by ParcelID

-- step3 now join table a and b based on parcel id and not unique id as it will not match

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) /* when a.proadd is null put the b.proadd there by this isnull portion . it will create new column which will be stuck finally in proper.add */
From PORTFOLIOPROJECT.dbo.NashvilleHousing a
JOIN PORTFOLIOPROJECT.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- step 4

Update a  /* when update after joining not to put NushvilleHousing put the alias (a) */
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) /*isnull portion property address a chole jabe */
From PORTFOLIOPROJECT.dbo.NashvilleHousing a
JOIN PORTFOLIOPROJECT.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- then again check step 3 , if there is any null value it will show


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- step 1


Select PropertyAddress
From PORTFOLIOPROJECT.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-- step 2 : divide the address into two part
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address  /* proadd has 3 parts inside the coma.so 1st part consider as 1. CHARINDEX(',', PropertyAddress) means a position which will give a number about in which position  the coma belong . putting -1 remove coma */
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
-- +1 to get the actual coma position. where we need to go can be found by putting len as every address has diffrent lenghth
From PORTFOLIOPROJECT.dbo.NashvilleHousing


-- step 3 : create two new columns add these values there


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255); /* larger stirng so 255 and adding string so Nvarchar */

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From PORTFOLIOPROJECT.dbo.NashvilleHousing



--simpler way to seperate

Select OwnerAddress
From PORTFOLIOPROJECT.dbo.NashvilleHousing


-- if we put 1,2,3 get backwards but put 321 get address, city, states respectively

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) /* replace , with . */
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PORTFOLIOPROJECT.dbo.NashvilleHousing



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
From PORTFOLIOPROJECT.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

-- find out total number of Yes/no, y/n


Select Distinct(SoldAsVacant), Count(SoldAsVacant) /* without group and order by we will get yes no y n */
From PORTFOLIOPROJECT.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2 /* column number */
 



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant /* otherwise keep as soldvacant */
	   END
From PORTFOLIOPROJECT.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- windows will be súsed to find out duplicates

WITH RowNumCTE AS(  /* to avoid error */
Select *,
	ROW_NUMBER() OVER (      /* check rank and using rownumber its simple */
	PARTITION BY ParcelID,     /* partition need for unique things */
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID /* order by unique id */
					) row_num 

From PORTFOLIOPROJECT.dbo.NashvilleHousing
--order by ParcelID
)

--DELETE  /* instead of select we have to white delete to delete duplicates */
Select * /* after deleter again write select to check if there any duplicate */
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PORTFOLIOPROJECT.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PORTFOLIOPROJECT.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



