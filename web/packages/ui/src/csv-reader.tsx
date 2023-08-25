import React from 'react'
import { useCSVReader } from 'react-papaparse'
import { IconButton, Tooltip } from '@chakra-ui/react'
import { Icons } from '.'

interface Ipapers {
    data: Array<Array<string>>
    erros: Array<string>
    meta: Array<string>
}

interface CsvParseProps {
    child: React.ReactNode
    cb: (dd: Array<any>) => void
}

export const CsvParse: React.FC<CsvParseProps> = (props) => {
    const [isLoading, setLoading] = React.useState(false)
    const { CSVReader } = useCSVReader()

    return (
        <div>
            <CSVReader
                onUploadAccepted={(results: Ipapers) => {
                    const dd: any[] = []
                    setLoading(true)
                    setTimeout(() => {
                        setLoading(false)
                    }, 1000)
                    return new Promise((r, j) => {
                        results.data.forEach((i, idx) => {
                            if (idx > 0) {
                                const row: any = {}
                                results.data[0].forEach((j, jdx) => {
                                    row[j] = i[jdx]
                                })
                                dd.push(row)
                            }
                        })
                        props.cb(dd)
                    })
                }}
            >
                {({
                    getRootProps,
                    acceptedFile,
                    ProgressBar,
                    getRemoveFileProps,
                }: any) => (
                    <>
                        <div>
                            <Tooltip label="Import Data">
                                <IconButton
                                    bg={'red.200'}
                                    aria-label="Search database"
                                    icon={<Icons.ImportIcons color={'white'} />}
                                    {...getRootProps()}
                                />
                            </Tooltip>
                            <div>{acceptedFile && acceptedFile.name}</div>
                        </div>
                        <ProgressBar />
                    </>
                )}
            </CSVReader>
        </div>
    )
}
