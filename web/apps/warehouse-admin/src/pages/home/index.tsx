import React from 'react'
import { LayoutHome } from 'ui'
import { ListItemHomeWarehouseAdmin } from '~/utils/list-items-home'
const HomePages = () => {
    return (
        <div>
            <LayoutHome
                appName={'Warehouse'}
                list={ListItemHomeWarehouseAdmin}
            />
        </div>
    )
}

export default HomePages
