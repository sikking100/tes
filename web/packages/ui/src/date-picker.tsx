import { RangeDatepicker } from 'chakra-dayzed-datepicker'
import React from 'react'

interface DatePickerProps {
  callback(data: Date[]): void
}

const DatePicker: React.FC<DatePickerProps> = ({ callback }) => {
  const [selectedDates, setSelectedDates] = React.useState<Date[]>([new Date(), new Date()])

  const onSetSelectedDates = (dates: Date[]) => {
    callback(dates)
    setSelectedDates(dates)
  }

  return (
    <div>
      <RangeDatepicker
        selectedDates={selectedDates}
        onDateChange={onSetSelectedDates}
        maxDate={new Date()}
      />
    </div>
  )
}

export default DatePicker
