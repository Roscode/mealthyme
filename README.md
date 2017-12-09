# mealthyme

[See the repo](https://github.com/Roscode/mealthyme)

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

You will need to install [node and npm](https://nodejs.org/en/), [elm](https://guide.elm-lang.org/install.html), and [drracket](https://download.racket-lang.org/) (and mysql if you haven't already). You can use `model/dump.sql` to create the schema and tuples.

Also we have had some compatibility issues with Windows, so if you don't own a unix machine go buy one (or install linux).

#### Installing dependencies

Open MySql workbench and create a new schema using `model/dump.sql`

Once Racket (and the bundled raco tool) is installed run:
`raco pkg install spin`
`raco pkg install bcrypt`
`raco pkg install net-jwt`

Open `api/mealthyme.rkt` in drracket and hit run

`cd` into the views folder and run `elm-package install`, `npm install` then `npm start`

Go to `localhost:3000` in your browser and see the magic!

See the future work section for ways we plan to improve this build process

### Technical Specification

Our stack is the following:
* MySql DBMS
* A Racket REST(ish) API using the following libraries:
  + racket base web-server/servlet, http, http/request-structs, and json
  + [dmac/spin](https://github.com/dmac/spin) for our rest API framework to speed up development
  + [net/jwt](https://pkgs.racket-lang.org/package/net-jwt) for jwt encoding/decoding
  + [bcrypt](https://pkgs.racket-lang.org/package/bcrypt) for password hashing
* An Elm Web User interface using the following libraries
  + [NoRedInk/elm-decode-pipeline](http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/3.0.0/Json-Decode-Pipeline)
  + [elm-community/json-extra](http://package.elm-lang.org/packages/circuithub/elm-json-extra/latest/Json-Decode-Extra)
  + [evancz/url-parser](https://github.com/evancz/url-parser)
  + [lukewestby/elm-http-builder](http://package.elm-lang.org/packages/lukewestby/elm-http-builder/latest/HttpBuilder)
  + [lukewestby/elm-string-interpolation](http://package.elm-lang.org/packages/lukewestby/elm-string-interpolate/1.0.1/String-Interpolate)
  + [rtfeldman/elm-validate](http://package.elm-lang.org/packages/rtfeldman/elm-validate/1.1.3)


### ER Diagram
The ER diagram can be found at [model/er_diagram.pdf](https://github.com/Roscode/mealthyme/blob/master/model/er_diagram.pdf)

### Data

We have been manually gathering our data from [The Yummly Recipe API](https://developer.yummly.com/) for now, and will be using it as a live source of data once our Elm frontend is more polished.

### User Flow

Currently the user flow of our frontend is restricted to the following actions.

## Register
The user navigates to the sign up page, enters a username and password and submits the form, an account is created and they are redirected to the homepage along with an token for future authentication.

## Login
the user navigates to the login page, enters the same username and password as when they signed up, and they are redirected to the homepage along with a token for authentication.

## Edit Pantry
From the homepage the user is able to edit the contents of their pantry, this involves either searching for a food and adding one from the list of results by clicking the check mark, or deleting an item from the user's pantry by clicking the corresponding 'X'.

The following actions are available at the database (or api) level but haven't been fully implemented through the frontend yet.

## Create a meal
Through an insert into the meals table and a sequence of add_recipe_to_meal procedure calls you can create meals consisting of recipes

## Plan a Meal
The add_meal_to_shopping_list procedure represents planning a meal by adding all ingredients used in the meal and not present in the user's pantry to the user's shopping list.

### Lessons Learned
Over the course of this project we learned a lot. Mostly through failure, which as everyone knows is the best way to learn! Here are some of the things we learned
1. Elm! Elm is a language Darren has been eyeballing all semester, but didn't have the time or opportunity to try it out until this project. After a few weeks of using it successfully we are very pleased with what we've found. In particular the compiler error messages are some of the best we've seen and super helpful in finding bugs before they run. Also it compiles to javascript so it is easy to build and manage dependencies using the elm-package and npm package distribution systems.
2. Trevor learned git! We used git to manage our source code.
3. We both learned the difficulties of distributed work flows. We had a lot of trouble initially being able to work on the project simultaneously since any work being done that early would heavily depend on everything else so multiple separate changes could quickly break the app. Because of this we did a lot of partner programming, and then soon after getting to a point where distributing work made sense, we began having compatibility issues with windows, namely because of a dependency on gcc deep in one of our racket packages.
4. Currently our frontend is pretty lacking in features as we decided to completely overhaul it after our presentation (it was very hacky before then). We did this because this is something that interests us and we intend to work more on it after the semester ends, so we wanted to start from a more solid base rather than continue to throw features on top of a plate of spaghetti (code) only to later realize we forgot the meatballs (passwords, proper routing, etc.).

### Future Work

This project was very challenging, we set high goals, and frankly there is a lot left to do. This was intentional, and we will be doing more with the project after finals. Among the many improvements we plan to make are the following:
1. Finish the Elm UI. Now that we have a solid base and a better grasp of Elm practices and patterns this will get easier and easier.
2. Add calendar support. We decided early on not to worry about dates yet (i.e. expiring food and planning a meal for a specific day) and instead to simply have meals and the ability to add the required (and not already owned) ingredients to the shopping list, but it will become necessary if we want to be able to offer meal plan optimizations (along the lines of offering strings of meals which encourage ingredient reuse).
3. Add support for amounts. Another challenge we outsourced to our future selves is dealing with amounts of foods. This may sounds simple (and did to us at first) until you realize that in order to be useful the representation of food amounts must be able to convert between amounts bought (i.e. 1 lb of flour) and amounts used (i.e. 1 cup of flour), a problem we tremble in fear before (currently, I'm sure our future selves with handle it just fine).
4. Improve/automate build process. Currently our build process is almost entirely manual. The Elm code is managed by npm but the racket dependencies have to be manually installed, which is a pain, so one of our next steps is to figure out the best dependency management practice for racket.
5. In order not to waste API requests before having a full frontend (we have a fixed allowance for life unless we want pay for it) we have not included calling the Yummly API in the app itself and instead have been using curl to get data to fill our database, but once the we have something we feel is deployable, we will add back in the API calls.

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

