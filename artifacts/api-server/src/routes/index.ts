import { Router, type IRouter } from "express";
import healthRouter from "./health";
import nmapRouter from "./nmap";
import niktoRouter from "./nikto";
import sqlmapRouter from "./sqlmap";
import aircrackRouter from "./aircrack";
import dnsRouter from "./dns";
import hashcatRouter from "./hashcat";
import captureRouter from "./capture";
import systemRouter from "./system";
import metasploitRouter from "./metasploit";
import { requireApiKey } from "../middleware/auth";

const router: IRouter = Router();

router.use(healthRouter);
router.use(requireApiKey);
router.use(nmapRouter);
router.use(niktoRouter);
router.use(sqlmapRouter);
router.use(aircrackRouter);
router.use(dnsRouter);
router.use(hashcatRouter);
router.use(captureRouter);
router.use(systemRouter);
router.use(metasploitRouter);

export default router;
