require 'rake'
require_relative './lib/utils/version'

Gem::Specification.new do |s|
    s.name     = 'jekyll-site-tree'
    s.version  = Jekyll::SiteTree::VERSION
    s.summary  = 'create a site tree from a jekyll page'
    s.licenses = ['GPL-3.0']
    s.authors  = ['mohkale']
    s.email    = 'mohkalsin@gmail.com'
    s.files    = FileList['lib/**/*.rb']

    s.add_dependency "jekyll"
    s.add_dependency "natural_sort", "~> 0.3.0"
    s.add_dependency  "htmlentities", "~> 4.3.3"
    s.add_development_dependency 'bundler'

    s.description = <<EOF
A jekyll generator which creates a site-tree consisting of all the files in the output (built) path of a jekyll website.

For a site with a structure like:
  - /foo.md
  - /bar.html
  - /posts/2019/15/10/hello-world.md
  - /posts/2019/15/10/lo-and-behold.md
  - /assets/styles/main.scss

You'll recieve an XML unordered list like:
  - foo
  - bar
  - posts/2019/15/10
    - hello-world
    - lo-and-behold
  - assets/styles
    - main
EOF
end
