
Entites:
Food
    Need to represent both the concept and an individual food item/amount
    Maybe foods are the concept and a food item is an amount of food in a pantry
Food items (NOT YET)
    represent an amount of food in a pantry
    need to deal with changing the amount e.g. not using all of the rice
User
    id
    has a pantry (maybe more if you own multiple houses?)
    makes meals out of recipes using food items
    puts food items into pantry
Meals
    Made up of one or more recipes
        balanced recipe: up to the user
        what about leftovers?
            possibly create food item for every recipe called 'leftover-recipe'
        Like a playlist
Recipes
    contain food items and quanities
    probably taste description and other info i.e. breakfast, lunch, or dinner food
    directions and time info
    modifications
    Serving sizes
    cuisine: describes the nature of the food i.e. when and with what
Pantries
    contains food items
    belongs to a user
    a pantry is basically a table, do we create a table for every pantry? yikes
        maybe pantries is just an id and an owner,
            and there is a pantry-food-item relation table matching items to pantries in quanities,
            and maybe there is a view for each pantry which is the filtered join of the pantries and the p-f-i relation
Shopping list
    set of items to buy to make all the meals planned
    probably a lot more to this, it's like the crux of the application

