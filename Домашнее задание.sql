
-- Нужно ускорить запросы ниже любыми способами
-- Можно менять текст самого запроса или добавилять новые индексы
-- Схему БД менять нельзя
-- В овете пришлите итоговый запрос и все что было создано для его ускорения

-- Задача 1
DROP INDEX idx_WebLog_SessionS ON Marketing.WebLog
CREATE INDEX idx_WebLog_SessionS ON Marketing.WebLog (SessionStart, ServerID) INCLUDE (SessionID, UserName)

DECLARE @StartTime datetime2 = '2010-08-30 16:27';

SELECT TOP(5000)  wl.SessionID, wl.ServerID, wl.UserName 
FROM Marketing.WebLog AS wl
WHERE wl.SessionStart >= @StartTime
ORDER BY wl.SessionStart, wl.ServerID;
GO

-- Задача 2
DROP INDEX idx_PostalCode ON Marketing.PostalCode
CREATE INDEX idx_PostalCode ON Marketing.PostalCode (StateCode, PostalCode) INCLUDE (Country)

SELECT PostalCode, Country
FROM Marketing.PostalCode 
WHERE StateCode = 'KY'
ORDER BY  PostalCode;
--сортировка по StateCode не нужна, так как по условию выбраны все значения равные KY
GO

-- Задача 3
---Новый запрос
CREATE INDEX indx_SalespersonName ON Marketing.Salesperson (LastName)
CREATE INDEX idx_Prospect ON Marketing.Prospect (LastName, FirstName)

SELECT pros.LastName, pros.FirstName into #Table1  FROM Marketing.Prospect AS pros
  WHERE pros.LastName IN 
  (SELECT sap.LastName FROM  Marketing.Salesperson AS sap)
  ORDER BY pros.LastName, pros.FirstName;

DECLARE @Counter INT = 0;
SELECT * INTO #Table2 FROM Marketing.Prospect AS p
WHERE p.LastName = 'Smith';


WHILE @Counter < 50
BEGIN
  SELECT * FROM #Table1
  SET @Counter = @Counter + 1;
END;

-- удаление 
DROP TABLE #Table1 
DROP TABLE #Table2

--------Исходный запрос-------
WHILE @Counter < 350
BEGIN
  SELECT p.LastName, p.FirstName 
  FROM Marketing.Prospect AS p
  INNER JOIN Marketing.Salesperson AS sp
  ON p.LastName = sp.LastName
  ORDER BY p.LastName, p.FirstName;
  
  SELECT * 
  FROM Marketing.Prospect AS p
  WHERE p.LastName = 'Smith';
  SET @Counter += 1;
END;


-- Задача 4
--Измененный запрос
CREATE INDEX indx_Product on Marketing.Product(SubcategoryID, ProductModelID, ProductID)

SELECT CategoryName,
	SubcategoryName,
	pm.ProductModel,
	 ModelCount
FROM 
(
SELECT CategoryID, SubcategoryName, ProductModelID, sum(ModelCount) as ModelCount
FROM
(SELECT p.SubcategoryID, p.ProductModelID, COUNT(p.ProductID) AS ModelCount
FROM
Marketing.Product as p
GROUP BY p.SubcategoryID, p.ProductModelID
HAVING COUNT(p.ProductID) > 1) AS s1
JOIN Marketing.Subcategory sc
	ON sc.SubcategoryID = s1.SubcategoryID
	GROUP BY sc.SubcategoryName, sc.CategoryID, ProductModelID ) AS s2
JOIN Marketing.Category AS categ
	ON categ.CategoryID = s2.CategoryID
join Marketing.ProductModel AS pm
ON s2.ProductModelID = pm.ProductModelID


--Исходный запрос
SELECT
	c.CategoryName,
	sc.SubcategoryName,
	pm.ProductModel,
	COUNT(p.ProductID) AS ModelCount
FROM Marketing.ProductModel pm
	JOIN Marketing.Product p
		ON p.ProductModelID = pm.ProductModelID
	JOIN Marketing.Subcategory sc
		ON sc.SubcategoryID = p.SubcategoryID
	JOIN Marketing.Category c
		ON c.CategoryID = sc.CategoryID
GROUP BY c.CategoryName,
	sc.SubcategoryName,
	pm.ProductModel
HAVING COUNT(p.ProductID) > 1