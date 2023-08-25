import * as z from 'zod'
import { CreateRegion } from 'apis'

export const regionSchema: z.ZodSchema<CreateRegion> = z.object({
  id: z.string({ required_error: 'Id region tidak boleh kosong' }),
  name: z.string({ required_error: 'Nama region tidak boleh kosong' }),
})
