
import express from "express";
import morgan from "morgan";
import cors from "cors";

import authRoutes from "./routes/auth.js";
import appointmentRoutes from "./routes/appointments.js";
import reportRoutes from "./routes/reports.js";

const app = express();

app.use(morgan("dev"));
app.use(cors());
app.use(express.json());

// Routes
app.use("/auth", authRoutes);
app.use("/appointments", appointmentRoutes);
app.use("/reports", reportRoutes);

app.get("/", (req, res) => res.json({ ok: true, msg: "XStar App API" }));

export default app;