# Product CRUD Application

This is a full-stack application that allows users to manage products. It consists of a Flutter frontend and a Node.js backend.

## Features

- Create, Read, Update, and Delete (CRUD) products.
- Search for products.
- Export product details as a PDF.
- Sort pirce & stock

## Tech Stack

**Frontend:**

- Flutter
- Dart
- Provider (for state management)
- Dio (for HTTP requests)
- GoRouter (for navigation)

**Backend:**

- Node.js
- Express.js
- MySQL2
- PDFKit (for PDF generation)

## Prerequisites

Before you begin, ensure you have the following installed:

- Node.js
- Flutter SDK
- A running MySQL instance

## Getting Started

### Backend Setup

1.  **Navigate to the backend directory:**

    ```bash
    cd backend
    ```

2.  **Install dependencies:**

    ```bash
    npm install
    ```

3.  **Set up environment variables:**

    Create a `.env` file in the `backend` directory and add the following, replacing the placeholder values with your MySQL database credentials:

    ```
    PORT=3000
    DB_HOST=localhost
    DB_USER=your_db_user
    DB_PASSWORD=your_db_password
    DB_NAME=your_db_name
    ```

4.  **Initialize the database:**

    Connect to your MySQL instance and run the SQL script located at `backend/init-db.sql` to create the necessary tables.

5.  **Run the server:**

    ```bash
    npm run dev
    ```

The backend server will be running at `http://localhost:3000`.

### Frontend Setup

1.  **Navigate to the frontend directory:**

    ```bash
    cd frontend
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Set up environment variables:**

    Create a `.env` file in the `frontend` directory and add the following:

    ```
    API_BASE_URL=http://localhost:3000/api
    ```

4.  **Run the application:**

    ```bash
    flutter run
    ```

## API Endpoints

The backend exposes the following RESTful API endpoints:

- `GET /api/products`: Get all products (with optional search).
- `GET /api/products/:id`: Get a single product by its ID.
- `POST /api/products`: Create a new product.
- `PUT /api/products/:id`: Update an existing product.
- `DELETE /api/products/:id`: Delete a product.
- `GET /api/products/:id/pdf`: Export a product's details as a PDF.

## 📸 Screenshots

<p float="left">
<img src="https://github.com/user-attachments/assets/0daf14a2-268f-46e7-88e3-29e21d1e210d" alt="Screenshot 1" width="20%" />
<img src="https://github.com/user-attachments/assets/fc5732de-c36a-4427-81c0-fa602adf3356" alt="Screenshot 2" width="20%" />
<img src="https://github.com/user-attachments/assets/ab8baf05-abc2-4573-85f9-e4a04f1fad0e" alt="Screenshot 3" width="20%" />
<img src="https://github.com/user-attachments/assets/9f90aa08-14d5-4e61-a436-db3b4d96c0bf" alt="App Screenshot" width="20%">
</p>
