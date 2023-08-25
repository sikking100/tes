// import { FormControl, FormLabel } from '@chakra-ui/react'
// import { Controller } from 'react-hook-form'
// import { DataTypes } from 'api'
// import { AsyncSelect, OptionBase, GroupBase } from 'chakra-react-select'

// interface SelectTypes {
//   label: any
//   title: any
//   control: any
//   required: any
//   data: DataTypes.SelectsTypes[]
//   placeholder?: string
// }

// export const Selects: React.FC<SelectTypes> = ({
//   control,
//   label,
//   required,
//   title,
//   placeholder,
//   data,
// }) => {
//   return (
//     <FormControl>
//       <FormLabel as={'label'} htmlFor={label} fontSize={'sm'} textTransform={'capitalize'}>
//         {title}
//       </FormLabel>
//       <Controller
//         control={control}
//         name={label}
//         rules={{ required }}
//         render={({ field }) => (
//           <AsyncSelect<any>
//             name={field.name}
//             ref={field.ref}
//             onChange={field.onChange}
//             onBlur={field.onBlur}
//             value={field.value}
//             options={data}
//             placeholder={placeholder}
//             closeMenuOnSelect={true}
//           />
//         )}
//       />
//     </FormControl>
//   )
// }
