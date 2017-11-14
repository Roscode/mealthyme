use mealthyme;

-- ordered table drops
drop table if exists meal_recipes;
drop table if exists meals;
drop table if exists recipe_ingredients;
drop table if exists recipes;
drop table if exists shopping_lists;
drop table if exists pantry_foods;
drop table if exists pantries;
drop table if exists user_households;
drop table if exists households;
drop table if exists users;
drop table if exists foods;

create table foods (
    food_id int not null AUTO_INCREMENT PRIMARY KEY,
    name varchar(128) not null,
    img varchar(128)
);

create table users (
    user_id int not null AUTO_INCREMENT primary KEY,
    username varchar(128) unique
);

create table households (
    household_id int not null AUTO_INCREMENT primary KEY
);

create table user_households (
    user_id int not null,
    household_id int not null,
    foreign key (user_id) references users(user_id),
    foreign key (household_id) references households(household_id),
    unique (user_id, household_id)
);

create table pantries (
    pantry_id int not null AUTO_INCREMENT PRIMARY KEY
    household_id int not null,
    foreign key (household_id) references households(household_id),
    unique (household_id)
);

create table pantry_foods (
    pantry_id int not null,
    food_id int not null,
    foreign key (pantry_id) references pantries(pantry_id),
    foreign key (food_id) references foods(food_id),
    unique (pantry_id, food_id)
);

create table shopping_lists (
    household_id int not null,
    food_id int not null,
    foreign key (household_id) references households(household_id),
    foreign key (food_id) references foods(food_id),
    unique (food_id, household_id)
);

create table recipes (
    recipe_id int not null AUTO_INCREMENT primary key,
    cuisine varchar(128),
    directions TEXT
);

create table recipe_ingredients (
    recipe_id int not null,
    food_id int not null,
    foreign KEY (recipe_id) references recipes(recipe_id),
    foreign key (food_id) references foods(food_id),
    unique (recipe_id, food_id)
);

create table meals (
    meal_id int not null AUTO_INCREMENT PRIMARY KEY,
    name varchar(128) not null
);

create table meal_recipes (
    meal_id int not null,
    recipe_id int not null,
    multiplicity int not null,
    foreign key (meal_id) references meals(meal_id),
    foreign key (recipe_id) references recipes(recipe_id),
    unique (meal_id, recipe_id)
);
