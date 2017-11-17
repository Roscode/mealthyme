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

Please (go to the repo) and see [schema.sql](https://github.com/Roscode/mealthyme/blob/master/model/schema.sql) and [er_diagram.pdf](https://github.com/Roscode/mealthyme/blob/master/model/er_diagram.pdf) for database structure. Currently the schema is missing some fields (such as an amount column in pantry_contents to take that into account when planning meals and shopping) on purpose because of their complexity, once we have finished building the skeleton of the application and represented the schema so far we will begin adding those extra details and features.

### Data

The nature of our application is such that it requires quite a bit of data to be very useful, and having the user input all of the recipe data defeats the point of having an application at all. So we went looking for a suitable API to get access to some of that valuable data, and found [The Yummly Recipe API](https://developer.yummly.com/). We have an api key and are already beginning to use it's metadata dictionaries to fill our foods table. We will also use the API to power the recipe search functionality in our application.

When we first found the yummly API we were minorly disheartened since the yummly app seems like a much better version of our goal for this project, but we realized that in our app we also represent meals as combinations of recipes and that once we are able to implement keeping track of amounts, we will be able optimize on those meals in a way that yummly does not do.

### Users of the database system

1. End Users
2. Application/Developers
3. DB Admins

### End User Interactions

#### Add Stuff to pantry

* Create food for each type of item in the real pantry
* Create a food items for each item in the real pantry
    * User inputs price when possible, we'll deal with that later
    * Amounts are tough, converting between weights and volumes frequently, for now the user will just input when they are low/out of something
* Created food items are automatically added to the pantry
* Combine different items of the same food type

#### Recipe/Meal Creation

* A user can manually create a recipe
    * User creates food for items in the recipe
    * User creates the recipe
    * A compilation food and amounts
    * Directions, time serving size etc.
* Or they can search the api
    * Search by different concepts (cuisine, nutrition maybe, food contents, diet)
* Either way add recipes to a meal
* Save the meal


#### Plan a meal

* Choose a meal to make sometime in the future (dates are another area we will come back to after fleshing out the current schema more)
* The necessary ingredients which are not in your pantry are added to your shopping list

#### Go shopping

* Display the shopping list
* Check off items as you go for convenience
* Afterwards, you input prices for everything (optional) and amounts (maybe)
* Those things are added to your pantry
* Items are removed from shopping list

#### Make a meal

* Select a meal as to be prepared
* Gives you the directions or a link or whatever
* When you mark as made it asks if you are out of any of the items
    * If so remove from pantry

#### Have a snack

* Remove specific items from the pantry
* They were eaten or went bad or something

### Choice of database

We will use MySQL.

### Software, Apps, Languages, Libraries, Hardware etc.

We are beginning to implement using the following stack:
* An Elm-based web user interface
* A Racket HTTP application server, using [Spin](https://github.com/dmac/spin) for a rest framework
* MySQL database connection using the racket db package

We want our backend to run as portably as possible to keep cloud hosting options simple to implement if we decide to do so, therefore we will develop for linux and/or use a containerization system such as docker.

### Link to the repo

[View the code here](https://github.com/Roscode/mealthyme)
