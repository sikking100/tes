import React from "react";
import { Box } from "@chakra-ui/layout";
import { useForm } from "react-hook-form";
import { FormControls, LoadingForm, Modals, PText } from "ui";
import { disclousureStore } from "~/store";
import { helpService } from "hooks";
import { Help } from "apis";

const HelpDetailPages: React.FC<{ id: string }> = ({ id }) => {
  const isOpenEdit = disclousureStore((v) => v.isOpenEdit);
  const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit);
  const { data, error, isLoading } = helpService.useGetHelpById(id);
  const {
    register,
    formState: { errors },
    reset,
  } = useForm<Help>();

  React.useEffect(() => {
    if (data) {
      reset(data);
    }
  }, [isLoading]);

  return (
    <Modals
      isOpen={isOpenEdit}
      setOpen={() => setIsOpenEdit(false)}
      size={"3xl"}
      title="Detail Bantuan"
    >
      {error ? (
        <PText label={error} />
      ) : isLoading ? (
        <LoadingForm />
      ) : (
        <form>
          <Box experimental_spaceY={3}>
            <FormControls
              label="topic"
              register={register}
              title={"Topik"}
              errors={errors.topic?.message}
              required={"Topik tidak boleh kosong"}
            />

            <FormControls
              label="question"
              register={register}
              title={"Pertanyaan"}
              errors={errors.question?.message}
              required={"Pertanyaan tidak boleh kosong"}
            />

            <FormControls
              label="answer"
              register={register}
              title={"Jawaban"}
              errors={errors.answer?.message}
              required={"Jawaban tidak boleh kosong"}
            />
          </Box>
        </form>
      )}
    </Modals>
  );
};

export default HelpDetailPages;
