import mongoose from "mongoose";

const { Schema } = mongoose;

const appointmentSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: "User", required: true },
  title: { type: String, required: true },
  description: { type: String },
  date: { type: Date, required: true },
  status: {
    type: String,
    enum: ["Pending", "Confirmed", "Cancelled", "Completed"],
    default: "Pending",
  },
  createdAt: { type: Date, default: Date.now },
});

const Appointment = mongoose.model("Appointment", appointmentSchema);

export default Appointment;
