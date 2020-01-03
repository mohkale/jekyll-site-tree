# Jekyll Site Tree

requires ruby 2.4+

## Summary
Constructs a HTML site tree consisting of all the URIs of your built jekyll site. You can see an
example of the affect on my blog ~~INSERT SHAMELESS PLUG~~ [here](https://mohkale.gitlab.io/map).
To summarise, if you've got a jekyll site with a source structure like:

- /foo.md
- /bar.html
- /posts/2019/15/10/hello-world.md
- /posts/2019/15/10/lo-and-behold.md
- /assets/styles/main.scss

You'll recieve an unordered list like this:

```yaml
- foo
- bar
- posts
  - 2019
    - 15
      - 10
        - hello-world
        - lo-and-behold
- assets
  - styles
    - main
```

## Installation
You can either:
* `gem install jekyll-site-tree` and then add `jekyll-site-tree` to your plugins in your sites `_config.yml`.
* add `jekyll-site-tree` to your Gemfile under the `:jekyll_plugins` group & then run `bundle install`.

see [here](https://jekyllrb.com/docs/plugins/installation/) for a guide on both approaches.

## How it works?
This plugin constructs a site-tree on every build and adds it to the local data of some pages,
specified in your `_config.yml` file. If you don't specify any pages, the `site-tree` will be
added to the scope of every page on the site.

To specify the file, add the following section to your `_config.yml` file:

```yaml
site_tree.file: map.md
```

where `map.md` is a file findable from the root of your jekyll sites source directory.
If the file cannot be found or is unspecified, then the plugin logs a warning but doesn't
interrupt the build process.

A minimal example of `map.md` would be:

```markdown
---
---
{{ page.site_tree }}

```

## Customisation
### Configuration Options
The default configuration for `jekyll-site-tree` looks like this:

```yaml
site_tree:
  file: null
  files: []
  extension: false
  collapse: false
  exclude: []
  substitute: []
```

NOTE: `file` and `files` are essentially the same option. both exist purely for semantic
      purposes and you can use either as a replacement or alognside the other.

### File Extensions
By default `jekyll-site-tree` doesn't include the extension of files in the output tree.
You can force the inclusion of extensions by setting `site_tree.extension = true`.

### Collapsing Singular Paths
Quite often you may recieve a site tree like:

```yaml
- posts
  - 2019
    - 15
      - 10
        - hello-world
        - lo-and-behold
```

that's a lot of exorbitant empty directories a user is quite unlikely to need to
access. In this case you can set `site_tree.collapse = true` and `site-tree` will
automatically collapse these directories in a smart way.

```yaml
- posts/2019/15/10
  - hello-world
  - lo-and-behold
```

if you have a page at `/posts` then the hyperlink for the entire `posts/2019/15/10` page
will link to that page. if you have a page for `posts` & `posts/2019/` `site-tree` will
expand the paths to ensure a link for both pages is included in the tree, like so:

```yaml
- posts
  - 2019/15/10
    - hello-world
    - lo-and-behold
```

### Filtering & Renaming
The `exclude` section lets you specify regular expressions of URIs which you don't want
included in the tree; only one regexp needs to match for a file to be excluded. For example:

```yaml
site_tree.exclude:
  - /\d+\.[^\/]+$
  - \.(js|css|json|xml|png|jpeg|jpg|art|ant|ico)$
```

will hide any status error pages (eg: 404.html 287.html etc.) & any js, css, json... files
from the site tree.

NOTE: an exclusion regular expression beginning with a forward-slash will be substituted with a `^`
      and matches a complete path. Any other type of expression matches globally.

The `substitute` section let's you rename a URI in the tree by specifying a regular expression for the
permalink (`expr`) and a substitution string (`name`). Capture groups are replaced in the substitution
string in the same way as vim. I.E. `\0` substitutes the full matched pattern. `\1` substitutes the
first capture group. NOTE This substitution has no affect on the actual permalink of the file.

For example:

```yaml
site_tree.substitute:
  - expr: ^\/(.+)\/(\d{4})\/(\d{2})\/(\d{2})\/([^\/]+)$
    name: /\1/\5
  - expr: ^/(.+)/index.html
    name: /\1
```

the first pattern will omit any dates from posts files & the second wil replace any directory index files
with the names of their parent directories (`/posts/index.html` becomes `/posts`).

## TODO
* Implement some proper unit testing. I just took this script outside of the local plugins for my git~~hub~~**lab**
pages site, so I haven't added any unit/feature testing yet. Hopefully I'll get round to it
(sooner, rather than later).
