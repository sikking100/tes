import { useEffect, useState } from "react";
import { FbAuth } from "apis";
import { getDownloadURL, getStorage, ref } from "firebase/storage";
import type firebase from "firebase/compat/app";

export const useAuth = () => {
  const [user, setUser] = useState<firebase.User | undefined>(undefined);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | undefined>(undefined);

  useEffect(() => {
    const unsubscribe = FbAuth.onAuthStateChanged(
      (user) => {
        if (user) setUser(user);
        else setUser(undefined);
        setLoading(false);
      },
      (e) => {
        setError(e);
        setLoading(false);
      }
    );
    return () => unsubscribe();
  }, []);

  const logout = async () => {
    try {
      await FbAuth.signOut();
      localStorage.clear();
    } catch (e) {
      const error = e as Error;
      setError(error);
    }
  };

  return { user, loading, error, logout };
};

const storage = getStorage();

export const useDownloadImage = (path: string) => {
  return new Promise<string>((resolve, reject) => {
    getDownloadURL(ref(storage, path))
      .then((v) => {
        resolve(v);
      })
      .catch((error) => {
        switch (error.code) {
          case "storage/object-not-found":
            // File doesn't exist
            reject("File doesn't exist");
            break;
          case "storage/unauthorized":
            // User doesn't have permission to access the object
            reject("User doesn't have permission to access the object");
            break;
          case "storage/canceled":
            // User canceled the upload
            reject("User canceled the upload");
            break;

          case "storage/unknown":
            // Unknown error occurred, inspect the server response
            reject("Unknown error occurred, inspect the server response");
            break;
        }
      });
  });
};
