import React from 'react'
import { PagingButton, PText, Root, Tables } from 'ui'
import columnsBusiness from './business-columns'
import { dataListBusiness } from '../../navigation'
import { customersService, setHeight, store } from 'hooks'
import { TypeCustomerApply } from 'apis'
import { BusinessDetailApplyPages } from './business-detail'
import { disclousureStore } from '../../store'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Branch" items={dataListBusiness} backUrl={'/'} activeNum={2}>
        {children}
    </Root>
)

const BusinessPages = () => {
    const height = setHeight({ useSearch: false })
    const admin = store.useStore((i) => i.admin)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const { column, id } = columnsBusiness()
    const { data, page, setPage, error, isLoading } = customersService.useGetCustomerApply({
        type: TypeCustomerApply.WAITING_CREATE,
        userId: `${admin?.id}`,
    })

    return (
        <Wrap>
            {isOpenEdit && id && <BusinessDetailApplyPages id={id.id} />}
            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables pageH={height} columns={column} data={isLoading ? [] : data.items} isLoading={isLoading} />
                    <PagingButton
                        page={page}
                        nextPage={() => setPage(page + 1)}
                        prevPage={() => setPage(page - 1)}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </Wrap>
    )
}

export default BusinessPages
