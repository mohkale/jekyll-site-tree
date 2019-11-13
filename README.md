# Jekyll Site Tree

requires ruby 2.4+

## Summary
Constructs a HTML site tree consisting of all the URIs of your built jekyll site. You can see an example of the affect on my blog ~~INSERT SHAMELESS PLUG~~ [here](https://mohkale.gitlab.io/map). To summarise, if you've got a jekyll site with a source structure like:

- /foo.md
- /bar.html
- /posts/2019/15/10/hello-world.md
- /posts/2019/15/10/lo-and-behold.md
- /assets/styles/main.scss

You'll recieve an unordered list like this:
- foo
- bar
- posts/2019/15/10
  - hello-world
  - lo-and-behold
- assets/styles
  - main

## Installation
You can either:
* `gem install jekyll-site-tree` and then add `jekyll-site-tree` to your plugins in your sites `_config.yml`.
* add `jekyll-site-tree` to your Gemfile under the `:jekyll_plugins` group & then run `bundle install`.

see [here](https://jekyllrb.com/docs/plugins/installation/) for a guide on both approaches.

## How it works?
This plugin constructs a site-tree on every build and adds it to the local data of some page, specified in your `_config.yml` file. To specify the file, add the following section to your `_config.yml` file:

```yaml
site_tree:
  file: map.md
```

where `map.md` is a file findable from the root of your jekyll sites source directory. If the file cannot be found or is unspecified, then the plugin logs a warning but doesn't interrupt the build process.

`jekyll-site-tree` will inject a field named `site_tree` to the data of the page (as if you specified it in the header YAML) & you're expected to use it in the site-tree file. A minimal example of which would be:

```markdown
---
---
{{ page.site_tree }}

```

## Customisation
### A Complete Configuration
```yaml
site_tree:
  file: map.md
  extension: false
  exclude:
    - /\d+\.[^\/]+$
    - \.(js|css|json|xml|png|jpeg|jpg|art|ant|ico)$
  substitute:
    # exclude dates from pretty formatted permalinks
    - expr: ^\/(.+)\/(\d{4})\/(\d{2})\/(\d{2})\/([^\/]+)$
      name: /\1/\5
    - expr: ^/$
      name: /home
    - expr: ^/(.+)/index.html
      name: /\1
```

### File Extensions
By default `jekyll-site-tree` doesn't include the extension of files in the output tree. You can force the inclusion of extensions by setting `site_tree.extension` to `true`.

### Filtering & Renaming
The `exclude` section lets you specify regular expressions of URIs which you don't want included in the tree; only one regexp needs to match for a file to be excluded. In the above case I've hidden any status error files (eg: 404.html, 287.html etc.) & any non HTML files from inclusion..

The `substitute` section let's you rename a URI in the tree (this has no affect on the actual permalink of the file) by specifying a regular expression for the permalink (`expr`) and a substitution string (`name`). In the above example I'm stripping the dates from any posts, renaming the root file to '/home' & replacing any index files with the URIs of their containing directory.

## TODO
* Implement some proper unit testing. I just took this script outside of the local plugins for my git~~hub~~**lab** pages site, so I haven't added any unit/feature testing yet. Hopefully I'll get round to it (sooner, rather than later).
