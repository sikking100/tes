import { LayoutProfile } from 'ui'
import { dataListProfile } from '~/navigation'

const ProfilePage = () => {
  return (
    <div>
      <LayoutProfile appName={'System'} items={dataListProfile} />
    </div>
  )
}

export default ProfilePage
