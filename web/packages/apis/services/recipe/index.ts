import { ResPaging } from '..'
import { Api, CreateRecipe, Recipe, ReqPagingRecipe } from './recipe'
export type { CreateRecipe, Recipe }
export interface ApiRecipeInfo {
    find(r: ReqPagingRecipe): Promise<ResPaging<Recipe>>
    findById(id: string): Promise<Recipe>
    create(r: CreateRecipe): Promise<Recipe>
    update(r: Recipe): Promise<Recipe>
    delete(id: string): Promise<Recipe>
}
export function getRecipeApiInfo(): ApiRecipeInfo {
    return Api.getInstance()
}
