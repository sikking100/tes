import { extendTheme } from '@chakra-ui/react'
import { StepsTheme as Steps } from 'chakra-ui-steps';
// Component style overrides
import Button from './components/button-config'
import IconButton from './components/icon-button'
import ImageConfig from './components/image-config'
import Input from './components/input-config'
import Popover from './components/popover'
import TextArea from './components/textarea-config'
import colors from './foundations/colors'
// Foundational style overrides
import config from './foundations/config'
import fonts from './foundations/fonts'

const breakpoints = {
  sm: '320px',
  md: '768px',
  lg: '960px',
  xl: '1200px',
  '2xl': '1536px',
}

const customTheme = {
  fonts,
  config,
  colors,
  components: {
    Button,
    IconButton,
    Input,
    ImageConfig,
    Steps,
    Popover,
    TextArea,
  },
  breakpoints,
}

export default extendTheme(customTheme)
