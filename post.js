#!/usr/bin/env node
import { readFile } from "node:fs/promises";
const filePath = "/opt/hugoalh/test/foobar.txt";
console.log(await readFile(filePath, { encoding: "utf8" }));
