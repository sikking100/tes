require('dotenv').config();

const id = process.env.ID;
const roles = parseInt(process.env.ROLES) || 0;
const phone = process.env.PHONE || "";
const locationId = process.env.LOCATION_ID || "";
const team = parseInt(process.env.TEAM) || 0;

const user = {id,roles,phone,locationId,team};
console.log(user);
console.log(Buffer.from(JSON.stringify(user)).toString("base64"));