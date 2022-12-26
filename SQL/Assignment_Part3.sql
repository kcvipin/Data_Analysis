USE ASSIGNMENT;

-- 1.
SELECT * FROM ORDERS;

DELIMITER //
CREATE PROCEDURE ORDER_STATUS(IN VAR1 INT, IN VAR2 INT)
BEGIN
SELECT ORDERNUMBER, ORDERDATE, STATUS FROM ORDERS
WHERE YEAR(ORDERDATE)=VAR1 AND MONTH(ORDERDATE)=VAR2;
END //
DELIMITER //

CALL ORDER_STATUS(2005,11);
CALL ORDER_STATUS(2003,03);

-- 2.
-- a).
DROP TABLE IF EXISTS CANCELLATIONS;
CREATE TABLE CANCELLATIONS(
ID INT PRIMARY KEY,
CUSTOMERNUMBER INT,
ORDERNUMBER INT,
COMMENTS VARCHAR(100));

ALTER TABLE CANCELLATIONS ADD CONSTRAINT CUST_FK FOREIGN KEY (CUSTOMERNUMBER) REFERENCES CUSTOMERS(CUSTOMERNUMBER);
ALTER TABLE CANCELLATIONS ADD CONSTRAINT ORDER_FK FOREIGN KEY (ORDERNUMBER) REFERENCES ORDERS(ORDERNUMBER);

SELECT * FROM CANCELLATIONS;
SELECT * FROM ORDERS;

-- b).
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `assignment 2`()
BEGIN
declare lcl_orn integer;
declare lcl_cn integer;
declare lcl_com text;
declare finished integer default 0;
declare mycur cursor for select  ordernumber,customernumber,comments from orders where status='cancelled';
declare continue handler for not found
begin
   set finished =1;
end;

open mycur;
     myloop:loop
     
     
     fetch mycur into lcl_orn,lcl_cn,lcl_com;
  
  if finished =1 then 
     leave myloop;
   end if;
   insert into cancellation (ordernumber,customernumber,comments) values(lcl_orn,lcl_cn,lcl_com);
   end loop myloop;
END //
DELIMITER ;

-- 3.
-- a).

DROP FUNCTION STATUS_FUNCTION;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `status_function`(custnum int) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE status VARCHAR(20);
    declare amt int;
    select sum(amount) into amt from payments where customernumber =custnum;
    IF amt < 25000 THEN SET status = 'GOLD';
    ELSEIF (amt >=25000 AND amt <= 50000) THEN

        SET status = 'GOLD';
    ELSe
        SET status = 'PLATINUM';
	end if;
	-- return the customer level
RETURN (status);
End//
DELIMITER ;

-- b).
SELECT customernumber,customername,status_function(customernumber) as purchase_status from customers;

-- 4.
SELECT * FROM MOVIES;
SELECT * FROM RENTALS;

DELIMITER //
CREATE TRIGGER ON_DELETE_TRIGG
AFTER DELETE ON MOVIES FOR EACH ROW
BEGIN
DELETE FROM RENTALS WHERE MOVIEID NOT IN (SELECT DISTINCT ID FROM MOVIES);
END //
DELIMITER ;

DELIMITER &&
CREATE TRIGGER ON_UPDATE_TRIGG
AFTER UPDATE ON MOVIES FOR EACH ROW
BEGIN
UPDATE RENTALS SET MOVIEID = ID WHERE MOVIEID = OLD.ID;
END &&
DELIMITER ;

SHOW TRIGGERS;

-- 5.
SELECT * FROM EMPLOYEE;

SELECT FNAME FROM EMPLOYEE ORDER BY SALARY DESC LIMIT 1 OFFSET 2;

-- 6.
SELECT *,RANK() OVER (ORDER BY SALARY DESC) AS SAL_RANK FROM EMPLOYEE ;