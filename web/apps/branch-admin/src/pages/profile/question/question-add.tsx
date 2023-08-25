import React from 'react'
import { LayoutQuestionAdd } from 'ui'
import { disclousureStore } from '~/store'

const QuestionAddPages = () => {
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)

    return (
        <React.Fragment>
            <LayoutQuestionAdd cb={() => setOpenAdd(false)} isOpen={isAdd} />
        </React.Fragment>
    )
}

export default QuestionAddPages
