import { SelectsTypes, getEmployeeApiInfo, getBranchApiInfo, getRegionApiInfo, getCategoryApiInfo } from 'apis'
import { ROLES_ADMIN } from '../../utils/roles'

type TSearch = 'employee' | 'branch' | 'region' | 'category'

export const Searchs = (type: TSearch) => {
    const s = (e: string): Promise<SelectsTypes[]> => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const transform: SelectsTypes[] = []
            let res
            ;(async () => {
                switch (type) {
                    case 'employee':
                        res = await getEmployeeApiInfo().find({
                            limit: 10,
                            page: 1,
                            search: e,
                        })
                        res.items.forEach((v) => {
                            transform.push({
                                value: JSON.stringify(v),
                                label: v.name,
                            })
                        })
                        break
                    case 'branch':
                        res = await getBranchApiInfo().find({
                            limit: 10,
                            page: 1,
                            search: e,
                        })
                        res.items.forEach((v) => {
                            transform.push({
                                value: JSON.stringify(v),
                                label: v.name,
                            })
                        })
                        break
                    case 'region':
                        res = await getRegionApiInfo().find({
                            limit: 10,
                            page: 1,
                            search: e,
                        })
                        res.items.forEach((v) => {
                            transform.push({
                                value: JSON.stringify(v),
                                label: v.name,
                            })
                        })
                        break
                    case 'category':
                        res = await getCategoryApiInfo().find()
                        res.filter((v) => v.name.includes(e))
                        res.forEach((v) => {
                            transform.push({
                                value: JSON.stringify(v),
                                label: v.name,
                            })
                        })
                        break
                    default:
                        break
                }
            })()

            resolve([...transform])
        })
    }

    return s
}

export const setRole = (req: { team: string; setRoles: (v: SelectsTypes[]) => void }) => {
    req.setRoles(ROLES_ADMIN)
}
