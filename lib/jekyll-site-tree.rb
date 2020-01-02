require 'jekyll'
require 'natural_sort'

module Jekyll
  class SiteTreeGenerator < Jekyll::Generator
    def generate(site)
      @site = site

      unless site_tree_file
        Jekyll.logger.warn("SiteTree:", "skipped because no 'site-tree' file specified in config")
        return
      end

      page = @site.pages.find { |page| page.dir.slice(1, page.dir.length) + page.name == site_tree_file }

      if page.nil?
        Jekyll.logger.error("SiteTree:", "unable to find 'site-tree' file: " + site_tree_file)
        return
      end

      Jekyll.logger.info("SiteTree:", "building site tree")
      # page.data['site_tree_permalinks'] = permalinks
      page.data['site_tree'] = site_tree
    end

    def permalinks
      pages  = @site.pages
      pages += @site.static_files
      pages += @site.collections.map do |tuple|
        name, collection = tuple
        (collection.write?) ? collection.docs : []
      end.flatten

      pages.map { |pg| pg.url }.select do |page|
        !excludes.any? { |rx| rx.match? page }
      end.uniq.sort(&NaturalSort)
    end

    private

    def config
      @site.config["site_tree"] || Hash.new
    end

    def site_tree_file
      config["file"]
    end

    def include_extension?
      !!config["extension"]
    end

    def excludes
      if @excludes.nil?
        @excludes = (config["exclude"] || []).map do |exclude|
          # if exclude begins with a slash, the expression references
          # an absolute path, otherwise any match is considered valid
          Regexp.new(exclude[0] == '/' ? '^' + exclude : exclude)
        end
      end
      @excludes
    end

    def substitutions
      if @substitutions.nil?
        @substitutions = (config["substitute"] || []).each do |subs|
          subs["expr"] = Regexp.new(subs["expr"])
        end
      end
      @substitutions
    end

    def permalink_tuples
      subs = substitutions

      permalinks.map do |link|
        sub = subs.find { |sub| sub["expr"].match?(link) }
        new = (sub.nil?) ? link : link.gsub(sub["expr"], sub["name"])

        unless include_extension?
          new = File.join(File.dirname(new), File.basename(new, '.*'))
        end

        { :path => new, :link => link }
      end
    end

    # kind of an ugly solution, nests each path in the sites permalinks
    # into a series of hashes (each hash connects to the next hash) which
    # constructs a sort of tree. The path & link for the current entry is
    # found through the :path & :link fields.
    def permalink_tree
      tree = Hash.new

      permalink_tuples.each do |tuple|
        branch = tree
        branch_path = tuple[:path].split('/')

        branch_path.slice(1, branch_path.length-2).each do |path|
          branch = (branch[path] ||= Hash.new)
        end

        branch[branch_path.last] = tuple
      end

      tree
    end

    # converts a permalink_tree into an XML structure
    def site_tree
      def recursive_construct_tree(name, tree)
        result = '<li>'

        current_path = tree.delete(:path)
        current_link = tree.delete(:link)

        if current_path
          result += "<a href=\"%s\">%s</a>" % [
            current_link, name].map { |s| html_coder.encode(s) }
        end

        unless tree.empty?
          if tree.length == 1 && !current_path then
            child_name = tree.keys[0]

            return recursive_construct_tree(
              name + '/' + child_name, tree[child_name])
          else
            result += html_coder.encode(name) if !current_path

            result += '<ul>'
            tree.each do |name, subtree|
              result += recursive_construct_tree(name, subtree)
            end
            result += '</ul>'
          end
        end

        result += '</li>'
      end

      result = '<ul>'
      permalink_tree.each do |name, tree|
        result += recursive_construct_tree(name, tree)
      end
      result += '</ul>'
    end

    def html_coder
      @@html_coder ||= HTMLEntities.new
    end
  end
end
