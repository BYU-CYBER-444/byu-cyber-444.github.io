source "https://rubygems.org"

# Jekyll 4 — required by just-the-docs v0.8+
# Do NOT use the "github-pages" gem here: it pins Jekyll 3 and breaks
# just-the-docs. Instead, GitHub Actions (jekyll.yml) runs bundle exec jekyll
# build directly, which uses these versions.
gem "jekyll", "~> 4.3"

# just-the-docs theme
gem "just-the-docs", "~> 0.8.2"

group :jekyll_plugins do
  gem "jekyll-remote-theme", "~> 0.4"
  gem "jekyll-seo-tag",      "~> 2.8"
  gem "jekyll-sitemap",      "~> 1.4"
  gem "jekyll-include-cache","~> 0.2"
end

# Windows / JRuby compatibility
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
gem "wdm", "~> 0.1.1", platforms: [:mingw, :x64_mingw, :mswin]
