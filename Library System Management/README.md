# Library Management System using SQL Project

## Project Overview
* **Project Title:** Library Management System
* **Level:** Intermediate
* **Database name:** ```Library Management``` 

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library Image](https://github.com/Shivaraju-Jayaram/Images/blob/main/library.jpg)

## Objectives
- **Set up the Library Management System Database:** Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
- **CRUD Operations:** Perform Create, Read, Update, and Delete operations on the data.
- **CTAS (Create Table As Select):** Utilize CTAS to create new tables based on query results.
- **Advanced SQL Queries:** Develop complex queries to analyze and retrieve specific data.

## Project Structure
### 1. Database Setup
![ERD Diagram](https://github.com/Shivaraju-Jayaram/Images/blob/main/library_erd.png)

* **Database Creation:** Created a database named ```Library Management```.
* **Table Creation:** Created tables for ```branches```, ```employees```, ```members```, ```books```, ```issued_status```, and ```return_status```. Each table includes relevant columns and relationships.
```SQL
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
    branch_id        VARCHAR(10) PRIMARY KEY,
    manager_id       VARCHAR(10),
    branch_address   VARCHAR(30),
    contact_no       VARCHAR(15)
);

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
    emp_id          VARCHAR(10) PRIMARY KEY,
    emp_name        VARCHAR(30),
    position        VARCHAR(30),
    salary          DECIMAL(10,2),
    branch_id       VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
    member_id        VARCHAR(10) PRIMARY KEY,
    member_name      VARCHAR(30),
    member_address   VARCHAR(30),
    reg_date         DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
    isbn            VARCHAR(50) PRIMARY KEY,
    book_title      VARCHAR(80),
    category        VARCHAR(30),
    rental_price    DECIMAL(10,2),
    status          VARCHAR(10),
    author          VARCHAR(30),
    publisher       VARCHAR(30)
);

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
    issued_id        VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date      DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id    VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
    return_id        VARCHAR(10) PRIMARY KEY,
    issued_id        VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date      DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

### 2. CRUD Operations
* **Create:** Inserted sample records into the books table.
* **Read:** Retrieved and displayed data from various tables.
* **Update:** Updated records in the employees table.
* **Delete:** Removed records from the members table as needed.

#### Task 1. Create a New Book Record 
**Objective:** Insert a new record to books table "('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
```SQL
INSERT INTO
    books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES
    ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT *
FROM books;
```

#### Task 2: Update a Record on Members table
**Objective:** Update an Existing Member's Address
```SQL
UPDATE members
    SET member_address = '125 Oak St'
WHERE
    member_id = 'C101';
```

#### Task 3: Delete a Record from the Issued Status Table 
**Objective:** Delete the record with issued_id = 'IS121' from the issued_status table.
```SQL
DELETE 
FROM issued_status
WHERE
    issued_id = 'IS133';
```

#### Task 4: Retrieve All Books Issued by a Specific Employee 
**Objective:** Select all books issued by the employee with emp_id = 'E101'.
```MySQL
SELECT *
FROM issued_status
WHERE
    issued_emp_id = 'E101'
```

#### Task 5: List Members Who Have Issued More Than One Book
**Objective:** Use GROUP BY to find members who have issued more than one book.
```SQL
SELECT
    member_name
FROM members AS m
JOIN issued_status AS ist
    ON m.member_id = ist.issued_member_id
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. Data Analysis & Findings
**The following SQL queries were used to address specific questions:**

#### Task 6. Retrieve All Books in a Specific Category:
```SQL
SELECT *
FROM books
WHERE
    category = 'History'
```
#### Task 7: Find Total Rental Income by Category:
```SQL
SELECT 
    b.category,
    SUM(b.rental_price) AS rental_income
FROM books AS bk
JOIN issued_status AS ist
    ON bk.isbn = ist.issued_book_isbn
GROUP BY 1
```

#### Task 8: List Members Who Registered in the Last 180 Days:
```SQL
SELECT *
FROM members
WHERE
    reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

#### Task 9: List Employees with Their Branch Manager's Name and their branch details:
```SQL
SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS Branch_Manager
FROM employees AS e1
JOIN branch AS b
    ON e1.branch_id = b.branch_id
JOIN employees AS e2
    ON b.manager_id = e2.emp_id
```

#### Task 10. Create a Table of Books with Rental Price Above a Certain Threshold:
```SQL
CREATE TABLE above_avg_rental_price
AS
    SELECT *
    FROM books
    WHERE
        rental_price > (
                        SELECT AVG(rental_price)
                        FROM books
                       )

SELECT *
FROM above_avg_rental_price
```

#### Task 11: Retrieve the List of Books Not Yet Returned
```SQL
SELECT *
FROM issued_status ist
LEFT JOIN return_status rs
    ON ist.issued_id = rs.issued_id
WHERE rs.issued_id IS NULL
```

## Advanced SQL

#### Task 12: Identify Members with Overdue Books
**Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.**
```SQL
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
WHERE rs.return_date IS NULL    AND
      CURRENT_DATE - ist.issued_date > 30
ORDER BY 1
```

#### Task 13: Find Employees with the Most Book Issues Processed
**Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.**
```SQL
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
```

### 4. CTAS (Create Table As Select)

#### Task 14: Create Summary Tables: 
**Used CTAS to generate new tables based on query results - each book and total book_issued_count**
```SQL
CREATE TABLE book_summary
AS
    SELECT 
        b.isbn, 
        b.book_title, 
        COUNT(*) AS book_issued_cnt
    FROM books AS b
    JOIN issued_status AS ist
        ON b.isbn = ist.issued_book_isbn
    GROUP BY 1, 2;

SELECT *
FROM book_summary;
```
#### Task 15: Branch Performance Report
**Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.**
```SQL
CREATE TABLE branch_report
AS
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

SELECT *
FROM branch_report
```
#### Task 16: CTAS: Create a Table of Active Members
**Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.**
```SQL
CREATE TABLE active_members
AS
    SELECT *
    FROM members
    WHERE member_id IN(
                        SELECT 
                            DISTINCT ist.issued_member_id
                        FROM issued_status ist
                        WHERE
                            issued_date >= CURRENT_DATE - INTERVAL '7 months'
                      )

SELECT *
FROM active_members
```

#### Task 17: Create Table As Select (CTAS) 
**Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.**
**Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines**
```SQL
CREATE TABLE fine_calculated_table
AS
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

SELECT *
FROM fine_calculated_table
```
### 5. Stored Procedures

#### Task 18: Update Book Status on Return
**Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).**
```SQL
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    --ALL THE VARIABLES
        v_isbn VARCHAR(25);
        v_bookname VARCHAR(75);
BEGIN
    -- ALL THE LOGICS AND CODES
    SELECT
        issued_book_isbn,
        issued_book_name
        INTO 
        v_isbn,
        v_bookname
    FROM issued_status
    WHERE
        issued_id = p_issued_id;

    INSERT INTO
        return_status(return_id, issued_id, return_book_name, return_date, return_book_isbn)
    VALUES
        (p_return_id, p_issued_id, v_bookname, CURRENT_DATE, v_isbn);
	
    UPDATE books 
	    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_bookname;
END;
$$

-- Removing the record if exists
DELETE
FROM return_status
WHERE return_id = 'RS119'

-- Calling the stored procedures
CALL add_return_records('RS119', 'IS139');

-- Checking it's functionality
SELECT *
FROM return_status
WHERE return_id = 'RS119'

SELECT *
FROM issued_status
WHERE issued_id = 'IS139'

SELECT *
FROM books
WHERE isbn = '978-0-679-76489-8'
```

#### Task 20: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
**Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.**
```SQL
CREATE OR REPLACE PROCEDURE book_status(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(25), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    -- ALL THE VARIABLES
        v_status VARCHAR(10);
        v_book_title VARCHAR(100);
BEGIN
    -- ALL THE LOGICS AND CODES

    SELECT 
        status,
        book_title
        INTO 
        v_status,
        v_book_title
    FROM books
    WHERE
        isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO
            issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
            (p_issued_id, p_issued_member_id, v_book_title, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book having "%", and the title "%" has been issued', p_issued_book_isbn, v_book_title;
    ELSE
        RAISE NOTICE 'Sorry, the book "%" you have requested is unavailble at the moment', v_book_title;
    END IF;

END;
$$

-- Calling the stored procedure
CALL book_status('IS141', 'C102','978-0-553-29698-2','E102')

-- Checking the functionality
SELECT *
FROM books

SELECT *
FROM issued_status

SELECT *
FROM members

-- Removing the record if exists
DELETE
FROM issued_status
WHERE
    issued_id = 'IS141'

-- Updating the status manually
UPDATE books
    SET status = 'yes'
WHERE
    isbn = '978-0-553-29698-2'
```
## Reports

* **Database Schema:** Detailed table structures and relationships.
* **Data Analysis:** Insigts into book categories, employee salaries, member registration trends, and issued books.
* **Summary Reports:** Aggregated data on high-demand books and employee performance.

## Conclusion
This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.
