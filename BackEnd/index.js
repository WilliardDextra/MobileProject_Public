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
        phone: user.phone,
        address: user.address || "",
        role: user.role,
        coins: user.coins,
      },
    });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/api/users/:id", async (req, res) => {
  const userId = req.params.id;

  try {
    const [users] = await db.query(
      "SELECT id, nama, email, phone, role, coins, address FROM users WHERE id = ?",
      [userId],
    );
    if (users.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: "User tidak ditemukan" });
    }
    res.json(users[0]);
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.put("/api/users/:id", async (req, res) => {
  const userId = req.params.id;
  const { nama, address, password } = req.body;

  try {
    const updateFields = [];
    const params = [];

    if (nama) {
      updateFields.push("nama = ?");
      params.push(nama);
    }
    if (address != null) {
      updateFields.push("address = ?");
      params.push(address);
    }
    if (password) {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      updateFields.push("password = ?");
      params.push(hashedPassword);
    }

    if (updateFields.length === 0) {
      return res
        .status(400)
        .json({ status: "error", message: "Tidak ada data yang diubah" });
    }

    params.push(userId);
    const sql = `UPDATE users SET ${updateFields.join(", ")} WHERE id = ?`;
    await db.query(sql, params);

    const [rows] = await db.query(
      "SELECT id, nama, email, phone, role, coins, address FROM users WHERE id = ?",
      [userId],
    );
    res.json({ status: "success", message: "Profile updated", data: rows[0] });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.post("/api/payment-history", async (req, res) => {
  const {
    user_id,
    restaurant_name,
    service_type,
    payment_method,
    item_count,
    voucher,
    coins_used,
    total_amount,
    date,
    coins_reward,
    items,
  } = req.body;

  try {
    await db.query(
      "INSERT INTO payment_history (user_id, restaurant_name, service_type, payment_method, item_count, voucher, coins_used, total_amount, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        user_id,
        restaurant_name,
        service_type,
        payment_method,
        item_count,
        voucher,
        coins_used,
        total_amount,
        date,
      ],
    );

    const coinsUsedValue = Number(coins_used) || 0;
    const coinsRewardValue = Number(coins_reward) || 0;

    if (coinsUsedValue > 0 || coinsRewardValue > 0) {
      await db.query(
        "UPDATE users SET coins = GREATEST(coins - ?, 0) + ? WHERE id = ?",
        [coinsUsedValue, coinsRewardValue, user_id],
      );
    }

    if (items && Array.isArray(items)) {
      for (const item of items) {
        await db.query(
          "UPDATE menus SET f_stock = GREATEST(f_stock - ?, 0) WHERE id = ?",
          [item.quantity, item.menuId],
        );
      }
    }

    const [userRows] = await db.query("SELECT coins FROM users WHERE id = ?", [
      user_id,
    ]);
    const updatedCoins = userRows[0]?.coins ?? 0;

    res.json({
      status: "success",
      message: "Payment history saved",
      coins: updatedCoins,
    });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/api/payment-history/:userId", async (req, res) => {
  const userId = req.params.userId;
  try {
    const [rows] = await db.query(
      "SELECT * FROM payment_history WHERE user_id = ? ORDER BY date DESC",
      [userId],
    );
    res.json(rows);
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
