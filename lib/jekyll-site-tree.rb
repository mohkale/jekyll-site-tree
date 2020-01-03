require 'jekyll'
require 'natural_sort'

module Jekyll
  class SiteTreeGenerator < Jekyll::Generator
    priority(:lowest)

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

    #
    # get the url of every page in the current site.
    def permalinks
      pages  = @site.pages
      pages += @site.static_files
      pages += @site.collections.map do |tuple|
        name, collection = tuple
        collection.docs if collection.write?
      end.flatten

      pages.map(&:url).select do |page|
        !excludes.any? { |rx| rx.match? page }
      end.uniq.sort(&NaturalSort)
    end

    def include_extension?
      !!config["extension"]
    end

    def collapse_paths?
      !!config['collapse']
    end

    private

    def config
      @site.config["site_tree"] || Hash.new
    end

    def site_tree_file
      @site_tree_file ||= config["file"]
    end

    def excludes
      @excludes ||= Array(config["exclude"]).map do |exclude|
        # if exclude begins with a slash, the expression references
        # an absolute path, otherwise any match is considered valid
        Regexp.new(exclude[0] == '/' ? '^' + exclude : exclude)
      end
    end

    def substitutions
      @substitutions ||= Array(config["substitute"]).each do |subs|
        subs["expr"] = Regexp.new(subs["expr"])
      end
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
            html_coder.encode(current_link), html_coder.encode(name)]
        end

        unless tree.empty?
          if collapse_paths? && (tree.length == 1 && !current_path) then
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
