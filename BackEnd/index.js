const express = require("express");
const cors = require("cors");
const db = require("./db");
const app = express();

app.use(cors());
app.use(express.json());

app.get("/api/bakeries", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM bakeries");
    res.json(rows); // Mengirim data sebagai list JSON
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));
