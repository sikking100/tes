import { getEmployeeApiInfo, Employee, FbAuth } from "apis";
import * as store from "zustand";

interface AuthState {
  admin: Employee | undefined;
  isLoading?: boolean;
  setAdmin: () => void;
}

const useAuthSlice: store.StateCreator<AuthState, [], [], AuthState> = (
  set
) => ({
  admin: undefined,
  isLoading: true,
  setAdmin: () => {
    FbAuth.onIdTokenChanged((user) => {
      user
        ?.getIdTokenResult()
        .then(async (it) => {
          const res = await getEmployeeApiInfo().findById(it.claims.user_id);
          localStorage.setItem("admin-id", res.id);
          set({ admin: res });
        })
        .finally(() => {
          set({ isLoading: false });
        });
    });
  },
});

export const useStore = store.create<AuthState>()((...a) => ({
  ...useAuthSlice(...a),
}));
