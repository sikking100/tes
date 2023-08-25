import { SelectsTypes } from "apis"

export const RegExPhoneNumber = /^[0-9 ()+]{7,16}$/
export const RegExSpescialChar = /^[a-zA-Z0-9_.-]*$/
export const RegExNumber = /^\d+$/
export const RegExEmail = /\S+@\S+\.\S+/

export const OptionsTeam: SelectsTypes[] = [
  {
    value: 'FOOD SERVICE',
    label: 'Food Service',
  },
  {
    value: 'RETAIL',
    label: 'Retail',
  },
]
