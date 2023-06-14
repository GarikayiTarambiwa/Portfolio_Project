select *
from PortfolioProject..Housing

Alter Table PortfolioProject..Housing
Alter Column SaleDate date

Alter Table PortfolioProject..Housing
Alter Column UniqueID int

Alter Table PortfolioProject..Housing
Alter Column SalePrice int

Alter Table PortfolioProject..Housing
Alter Column Acreage float

Alter Table PortfolioProject..Housing
Alter Column LandValue int

Alter Table PortfolioProject..Housing
Alter Column BuildingValue int

Alter Table PortfolioProject..Housing
Alter Column TotalValue int

Alter Table PortfolioProject..Housing
Alter Column YearBuilt int

Alter Table PortfolioProject..Housing
Alter Column Bedrooms int

Alter Table PortfolioProject..Housing
Alter Column FullBath int

Alter Table PortfolioProject..Housing
Alter Column HalfBath int

USE PortfolioProject;
sp_help Housing

--Populate Property Address data

Select * 
From PortfolioProject..Housing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..Housing a
Join PortfolioProject..Housing b
	on a.ParcelID =b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

update a 
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..Housing a
Join PortfolioProject..Housing b
	on a.ParcelID =b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

----------------------Breaking out Address into individual Columns (Address, City, State)--------------------------------

------1. Property Address 

Select PropertyAddress
From PortfolioProject..Housing

Select
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, Substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as Address

From PortfolioProject..Housing

Alter Table Housing
Add PropertySplitAddress Nvarchar(255)

update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, charindex(',',PropertyAddress)-1)

Alter Table Housing 
Add PropertySplitCity nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1,len(PropertyAddress))

select *
from PortfolioProject..Housing

--------- 2. Owner Address

Select OwnerAddress
From PortfolioProject..Housing

Select 
PARSENAME(Replace(OwnerAddress,',', '.'),3),
PARSENAME(Replace(OwnerAddress,',', '.'),2),
PARSENAME(Replace(OwnerAddress,',', '.'),1)
From PortfolioProject..Housing

Alter Table Housing 
Add OwnerSplitAddress Nvarchar(255)

Update Housing 
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'),3)

Alter Table Housing 
Add OwnerSplitCity Nvarchar(255)

Update Housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'),2)


Alter Table Housing 
Add OwnerSplitState Nvarchar(255)

Update Housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1)


Select *
From PortfolioProject..Housing

---------------------------------Change Y and N to Yes and No in 'Sold As Vacant'-----------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..Housing
Group by SoldAsVacant 
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant 
		END
FROM PortfolioProject..Housing

Update Housing 
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant 
		END

----------------------------------------Remove Duplicates-----------------------------------------------
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						)row_num
From PortfolioProject..Housing
)
select*
--Delete
From RowNumCTE
Where row_num > 1

------------------------------------------------ Delete Unused Columns---------------------------------------------

Select * 
From PortfolioProject..Housing

Alter Table PortfolioProject..Housing
Drop Column OwnerAddress, TaxDistrict,PropertyAddress, SaleDate

----------------------------------------------------------------------------------------------------------------------------------------------



Alter Table PortfolioProject..Housing
Alter Column UniqueID nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column SalePrice nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column Acreage nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column LandValue nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column BuildingValue nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column TotalValue nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column YearBuilt nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column Bedrooms nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column FullBath nvarchar(255)

Alter Table PortfolioProject..Housing
Alter Column HalfBath nvarchar(255)