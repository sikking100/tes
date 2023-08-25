import React from 'react'
import { LayoutHome } from 'ui'
import { ListItemHomeBranch } from '../../utils/list-items-home'

const HomePages = () => {
    return (
        <div>
            <LayoutHome appName={'Branch'} list={ListItemHomeBranch} />
        </div>
    )
}

export default HomePages
