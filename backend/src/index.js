import mongoose from "mongoose";
import dotenv from "dotenv";
import app from "./app.js";

// dotenv.config();

import path from "path";
import { fileURLToPath } from "url";

// Fix path issue for ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env file from parent folder
dotenv.config({ path: path.join(__dirname, "../.env") });

console.log("Loaded MONGO_URI:", process.env.MONGO_URI);  // debugging


const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
  })
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err);
    process.exit(1);
  });