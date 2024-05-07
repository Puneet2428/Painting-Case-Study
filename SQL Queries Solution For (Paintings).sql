-- All tables with Total number of Rows
Select 'artist' AS Table_Name, COUNT(*) As Row_Count  From artist union all
Select 'canvas_size' AS Table_Name, COUNT(*) As Row_Count  From canvas_size union all
Select 'image_link' AS Table_Name, COUNT(*) As Row_Count  From image_link union all
Select 'museum' AS Table_Name, COUNT(*) As Row_Count  From museum union all
Select 'museum_hours' AS Table_Name, COUNT(*) As Row_Count  From museum_hours union all 
Select 'product_size' AS Table_Name, COUNT(*) As Row_Count  From product_size union all
Select 'subject' AS Table_Name, COUNT(*) As Row_Count  From subject union all
Select 'work' AS Table_Name, COUNT(*) As Row_Count  From work ;

-- To Retrieve All the Tables
Select * From artist
Select * From canvas_size
Select * from image_link
Select * from museum
Select * from museum_hours
Select * from product_size
Select * from subject
Select * from work
Select * from canvas_size


--Solution:1
Select [Name]
From work 
Where museum_id is null

--Solution:2
Select * From museum
Where museum_id 
Not in (Select museum_id from work)

--Solution:3
Select * from product_size
Where sale_price > regular_price

--Solution:4
Select * from product_size
Where sale_price <  regular_price*50/100

--Solution:5
Select [label] as Canva_Size,sale_price From
(Select C.*,sale_price, DENSE_RANK() Over (Order by sale_price Desc) AS Rnks From canvas_size C Join product_size P
On C.size_id=P.size_id
Group By C.size_id,width,height,label,sale_price) High_Price_Size
Where Rnks = 1
Order by sale_price Desc

--Solution:6
/* I have first Added A column Named SNO with data type int and constraint Identity(1,1) in all the tables seperately
Then I have used window funtion Row_Number over(Partition by All the columns present in table) to provide ranks to each and every row so that I can Delete the
rows where the SNO > 1 
After deleting the duplicate entries, I have Dropped the SNO column From each and every table*/


--Solution:7

select * from museum 
	where city like '[1,2,3,4,5,6,7,8,9,0]%'

--Solution:8
/*Invalid entry found-- Duplicate Row Removed By Adding Row_Number as SNO. Leter on deleted
Delete From museum_hours Where SNO IN (
Select SNo From
(Select museum_id,[day],[open],[close], SNO,ROW_NUMBER() Over (Partition by museum_id,[day],[open],[close] Order by museum_id ) as Rnks 
From museum_hours) X
Where Rnks>1
)*/

--Solution:9
Select Subject, Total_paintings From
      (Select Subject, count(subject) As Total_Paintings,
      DENSE_RANK() Over (Order by count(subject) Desc) As rnks
      From Subject 
      Group by subject
      ) Top_Subject
Where rnks<=10
Order by  Total_Paintings Desc

--Solution:10
Select Name,city From museum Where museum_id in (
(Select  museum_id From museum_hours
Where day = 'Sunday' 
Intersect
Select museum_id From museum_hours
Where day = 'Monday') 
)
Order by name


--Solution:11
Select Name From museum Where museum_id IN
(Select museum_id  from museum_hours
Group by museum_id
Having Count(*)>=7)

--Solution:12
Select [Name],Country,Total_paintings From 
(Select M.museum_id,M.[name],country,count(M.[name]) As Total_paintings,DENSE_RANK() Over (Order by count(M.[Name])Desc) As Rnks 
From museum M Join work W 
On M.museum_id=W.museum_id
Group by M.museum_id,M.[name],Country) Top_painting
Where Rnks<=5
Order By Total_paintings Desc

--Solution:13
Select Artist_id,Full_Name,Nationality,Total_Paintings From
(Select A.Artist_ID,Full_Name,Nationality,count([Name]) As Total_Paintings, DENSE_RANK() Over (Order by count([Name])Desc) As Rnks 
From artist A Join work W 
on A.artist_id=W.artist_id
Group by A.Artist_ID,Full_Name,Nationality
) Popular_artist
Where Rnks<=5
Order by Total_paintings Desc

--Solution:14
Select * From (
Select C.size_id,[label],Count(*) As Size_Count, DENSE_RANK() Over (Order by count(*) ASC) Rnks
From canvas_size C join product_size P on c.size_id=p.size_id Join work W on w.work_id=P.work_id
Group by C.size_id,[label]) SIZE
Where Rnks<=3
Order by Size_Count ASC

--Solution:15
Select [Name],[State],[Day],[Hours Open] From
(
Select [Name],[State],[Day],Datediff([HOUR],[open],[close]) As [Hours Open], DENSE_RANK() Over(Order by Datediff([HOUR],[open],[close]) Desc) AS Rnks
From museum_hours MH Join museum M On MH.museum_id=M.museum_id
) Museum_hours
Where Rnks = 1
Order by [Hours Open] Desc

--Solution:16
Select Top 1 M.[Name],Style,count(*) Painting_Count From museum M Join work W on M.museum_id=W.museum_id
Where style IN(
               Select Style From 
                          (Select Style, count(*) AS Total_Paintings , DENSE_RANK() Over(Order by Count(*) Desc) as Rnks
                          From work
                          Group by style) Popular_Style
               Where Rnks=1
              )
Group by M.[name],style
Order by Painting_Count Desc

--Solution:17

With CTE as (
Select  A.full_name,museum_id From work W  Join artist A on W.artist_id = A.artist_id
Group by A.full_name,A.artist_id,museum_id 
),
Max_Country AS(
Select full_name,country,Count(M.museum_id) As MC  from museum M Join CTE on M.museum_id = CTE.museum_id
Group by full_name,country
)
Select Distinct full_name, count(full_name) As No_Of_Countries From Max_Country
Group by full_name
Having count(full_name)>1
Order by No_Of_Countries Desc

--Solution:18
Select City,Country From 
(Select City,country,count(*) As Total_museums,DENSE_RANK() Over(Order by Count(*) Desc) Rnks 
From museum
Group by city,country
) Top_City
Where Rnks=1
Order by Total_museums Desc

SELECT
    STRING_AGG(city, ', ') AS Cities,
    country, count(*) As Museum_count
FROM
    museum
GROUP BY
    country
Order by Museum_count Desc

--Solution:19
Select full_name,Painting_Name,Museum_Name,Museum_City,Canvas_Label,Sale_Price From
       (Select A.full_name,W.[name] As Painting_Name,M.[name] As Museum_Name,M.city As Museum_City,[label] As Canvas_Label,
	   max(sale_price) As Sale_Price , 
       DENSE_RANK() Over(Order by Max(Sale_price) Desc) AS Rnk_1,
       DENSE_RANK() Over(Order by Max(Sale_price) Asc) AS Rnk_2
       From product_size P
       Join canvas_size C on P.size_id=C.size_id
       Join work W on P.work_id=W.work_id
       Join museum M on M.museum_id= W.museum_id
       Join artist A On A.artist_id=W.artist_id
       Group by A.full_name,W.[name],M.[name],M.city ,[label] ) ALL_list
Where Rnk_1=1 Or Rnk_2=1
Order by Sale_Price Desc

--Solution:20
Select Country, Total_Paintings From
(Select Country, count(W.[name]) As Total_Paintings, DENSE_RANK() Over (Order by count(W.[Name]) Desc) As Rnks
From work W Join museum M on W.museum_id=M.museum_id
Group by country 
) Popular_Country
Where Rnks=5
Order by Total_Paintings Desc

--Solution:21
With CTE AS(
Select Style,Count(Style) AS Total_Paintings, 
DENSE_RANK() Over(Order by count(Style) Desc) As Rnks, DENSE_RANK() Over(Order by count(Style) Asc) As Rnks_2
From work
Where Style is NOt null
Group By style
)
Select Style,Total_Paintings, Case When Rnks<=3 Then 'Most Popular' Else 'Least Popular' End As Popularity
From CTE
Where Rnks<=3 Or Rnks_2<=3
Order by Total_Paintings Desc

--Solution:22
Select Full_Name, Nationality, Total_Paintings From 
(Select A.Full_Name,A.Nationality, Count(*) As Total_Paintings, DENSE_RANK() Over (Order by count(*) Desc) As Rnks
From work W
Join artist A on W.artist_id=A.artist_id
Join museum M On M.museum_id=W.museum_id 
Join [subject] S On S.work_id=W.work_id
Where S.subject Like 'Port%' And M.country Not like 'USA'
Group by A.Full_Name,A.Nationality
) Most_Portraits
Where Rnks=1
Order by Total_Paintings Desc