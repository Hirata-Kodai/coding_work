import { Request, Response } from "express"
import puppeteer from 'puppeteer';

const fetch = async (req: Request, res: Response) => {
    // ブラウザを起動
    const browser = await puppeteer.launch();

    // 新しいページを開く
    const page = await browser.newPage();

    // 指定されたURLに移動
    await page.goto(req.body.url, { waitUntil: 'networkidle0' });

    // ページのタイトルを取得
    const title = await page.title();

    // ブラウザを閉じる
    await browser.close();

    res.send(title);
}

export default fetch;
