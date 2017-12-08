-- drop schema if exists mealthyme;
-- create schema mealthyme;
use mealthyme;

-- ordered table drops
-- drop table if exists meal_recipes;
-- drop table if exists meals;
-- drop table if exists recipe_ingredients;
-- drop table if exists recipes;
-- drop table if exists shopping_list_contents;
-- drop table if exists pantry_contents;
-- drop table if exists users;
-- drop table if exists foods;


-- ordered table creates
CREATE TABLE foods (
    food_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    food_name VARCHAR(128) NOT NULL,
    img_path VARCHAR(128)
);

CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(128) UNIQUE NOT NULL,
    password_hash CHAR(61)BINARY
);

CREATE TABLE pantry_contents (
    user_id INT NOT NULL,
    food_id INT NOT NULL,
    CONSTRAINT pantry_user_fk FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT pantry_food_fk FOREIGN KEY (food_id)
        REFERENCES foods (food_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (user_id , food_id)
);

CREATE TABLE shopping_list_contents (
    user_id INT NOT NULL,
    food_id INT NOT NULL,
    CONSTRAINT shopping_list_user_fk FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT shopping_list_food_fk FOREIGN KEY (food_id)
        REFERENCES foods (food_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (user_id , food_id)
);


drop table recipes;
CREATE TABLE recipes (
    recipe_id VARCHAR(128) NOT NULL PRIMARY KEY,
    recipe_name VARCHAR(128) NOT NULL,
    rating INT,
    source_display_name VARCHAR(128),
    attribution VARCHAR(256)
);

CREATE TABLE recipe_ingredients (
    recipe_id VARCHAR(128) NOT NULL,
    food_id INT NOT NULL,
    CONSTRAINT recipe_fk FOREIGN KEY (recipe_id)
        REFERENCES recipes (recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ingedient_fk FOREIGN KEY (food_id)
        REFERENCES foods (food_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (recipe_id , food_id)
);

CREATE TABLE meals (
    meal_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    meal_name VARCHAR(128) NOT NULL,
    description TEXT
);

CREATE TABLE meal_recipes (
    meal_id INT NOT NULL,
    recipe_id varchar(128) NOT NULL,
    multiplicity INT NOT NULL,
    CONSTRAINT meal_fk FOREIGN KEY (meal_id)
        REFERENCES meals (meal_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT meal_recipe_fk FOREIGN KEY (recipe_id)
        REFERENCES recipes (recipe_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE (meal_id , recipe_id)
);

delimiter //
drop procedure bought_food_from_shopping_list //
create procedure bought_food_from_shopping_list(
	uid int,
    fid int
)
begin
if (select exists(select * from shopping_list_contents where user_id = uid and food_id = fid)) then
delete from shopping_list_contents where user_id = uid and food_id = fid;
call add_to_pantry(uid, fid);
end if;
-- do nothing if the item is not in the shopping list
end //

drop procedure add_recipe_to_meal //
create procedure add_recipe_to_meal(
	m_id int,
    r_id varchar(128)
)
begin
if (select exists(select * from meal_recipes where meal_id = m_id and recipe_id = r_id)) then
update meal_recipes set multiplicity = (multiplicity + 1)
where meal_id = m_id and recipe_id = r_id;
else
insert into meal_recipes values (m_id, r_id, 1);
end if;
end//

drop procedure add_ingredient_to_recipe //
create procedure add_ingredient_to_recipe(
	rid varchar(128),
    fname varchar(128)
)
begin
insert ignore into recipe_ingredients
select rid, food_id
from foods where food_name = fname;
end //

drop procedure if exists add_meal_to_shopping_list //
create procedure add_meal_to_shopping_list(
	uid int,
    mealid int
)
begin
insert ignore into shopping_list_contents
select distinct uid, food_id
from meal_recipes join recipe_ingredients using (recipe_id)
	where meal_id = mealid and food_id not in (select food_id from pantry_contents where user_id = uid);
end //



drop procedure if exists get_all_food //
create procedure get_all_food()
begin
select food_name from foods;
end //


drop procedure if exists add_to_pantry //
create procedure add_to_pantry(
	uid int,
    fid int
)
begin
	insert ignore into pantry_contents (user_id, food_id)
    value (uid, fid);
end //


drop procedure if exists get_user_pantry //
create procedure get_user_pantry
(
	uid int
)
begin
SELECT 
    food_name, food_id
FROM
    foods f
        JOIN
    pantry_contents USING (food_id)
WHERE
    user_id = uid;
end //

drop function if exists register //
create function register (
	uname varchar(128),
    pword char(61) binary
)
returns int
begin
insert into users (username, password_hash) values (uname, pword);
return LAST_INSERT_ID();
end //
delimiter ;