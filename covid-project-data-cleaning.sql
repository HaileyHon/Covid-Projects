Select *
From SQLTutorial..NashvilleHousing

--Standardize Data Format

Select SaleDateConverted, Convert (Date, SaleDate)
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert (Date, SaleDate)

--Populate Property Address data

Select a.ParcelID, 
       a.PropertyAddress, 
       b.ParcelID,
       b.PropertyAddress,
       ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLTutorial..NashvilleHousing a 
Join SQLTutorial..NashvilleHousing b 
  on a.ParcelID = b.ParcelID
  and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLTutorial..NashvilleHousing a 
Join SQLTutorial..NashvilleHousing b 
on a.ParcelID = b.ParcelID
  and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking out Address into Individual Colums (Address, City, State)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  as Address
From SQLTutorial..NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select * 
From SQLTutorial..NashvilleHousing

---  ---

Select OwnerAddress
From SQLTutorial..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From SQLTutorial..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From SQLTutorial..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
     Else SoldAsVacant
     END
From SQLTutorial..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
     Else SoldAsVacant
     END

--Remove Dupicates

With RowNumCTE as (
Select *,
    ROW_NUMBER() Over (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
                    UniqueID 
                       ) Row_num 
From SQLTutorial..NashvilleHousing
                   )
Delete 
From RowNumCTE
Where Row_num > 1

--Delete Unused Colums 

Select * 
From SQLTutorial..NashvilleHousing

Alter table NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
Drop COLUMN SaleDate