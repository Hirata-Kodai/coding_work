"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const hadler_1 = __importDefault(require("./hadler"));
const router = (0, express_1.Router)();
router.get('/', (req, res) => {
    res.send('Hello');
});
router.post('/v1/fetch', hadler_1.default);
exports.default = router;
