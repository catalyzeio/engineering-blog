require 'builder'
Time.zone = 'UTC'

set :css_dir, 'assets/css'
set :js_dir, 'assets/js'
set :images_dir, 'assets/img'

# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# Clean URLs
activate :directory_indexes

# Build
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :directory_indexes
end

# Reload the page on save
configure :development do
  activate :livereload
end

# Markdown settings
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :tables => true, :with_toc_data => true, :no_intra_emphasis => true
activate :syntax, :wrap => true

# XML
set :url_root, 'https://engineering.datica.com'
activate :search_engine_sitemap
page '/sitemap.xml', :layout => false

# Blog settings
activate :blog do |blog|
  blog.permalink = '{title}.html'
  blog.sources = '{year}-{month}-{day}-{title}.html'
  blog.layout = 'layout_blog'
  blog.summary_length = 500
  blog.tag_template = 'tag.html'
  blog.calendar_template = 'calendar.html'
end
