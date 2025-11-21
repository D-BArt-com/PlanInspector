/*
Demo flow
Create XE show and explain filter on QueryHash
Start XE 
Run the demo query's 
Stop XE
Run the 3 Powershell scripts
SQL views:
[dbo].[vw_ParameterList]
[dbo].[vw_ParameterListRuntime]
[dbo].[vw_ParameterListCompiled]
*/
DECLARE @ModifiedDate DATE = '2011-01-01';     
DECLARE @SQL NVARCHAR(MAX);  
SET @SQL = N'  
SELECT       
SOD.[SalesOrderID],      
SOD.[SalesOrderDetailID],      
SOD.[CarrierTrackingNumber],      
SOD.[OrderQty],      
SOD.[ProductID],      
SOD.[SpecialOfferID],      
SOD.[UnitPrice],      
SOD.[UnitPriceDiscount],      
SOD.[LineTotal],      
SOD.[rowguid],      
SOD.[ModifiedDate],      
TH.[TransactionID],      
TH.[ProductID] AS TransactionProductID,      
TH.[ReferenceOrderID],      
TH.[ReferenceOrderLineID],      
TH.[TransactionDate],      
TH.[TransactionType],      
TH.[Quantity],      
TH.[ActualCost],      
TH.[ModifiedDate] AS TransactionModifiedDate  
FROM       
[Sales].[SalesOrderDetail] SOD      
INNER JOIN 
[Production].[TransactionHistory] TH ON SOD.ProductID = TH.ProductID  
WHERE       
SOD.[ModifiedDate] < @ModifiedDate  
ORDER BY       
SOD.[SalesOrderID], SOD.[SalesOrderDetailID];  ';    
EXEC sp_executesql @SQL, N'@ModifiedDate DATE', @ModifiedDate;  
GO
DECLARE @ModifiedDate DATE = '2011-06-01';     
DECLARE @SQL NVARCHAR(MAX);  
SET @SQL = N'  
SELECT       
SOD.[SalesOrderID],      
SOD.[SalesOrderDetailID],      
SOD.[CarrierTrackingNumber],      
SOD.[OrderQty],      
SOD.[ProductID],      
SOD.[SpecialOfferID],      
SOD.[UnitPrice],      
SOD.[UnitPriceDiscount],      
SOD.[LineTotal],      
SOD.[rowguid],      
SOD.[ModifiedDate],      
TH.[TransactionID],      
TH.[ProductID] AS TransactionProductID,      
TH.[ReferenceOrderID],      
TH.[ReferenceOrderLineID],      
TH.[TransactionDate],      
TH.[TransactionType],      
TH.[Quantity],      
TH.[ActualCost],      
TH.[ModifiedDate] AS TransactionModifiedDate  
FROM       
[Sales].[SalesOrderDetail] SOD      
INNER JOIN 
[Production].[TransactionHistory] TH ON SOD.ProductID = TH.ProductID  
WHERE       
SOD.[ModifiedDate] < @ModifiedDate  
ORDER BY       
SOD.[SalesOrderID], SOD.[SalesOrderDetailID];  ';    
EXEC sp_executesql @SQL, N'@ModifiedDate DATE', @ModifiedDate;  

GO
DECLARE @ModifiedDate DATE = '2011-09-01';     
DECLARE @SQL NVARCHAR(MAX);  
SET @SQL = N'  
SELECT       
SOD.[SalesOrderID],      
SOD.[SalesOrderDetailID],      
SOD.[CarrierTrackingNumber],      
SOD.[OrderQty],      
SOD.[ProductID],      
SOD.[SpecialOfferID],      
SOD.[UnitPrice],      
SOD.[UnitPriceDiscount],      
SOD.[LineTotal],      
SOD.[rowguid],      
SOD.[ModifiedDate],      
TH.[TransactionID],      
TH.[ProductID] AS TransactionProductID,      
TH.[ReferenceOrderID],      
TH.[ReferenceOrderLineID],      
TH.[TransactionDate],      
TH.[TransactionType],      
TH.[Quantity],      
TH.[ActualCost],      
TH.[ModifiedDate] AS TransactionModifiedDate  
FROM       
[Sales].[SalesOrderDetail] SOD      
INNER JOIN 
[Production].[TransactionHistory] TH ON SOD.ProductID = TH.ProductID  
WHERE       
SOD.[ModifiedDate] < @ModifiedDate  
ORDER BY       
SOD.[SalesOrderID], SOD.[SalesOrderDetailID];  ';    
EXEC sp_executesql @SQL, N'@ModifiedDate DATE', @ModifiedDate;  


GO
DECLARE @ModifiedDate DATE = '2012-01-01';     
DECLARE @SQL NVARCHAR(MAX);  
SET @SQL = N'  
SELECT       
SOD.[SalesOrderID],      
SOD.[SalesOrderDetailID],      
SOD.[CarrierTrackingNumber],      
SOD.[OrderQty],      
SOD.[ProductID],      
SOD.[SpecialOfferID],      
SOD.[UnitPrice],      
SOD.[UnitPriceDiscount],      
SOD.[LineTotal],      
SOD.[rowguid],      
SOD.[ModifiedDate],      
TH.[TransactionID],      
TH.[ProductID] AS TransactionProductID,      
TH.[ReferenceOrderID],      
TH.[ReferenceOrderLineID],      
TH.[TransactionDate],      
TH.[TransactionType],      
TH.[Quantity],      
TH.[ActualCost],      
TH.[ModifiedDate] AS TransactionModifiedDate  
FROM       
[Sales].[SalesOrderDetail] SOD      
INNER JOIN 
[Production].[TransactionHistory] TH ON SOD.ProductID = TH.ProductID  
WHERE       
SOD.[ModifiedDate] < @ModifiedDate  
ORDER BY       
SOD.[SalesOrderID], SOD.[SalesOrderDetailID];  ';    
EXEC sp_executesql @SQL, N'@ModifiedDate DATE', @ModifiedDate;  