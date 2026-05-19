source "https://rubygems.org"

# Jekyll 4
# Do NOT use the "github-pages" gem — it pins Jekyll 3.
# The just-the-docs theme is loaded via remote_theme (jekyll-remote-theme),
# so the just-the-docs gem does NOT need to be listed here.
gem "jekyll", "~> 4.3"

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
