import express from "express";
import router from "./router"
import helmet from "helmet";
import morgan from "morgan";
import rateLimit from "express-rate-limit";

const app = express();
// JSON ボディのパースを有効化
app.use(express.json());
// logging middleware
app.use(morgan("common"));
// security middleware
app.use(helmet());
// rate-limitting middleware
app.use(rateLimit({
    windowMs: 1 * 60 * 1000,
    max: 10
}));
app.use(router);

export default app;
