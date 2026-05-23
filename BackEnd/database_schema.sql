-- Create Orders Table
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  merchant_id INT NOT NULL,
  merchant_name VARCHAR(255) NOT NULL,
  service_type ENUM('delivery', 'pickUp') NOT NULL,
  subtotal DECIMAL(15, 2) NOT NULL DEFAULT 0,
  delivery_fee DECIMAL(15, 2) NOT NULL DEFAULT 0,
  packaging_fee DECIMAL(15, 2) NOT NULL DEFAULT 0,
  app_fee DECIMAL(15, 2) NOT NULL DEFAULT 0,
  discount DECIMAL(15, 2) NOT NULL DEFAULT 0,
  coins_used DECIMAL(15, 2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(15, 2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  voucher VARCHAR(50) DEFAULT 'None',
  status ENUM('order_confirmed', 'preparing', 'on_delivery', 'ready_to_pickup', 'completed') NOT NULL DEFAULT 'order_confirmed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (merchant_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_merchant_id (merchant_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
);

-- Create Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  menu_id INT NOT NULL,
  menu_name VARCHAR(255) NOT NULL,
  price DECIMAL(15, 2) NOT NULL,
  quantity INT NOT NULL,
  image VARCHAR(255),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE SET NULL,
  INDEX idx_order_id (order_id)
);
