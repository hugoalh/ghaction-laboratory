#!/usr/bin/env node
import { readFile, writeFile } from "node:fs/promises";
const filePath = "/opt/hugoalh/test/foobar.txt";
console.log(await readFile(filePath, { encoding: "utf8" }));
await writeFile(filePath, "Hello, world! This is a longer sentence.", { encoding: "utf8" });
