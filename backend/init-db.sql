-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS express_test;

-- Use the database
USE express_test;

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  stock INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert some sample data
INSERT INTO products (name, price, stock) VALUES 
('Laptop', 999.99, 10),
('Smartphone', 699.99, 20),
('Headphones', 99.99, 50);
