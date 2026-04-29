const mysql = require("mysql2");

const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "",
  database: "database_flutterproject", // Pastikan namanya sama dengan yang di phpMyAdmin
});

module.exports = pool.promise();
