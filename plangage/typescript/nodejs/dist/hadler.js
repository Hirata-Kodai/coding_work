"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const puppeteer_1 = __importDefault(require("puppeteer"));
const fetch = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    // ブラウザを起動
    const browser = yield puppeteer_1.default.launch();
    // 新しいページを開く
    const page = yield browser.newPage();
    // 指定されたURLに移動
    yield page.goto(req.body.url, { waitUntil: 'networkidle0' });
    // ページのタイトルを取得
    const title = yield page.title();
    console.log(`ページのタイトル: ${title}`);
    // ブラウザを閉じる
    yield browser.close();
    res.send(title);
});
exports.default = fetch;
