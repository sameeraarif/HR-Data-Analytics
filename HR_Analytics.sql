--## Data Cleaning
--## I want to add a column to my table to help me understand attrition better. 
--## If Attrition is Yes, the value will be 1, otherwise 0.

ALTER TABLE dbo.HR_Analytics
ADD attrition_value INT;

UPDATE dbo.HR_Analytics
SET attrition_value = CASE
    WHEN Attrition = 'Yes' THEN 1
    ELSE 0
END;

SELECT * FROM dbo.HR_Analytics;


--## I noticed that the column YearsWithCurrManager is not useful for me, so I will remove it.

ALTER TABLE dbo.HR_Analytics
DROP COLUMN YearsWithCurrManager;


--## I want to check if there are duplicate rows in my table.

SELECT empid,
       ROW_NUMBER() OVER (PARTITION BY empid ORDER BY empid) AS num_rows
FROM dbo.HR_Analytics
ORDER BY num_rows DESC;


--## There are duplicates, so I will remove them by creating a new table with only distinct rows.

SELECT DISTINCT * 
INTO dbo.HR2
FROM dbo.HR_Analytics;

--## I empty the original table

TRUNCATE TABLE dbo.HR_Analytics;

--## And then insert the distinct rows back

INSERT INTO dbo.HR_Analytics
SELECT * FROM dbo.HR2;

--## Now I can remove the temporary table

DROP TABLE dbo.HR2;

--## Check again if duplicates are gone

SELECT empid,
       ROW_NUMBER() OVER (PARTITION BY empid ORDER BY empid) AS num_rows
FROM dbo.HR_Analytics
ORDER BY num_rows DESC;


--## In BusinessTravel column, I have Travel_Rarely and TravelRarely. I want to fix them.

SELECT BusinessTravel
FROM dbo.HR_Analytics
GROUP BY BusinessTravel;

UPDATE dbo.HR_Analytics
SET BusinessTravel = 'Travel_Rarely'
WHERE BusinessTravel = 'TravelRarely';

SELECT BusinessTravel
FROM dbo.HR_Analytics
GROUP BY BusinessTravel;


--## Now my data is cleaned. Next, I want to do some basic analysis.
--## I will create views to see attrition by Age, Department, EducationField, JobRole, Salary, YearsAtCompany, Gender, and OverTime.

--## Attrition vs Age
DROP VIEW IF EXISTS AttVSAge;

CREATE VIEW AttVSAge AS
SELECT AgeGroup,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(AgeGroup) AS [Employee count],
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(AgeGroup))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY AgeGroup;

SELECT * FROM AttVSAge;


--## Attrition by Department
DROP VIEW IF EXISTS AttVSDep;

CREATE VIEW AttVSDep AS
SELECT Department,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(Department) AS TotalEmployeePerDepartment,
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(Department))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY Department;

SELECT * FROM AttVSDep;


--## Attrition vs Education Field
DROP VIEW IF EXISTS AttVSEdu;

CREATE VIEW AttVSEdu AS
SELECT EducationField,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(EducationField) AS TotalEmployeePerEducation,
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(EducationField))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY EducationField;

SELECT * FROM AttVSEdu;


--## Attrition vs Job Role
DROP VIEW IF EXISTS AttVSJob;

CREATE VIEW AttVSJob AS
SELECT JobRole,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(JobRole) AS TotalEmployeePerJobrole,
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(JobRole))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY JobRole;

SELECT * FROM AttVSJob;


--## Attrition vs Salary Slab
DROP VIEW IF EXISTS AttVSSal;

CREATE VIEW AttVSSal AS
SELECT SalarySlab,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(SalarySlab) AS TotalEmployeePerSalarySlab,
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(SalarySlab))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY SalarySlab;

SELECT * FROM AttVSSal;


--## Attrition vs Years at Company
DROP VIEW IF EXISTS AttVSYrs;

CREATE VIEW AttVSYrs AS
SELECT YearsAtCompany,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(YearsAtCompany) AS TotalEmployeePerYearsAtCompany,
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(YearsAtCompany))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY YearsAtCompany;

SELECT * FROM AttVSYrs;


--## Attrition by OverTime
DROP VIEW IF EXISTS AttVSOverT;

CREATE VIEW AttVSOverT AS
SELECT OverTime,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(OverTime) AS TotalEmployeePerOverTime,
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(OverTime))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY OverTime;

SELECT * FROM AttVSOverT;


--## Attrition by Gender
DROP VIEW IF EXISTS AttVSGen;

CREATE VIEW AttVSGen AS
SELECT Gender,
       SUM(attrition_value) AS [number of employee attrited],
       COUNT(Gender) AS TotalEmployeePerGender,
       (CONVERT(FLOAT, SUM(attrition_value)) / CONVERT(FLOAT, COUNT(Gender))) * 100 AS Attrition_percentage
FROM dbo.HR_Analytics
GROUP BY Gender;

SELECT * FROM AttVSGen;


--## Example using CTE to calculate attrition by Age (just for learning)
WITH cte AS (
    SELECT AgeGroup,
           SUM(attrition_value) AS emp_attri,
           COUNT(AgeGroup) AS count_age
    FROM dbo.HR_Analytics
    GROUP BY AgeGroup
)
SELECT *,
       (CONVERT(FLOAT, emp_attri) / CONVERT(FLOAT, count_age)) * 100 AS Attrition_percentage
FROM cte
ORDER BY emp_attri DESC;
