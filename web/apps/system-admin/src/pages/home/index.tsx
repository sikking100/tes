import React from 'react'
import { LayoutHome, Items } from 'ui'

const HomePages = () => {
  return (
    <div>
      <LayoutHome appName={'System'} list={Items.ListItemHomeSystemAdmin} />
    </div>
  )
}

export default HomePages
