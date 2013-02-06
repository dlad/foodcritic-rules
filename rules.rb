rule "TC001", "Version number should be updated if a cookbook is changed" do
  tags %w{style metadata thecloud}

# I try to detect if the version line has changed
# I am not that clever and can be fooled by any changed on the version line

# TODO: rewrite using native ruby
# TODO: be more clever about the version number and see if it was actually bumped

  cookbook do |c|
    detect_changed_cookbook = "git diff --quiet --exit-code HEAD^ HEAD #{c}"
    %x{ #{detect_changed_cookbook} }
    if $?.exitstatus == 1
      m = File.join(c, 'metadata.rb')
      if File.exists?(m)
        # find line number to error on - does not quite work yet
        # v = read_ast(m).xpath('//command[ident/@value="version"]')
        # use with: [match(v)]

        detect_changed_metadata = "git diff --quiet --exit-code HEAD^ HEAD #{m}"
        %x{ #{detect_changed_metadata} }
        if $?.exitstatus == 0
          # cookbook changed, metadata not changed
          [file_match(m)]
        else
          detect_changed_version = "git diff --exit-code --unified=0 -w HEAD^ HEAD #{m}|grep -v '@@ version'|grep version"
          %x{ #{detect_changed_version} }
          if $?.exitstatus == 1
            # cookbook and metadata changed but version not changed
            [file_match(m)]
          end
        end
      end
    end
  end
end


rule "TC002", "Debugging statements should be removed" do
  tags %w{style thecloud}

# Using puts/print/pp is ugly, use the `Log` resource instead

  recipe do |ast|
    ast.xpath('//command[ident/@value="puts"]|//command[ident/@value="pp"]|//command[ident/@value="print"]')
  end
end


# taken from http://rubygems.org/gems/ptools/versions/1.1.7
def binary?(file)
  s = (File.read(file, File.stat(file).blksize) || "").split(//)
  ((s.size - s.grep(" ".."~").size) / s.size.to_f) > 0.30
end


rule "TC003", "Chef managed files should state as such" do
  tags %w{style thecloud}

# So that people looking at a deployed file know that its chef managed, the
# file should say it is at the top

# NOTE: binary files are not checked
# TODO: rewrite using native ruby

  cookbook do |c|
    matches = []
    Dir.glob("#{c}/{files,templates}/**/*").each do |file|
      if File.directory?(file) or 
	binary?(file)
	  next
      end
      check_header = "head -n 5 #{file}|grep -q -i 'this file is chef managed'"
      %x{ #{check_header} }
      if $?.exitstatus > 0
         matches << file_match(file)
      end
    end
    matches
  end
end

