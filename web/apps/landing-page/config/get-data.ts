import path from 'path'
import fs from 'fs'

/**
 * Handle Parse Data
 * @param req {parseDataProps}
 */

export const parseData = async (filename: string, location?: string) => {
  const locateFile =
    location === 'en' ? 'locales/en' : location === 'id' ? 'locales/id' : 'locales/id'
  try {
    const filePath = path.join(process.cwd(), locateFile, filename)
    const set = fs.readFileSync(filePath)
    return JSON.parse(String(set))
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    const err = new Error(error.response.data)
    console.log(err)
  }
}
