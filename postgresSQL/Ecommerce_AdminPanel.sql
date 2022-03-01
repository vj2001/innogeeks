/*create table roles(
   roleid INT PRIMARY KEY SERIAL,
   rolename ENUM('seller','buyer') NOT NULL
)*/

create table users(
   userid SERIAL PRIMARY KEY,
   username varchar(50)
)
alter table users ADD COLUMN phone varchar(12) UNIQUE, ADD COLUMN pincode varchar(10);

create table categories(
    catid SERIAL PRIMARY KEY,
	catname varchar(30) UNIQUE
)
create table products(
	 productid SERIAL PRIMARY KEY,
	 productname varchar(50),
	 catid INT references categories(catid),
	 price INT,
	 prodcount INT
)
Alter table products Add constraint prodcount_check CHECK(prodcount>=0)
/* ALTER table products ADD COLUMN productname varchar(50);
 alter table products alter price type decimal;
 delete from products 
alter table users ADD COLUMN phone varchar(12) UNIQUE,ADD COLUMN pincode varchar(10);
Update users SET phone = '2309123451' where userid=1;
Update users SET phone = '6548122507' where userid=2;
Update users SET phone = '9765489077' where userid=3 */

create table orders(
      orderid SERIAL PRIMARY KEY,
	  recid INT REFERENCES users(userid),
	  prodid INT references products(productid),
	  ordertime TIMESTAMP NOT NULL,
	  totalcost INT
)
alter table orders alter totalcost type decimal;
alter table orders add column coupon boolean default false;

CREATE OR REPLACE FUNCTION increase_the_products()

	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	as
	$$
		 BEGIN
		             IF (select COUNT(*) from products where productname=NEW.productname)>1 then
					 UPDATE products SET prodcount= prodcount+1 where productname = NEW.productname;
					 DELETE from products where productid= NEW.productid;
					 ELSE
					 UPDATE products SET prodcount= 1 where productid = NEW.productid;
					 END IF;
					 RETURN NEW;
		 END;
	$$


-- creating trigger to increase count of specific product
CREATE TRIGGER increase_products_count    
 AFTER INSERT
 ON products
 FOR EACH ROW
     EXECUTE PROCEDURE increase_the_products();
	

-------------------------------------
CREATE OR REPLACE FUNCTION decrease_the_products()

	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	as
	$$
	     DECLARE totcost decimal;
		 BEGIN        
		            /*IF (select prodcount from products where productid=NEW.prodid)=0 then
					Delete from orders where orderid=(select orderid from orders ORDER BY orderid DESC LIMIT 1);
					RAISE NOTICE 'Hey Admin, Please add more samples to order';
					ELSE*/
		            Update products SET prodcount= prodcount-1 where productid = NEW.prodid; 
					totcost= (select price from products where productid=NEW.prodid);
					
					IF (NEW.coupon= true) then                       --coupon applied--
					totcost = ROUND((totcost/2),2);                  --round off 2 decimal places
					END IF;
					 
					UPDATE orders set totalcost= totcost where orderid=NEW.orderid;
					RETURN NEW;
		 END;
	$$

-- creating trigger to decrease count of specific product
CREATE TRIGGER decrease_products_count    
 AFTER INSERT
 ON orders
 FOR EACH ROW
     EXECUTE PROCEDURE decrease_the_products();


-- creating complete view

CREATE OR REPLACE VIEW bill
as
   select o.orderid,o.ordertime,o.totalcost,pr.productname,ct.catname,u.username,u.phone,u.pincode
   from orders o
   INNER JOIN products pr
   ON o.prodid = pr.productid
   INNER JOIN users u
   ON o.recid = u.userid
   INNER JOIN categories ct
   ON pr.catid = ct.catid
   
 select * from bill
   
 insert into users(username) values ('Vishal'),('Tom'),('Dhanush');
 select * from users;
 insert into categories(catname) values ('Electronics'),('Grocery');
 select * from categories;
 insert into products(productname,catid,price) values('Headphones',1,850),('Noodles',2,30),('Earphones',1,230);
 select * from products
 insert into products(productname,catid,price) values('Headphones',1,850)
 
 insert into orders(recid,prodid,ordertime) values(1,13,now()),(2,12,now())
 select * from orders
  insert into orders(recid,prodid,ordertime) values(1,11,now())
  insert into products(productname,catid,price) values('Earphones',1,230),('Cornflakes',2,432.5);
  
  
  
  -- AuditTrails for each table--
  --For products table
  CREATE TABLE audit_products(
    audit_id SERIAL PRIMARY KEY,
	audit_op varchar(15),
	audit_time TIMESTAMP NOT NULL,
	cat_name varchar(30),
	old_prod_name varchar(50),
	old_prod_price INT,
	old_prod_count INT,
	new_prod_name varchar(50),
	  new_prod_price INT,
	  new_prod_count INT
  )
  
  CREATE OR REPLACE FUNCTION logs_products()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	as
	$$
		 BEGIN
		         IF(TG_OP ='INSERT') THEN
		         INSERT INTO audit_products(audit_op,audit_time,cat_name,old_prod_name,old_prod_price,
											old_prod_count,new_prod_name,new_prod_price,new_prod_count)
				 VALUES('INSERT',now(),(select catname from categories where catid=NEW.catid),NULL,NULL,
						NULL,NEW.productname,NEW.price,NEW.prodcount);
				    
				 ELSIF(TG_OP ='UPDATE') THEN
		         INSERT INTO audit_products(audit_op,audit_time,cat_name,old_prod_name,old_prod_price,
											old_prod_count,new_prod_name,new_prod_price,new_prod_count)
				 VALUES('UPDATE',now(),(select catname from categories where catid=NEW.catid),OLD.productname,
						OLD.price,OLD.prodcount,NEW.productname,NEW.price,NEW.prodcount);
					
				 END IF;
				 RETURN NULL;
		 END;
	$$


-- creating trigger to record product logs
CREATE TRIGGER get_products_logs
 AFTER INSERT OR UPDATE
 ON products
 FOR EACH ROW
     EXECUTE PROCEDURE logs_products()
	

select * from audit_products


  --For users table
  CREATE TABLE audit_users(
    audit_id SERIAL PRIMARY KEY,
	audit_op varchar(15),
	audit_time TIMESTAMP NOT NULL,
	old_user_name varchar(50),
	new_user_name varchar(50),
	  old_phone varchar(12),
	new_user_phone varchar(12),
	  old_user_pincode varchar(10),
	new_user_pincode varchar(10)
  )
  
  CREATE OR REPLACE FUNCTION logs_users()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	as
	$$
		 BEGIN
		         IF(TG_OP='INSERT') THEN
		         INSERT INTO audit_users(audit_op,audit_time,old_user_name,new_user_name,
										 old_phone,new_user_phone,old_user_pincode,new_user_pincode)
				 VALUES('INSERT',now(),NULL,NEW.username,NULL,NEW.phone,NULL,NEW.pincode);
					   
				 ELSIF(TG_OP='UPDATE') THEN
		         INSERT INTO audit_users(audit_op,audit_time,old_user_name,new_user_name,
										 old_phone,new_user_phone,old_user_pincode,new_user_pincode)
				 VALUES('UPDATE',now(),OLD.username,NEW.username,OLD.phone,NEW.phone,OLD.pincode,NEW.pincode);
					   
				 END IF;
				 RETURN NULL;
		 END;
	$$


-- creating trigger to get user logs
CREATE TRIGGER get_users_logs
 AFTER INSERT OR UPDATE
 ON users
 FOR EACH ROW
     EXECUTE PROCEDURE logs_users();

select * from users;
insert into users(username,phone,pincode) values ('Nick Jonas','8004532123','435761')
update users set username='Vishal Jain' where username='Vishal'
update users set username='Tom Mike' where username='Tom'
update users set username='Dhanush Kumar' where username='Dhanush'

select * from audit_users;

--Fire some more queries
insert into categories(catname) values('LifeStyle');
select * from categories;
insert into products(productname,catid,price) values('Hoodies',3,540);
insert into products(productname,catid,price) values('Noodles',2,30);
select * from products
insert into orders(recid,prodid,ordertime) values(9,23,now())
select * from orders

select * from bill

insert into orders(recid,prodid,ordertime) values(2,12,now())
insert into products(productname,catid,price) values('Cornflakes',2,432.5)

-- violating the constraint that product not available in stock
insert into orders(recid,prodid,ordertime,coupon) values(9,18,now(),true)
insert into orders(recid,prodid,ordertime,coupon) values(1,23,now(),true)
--delete from orders where orderid=24
