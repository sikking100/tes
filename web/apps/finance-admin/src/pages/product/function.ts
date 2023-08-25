import { getBranchApiInfo, getBrandApiInfo, getCategoryApiInfo, SelectsTypes } from 'apis'

export const searchs = (r: 'brand' | 'category' | 'branch') => {
    const res = async (e: string) => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const dataTransform: SelectsTypes[] = []
            switch (r) {
                case 'brand':
                    getBrandApiInfo()
                        .find()
                        .then((res) => {
                            res.forEach((i) => {
                                dataTransform.push({
                                    label: i.name,
                                    value: JSON.stringify(i),
                                })
                            })
                            resolve(dataTransform)
                        })

                    break
                case 'category':
                    getCategoryApiInfo()
                        .find()
                        .then((res) => {
                            res.forEach((i) => {
                                dataTransform.push({
                                    label: i.name,
                                    value: JSON.stringify(i),
                                })
                            })
                            resolve(dataTransform)
                        })
                    break
                case 'branch':
                    getBranchApiInfo()
                        .find({ page: 1, limit: 20, search: e })
                        .then((res) => {
                            res.items.forEach((i) => {
                                dataTransform.push({
                                    label: i.name,
                                    value: JSON.stringify(i),
                                })
                            })
                            resolve(dataTransform)
                        })
                    break
                default:
                    break
            }
        })
    }

    return res
}
