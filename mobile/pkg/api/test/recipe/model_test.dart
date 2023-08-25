import 'dart:convert';

import 'package:api/recipe/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../json_reader.dart';

final tRecipe = Recipe(
  id: 'string',
  title: 'string',
  imageUrl: 'string',
  category: 'string',
  description: 'string',
  createdAt: DateTime.parse('2022-11-27T01:43:19.030Z').toLocal(),
  updatedAt: DateTime.parse('2022-11-27T01:43:19.030Z').toLocal(),
);

// final tpRecipe = Paging<Recipe>(null, null, [tRecipe]);

final jRecipe = readJson('recipe/recipe.json');
final jRecipeList = readJson('recipe/recipe_list.json');

void main() {
  test('Recipe model fromMap', () {
    final result = Recipe.fromMap(jsonDecode(jRecipe)['data']);
    expect(result, equals(tRecipe));
  });
}
