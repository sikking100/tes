import { Api, Category, CreateCategory } from './category'
export type { Category, CreateCategory }
export interface ApiCategoryInfo {
    find(): Promise<Category[]>
    findById(id: string): Promise<Category>
    create(r: CreateCategory): Promise<Category>
    delete(id: string): Promise<Category>
}
export function getCategoryApiInfo(): ApiCategoryInfo {
    return Api.getInstance()
}
