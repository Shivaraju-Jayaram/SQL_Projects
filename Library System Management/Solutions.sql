SELECT * FROM books;

SELECT * FROM branch;

SELECT * FROM employees;

SELECT * FROM issued_status;

SELECT * FROM return_status;

SELECT * FROM members;

-- 1. Create a New Book Record -- "'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C101';

SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS133' from the issued_status table.
DELETE 
FROM issued_status
WHERE issued_id = 'IS133';

SELECT * FROM issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT member_name
FROM members AS m
JOIN issued_status AS ist
	ON m.member_id = ist.issued_member_id
GROUP BY 1
HAVING COUNT(*) > 1


-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_summary AS
SELECT 
	b.isbn, 
	b.book_title, 
	COUNT(*) AS book_issued_cnt
FROM books AS b
JOIN issued_status AS ist
	ON b.isbn = ist.issued_book_isbn
GROUP BY 1, 2;

SELECT * FROM book_summary;

-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'History'

-- Task 8: Find Total Rental Income by Category:
SELECT 
	b.category,
	SUM(b.rental_price) AS rental_income
FROM books AS b
JOIN issued_status AS ist
	ON	b.isbn = ist.issued_book_isbn
GROUP BY 1

-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS Branch_Manager
FROM employees AS e1
JOIN branch AS b
ON e1.branch_id = b.branch_id
JOIN employees AS e2
ON b.manager_id = e2.emp_id

-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE above_avg_rental_price AS
SELECT * FROM books
WHERE rental_price > (SELECT AVG(rental_price)
						FROM books)

SELECT * FROM above_avg_rental_price

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT *
FROM issued_status ist
LEFT JOIN return_status rtn
	ON ist.issued_id = rtn.issued_id
WHERE rtn.issued_id IS NULL

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT 
	ist.issued_member_id,
	m.member_name,
	ist.issued_book_name,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status ist
JOIN members m
	ON m.member_id = ist.issued_member_id
JOIN books bk
	ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs
	ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL
	AND CURRENT_DATE - ist.issued_date > 30
ORDER BY 1

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(25);
	v_bookname VARCHAR(75);
BEGIN
	-- All Logics and Codes
	SELECT	
		issued_book_isbn,
		issued_book_name
		INTO 
		v_isbn,
		v_bookname
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	INSERT INTO return_status(return_id, issued_id, return_book_name, return_date, return_book_isbn)
	VALUES(p_return_id, p_issued_id, v_bookname, CURRENT_DATE, v_isbn);
	
	UPDATE books 
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_bookname;
END;
$$

CALL add_return_records('RS119', 'IS139');

SELECT * FROM return_status
WHERE return_id = 'RS119'

DELETE FROM return_status
WHERE return_id = 'RS119'

SELECT * FROM issued_status
WHERE issued_id = 'IS139'

SELECT * FROM books
WHERE isbn = '978-0-679-76489-8'

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals.
*/
CREATE TABLE branch_report AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS books_issued,
	COUNT(rs.issued_id) AS books_returned,
	SUM(rental_price) AS total_revenue
FROM branch b
JOIN employees emp 
ON b.branch_id = emp.branch_id
JOIN issued_status ist
ON ist.issued_emp_id = emp.emp_id
LEFT JOIN return_status rs
ON ist.issued_id = rs.issued_id
JOIN books bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2

SELECT * FROM branch_report

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 7 months.
*/
CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN(SELECT 
	DISTINCT ist.issued_member_id
FROM issued_status ist
WHERE issued_date >= CURRENT_DATE - INTERVAL '7 months'
)

SELECT * FROM active_members
/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

SELECT 
	e.emp_name AS Employee,
	b.*,
	COUNT(ist.issued_book_isbn) AS books_issued	
FROM issued_status ist
JOIN employees e
ON ist.issued_emp_id = e.emp_id
JOIN branch b
ON e.branch_id = b.branch_id
JOIN books bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2
ORDER BY books_issued DESC
LIMIT 3

SELECT * FROM branch

/*

*/
/*
Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
SELECT * FROM books
SELECT * FROM issued_status

CREATE OR REPLACE PROCEDURE book_status(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(25), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	-- ALL THE VARIABLES
	v_status VARCHAR(10);
	v_book_title VARCHAR(100);
BEGIN
	-- ALL THE CODE
	--Checking if book is available 'yes'
	SELECT 
		status,
		book_title
		INTO 
		v_status,
		v_book_title
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN

		INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
		VALUES(p_issued_id, p_issued_member_id, v_book_title, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book having "%", and the title "%" has been issued', p_issued_book_isbn, v_book_title;
	ELSE
		RAISE NOTICE 'Sorry, the book "%" you have requested is unavailble at the moment', v_book_title;
	END IF;



END;
$$

SELECT * FROM books
SELECT * FROM issued_status
SELECT * FROM members

CALL book_status('IS141', 'C102','978-0-553-29698-2','E102')

DELETE FROM issued_status
WHERE issued_id = 'IS141'

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-553-29698-2'

/*
Task 19: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
*/
CREATE TABLE fine_calculated_table AS
SELECT 
	m.member_id,
	COUNT(ist.issued_id) AS Number_of_overdue_books,
	SUM(CURRENT_DATE - issued_date) * 0.50 AS Total_fines
FROM issued_status ist
JOIN members m
ON ist.issued_member_id = m.member_id
LEFT JOIN return_status rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL
GROUP BY 1
ORDER BY 3 DESC

SELECT * FROM fine_calculated_table
