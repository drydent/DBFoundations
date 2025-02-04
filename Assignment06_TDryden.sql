--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-08-05, TDRYDEN, Assignment06
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TDryden')
	 Begin 
	  Alter Database Assignment06DB_TDryden set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TDryden;
	 End
	Create Database Assignment06DB_TDryden;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TDryden;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Create View vwCategories
--With SchemaBinding
--As 
--Select CategoryID, CategoryName 
--from dbo.Categories;

--Create View vwProducts
--With SchemaBinding
--As 
--Select ProductID, ProductName, CategoryID, UnitPrice 
--from dbo.Products;

--Create View vwEmployees
--With SchemaBinding
--As 
--Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID 
--from dbo.Employees;

--Create View vwInventories
--With SchemaBinding
--As 
--Select  InventoryID, InventoryDate, EmployeeID, ProductID, [Count] 
--from dbo.Inventories;

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Deny Select On Categories to Public;
--Deny Select On Products to Public;
--Deny Select On Inventories to Public;
--Deny Select On Employees to Public;

--Grant Select on vwCategories to Public;
--Grant Select on vwProducts to Public;
--Grant Select on vwInventories to Public;
--Grant Select on vwEmployees to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Create View vwProductsbyCategories 
--as
--Select Top 10000000
--C.CategoryName
--,P.ProductName
--,P.UnitPrice
--From vwCategories c
--Join vwProducts p on c.CategoryID = P.CategoryID
--Order by C.CategoryName,P.ProductName,P.UnitPrice

--Select * from vwProductsbyCategories 

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Create View vwInventoriesByProductsByDates
--as
--Select Top 100000
--P.ProductName
--,I.InventoryDate
--,I.[Count]
--From vwProducts P
--Join vwInventories I on P.ProductID = I.ProductID
--Order by I.InventoryDate, P.ProductName, I.[Count]

--Select * From vwInventoriesByProductsByDates

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--Create View vwInventoriesByEmployeesByDates
--as 
--Select Distinct Top 1000000
--I.InventoryDate
--,E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName
--From vwInventories I 
--Join vwEmployees E on I.EmployeeId = E.EmployeeID
--Order by 1,2;

--Select * from vwInventoriesByEmployeesByDates;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Create View vwInventoriesByProductsByCategories
--as
--Select Top 1000000
--C.CategoryName
--,P.ProductName
--,I.InventoryDate
--,I.[Count]
--From vwInventories I
--Join vwEmployees E on I.EmployeeID = E.EmployeeID
--Join vwProducts P on I.ProductID = P.ProductID
--Join vwCategories c on P.CategoryID = C.CategoryID
--Order by 1,2,3,4;

--Select * From vwInventoriesByProductsByCategories


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Create View vwInventoriesByProductsByEmployees
--as
--Select Top 1000000
--C.Categoryname
--,P.ProductName
--,I.InventoryDate
--,I.[Count]
--,E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName
--From vwInventories I
--Join vwEmployees E on I.EmployeeID = E.EmployeeID
--Join vwProducts P on I.ProductID = P.ProductID
--Join vwCategories c on P.CategoryID = C.CategoryID
--Order by 3,1,2,4;

--Select * From vwInventoriesByProductsByEmployees

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Create View vwInventoriesForChaiandChangeByEmployees
--as
--Select Top 1000000
--C.Categoryname
--,P.ProductName
--,I.InventoryDate
--,I.[Count]
--,E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName
--From vwInventories I
--Join vwEmployees E on I.EmployeeID = E.EmployeeID
--Join vwProducts P on I.ProductID = P.ProductID
--Join vwCategories c on P.CategoryID = C.CategoryID
--Where I.ProductID in (Select ProductID From vwProducts Where ProductName in ('Chai','Chang'))
--Order by 3,1,2,4;

--Select * From vwInventoriesForChaiandChangeByEmployees;
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Create View vwEmployeesByManager
--as 
--Select Top 1000000
--M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
--,E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
--From vwEmployees as E
--Join vwEmployees as M on E.ManagerID = M.EmployeeID
--Order by 1,2;

--Select * From vwEmployeesByManager;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--Create View vwInventoriesByProductsByCategoriesByEmployees
--as
--Select Top 1000000
--C.categoryID
--,C.CategoryName
--,P.ProductID
--,P.ProductName
--,P.UnitPrice
--,I.InventoryID
--,I.InventoryDate
--,I.[Count]
--,E.EmployeeID
--,M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
--,E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
--From vwCategories C
--Join vwProducts P on P.CategoryID = C.CategoryID
--Join vwInventories I on P.ProductID = I.ProductID
--Join vwEmployees E on I.EmployeeID = E.EmployeeID
--Join vwEmployees M on E.ManagerID = M.EmployeeID
--Order by 1,3,6,9;


--Select * From vwInventoriesByProductsByCategoriesByEmployees
-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vwCategories]
Select * From [dbo].[vwProducts]
Select * From [dbo].[vwInventories]
Select * From [dbo].[vwEmployees]

Select * From [dbo].[vwProductsByCategories]
Select * From [dbo].[vwInventoriesByProductsByDates]
Select * From [dbo].[vwInventoriesByEmployeesByDates]
Select * From [dbo].[vwInventoriesByProductsByCategories]
Select * From [dbo].[vwInventoriesByProductsByEmployees]
Select * From [dbo].[vwInventoriesForChaiAndChangeByEmployees]
Select * From [dbo].[vwEmployeesByManager]
Select * From [dbo].[vwInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/