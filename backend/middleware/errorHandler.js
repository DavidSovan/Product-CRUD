const errorHandler = (err, req, res, next) => {
  console.error("Error:", err);

  // Default error status and message
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";

  // Log the full error in development
  const errorResponse = {
    success: false,
    error: message,
  };

  // Include stack trace in development
  if (process.env.NODE_ENV === "development") {
    errorResponse.stack = err.stack;

    // If it's a validation error, include the validation errors
    if (err.errors) {
      errorResponse.errors = err.errors;
    }
  }

  res.status(statusCode).json(errorResponse);
};

// Handle 404 errors
const notFound = (req, res, next) => {
  const error = new Error(`Not Found - ${req.originalUrl}`);
  res.status(404);
  next(error);
};

module.exports = { errorHandler, notFound };
