use mealthyme;

-- ordered table drops
drop table if exists meal_recipes;
drop table if exists meals;
drop table if exists recipe_ingredients;
drop table if exists recipes;
drop table if exists shopping_lists;
drop table if exists pantry_foods;
drop table if exists pantries;
drop table if exists users;
drop table if exists foods;

CREATE TABLE foods (
    food_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(128) NOT NULL,
    img_path VARCHAR(128)
);

insert into foods (fname, img_path)
values ("rice", "rice.jpg"), ("peanut butter", "pb.j(pg)"), ("jelly", "j.pg"), ("beans", "magicalfruit.jpg");

CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(128) UNIQUE
);

insert into users (username) values ("roscode");

CREATE TABLE pantries (
    pantry_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    UNIQUE (user_id)
);

insert into pantries (user_id) values (1);

CREATE TABLE pantry_foods (
    pantry_id INT NOT NULL,
    food_id INT NOT NULL,
    FOREIGN KEY (pantry_id)
        REFERENCES pantries (pantry_id),
    FOREIGN KEY (food_id)
        REFERENCES foods (food_id),
    UNIQUE (pantry_id , food_id)
);

insert into pantry_foods values (1, 1), (1, 2), (1, 3), (1, 4);


CREATE TABLE shopping_lists (
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
    recipe_name varchar(128),
    cuisine VARCHAR(128),
    servings int,
    course varchar(45)
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

