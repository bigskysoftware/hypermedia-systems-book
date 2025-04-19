import { bundle } from "jsr:@deno/emit";

const { code } = await bundle("lib/muteferrika.ts")
Deno.stdout.write(new TextEncoder().encode(code))
