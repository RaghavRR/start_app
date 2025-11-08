import express from "express";
import morgan from "morgan";
import cors from "cors";
import dotenv from "dotenv";
import mongoose from "mongoose";

// Import routes
import authRoutes from "./routes/auth.js";
import appointmentRoutes from "./routes/appointments.js";
import reportRoutes from "./routes/reports.js";

// Initialize
dotenv.config();
const app = express();

// --- Middlewares ---
app.use(morgan("dev"));
app.use(cors());
app.use(express.json());

// --- Database Connection ---
const MONGO_URI = process.env.MONGO_URI;

mongoose
  .connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.error("❌ MongoDB Connection Error:", err.message));

// --- Routes ---
app.get("/", (req, res) => {
  res.json({ ok: true, message: "XStar App API Running 🚀" });
});

app.use("/auth", authRoutes);
app.use("/appointments", appointmentRoutes);
app.use("/reports", reportRoutes);

// --- 404 Handler ---
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

// --- Error Handler Middleware ---
app.use((err, req, res, next) => {
  console.error("🔥 Server Error:", err.stack);
  res.status(500).json({ error: "Internal Server Error" });
});

// --- Start Server ---
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));

export default app;
