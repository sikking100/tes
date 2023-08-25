import { LayoutProfile } from 'ui'
import { dataListProfile } from '~/navigation'

const ProfilePage = () => {
    return (
        <div>
            <LayoutProfile appName={'Sales'} items={dataListProfile} />
        </div>
    )
}

export default ProfilePage
