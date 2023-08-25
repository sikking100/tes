import { LayoutHome } from 'ui'

import { ListItemHome } from '~/utils/list-items-home'

const HomePages = () => {
  return (
    <div>
      <LayoutHome appName={'Finance'} list={ListItemHome} />
    </div>
  )
}

export default HomePages
