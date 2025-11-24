import express from "express";
import auth from "../middleware/auth.js";
import Report from "../models/Report.js";

const router = express.Router();


router.post("/", auth, async (req, res) => {
  try {
    const { labNumber, title, details, fileUrl } = req.body;
    const report = await Report.create({
      user: req.user.id,
      labNumber,
      title,
      details,
      fileUrl,
    });
    res.json({ ok: true, report });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});


router.get("/", auth, async (req, res) => {
  try {
    const reports = await Report.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json({ ok: true, reports });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});


router.get("/:id", auth, async (req, res) => {
  try {
    const report = await Report.findOne({ _id: req.params.id, user: req.user.id });
    if (!report) return res.status(404).json({ error: "Not found" });
    res.json({ ok: true, report });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

export default router;
