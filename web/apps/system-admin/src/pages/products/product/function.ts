import { SelectsTypes, getBrandApiInfo, getCategoryApiInfo, getBranchApiInfo } from 'apis'
import { entity } from 'ui'

type TSearch = 'brand' | 'category' | 'branch'

export const useSearch = (r: TSearch) => {
    const s = (e: string): Promise<SelectsTypes[]> => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const data: SelectsTypes[] = []
            let res
            ;(async () => {
                switch (r) {
                    case 'brand':
                        res = await getBrandApiInfo().find()
                        res.filter((v) => v.name.toLowerCase().includes(e.toLowerCase()))
                        res.forEach((v) => {
                            data.push({
                                value: JSON.stringify(v),
                                label: v.name,
                            })
                        })
                        resolve(data)
                        break
                    case 'category':
                        res = await getCategoryApiInfo().find()
                        res.filter((v) => v.name.toLowerCase().includes(e.toLowerCase()))
                        res.forEach((v) => {
                            data.push({
                                value: JSON.stringify(v),
                                label: `${v.name} - ${entity.team(String(v.team))}`,
                            })
                        })
                        resolve(data)
                        break
                    case 'branch':
                        res = await getBranchApiInfo().find({ limit: 10, page: 1 })
                        res.items.forEach((v) => {
                            data.push({
                                value: JSON.stringify(v),
                                label: v.name,
                            })
                        })
                        resolve(data)
                        break
                    default:
                        break
                }
            })()
        })
    }
    return s
}
