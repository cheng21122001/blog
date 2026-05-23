# Papermod Blog — Agent Guide

This is a personal blog built with Hugo (a static site generator) using the PaperMod theme. The owner writes content in Chinese and publishes through Vercel or GitHub Pages. No coding knowledge is needed to manage this blog — the only files the owner ever needs to touch are in the `content/` folder and `config.yml`.

When helping the owner, **always use plain, friendly language**. Avoid jargon. If something technical must be explained, use an analogy. Never make changes outside of `content/` and `config.yml` unless explicitly asked.

---

## What the owner will commonly ask for

### Writing a new blog post

Posts live in `content/posts/`. Each post is a plain text file ending in `.md`. To create a new post, make a new file there (e.g., `content/posts/my-new-post.md`).

Every post must start with a "front matter" block — a small header between two `---` lines that tells the site the post's title, date, and other info:

```
---
title: "Your Post Title Here"
date: 2026-05-22
description: "A short one-line summary shown in the post list"
tags: ["tag1", "tag2"]
draft: false
---

Your content starts here...
```

Key front matter fields:

| Field | What it does | Required? |
|---|---|---|
| `title` | The title shown on the post | Yes |
| `date` | Publication date (YYYY-MM-DD) | Yes |
| `description` | Summary shown in listings and search | Recommended |
| `tags` | Labels for the post, e.g. `["旅行", "美食"]` | Optional |
| `draft: true` | Hides the post from the live site | Optional |
| `cover.image` | Path to a cover image, e.g. `/images/photo.jpg` | Optional |
| `ShowToc: true` | Shows a table of contents | Optional |

---

### Editing an existing post

All posts are in `content/posts/`. Open the relevant `.md` file and edit the text directly. The front matter block at the top controls title, date, tags, etc.

---

### Adding images

1. Put the image file in `assets/images/` (e.g., `assets/images/my-photo.jpg`).
2. Reference it in a post with: `![](/images/my-photo.jpg)`
3. To control size, use HTML: `<img src="/images/my-photo.jpg" width="400px">`

---

### Writing content (Markdown basics)

```
# Big heading
## Medium heading
### Small heading

Normal paragraph text.

**Bold text**   *Italic text*

- Bullet point one
- Bullet point two

[Link text](https://example.com)
```

---

### Embedding videos

For Bilibili:
```html
<div style="width: 100%; aspect-ratio: 16 / 9;">
  <iframe style="width: 100%; height: 100%;"
    src="//player.bilibili.com/player.html?bvid=BVID_HERE&autoplay=0"
    frameborder="0" allowfullscreen="true">
  </iframe>
</div>
```

For Douyin:
```html
<div style="display: flex; justify-content: center; margin: 20px 0;">
  <iframe width="400" height="800" frameborder="0"
    src="https://open.douyin.com/player/video?vid=VIDEO_ID_HERE&autoplay=0"
    referrerpolicy="unsafe-url" allowfullscreen>
  </iframe>
</div>
```

---

### Editing site-wide settings

The main config file is `config.yml`. Things the owner might want to change:

- `title` — the site's name shown in the browser tab
- `params.homeInfoParams.Title` — the headline on the homepage
- `params.homeInfoParams.Content` — the description text on the homepage
- `languages.cn` menu items — the navigation links at the top of the site

---

## Running the site locally (to preview changes)

Requirements: Hugo must be installed (`brew install hugo` on Mac).

```bash
hugo server
```

Then open `http://localhost:1313/papermod/` in a browser. Changes to content files are reflected instantly without restarting.

To also see draft posts:
```bash
hugo server -D
```

---

## Deploying / publishing

Changes are deployed automatically:
- **Vercel**: pushes to the `main` branch trigger a Vercel build and deploy.
- **GitHub Pages**: pushes to the `source` branch trigger the GitHub Actions workflow in `.github/workflows/gh-pages.yml`.

The owner does not need to run any build commands manually — just commit and push the changed files.

---

## Project structure (for reference)

```
content/
  posts/        ← blog posts go here (one .md file per post)
  about.md      ← the About page
  archives.md   ← auto-generated archive (do not edit)
  search.md     ← search page (do not edit)
assets/
  images/       ← images used in posts go here
config.yml      ← site-wide settings
themes/
  hugo-PaperMod/  ← the theme (do not edit anything here)
public/           ← auto-generated build output (do not edit)
```

---

## Rules for this assistant

- Only touch files in `content/` and `config.yml` for content/configuration tasks.
- Never modify anything in `themes/`, `public/`, or `.github/` unless the owner specifically asks.
- Always explain what you changed and why, in plain terms.
- When creating a new post, ask the owner for: title, date, a short description, and the content. Do not invent these.
- If asked to "publish" or "deploy", explain that they need to commit and push the changes (or offer to help with that step).
