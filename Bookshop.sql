/*  In this project we are working with the bookshop data set for tableau. But it is also a good dataset to practice SQL
	skills as it showcases relationships and combination of data consisting of 13 tables.
	To simplify the data model, the core tables are Book, Author and Edition; where Book and Info can be joined where Book.BookID = Info.BookID1 + Info.BookID2

	To explore this data, these are the suggested analytical scenarios:
	.What books are the most popular? The least Popular?
	.Who was the youngest debut author? Who was the olders?
	.What was the longest time between editions of the same book?
	.Do some publishing houses seem to specialize in any way?
	.Do the authors who spend the most time writing have the most successful books? Do they have the highest page count?
	.When are the most books published?
*/
----------------
--Let's check the core tables:
--Leaving out Series information in the join as it is irrelevant to answer the above questions.
select Book.BookID, Book.Title, Book.AuthID, Info.Genre into Books
from Book
inner join Info on Book.BookID = concat(Info.BookID1, Info.BookID2);

select * from Author; 
--We can see that Writing hours is not standardized, and since all dates are in the future and this is fictional, we'll leave as-is.
--update Author set Hrs_Writing_per_Day = ROUND(Hrs_Writing_per_Day, 0);

select * from Edition; 
--Same, let's make it std rounding price by 2 decimal houses.
--update Edition set Price = ROUND(Price, 2);


----------------
--Which books are most and least popular? Our metric here will be the ammount of sales for the captured year.
/*
select * into Sales from Sales_Q1
insert into Sales select * from Sales_Q2
insert into Sales select * from Sales_Q3
insert into Sales select * from Sales_Q4
*/
select * from Sales;
update Sales set Discount = Round(Discount, 2);

select ISBN, count(OrderID) as Sales_Count from Sales
group by ISBN
order by Sales_Count;
--we also need the BookID: we need to join with edition and with Books, joining the 3 tables
select Books.Title, Edition.ISBN, Sales.OrderID
from ((Edition
	inner join Books on Books.BookID = Edition.BookID)
	inner join Sales on Sales.ISBN = Edition.ISBN);
--retrieving the info for minimum and maximum amount of books sold: 2 and 7334 copies sold respectively.
with BookSaleInfo as(
	select Books.Title as Books, count(Edition.ISBN) as BookCount
	from Books
	join Edition on Books.BookID = Edition.BookID
	join Sales on Sales.ISBN = Edition.ISBN
	group by Books.Title
)
select BSI_min.Books as minBookSold_Title, BSI_min.BookCount as minBookSale,
		BSI_max.Books as maxBookSold_Title, BSI_max.BookCount as maxBookSale
from BookSaleInfo BSI_min
join BookSaleInfo BSI_max on BSI_max.BookCount = (select max(BookCount) from BookSaleInfo)
where BSI_min.BookCount = (select min(BookCount) from BookSaleInfo);


----------------
--Who was the youngest debut author? Who was the olders?
--We can check by accessing publish date - birthday date:
--are there books published by the same author in different years:
select distinct(AuthID) from Books; --34 Authors
select AuthID from Books; --58 Authors

select Title, AuthID, Edition.Publication_Date from Books
join Edition on Books.BookID = Edition.BookID
order by AuthID;

--Let's get the oldest/debut publishing date from each author
with firstPublication as(
		select AuthID as AuthorID, Edition.Publication_Date as Debut_Date, ROW_NUMBER() OVER(PARTITION BY AuthID order by Edition.Publication_Date) as RowNum
		from Books join Edition on Books.BookID = Edition.BookID
)
select AuthID, DATEDIFF(YEAR, Author.Birthday, Debut_Date) as DebutAge into #tempDebut
from firstPublication
join Author on Author.AuthID = firstPublication.AuthorID
where RowNum = 1

select DebutAge, Author.First_Name, Author.Last_Name
from #tempDebut
join Author on Author.AuthID = #TempDebut.AuthID
where DebutAge = (select min(DebutAge) from #tempDebut) or 
	DebutAge = (select max(DebutAge) from #tempDebut)
order by DebutAge

drop table #tempDebut;


----------------
--What was the longest time between editions of the same book?
--Different ISBN can received same BookID, as ISBN is attached to publishing the edition of a book.
select * from Edition
order by BookID,ISBN;

--Similar to debut age, we need the most recent publication - oldest publication date for the same BookID.
--we can get the olders edition and take the difference against the newest edition
with firstPublication as(
		select AuthID as AuthorID, Edition.Publication_Date as Pub_Date, ROW_NUMBER() OVER(PARTITION BY AuthID order by Edition.Publication_Date DESC) as RowNumF
		from Books join Edition on Books.BookID = Edition.BookID
),
LastPublication as(
		select AuthID as AuthorID, Edition.Publication_Date as Pub_Date, ROW_NUMBER() OVER(PARTITION BY AuthID order by Edition.Publication_Date ASC) as RowNumL
		from Books join Edition on Books.BookID = Edition.BookID
)
select firstPublication.AuthorID, DATEDIFF(YEAR, LastPublication.Pub_Date, firstPublication.Pub_Date) as Time_Between_Editions into #tempPub
from firstPublication
join LastPublication on firstPublication.AuthorID = LastPublication.AuthorID
where RowNumL = 1 and RowNumF = 1;

select Time_Between_Editions, Author.First_Name, Author.Last_Name
from #tempPub
join Author on Author.AuthID = #tempPub.AuthorID
where Time_Between_Editions = (select max(Time_Between_Editions) from #tempPub)
order by Time_Between_Editions

drop table #tempPub;


----------------
--Do some publishing houses seem to specialize in any way?
--We can check that by having a list with publishing houses and books published in each genre
select distinct(Genre) from Books -- there are 8 Genres
select distinct(Publishing_House) from Publisher
order by Publishing_House; --4 publishing houses

select Books.Genre, Publisher.Publishing_House 
from ((Books
	join Edition on Books.BookID = Edition.BookID)
	join Publisher on Edition.PubID = Publisher.PubID)
order by Publishing_House;


----------------
--Do the authors who spend the most time writing have the most successful books? Do they have the highest page count? NO
select * from Sales;

with nBookSold as (
	select Sales.ISBN as a, Books.AuthID as AuthorID
	from ((Sales
		join Edition on Sales.ISBN = Edition.ISBN)
		join Books on Books.BookID = Edition.BookID)
)
select count(nBookSold.AuthorID) as Books_Sold, nBookSold.AuthorID into #tempHPD
from nBookSold
group by nBookSold.AuthorID
order by Books_Sold DESC;

select #tempHPD.Books_Sold, #tempHPD.AuthorID, Author.Hrs_Writing_per_Day from #tempHPD
join Author on Author.AuthID = #tempHPD.AuthorID
order by #tempHPD.Books_Sold DESC;

drop table #tempHPD;


----------------
--When are the most books published?
select * from Edition;

select count(DATEPART(q, Publication_Date)) as Publications_Quarter from Edition
group by DATEPART(q, Publication_Date);