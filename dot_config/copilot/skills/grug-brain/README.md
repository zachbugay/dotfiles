# grug-brain

grug brain skill for AI assistants. make AI write simpler code. fight complexity demon.

inspired by [grugbrain.dev](https://grugbrain.dev/). go read, grug learn lot there.

## what this do

when AI use this skill, AI become grug. grug hate complexity. grug like simple.

grug will:

- tell you if code too complex
- suggest simpler way
- explain things in grug speak
- review code and find complexity demon

## how use with different ai

skill file is `SKILL.md`. copy whole folder, not just file.

### github copilot (vs code)

copilot have skill system! grug happy. very easy.

**personal (work in all projects):**

```
~/.copilot/skills/grug-brain/SKILL.md
```

**project only:**

```
.github/skills/grug-brain/SKILL.md
```

then in chat: `/grug-brain` or just ask. copilot load skill automatic.

### claude code (cli)

claude code also have skill system! use same `SKILL.md` format.

**personal:**

```
~/.claude/skills/grug-brain/SKILL.md
```

**project only:**

```
.claude/skills/grug-brain/SKILL.md
```

then in chat: `/grug-brain` or describe task, claude load it.

### opencode

opencode have skill system. grug happy.

**personal:**

```
~/.agents/skills/grug-brain/SKILL.md
```

**project only:**

```
.agents/skills/grug-brain/SKILL.md
```

tell opencode: "use grug-brain skill" or type `/grug-brain`.

### cursor ai

cursor use rules system.

1. create `.cursor/rules/grug-brain.mdc` in project root
2. paste `SKILL.md` content (skip yaml frontmatter, just body)
3. set rule type to "always" or "agent requested"
4. cursor now grug-brain enabled

### claude.ai (web)

**project instructions:**

1. open project settings
2. paste `SKILL.md` content into custom instructions
3. grug always active for that project

**one-off:**

1. paste `SKILL.md` content at start of chat
2. say: "follow these instructions"
3. grug brain activate

### chatgpt / others

if AI let you add system prompt or custom instructions:

1. copy `SKILL.md` body (skip yaml frontmatter)
2. add to custom instructions or system prompt
3. ask AI to "follow grug philosophy"
4. simple!

## example prompts

use these to activate grug brain:

- "review this code with grug-brain skill"
- "think like grug - is this too complex?"
- "grug refactor this code"
- "explain this bug in grug speak"
- "would grug write it this way?"

## when use grug

good times for grug:

- code review
- architecture decision
- refactoring
- debugging
- learning new code

bad times for grug:

- writing poetry (grug bad at poetry)
- writing love letters (grug not romantic)
- writing academic papers (grug not academic)

## what grug believe

- best feature: feature not built
- best abstraction: abstraction not added
- complexity: apex predator
- simple: always better than clever

if grug say "no", listen. grug wise.

## contribute

want make grug better? good.

keep it simple. no complex build steps. no complex dependencies.

just markdown file. simple.

## license

grug not care about legal. do what you want. just fight complexity.

## thanks

big thanks to [grugbrain.dev](https://grugbrain.dev/) - the original grug who teach grug everything.

grug just messenger.

---

remember: given choice between complexity or one on one against t-rex, grug take t-rex. at least grug see t-rex.
