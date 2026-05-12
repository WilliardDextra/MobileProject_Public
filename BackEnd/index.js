const express = require("express");
const cors = require("cors");
const db = require("./db");
const app = express();

app.use(cors());
app.use(express.json());

app.get("/api/bakeries", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM bakeries");
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/bakeries/:id/menus", async (req, res) => {
  const bakeryId = req.params.id; // Mengambil ID dari URL
  try {
    const [rows] = await db.query("SELECT * FROM menus WHERE bakery_id = ?", [
      bakeryId,
    ]);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));
