#!/usr/bin/env node
import { writeFile } from "node:fs/promises";
const filePath = "/opt/hugoalh/test/foobar.txt";
await writeFile(filePath, "Hello, world!", { encoding: "utf8" });
