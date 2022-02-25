/*create table roles(
   roleid INT PRIMARY KEY SERIAL,
   rolename ENUM('seller','buyer') NOT NULL
)*/

create table users(
   userid SERIAL PRIMARY KEY,
   username varchar(50)
)

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
-- ALTER table products ADD COLUMN productname varchar(50);
-- alter table products alter price type decimal;
-- delete from products 

create table orders(
      orderid SERIAL PRIMARY KEY,
	  recid INT REFERENCES users(userid),
	  prodid INT references products(productid),
	  ordertime TIMESTAMP NOT NULL,
	  totalcost INT
)
alter table orders alter totalcost type decimal;

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
		 BEGIN        
		              UPDATE products SET prodcount= prodcount-1 where productid = NEW.prodid;
				      UPDATE orders set totalcost= (select price from products where productid=NEW.prodid)
					  where orderid=NEW.orderid;
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

CREATE OR REPLACE VIEW order_details
as
   select o.orderid,o.ordertime,o.totalcost,p.productname,p.prodcount,c.catname,u.username from orders o
   INNER JOIN products p
   ON o.prodid = p.productid
   INNER JOIN users u
   ON o.recid = u.userid
   INNER JOIN categories c
   ON p.catid = c.catid
   
 select * from order_details  
   
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