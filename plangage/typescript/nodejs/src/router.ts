import { Router } from "express";

import fetch from "./hadler";

const router = Router();
router.get('/', (req, res) => {
    res.send('Hello');
});
router.post('/v1/fetch', fetch)

export default router;
