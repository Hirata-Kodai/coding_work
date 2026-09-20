"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const router_1 = __importDefault(require("./router"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const app = (0, express_1.default)();
// JSON ボディのパースを有効化
app.use(express_1.default.json());
// logging middleware
app.use((0, morgan_1.default)("common"));
// security middleware
app.use((0, helmet_1.default)());
// rate-limitting middleware
app.use((0, express_rate_limit_1.default)({
    windowMs: 1 * 60 * 1000,
    max: 10
}));
app.use(router_1.default);
exports.default = app;
