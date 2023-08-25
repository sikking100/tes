import { LayoutProfile } from 'ui'
import { dataListProfile } from '../../navigation'

const ProfilePage = () => {
    return (
        <div>
            <LayoutProfile appName={'Branch'} items={dataListProfile} />
        </div>
    )
}

export default ProfilePage
