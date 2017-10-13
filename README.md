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

This projects aims to provide a single user (or household) with an easy and automated way to plan their grocery shopping and meal preparation. Many college students and people in general, ourselves included, find it difficult to efficiently plan their meals and shopping and as a result end up wasting food that goes bad, money to order food or go out, and time trying to organize everything by hand. Poor meal planning can also contribute to weight gain as the easiest meals aren't necessarily the healthiest.

The data domains we will need to master for this project will include:
* Food items including amount, price, and possibly nutritional data.
* Recipes and their relationship to food items especially regarding amount.
* Time. We will need to keep track of days, weeks, and possibly months in advance to really optimize for cost.
* Meals will likely be among the most complex entity/set of entities and relationships in the model, since they will need to relate to almost all other entities and represent much of the most crucial information for the app.
* Users will be represented of course.
* Households will be collections of users to allow for more than one person to collaborate on meal planning.
* A Pantry will represent the collection of food items available to a household.
* A Shopping list will represent the set of food needed for some future meals that isn't present in the Pantry
* Probably more we haven't thought of yet.

### Users of the database system

1. Users
2. Application/Developers
3. DB Admins

### Use cases
* Plan a meal
    1. The user queries the app for Recipes
    2. The user selects a recipe (or more than one), and a meal/time slot
    3. The app adds the meal to the user's plan
* Go grocery shopping
    1. The user queries the app for a shopping list for
    2. The app provides a list of items to purchase in order to fill the pantry for the most future meals using the least cost (and possibly optimize other metrics in future version).
    3. The user informs the app what was purchased and for how much and the app updates the pantry accordingly
        * This step could be tedious, we may want to look into grocery store APIs or receipt reading libraries if either of those exist
* Cook a meal
    1. The user selects a meal to make either from the plan or a list of recipes in the case of unplanned meals
    2. The app provides the recipe(s) and directions (or a link thereto) for the meal
    3. The user informs the app the meal is completed and optionally enters any extra ingredients used (in case of spillage and such)
    4. The app records the food items used and updates the pantry accordingly

### Choice of database

MySQL

### Software, Apps, Languages, Libraries, Hardware etc.

I'm thinking an Elm-based web front-end, anything but javascript for the application server, and MySQL.
