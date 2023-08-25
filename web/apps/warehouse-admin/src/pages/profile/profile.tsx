import { LayoutProfile } from 'ui'
import { dataListProfile } from '../../navigation'

const ProfilePage = () => {
    return (
        <div>
            <LayoutProfile appName={'Warehouse'} items={dataListProfile} />
        </div>
    )
}

export default ProfilePage
