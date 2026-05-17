const express = require("express");
const cors = require("cors");
const db = require("./db");
const app = express();
const bcrypt = require("bcrypt");

app.use(cors());
app.use(express.json());

app.post("/api/register", async (req, res) => {
  const { nama, email, phone, password, role } = req.body;

  try {
    const [existingUser] = await db.query(
      "SELECT email FROM users WHERE email = ?",
      [email],
    );
    if (existingUser.length > 0) {
      return res
        .status(400)
        .json({ status: "error", message: "Email Already Registered" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const sql =
      "INSERT INTO users (nama, email, phone, password, role, coins) VALUES (?, ?, ?, ?, ?, 0)";
    await db.query(sql, [nama, email, phone, hashedPassword, role]);

    res.json({ status: "success", message: "Registration Succeed" });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.post("/api/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const [users] = await db.query("SELECT * FROM users WHERE email = ?", [
      email,
    ]);

    if (users.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: "User tidak ditemukan" });
    }

    const user = users[0];

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res
        .status(401)
        .json({ status: "error", message: "Password salah" });
    }

    res.json({
      status: "success",
      message: "Login Berhasil",
      data: {
        id: user.id,
        nama: user.nama,
        email: user.email,
        role: user.role,
        coins: user.coins,
      },
    });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/api/bakeries", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM bakeries");
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/bakeries/:id/menus", async (req, res) => {
  const bakeryId = req.params.id;
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
