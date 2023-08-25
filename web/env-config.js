const fs = require("fs");
const targetPath = "./firebase.json";

if (process.argv.length < 3) {
  console.error("Usage: node app.js <NODE_ENV>");
  process.exit(1);
}

const nodeEnv = process.argv[2];
process.env.NODE_ENV = nodeEnv;

if (fs.existsSync(targetPath)) {
  const srcConfigPath =
    process.env.NODE_ENV === "production"
      ? "./firebase-prod.json"
      : "./firebase-dev.json";

  fs.writeFile(targetPath, "", (err) => {
    if (err) {
      console.error("Error deleting file contents:", err);
      return;
    }
  });

  fs.copyFileSync(srcConfigPath, targetPath);
  console.log("oke");
} else {
  console.error(
    `Could not find "${targetPath}". Make sure you have the correct path.`
  );
}
