import { ReqPaging, ResPaging } from '../'
import { Api, CreateQty, ProductBranch, PriceProducts } from './product'
import * as ProductTypes from './types'
export { ProductTypes }
export {
    CreateQty as CreateQtyClass,
    ProductBranch as ProductBranchClass,
    PriceProducts,
}

export interface ApiProductInfo {
    find(r: ProductTypes.ReqProductFind): Promise<ProductTypes.Product[]>
    findById(id: string): Promise<ProductTypes.Product>
    create(body: ProductTypes.CreateProduct): Promise<ProductTypes.Product>
    delete(id: string): Promise<ProductTypes.Product>

    // SECTION PRODUCT IN BRANCH
    findProductBranch(
        r: ProductTypes.ReqProductFind
    ): Promise<ResPaging<ProductTypes.Product>>
    findProductBranchById(branchId: string): Promise<ProductTypes.Product>
    createProductPrice(
        r: ProductTypes.ProductPrice
    ): Promise<ProductTypes.Product>
    createProductInBranch(
        r: ProductTypes.CrateProductBranch
    ): Promise<ProductTypes.Product>
    addQtyProduct(r: ProductTypes.CreateQty): Promise<void>
    transferQty(r: ProductTypes.CreateTransferQty): Promise<void>
    updateVisibleProcutInBrancb(
        productId: string
    ): Promise<ProductTypes.Product>

    // SERCTION PRODUCT HISTORY
    findProductHistory(
        r: Omit<ProductTypes.ReqFindProductInBranch, 'qType' | 'qvalue'>
    ): Promise<ResPaging<ProductTypes.HistoryQty>>
    findHistoryById(id: string): Promise<ProductTypes.HistoryQty>

    findSalesProductInBranch(
        branchId: string
    ): Promise<ProductTypes.SalesProduct[]>

    updateSalesProduct(
        r: ProductTypes.UpdateSalesProduct
    ): Promise<ProductTypes.UpdateSalesProduct>

    // SECTION PRODUCT IMPORT
    findImportPrice(branchId: string): Promise<ProductTypes.Product[]>
    findImportQty(branchId: string): Promise<ProductTypes.Product[]>
}

export function getProdcutApiInfo(): ApiProductInfo {
    return Api.getInstance()
}
