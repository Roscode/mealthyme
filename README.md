# mealthyme
Database Design (CS3200) course project, essentially a meal/shopping planning app.


## Proposal

### Group members

Darren Roscoe
Trevor Fox
Aidan Trager

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
    1. User queries the system for Recipes
    2. User selects a recipe (or more than one), and a meal/time slot
    3. The system adds the meal to the plan and updates the shopping list accordingly
* Build a shopping list
    1. User asks the system for a shopping list
    2. The system compiles a list based on ingredients needed for coming meals which aren't in the pantry
* Cook a meal
    1. User selects a meal and marks it as made, optionally inputting any extra ingredients that were used.
    2.The system updates the pantry accordingly

### Choice of database

MySQL

### Software, Apps, Languages, Libraries, Hardware etc.

I'm thinking an Elm-based web front-end, anything but javascript for the application server, and MySQL.
