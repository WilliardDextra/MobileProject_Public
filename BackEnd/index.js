const express = require("express");
const cors = require("cors");
const db = require("./db");
const app = express();
const bcrypt = require("bcrypt");

app.use(cors());
app.use(express.json());

app.post("/api/register", async (req, res) => {
  const {
    nama,
    email,
    phone,
    password,
    role,
    store_name,
    owner_name,
    store_address,
  } = req.body;

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

    if (!nama || !email || !password || !role) {
      return res
        .status(400)
        .json({ status: "error", message: "Missing required fields" });
    }

    if (String(role).toLowerCase() === "merchant") {
      if (!store_name || !owner_name || !store_address) {
        return res.status(400).json({
          status: "error",
          message:
            "Merchant registration requires store_name, owner_name, and store_address",
        });
      }
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const sql =
      "INSERT INTO users (nama, email, phone, password, role, coins, store_name, owner_name, store_address) VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?)";
    const [result] = await db.query(sql, [
      nama,
      email,
      phone || null,
      hashedPassword,
      role,
      store_name || null,
      owner_name || null,
      store_address || null,
    ]);

    if (String(role).toLowerCase() === "merchant") {
      const userId = result.insertId;
      const bakerySql =
        "INSERT INTO bakeries (user_id, name, image, closing_time, address) VALUES (?, ?, NULL, NULL, ?)";
      await db.query(bakerySql, [userId, store_name, store_address]);
    }

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
    const [rows] = await db.query(
      "SELECT * FROM menus WHERE bakery_id = ? AND (is_active IS NULL OR is_active = 1)",
      [bakeryId],
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

async function verifyBakeryOwner(bakeryId, userId) {
  const [rows] = await db.query(
    "SELECT id, user_id FROM bakeries WHERE id = ?",
    [bakeryId],
  );
  if (rows.length === 0)
    return { ok: false, code: 404, message: "Bakery not found" };
  if (String(rows[0].user_id) !== String(userId))
    return { ok: false, code: 403, message: "Not the owner of this bakery" };
  return { ok: true };
}

app.get("/api/merchant/:userId/menus", async (req, res) => {
  const userId = req.params.userId;
  try {
    const [rows] = await db.query(
      "SELECT m.* FROM menus m JOIN bakeries b ON m.bakery_id = b.id WHERE b.user_id = ?",
      [userId],
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.post("/api/merchant/menus", async (req, res) => {
  const {
    user_id,
    bakery_id,
    f_name,
    f_image,
    f_description,
    f_price,
    f_stock,
    is_active,
  } = req.body;

  try {
    const ownerCheck = await verifyBakeryOwner(bakery_id, user_id);
    if (!ownerCheck.ok)
      return res.status(ownerCheck.code).json({ message: ownerCheck.message });

    const sql =
      "INSERT INTO menus (bakery_id, f_name, f_image, f_description, f_price, f_stock, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
    const [result] = await db.query(sql, [
      bakery_id,
      f_name,
      f_image || null,
      f_description || null,
      f_price || 0,
      f_stock || 0,
      is_active == null ? 1 : is_active ? 1 : 0,
    ]);

    res.json({ status: "success", menuId: result.insertId });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.put("/api/merchant/menus/:id", async (req, res) => {
  const menuId = req.params.id;
  const {
    user_id,
    f_name,
    f_image,
    f_description,
    f_price,
    f_stock,
    is_active,
  } = req.body;

  try {
    const [menus] = await db.query("SELECT * FROM menus WHERE id = ?", [
      menuId,
    ]);
    if (menus.length === 0)
      return res.status(404).json({ message: "Menu not found" });
    const menu = menus[0];

    const ownerCheck = await verifyBakeryOwner(menu.bakery_id, user_id);
    if (!ownerCheck.ok)
      return res.status(ownerCheck.code).json({ message: ownerCheck.message });

    const updateFields = [];
    const params = [];
    if (f_name != null) {
      updateFields.push("f_name = ?");
      params.push(f_name);
    }
    if (f_image != null) {
      updateFields.push("f_image = ?");
      params.push(f_image);
    }
    if (f_description != null) {
      updateFields.push("f_description = ?");
      params.push(f_description);
    }
    if (f_price != null) {
      updateFields.push("f_price = ?");
      params.push(f_price);
    }
    if (f_stock != null) {
      updateFields.push("f_stock = ?");
      params.push(f_stock);
    }
    if (is_active != null) {
      updateFields.push("is_active = ?");
      params.push(is_active ? 1 : 0);
    }

    if (updateFields.length === 0)
      return res.status(400).json({ message: "No fields to update" });

    params.push(menuId);
    const sql = `UPDATE menus SET ${updateFields.join(", ")} WHERE id = ?`;
    await db.query(sql, params);

    res.json({ status: "success", message: "Menu updated" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.delete("/api/merchant/menus/:id", async (req, res) => {
  const menuId = req.params.id;
  const { user_id } = req.body;
  try {
    const [menus] = await db.query("SELECT * FROM menus WHERE id = ?", [
      menuId,
    ]);
    if (menus.length === 0)
      return res.status(404).json({ message: "Menu not found" });
    const menu = menus[0];

    const ownerCheck = await verifyBakeryOwner(menu.bakery_id, user_id);
    if (!ownerCheck.ok)
      return res.status(ownerCheck.code).json({ message: ownerCheck.message });

    await db.query("DELETE FROM menus WHERE id = ?", [menuId]);
    res.json({ status: "success", message: "Menu deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.patch("/api/merchant/menus/:id/toggle-active", async (req, res) => {
  const menuId = req.params.id;
  const { user_id, is_active } = req.body;
  try {
    const [menus] = await db.query("SELECT * FROM menus WHERE id = ?", [
      menuId,
    ]);
    if (menus.length === 0)
      return res.status(404).json({ message: "Menu not found" });
    const menu = menus[0];

    const ownerCheck = await verifyBakeryOwner(menu.bakery_id, user_id);
    if (!ownerCheck.ok)
      return res.status(ownerCheck.code).json({ message: ownerCheck.message });

    let newState = is_active;
    if (newState == null) newState = menu.is_active ? 0 : 1;

    await db.query("UPDATE menus SET is_active = ? WHERE id = ?", [
      newState ? 1 : 0,
      menuId,
    ]);
    res.json({ status: "success", is_active: newState ? 1 : 0 });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/merchant/:userId/orders", async (req, res) => {
  const userId = req.params.userId;
  try {
    const [bakeries] = await db.query(
      "SELECT id, name FROM bakeries WHERE user_id = ?",
      [userId],
    );
    if (bakeries.length === 0) return res.json([]);

    const bakeryIds = bakeries.map((b) => b.id);
    const bakeryNames = bakeries.map((b) => b.name);

    try {
      const idPlaceholders = bakeryIds.map(() => "?").join(",");
      const [rows] = await db.query(
        `SELECT * FROM payment_history WHERE bakery_id IN (${idPlaceholders}) ORDER BY date DESC`,
        bakeryIds,
      );
      return res.json(rows);
    } catch (err) {
      const namePlaceholders = bakeryNames.map(() => "?").join(",");
      const [rows2] = await db.query(
        `SELECT * FROM payment_history WHERE restaurant_name IN (${namePlaceholders}) ORDER BY date DESC`,
        bakeryNames,
      );
      return res.json(rows2);
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/merchant/:userId/orders/:orderId", async (req, res) => {
  const { userId, orderId } = req.params;
  try {
    const [bakeries] = await db.query(
      "SELECT id, name FROM bakeries WHERE user_id = ?",
      [userId],
    );
    if (bakeries.length === 0)
      return res.status(404).json({ message: "No bakery for this user" });

    const bakeryIds = bakeries.map((b) => b.id);
    const bakeryNames = bakeries.map((b) => b.name);

    try {
      const [rows] = await db.query(
        "SELECT * FROM payment_history WHERE id = ? AND bakery_id IN (?)",
        [orderId, bakeryIds],
      );
      if (rows.length > 0) return res.json(rows[0]);
    } catch (err) {}

    const [rows2] = await db.query(
      "SELECT * FROM payment_history WHERE id = ? AND restaurant_name IN (?)",
      [orderId, bakeryNames],
    );
    if (rows2.length === 0)
      return res
        .status(404)
        .json({ message: "Order not found for this merchant" });
    res.json(rows2[0]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.post("/api/orders", async (req, res) => {
  const {
    user_id,
    merchant_id,
    merchant_name,
    service_type,
    items,
    subtotal,
    delivery_fee,
    packaging_fee,
    app_fee,
    discount,
    coins_used,
    total_amount,
    payment_method,
    voucher,
  } = req.body;

  try {
    if (!user_id || !merchant_id || !items || items.length === 0) {
      return res.status(400).json({
        status: "error",
        message: "Missing required fields",
      });
    }

    const [orderResult] = await db.query(
      "INSERT INTO orders (user_id, merchant_id, merchant_name, service_type, subtotal, delivery_fee, packaging_fee, app_fee, discount, coins_used, total_amount, payment_method, voucher, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'preparing')",
      [
        user_id,
        merchant_id,
        merchant_name,
        service_type,
        subtotal,
        delivery_fee,
        packaging_fee,
        app_fee,
        discount,
        coins_used,
        total_amount,
        payment_method,
        voucher || "None",
      ],
    );

    const orderId = orderResult.insertId;

    for (const item of items) {
      await db.query(
        "INSERT INTO order_items (order_id, menu_id, menu_name, price, quantity, image) VALUES (?, ?, ?, ?, ?, ?)",
        [
          orderId,
          item.menu_id,
          item.menu_name,
          item.price,
          item.quantity,
          item.image || null,
        ],
      );
    }

    res.json({
      status: "success",
      message: "Order created successfully",
      orderId: orderId,
    });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/api/orders/:orderId", async (req, res) => {
  const orderId = req.params.orderId;

  try {
    const [orders] = await db.query("SELECT * FROM orders WHERE id = ?", [
      orderId,
    ]);

    if (orders.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: "Order not found" });
    }

    const order = orders[0];

    const [items] = await db.query(
      "SELECT * FROM order_items WHERE order_id = ?",
      [orderId],
    );

    res.json({
      status: "success",
      data: {
        ...order,
        items: items,
      },
    });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/api/orders/user/:userId", async (req, res) => {
  const userId = req.params.userId;

  try {
    const [orders] = await db.query(
      "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC",
      [userId],
    );

    const ordersWithItems = [];
    for (const order of orders) {
      const [items] = await db.query(
        "SELECT * FROM order_items WHERE order_id = ?",
        [order.id],
      );
      ordersWithItems.push({
        ...order,
        items: items,
      });
    }

    res.json(ordersWithItems);
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/api/orders/merchant/:merchantId", async (req, res) => {
  const merchantId = req.params.merchantId;

  try {
    const [orders] = await db.query(
      "SELECT * FROM orders WHERE merchant_id = ? ORDER BY created_at DESC",
      [merchantId],
    );

    const ordersWithItems = [];
    for (const order of orders) {
      const [items] = await db.query(
        "SELECT * FROM order_items WHERE order_id = ?",
        [order.id],
      );
      ordersWithItems.push({
        ...order,
        items: items,
      });
    }

    res.json(ordersWithItems);
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.put("/api/orders/:orderId/status", async (req, res) => {
  const orderId = req.params.orderId;
  const { status } = req.body;

  try {
    const [orders] = await db.query("SELECT * FROM orders WHERE id = ?", [
      orderId,
    ]);

    if (orders.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: "Order not found" });
    }

    const validStatuses = [
      "order_confirmed",
      "preparing",
      "on_delivery",
      "ready_to_pickup",
      "completed",
    ];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        status: "error",
        message: "Invalid status",
      });
    }

    const completedAt =
      status === "completed" ? new Date() : orders[0].completed_at;

    await db.query(
      "UPDATE orders SET status = ?, completed_at = ? WHERE id = ?",
      [status, completedAt, orderId],
    );

    res.json({
      status: "success",
      message: "Order status updated",
    });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/api/orders/status/:status", async (req, res) => {
  const { status } = req.params;
  const { user_id, merchant_id } = req.query;

  try {
    let query = "SELECT * FROM orders WHERE status = ?";
    let params = [status];

    if (user_id) {
      query += " AND user_id = ?";
      params.push(user_id);
    }
    if (merchant_id) {
      query += " AND merchant_id = ?";
      params.push(merchant_id);
    }

    query += " ORDER BY created_at DESC";

    const [orders] = await db.query(query, params);

    const ordersWithItems = [];
    for (const order of orders) {
      const [items] = await db.query(
        "SELECT * FROM order_items WHERE order_id = ?",
        [order.id],
      );
      ordersWithItems.push({
        ...order,
        items: items,
      });
    }

    res.json(ordersWithItems);
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));
