import { getOrderApiInfo } from 'apis'

export const findTransaction = async (req: { userId: string }) => {
    try {
        const transactionLastMonth = await getOrderApiInfo().findTransactionLastMonth({ customerId: `${req.userId}` })
        const transactionPerMonth = await getOrderApiInfo().findTransactionPerMonth({ customerId: `${req.userId}` })
        return {
            transactionLastMonth,
            transactionPerMonth,
        }
        //   setTransactionLast(transactionLastMonth)
        //   setTransactionPer(transactionPerMonth)
    } catch (error) {
        console.log(error)
    }
}
