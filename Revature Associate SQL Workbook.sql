-- Part I – Working with an existing database

-- Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT * FROM employee;

--Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee WHERE lastname = 'King';

--Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee WHERE firstname = 'Andrew' AND reportsto is null;

--2.2 ORDER BY
--Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album ORDER BY title DESC;

--Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer ORDER BY city;

--2.3 INSERT INTO
--Task – Insert two new records into Genre table
INSERT INTO genre (genreid, name) VALUES (26, 'Country'), (27, 'Kpop');

--Task – Insert two new records into Employee table
INSERT INTO employee VALUES 
	(9, 'John', 'Alen', 'IT Staff', 6, '1962-02-19', '2002-08-14', '1234 Somewhere ave', 'highground', 'AL', 'Canada', 'T6k 2N5', '+1(123)456-7890', '+1(098)765-4321', 'John@chinookcorp.com'), 
	(10, 'Alen', 'JJ', 'IT Staff', 6, '1962-02-12', '2002-08-13', '5678 herewhere ave', 'lowground', 'AL', 'Canada', 'T6k 2N5', '+1(123)456-0000', '+1(098)765-1111', 'Alen@chinookcorp.com');

--Task – Insert two new records into Customer table
INSERT INTO customer VALUES 
	(60, 'Josh', 'Seit', 'John wood Inc.', '5052 shady lake', 'lakeland', 'FL', 'USA', '33888', '+1(574)847-4444', '+1(234)234-2345', 'ee@ee.com', 3),
	(61, 'King', 'tee', 'wood Inc.', '22222 shady lake', 'lakeland', 'GA', 'USA', '44444', '+1(574)847-4333', '+1(234)234-1212', 'ee@rr.com', 4);

--2.4 UPDATE
--Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer SET firstname='Robert', lastname='Walter' WHERE firstname='Aaron' AND lastname='Mitchell';

--Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist SET name='CCR' WHERE name='Creedence Clearwater Revival';

--2.5 LIKE
--Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice WHERE billingaddress LIKE 'T%';

--2.6 BETWEEN
--Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice WHERE total BETWEEN 15 AND 50;

--Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee WHERE hiredate BETWEEN '2003/06/01' AND '2004/03/01';

--2.7 DELETE
--Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
ALTER TABLE invoice
drop CONSTRAINT fk_invoicecustomerid

ALTER TABLE invoice
ADD CONSTRAINT fk_invoicecustomerid
    FOREIGN KEY (customerid)
    REFERENCES customer (customerid)
    ON DELETE CASCADE ON UPDATE NO ACTION

ALTER TABLE invoiceline
drop CONSTRAINT fk_invoicelineinvoiceid


ALTER TABLE invoiceline
ADD CONSTRAINT fk_invoicelineinvoiceid
	FOREIGN KEY (invoiceid)
	REFERENCES invoice (invoiceid)
	ON DELETE CASCADE ON UPDATE NO ACTION

delete from customer where firstname = 'Robert' and lastname='Walter';

--SQL Functions
--In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
--3.1 System Defined Functions
--Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION curr_time()
RETURNS text AS $$
	BEGIN 
	RETURN CURRENT_TIME;
	END;
$$ LANGUAGE plpgsql

--Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION mediatype_length()
	RETURNS integer AS $len$
	DECLARE len integer;
	BEGIN
		SELECT COUNT(mediatype) INTO len FROM mediatype;
		RETURN len;
	END;
	$len$ LANGUAGE plpgsql

--3.2 System Defined Aggregate Functions
--Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION invoice_total_avg()
	RETURNS float AS $total_avg$
	DECLARE total_avg float;
	BEGIN
		SELECT AVG(total) INTO total_avg FROM invoice;
		RETURN total_avg;
	END;
	$total_avg$ LANGUAGE plpgsql

--Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION most_expensive_track()
		RETURNS float AS $et$
		DECLARE et float;
		BEGIN
			SELECT MAX(unitprice) INTO et FROM track;
			RETURN et;
		END;
		$et$ LANGUAGE plpgsql


--3.3 User Defined Scalar Functions
--Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION invoiceline()
	RETURN integer as $a$
	DECLARE a integer;
	BEGIN
		SELECT AVG(unitprice) INTO a FROM invoiceline;
		RETURN a; 
	END;
	$a$ LANGUAGE plpgsql

--3.4 User Defined Table Valued Functions
--Task – Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION born_after_1968()
	RETURNS Table (firstname VARCHAR, lastname VARCHAR, birthdate TIMESTAMP ) as $x$
	BEGIN
		RETURN QUERY SELECT firstname, lastname, birthdate FROM employee WHERE birthdate >= '1969-01-01';
	END;
	$x$ LANGUAGE plpgsql

--4.0 Stored Procedures
--In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
--4.1 Basic Stored Procedure
--Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION employee_fullname()
    RETURNS TABLE ( firstname VARCHAR, lastname VARCHAR) as $x$
    BEGIN
        RETURN QUERY SELECT employee.firstname, employee.lastname FROM employee;
    END;
    $x$ LANGUAGE plpgsql

--4.2 Stored Procedure Input Parameters
--Task - Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION managers_employee()
    RETURNS void as $$
        BEGIN
            UPDATE employee SET firstname = 'Josh' WHERE employeeid = 10;
        END;
        $$ LANGUAGE plpgsql

--Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION managers_employee(managers integer)
	RETURNS TABLE (firstname VARCHAR, lastname VARCHAR) as $x$
	BEGIN
		RETURN QUERY SELECT employee.firstname, employee.lastname FROM employee 
			WHERE employee.employeeid =  managers;
		END;
		$x$ LANGUAGE plpgsql

--4.3 Stored Procedure Output Parameters
--Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION name_and_company(customer integer)
	RETURNS TABLE (firstname VARCHAR, lastname VARCHAR, company VARCHAR) as $x$
	BEGIN
		RETURN QUERY SELECT customer.firstname, customer.lastname customer.company
			FROM customer WHERE customer.customerid = customer;
	END;
	$x$ LANGUAGE plpgsql

--5.0 Transactions
--In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
--Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
--Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table

--6.0 Triggers
--In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE TRIGGER after_insert
    AFTER INSERT ON employee
    FOR EACH ROW
    EXECUTE PROCEDURE suppress_redundant_updates_trigger();

--Task – Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE TRIGGER after_update
	AFTER UPDATE ON album
	FOR EACH ROW
	executed Procedure suppress_redundant_updates_trigger();

--Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE TRIGGER after_delete
    AFTER DELETE ON customer
    FOR EACH ROW
    EXECUTE PROCEDURE suppress_redundant_updates_trigger();

--6.2 INSTEAD OF
--Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE VIEW invoice as SELECT * FROM invoice;
CREATE TRIGGER instead_of_delete_trigger
	INSTEAD OF DELETE ON invoice
		FOR EACH ROW
		WHEN (total > 50)
	EXCUTE PROCEDURE suppress_redundant_updates_trigger();

--7.0 JOINS
--In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
--7.1 INNER
--Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
Select customer.firstname, customer.lastname, invoice.invoiceid 
	FROM customer INNER JOIN invoice ON customer.customerid = invoice.customerid;

--7.2 OUTER
--Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
Select customer.customerid, customer.firstname, customer.lastname, invoice.invoiceid, invoice.total 
	FROM customer FULL JOIN invoice ON customer.customerid = invoice.customerid;

--7.3 RIGHT
--Task – Create a right join that joins album and artist specifying artist name and title.
SELECT artist.name, album.title 
	FROM album RIGHT JOIN artist ON album.artistid = artist.artistid;

--7.4 CROSS
--Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM album CROSS JOIN artist ORDER BY artist.name;

--7.5 SELF
--Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT * FROM employee e1 inner Join employee e2 ON e1.employeeid = e2.reportsto;



