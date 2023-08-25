import { RadioGroup, Stack, Radio, Text, Box } from '@chakra-ui/react'
import React from 'react'

const RadioButtonTypes: React.FC<{
  setType: React.Dispatch<React.SetStateAction<string>>
  defaultType?: string
}> = ({ setType, defaultType = '1' }) => {
  return (
    <div>
      <Box>
        <Text fontSize={'sm'} fontWeight={500} pb={1}>
          Pilih Tipe Aktifitas
        </Text>
        <RadioGroup defaultValue={defaultType} onChange={(e) => setType(e)}>
          <Stack spacing={5} direction='row'>
            <Radio colorScheme='red' value='1'>
              Gambar
            </Radio>
            <Radio colorScheme='red' value='2'>
              Video
            </Radio>
          </Stack>
        </RadioGroup>
      </Box>
    </div>
  )
}

export default RadioButtonTypes
