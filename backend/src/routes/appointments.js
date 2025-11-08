import express from "express";
import auth from "../middleware/auth.js";
import Appointment from "../models/Appointment.js";

const router = express.Router();

router.post("/", auth, async (req, res) => {
  try {
    const { title, description, date } = req.body;
    if (!title || !date)
      return res.status(400).json({ error: "title & date required" });

    const appt = await Appointment.create({
      user: req.user.id,
      title,
      description,
      date,
    });

    res.json({ ok: true, appointment: appt });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

router.get("/", auth, async (req, res) => {
  try {
    const appts = await Appointment.find({ user: req.user.id }).sort({ date: -1 });
    res.json({ ok: true, appointments: appts });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});


router.get("/:id", auth, async (req, res) => {
  try {
    const appt = await Appointment.findOne({ _id: req.params.id, user: req.user.id });
    if (!appt) return res.status(404).json({ error: "Not found" });
    res.json({ ok: true, appointment: appt });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

router.put("/:id", auth, async (req, res) => {
  try {
    const data = req.body;
    const appt = await Appointment.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      data,
      { new: true }
    );
    if (!appt) return res.status(404).json({ error: "Not found" });
    res.json({ ok: true, appointment: appt });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});


router.delete("/:id", auth, async (req, res) => {
  try {
    const appt = await Appointment.findOneAndDelete({ _id: req.params.id, user: req.user.id });
    if (!appt) return res.status(404).json({ error: "Not found" });
    res.json({ ok: true, msg: "Deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

export default router;
