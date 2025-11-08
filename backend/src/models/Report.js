import mongoose from "mongoose";

const { Schema } = mongoose;

const reportSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: "User", required: true },
  labNumber: { type: String },
  title: { type: String },
  details: { type: String },
  fileUrl: { type: String },
  createdAt: { type: Date, default: Date.now },
});

const Report = mongoose.model("Report", reportSchema);

export default Report;
