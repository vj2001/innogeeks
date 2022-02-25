/*create table roles(
   roleid INT PRIMARY KEY SERIAL,
   rolename ENUM('seller','buyer') NOT NULL
)*/

create table users(
   userid INT PRIMARY KEY SERIAL,
   username varchar(50),
   --roleid INT REFERENCES roles(roleid) 
)
create table categories(
    catid INT PRIMARY KEY SERIAL,
	catname varchar(30) UNIQUE
)
create table products(
	 productid INT PRIMARY KEY SERIAL,
	 productname varchar(50) UNIQUE,
	 catid INT references categories(catid),
	 price INT,
	 prodcount INT,
)
create table orders(
      orderid INT PRIMARY KEY SERIAL,
	  recid INT REFERENCES users(userid),
	  prodid INT references products(productid),
	  ordertime TIMESTAMP NOT NULL,
	  totalcost INT
)

CREATE OR REPLACE FUNCTION increase_the_products()

	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	as
	$$
		 BEGIN
		             IF EXISTS(select * from products where productname=NEW.productname) then
					 UPDATE products SET prodcount= prodcount+1 where productname = NEW.productname;
					 ELSE
					 INSERT INTO products(productname,catid,price,prodcount)
					                      values(NEW.productname,NEW.catid,NEW.price,1)
					 END IF;
					 
		 END;
	$$

-- creating trigger to increase count of specific product
CREATE TRIGGER increase_products_count    
 INSTEAD OF INSERT
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
				      UPDATE orders set totalcost= (select price from products where productid=NEW.productid); 
		 END;
	$$

-- creating trigger to increase count of specific product
CREATE TRIGGER decrease_products_count    
 BEFORE INSERT
 ON orders
 FOR EACH ROW
     EXECUTE PROCEDURE decrease_the_products()ategories	;


-- creating complete view

CREATE VIEW order_details
as
   select o.orderid,o.ordertime,o.totalcost,p.productname,p.prodcount,c.catname from orders o
   INNER JOIN products p
   ON o.prodid = p.productid
   INNER JOIN users u
   ON o.recid = u.userid
   INNER JOIN categories c
   ON p.catid = c.catid