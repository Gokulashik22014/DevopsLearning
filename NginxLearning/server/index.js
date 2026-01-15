import express from "express";
import os from "os"
const app = express();

app.use(express.json());
app.get("/", (req, res) => res.json({ message: "Hello World" }));
app.get("/whoami",(req,res)=>res.json({name:os.hostname(),time:new Date().toISOString()}))
app.listen(3000, () => console.log("Listening"));
