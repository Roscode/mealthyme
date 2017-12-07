use mealthyme;

-- ordered table drops
drop table if exists meal_recipes;
drop table if exists meals;
drop table if exists recipe_ingredients;
drop table if exists recipes;
drop table if exists shopping_list_contents;
drop table if exists pantry_contents;
drop table if exists users;
drop table if exists foods;

CREATE TABLE foods (
    food_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    food_name VARCHAR(128) NOT NULL,
    img_path VARCHAR(128)
);

delimiter //
drop procedure if exists get_all_food //
create procedure get_all_food()
begin
select food_name from foods;
end //
delimiter ;

CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(128) UNIQUE NOT NULL,
    password_hash CHAR(61) BINARY
);

delimiter //
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

CREATE TABLE pantry_contents (

    user_id INT NOT NULL,
    food_id INT NOT NULL,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    FOREIGN KEY (food_id)
        REFERENCES foods (food_id),
    UNIQUE (user_id , food_id)
);

select * from users;

insert into pantry_contents (user_id, food_id) values (1, 1);
insert into pantry_contents (user_id, food_id) value (1, 2);

delimiter //
drop procedure if exists add_to_pantry //
create procedure add_to_pantry(
	uid int,
    fid int
)
begin
	insert ignore into pantry_contents (user_id, food_id) value (uid, fid);
end //
delimiter ;

delimiter //
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
delimiter ;

call get_user_pantry(1);

select * from foods where food_name like '%egg%' limit 15;

CREATE TABLE shopping_list_contents (
    user_id INT NOT NULL,
    food_id INT NOT NULL,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    FOREIGN KEY (food_id)
        REFERENCES foods (food_id),
    UNIQUE (food_id , user_id)
);

CREATE TABLE recipes (
    recipe_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    recipe_name VARCHAR(128),
    cuisine VARCHAR(128),
    servings INT,
    course VARCHAR(45)
);

CREATE TABLE recipe_ingredients (
    recipe_id INT NOT NULL,
    food_id INT NOT NULL,
    FOREIGN KEY (recipe_id)
        REFERENCES recipes (recipe_id),
    FOREIGN KEY (food_id)
        REFERENCES foods (food_id),
    UNIQUE (recipe_id , food_id)
);

CREATE TABLE meals (
    meal_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    meal_name VARCHAR(128) NOT NULL,
    description TEXT
);

CREATE TABLE meal_recipes (
    meal_id INT NOT NULL,
    recipe_id INT NOT NULL,
    multiplicity INT NOT NULL,
    FOREIGN KEY (meal_id)
        REFERENCES meals (meal_id),
    FOREIGN KEY (recipe_id)
        REFERENCES recipes (recipe_id),
    UNIQUE (meal_id , recipe_id)
);