# IT&C 444 — Advanced System Administration & Hardening

Course website built with [Jekyll](https://jekyllrb.com) and the
[just-the-docs](https://just-the-docs.com) theme, hosted on GitHub Pages.

## Local Development

```bash
bundle install
bundle exec jekyll serve
# Open http://localhost:4000/cyber444/
```

## Deployment

Push to `main` — GitHub Actions (`.github/workflows/jekyll.yml`) builds and deploys automatically.

## Configuration

Update `_config.yml`:
- Set `baseurl` to your repo name (e.g., `/cyber444`)
- Set `url` to `https://[your-username].github.io`
- Update `footer_content` with your GitHub username

## Structure

```
cyber444-site/
├── _config.yml           # Jekyll + just-the-docs configuration
├── Gemfile               # Ruby dependencies
├── index.md              # Home page
├── syllabus.md           # Course syllabus
├── schedule/             # Weekly schedule pages (week-01.md ... week-15.md)
├── homework/             # Homework assignment pages (hw-01.md ... hw-14.md)
├── labs/                 # Lab assignment pages (lab-01.md ... lab-14.md)
├── capstone/             # Capstone project pages
├── resources/            # Tools, downloads, references
├── assets/css/           # Custom SCSS overrides
└── .github/workflows/    # GitHub Actions CI/CD deploy workflow
```
