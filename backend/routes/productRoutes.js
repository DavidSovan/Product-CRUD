const express = require("express");
const router = express.Router();
const controller = require("../controllers/productController");
const { validateProduct, validateId } = require("../middleware/validation");

// Get all products (with optional search)
router.get("/", controller.getAllProducts);

// Get single product
router.get("/:id", validateId, controller.getProductById);

// Create new product
router.post("/", validateProduct, controller.createProduct);

// Update product
router.put("/:id", [validateId, ...validateProduct], controller.updateProduct);

// Delete product
router.delete("/:id", validateId, controller.deleteProduct);

// Export product as PDF
router.get("/:id/pdf", validateId, controller.exportProductAsPDF);

module.exports = router;
