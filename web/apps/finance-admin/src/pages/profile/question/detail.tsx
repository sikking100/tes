import { Avatar, Box, HStack, Text } from "@chakra-ui/react";
import { Help } from "apis";
import React from "react";
import { useForm } from "react-hook-form";
import { FormControlsTextArea, Modals, entity } from "ui";
import { disclousureStore } from "~/store";

const LayoutQuestionDetailQuestion: React.FC<{
  data: Help;
}> = ({ data }) => {
  const { register, reset } = useForm<Help>();
  const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit);
  const isOpenEdit = disclousureStore((v) => v.isOpenEdit);

  React.useEffect(() => {
    if (data) {
      reset(data);
    }
  }, [data]);

  const onClose = () => setIsOpenEdit(false);

  return (
    <Modals
      isOpen={isOpenEdit}
      setOpen={onClose}
      title="Detail Pertanyaan"
      size="3xl"
    >
      <HStack mb={2}>
        <Avatar
          size={"xl"}
          src={data.creator.imageUrl}
          name={data.creator.name}
        />
        <Box experimental_spaceY={1}>
          <Text>{data.creator.name}</Text>
          <Text fontSize={"sm"} fontWeight={"bold"}>
            {entity.roles(data.creator.roles)}
          </Text>
        </Box>
      </HStack>
      <Box experimental_spaceY={3} pb={4}>
        <FormControlsTextArea
          readOnly
          label="question"
          title={"Pertanyaan"}
          register={register}
          placeholder={""}
        />

        <FormControlsTextArea
          readOnly
          label="answer"
          title={"Jawaban"}
          register={register}
          placeholder={"..."}
        />
      </Box>
    </Modals>
  );
};
export default LayoutQuestionDetailQuestion;
