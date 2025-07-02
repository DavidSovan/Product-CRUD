const pool = require("../config/db");
const PDFDocument = require("pdfkit");

// Get all products
exports.getAllProducts = async (req, res) => {
  const search = req.query.search;
  const sort = req.query.sort;

  try {
    let query = "SELECT * FROM products";
    let params = [];

    // Search
    if (search) {
      query += " WHERE product_name LIKE ?";
      params.push(`%${search}%`);
    }

    // Sort options
    const sortOptions = {
      price_asc: "price ASC",
      price_desc: "price DESC",
      stock_asc: "stock ASC",
      stock_desc: "stock DESC",
    };

    // Apply sorting
    if (sort && sortOptions[sort]) {
      query += ` ORDER BY ${sortOptions[sort]}`;
    } else {
      // Default sort order when no sort parameter is provided
      query += " ORDER BY product_id DESC";
    }

    const [rows] = await pool.query(query, params);

    res.status(200).json({
      success: true,
      count: rows.length,
      data: rows,
    });
  } catch (err) {
    console.error("Error fetching products:", err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch products",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};

// Get product by ID
exports.getProductById = async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM products WHERE product_id = ?",
      [req.params.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Product not found",
      });
    }

    res.status(200).json({
      success: true,
      data: rows[0],
    });
  } catch (err) {
    console.error(`Error fetching product ${req.params.id}:`, err);
    res.status(500).json({
      success: false,
      error: "Failed to fetch product",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};

// Create product
exports.createProduct = async (req, res) => {
  try {
    const [result] = await pool.query(
      "INSERT INTO products (product_name, price, stock) VALUES (?, ?, ?)",
      [req.body.product_name, req.body.price, req.body.stock]
    );

    const [newProduct] = await pool.query(
      "SELECT * FROM products WHERE product_id = ?",
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      data: newProduct[0],
    });
  } catch (err) {
    console.error("Error creating product:", err);
    res.status(500).json({
      success: false,
      error: "Failed to create product",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};

// Update product
exports.updateProduct = async (req, res) => {
  try {
    const [result] = await pool.query(
      `UPDATE products 
       SET product_name = ?, price = ?, stock = ? 
       WHERE product_id = ?`,
      [req.body.product_name, req.body.price, req.body.stock, req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: "Product not found",
      });
    }

    const [updatedProduct] = await pool.query(
      "SELECT * FROM products WHERE product_id = ?",
      [req.params.id]
    );

    res.status(200).json({
      success: true,
      data: updatedProduct[0],
    });
  } catch (err) {
    console.error(`Error updating product ${req.params.id}:`, err);
    res.status(500).json({
      success: false,
      error: "Failed to update product",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};

// Delete product
exports.deleteProduct = async (req, res) => {
  try {
    const [result] = await pool.query(
      "DELETE FROM products WHERE product_id = ?",
      [req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: "Product not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Product deleted successfully",
    });
  } catch (err) {
    console.error(`Error deleting product ${req.params.id}:`, err);
    res.status(500).json({
      success: false,
      error: "Failed to delete product",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};

// Export PDF
exports.exportProductAsPDF = async (req, res) => {
  const productId = req.params.id;

  try {
    const [rows] = await pool.query(
      "SELECT * FROM products WHERE product_id = ?",
      [productId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    const product = rows[0];

    const doc = new PDFDocument();

    // Set headers for download
    res.setHeader(
      "Content-Disposition",
      `attachment; filename=product-${productId}.pdf`
    );
    res.setHeader("Content-Type", "application/pdf");

    // Pipe PDF to response
    doc.pipe(res);

    // Write content
    doc.fontSize(20).text(`Product Details`, { underline: true });
    doc.moveDown();
    doc.fontSize(14).text(`ID: ${product.product_id}`);
    doc.text(`Name: ${product.product_name}`);
    doc.text(`Price: $${product.price}`);
    doc.text(`Stock: ${product.stock}`);

    doc.end(); // Finish PDF
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
