# mealthyme
Database Design (CS3200) course project, essentially a meal/shopping planning app.


## Proposal

### Group members

* Darren Roscoe
* Trevor Fox
* Aidan Trager

### Name of blackboard group

Fox-Roscoe-Trager

### Top level description

This projects aims to provide a single user with an (relatively) automated way to plan their grocery shopping and meal preparation. Many college students and people in general, ourselves included, find it difficult to efficiently plan their meals and shopping and as a result end up wasting food that goes bad, money to order food or go out, and time trying to organize everything by hand. Poor meal planning can also contribute to weight gain as the easiest meals aren't necessarily the healthiest.

### Model

Please (go to the repo) and see schema.sql and er_diagram.pdf for database structure. We are currently not going to concern ourselves with amounts of food because of the complexity there (i.e. buying a pound of flour and using "a little more than" 3 cups is difficult to model effectively), but as we get further into the project we will attempt to introduce it, so we're boing to build the system with that forethought.

### Users of the database system

1. Users
2. Application/Developers
3. DB Admins

### User stories

#### Add Stuff to pantry

* create food for each type of item in the real pantry
* create a food items for each item in the real pantry
    * User inputs price when possible, we'll deal with that later
    * amounts are tough, converting between weights and volumes frequently, for now the user will just input when they are low/out of something
* created food items are automatically added to the pantry
* combine different items of the same food type

#### Recipe/Meal Creation

* A user can manually create a recipe
    * User creates food for items in the recipe
    * User creates the recipe
    * a compilation food and amounts
    * directions, time serving size etc.
* Or they can search the api
    * search by different concepts (cuisine, nutrition maybe, food contents, diet)
* either way add recipes to a meal
* save the meal


#### Plan a meal

* choose a date to make the meal
* The necessary ingredients which are not in your pantry are added to your shopping list

#### Go shopping

* display the shopping list
* check off items as you go for convenience
* afterwards, you input prices for everything (optional) and amounts (maybe)
* those things are added to your pantry
* items are removed from shopping list

#### Make a meal

* Select a meal as to be prepared
* Gives you the directions or a link or whatever
* when you mark as made it asks if you are out of any of the items
    * if so remove from pantry

#### Have a snack

* Remove specific items from the pantry
* They were eaten or went bad or something

### Choice of database

We will use MySQL.

### Software, Apps, Languages, Libraries, Hardware etc.

We are beginning to implement using the following stack:
* An Elm-based web user interface
* A Racket HTTP application server
* MySQL database connection using the racket db package

We want our backend to run as portably as possible to keep cloud hosting options simple to implement if we decide to do so, therefore we will develop for linux and/or use a containerization system such as docker.

### Link to the repo

[View the code here](https://github.com/Roscode/mealthyme)
