# mealthyme

## Final Report

### Group members

* Darren Roscoe
* Trevor Fox

### Name of blackboard group

Fox-Roscoe-Trager

### Top level description

This projects aims to provide a single user with a relatively automated way to plan their grocery shopping and meal preparation. Many college students and people in general, ourselves included, find it difficult to efficiently plan their meals and shopping and as a result end up wasting food that goes bad, money to order food or go out, and time trying to organize everything by hand. Poor meal planning can also contribute to weight gain as the easiest meals aren't necessarily the healthiest.

### Setup

#### Software requirements

You will need to install [node and npm](https://nodejs.org/en/), [elm](https://guide.elm-lang.org/install.html), and [drracket](https://download.racket-lang.org/) (and mysql if you haven't already).

Also we have had some compatibility issues with Windows, so if you don't own a unix machine go buy one (or install linux).

#### Installing dependencies

`cd` into the views folder and run `npm install` then `npm start`

### Model

Please (go to the repo) and see [schema.sql](https://github.com/Roscode/mealthyme/blob/master/model/schema.sql) and [er_diagram.pdf](https://github.com/Roscode/mealthyme/blob/master/model/er_diagram.pdf) for database structure. Currently the schema is missing some fields (such as an amount column in pantry_contents to take that into account when planning meals and shopping) on purpose because of their complexity, once we have finished building the skeleton of the application and represented the schema so far we will begin adding those extra details and features.


### Technical Specification

Our stack is the following:
* MySql DBMS
* A Racket REST(ish) API using the following libraries:
  + racket base web-server/servlet, http, http/request-structs json
  + [dmac/spin](https://github.com/dmac/spin) for our rest API framework to speed up developement
  + [net/jwt](https://pkgs.racket-lang.org/package/net-jwt) for jwt encoding/decoding
  + [bcrypt](https://pkgs.racket-lang.org/package/bcrypt) for password hashing
* An Elm Web User interface using the following libraries
  + [NoRedInk/elm-decode-pipeline](http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/3.0.0/Json-Decode-Pipeline)
  + [elm-community/json-extra]()
  + [evancz/url-parser](http://package.elm-lang.org/packages/circuithub/elm-json-extra/latest/Json-Decode-Extra)
  + [lukewestby/elm-http-builder](http://package.elm-lang.org/packages/lukewestby/elm-http-builder/latest/HttpBuilder)
  + [lukewestby/elm-string-interpolation](http://package.elm-lang.org/packages/lukewestby/elm-string-interpolate/1.0.1/String-Interpolate)
  + [rtfeldman/elm-validate](http://package.elm-lang.org/packages/rtfeldman/elm-validate/1.1.3)
  + [rtfeldman/selectlist](http://package.elm-lang.org/packages/rtfeldman/selectlist/1.0.0)

### Data

The nature of our application is such that it requires quite a bit of data to be very useful, and having the user input all of the recipe data defeats the point of having an application at all. So we went looking for a suitable API to get access to some of that valuable data, and found [The Yummly Recipe API](https://developer.yummly.com/). We have an api key and are already beginning to use it's metadata dictionaries to fill our foods table. We will also use the API to power the recipe search functionality in our application.

When we first found the yummly API we were minorly disheartened since the yummly app seems like a much better version of our goal for this project, but we realized that in our app we also represent meals as combinations of recipes and that once we are able to implement keeping track of amounts, we will be able optimize on those meals in a way that yummly does not do.

### User Flow

### Lessons Learned
Over the course of this project we learned a lot. Mostly through failure, which as everyone knows is the best way to learn! Here are some of the things we learned
1. Elm! Elm is a language Darren has been eyeballing all semester, but didn't have the time or opportunity to try it out until this project. After a few weeks of using it succesfully we are very pleased with what we've found. In particular the compiler error messages are some of the best we've seen and super helpful in finding bugs before they run. Also it compiles to javascript so it is easy to build and manage dependencies using the elm-package and npm package distribution systems.
2. Trevor learned git! We used git to manage our source code.
3. We both learned the difficulties of distributed workflows. We had a lot of trouble initially being able to work on the project simultaneously since any work being done that early would heavily depend on everything else so multiple separate changes could quickly break the app. Because of this we did a lot of partner programming, and then soon after getting to a point where distributing work made sense, we began having compatibility issues with windows, namely because of a dependency on gcc deep in one of our racket packages.
4. Currently our frontend is pretty lacking in features as we decided to completely overhaul it after our presentation (it was very hacky before then). We did this because this is something that interests us and we intend to work more on it after the semester ends, so we wanted to start from a more solid base rather than continue to throw features on top of a plate of spaghetti (code) only to later realize we forgot the meatballs (passwords, proper routing, etc.).

### Future Work

This project was very challenging, we set high goals, and frankly there is a lot left to do. This was intentional, and we will be doing more with the project after finals. Among the many improvements we plan to make are the following:
1. Finish the Elm UI. Now that we have a solid base and a better grasp of Elm practices and patterns this will get easier and easier.
2. Add calendar support. We decided early on not to worry about dates yet (i.e. expiring food and planning a meal for a specific day) and instead to simply have meals and the ability to add the required (and not already owned) ingredients to the shopping list, but it will become necessary if we want to be able to offer meal plan optimizations (along the lines of offering strings of meals which encourage ingredient reuse).
3. Add support for amounts. Another challenge we outsourced to our future selves is dealing with amounts of foods. This may sounds simple (and did to us at first) until you realize that in order to be useful the representation of food amounts must be able to convert between amounts bought (i.e. 1 lb of flour) and amounts used (i.e. 1 cup of flour), a problem we temble in fear before (currently, I'm sure our future selves with handle it just fine).
4. In order not to waste API requests before having a full frontend (we have a fixed allowance for life unless we want pay for it) we have not included calling the Yummly API in the app itself and instead have been using curl to get data to fill our database, but once the we have something we feel is deployable, we will add back in the API calls.

### Group Member Contribution

#### Darren Roscoe

I provided the original idea, it's one I've had on my mind for a while, but haven't had the time or motivation to build it until now. I also wrote most of the original schema, which underwent heavy modification as a group, and I'm writing most of the Elm code because I have more experience with frontend work and I wanted most to learn Elm. In general for the Racket and SQL code we have been partner programming, since we are both familiar with those languages.

#### Trevor Fox

I contributed significantly to the initial redesign of the schema and wrote part of the Racket and SQL code while partner programming, and some of the Elm code as well.

### Procedure and Functions

1. Procedure add_ingredient_to_recipe adds an ingredient with the given name to a recipe's associated list of ingredients, it's used when creating recipes.
2. Procedure add_meal_to_shopping_list adds the ingredients in a meal which are not present in the given user's pantry to the given user's shopping list.
3. Procedure add_recipe_to_meal adds a recipe to a meal, increments the multiplicity if the recipe is already present.
4. Procedure add_to_pantry adds a given food to a given user's pantry.
5. Procedure bought_food_from_shopping_list moves the given food from the given user's shopping list to their pantry.
6. Procedure get_user_pantry gets a list of the foods in a given user's pantry
7. Function register registers a new user and returns their id or throws an error if the username is taken.

### Link to the repo

[View the code here](https://github.com/Roscode/mealthyme)

