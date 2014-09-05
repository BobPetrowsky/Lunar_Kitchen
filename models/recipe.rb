class Recipe
  attr_reader :id, :name, :instructions, :description, :ingredients
  def initialize(id, name, instructions = nil, description = nil, ingredients = [])
    @id = id
    @name = name
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end

  def self.all
    query = 'SELECT recipes.id, recipes.name FROM recipes'

    connection = PG.connect(dbname: 'recipes')
    results = connection.exec(query)
    connection.close


    recipes = []
    results.each do |result|
      recipes << Recipe.new(result['id'], result['name'], result['instructions'], result['description'])
    end
    recipes
  end

  def self.find(id)
    query = 'SELECT recipes.id, recipes.name, recipes.instructions, recipes.description, ingredients.name AS ingredients FROM recipes JOIN ingredients ON ingredients.recipe_id = recipes.id WHERE recipes.id = $1'
    ingredients_query = 'SELECT name FROM ingredients WHERE ingredients.recipe_id = $1'

    connection = PG.connect(dbname: 'recipes')
    results = connection.exec(query, [id])
    ingredients_results = connection.exec(ingredients_query, [id])
    connection.close

    ingredients = []

    ingredients_results.each do |ingredient|
      ingredients << Ingredient.new(ingredient['name'])
    end

    results.each do |result|
      @recipe = Recipe.new(result['id'], result['name'], result['instructions'] || "This recipe doesn't have any instructions.", result['description'] || "This recipe doesn't have a description.", ingredients)
    end
    @recipe
  end

end
