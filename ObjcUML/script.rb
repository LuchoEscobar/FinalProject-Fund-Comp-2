#!/usr/bin/ruby

require 'optparse'

options = {}

#Defaults
options[:exclusion_prefixes] = "NS|UI|CA"


parser = OptionParser.new do |o|
  o.separator "General options:"

  o.on('-s PROJECT_NAME', "Search project .o files by specified project name") { |project_name| 
    #replace whitespace in project name
    options[:project_name] = project_name.gsub(/\s/,'_')
  }
  o.on('-t TARGET_FILE_NAME', "Target of write file name") { |target_file_name| 
    options[:target_file_name] = target_file_name
  }

  o.separator "Common options:"
  o.on_tail('-h', "Prints this help") { puts o; exit }
  o.parse!
end

if options[:project_name]
  paths = []
  IO.popen("find ~/Library/Developer/Xcode/DerivedData -name \"#{options[:project_name]}*-*\" -type d -depth 1 -exec find {} -type d -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" \\; ") { |f| 
   f.each do |line|  
    paths << line
   end
  }

  IO.popen("find ~/Library/Caches/appCode*/DerivedData -name \"#{options[:project_name]}*-*\" -type d -depth 1 -exec find {} -type d -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" \\; ") { |f| 
   f.each do |line|  
    paths << line
   end
  }

  $stderr.puts "There were #{paths.length} directories found"
  if paths.empty?
    $stderr.puts "Cannot find projects that starts with '#{options[:project_name]}'"
    exit 1
  end  

  filtered_by_target_paths = paths

  paths_sorted_by_time = filtered_by_target_paths.sort_by{ |f| 
    File.ctime(f.chomp)
  }
  
  paths_sorted_by_time = paths_sorted_by_time.select{ |f| 
    f.index("Tests.build") == nil
  }

  paths_sorted_by_time = paths_sorted_by_time.select{ |f| 
    f.index("Pods.build") == nil
  }

  last_modified_dir = paths_sorted_by_time.last.chomp

  $stderr.puts "Last modifications were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}" 
  
  options[:search_directory] = last_modified_dir
end

if !options[:search_directory]
  puts parser.help
  exit 1
end


#Header

target = File.open(options[:target_file_name], 'w')
target.write("   var dependencies = {\n")
target.write("    links:\n")
target.write("      [\n")


#Searching all the .o files and showing its information through nm call
IO.popen("find \"#{options[:search_directory]}\" -name \"*.o\" -exec  /usr/bin/nm -o {} \\;") { |f| 
	 f.each do |line|  

      # Gathering only OBC_CLASSES
      match = /_OBJC_CLASS_\$_/.match line

      if match != nil
            exclusion_match = /_OBJC_CLASS_\$_(#{options[:exclusion_prefixes]})/.match line

      		# Excluding base frameworks prefixes
      		if exclusion_match == nil

      			#Capturing filename (We'll think that this is source)
      			#And dependency (We'll think that this is the destination)

      			source,dest = /[^\w]*([^\.\/]+)\.o.*_OBJC_CLASS_\$_(.*)/.match(line)[1,2]
      			if source != dest 
            target.write("            { \"source\" : \"#{source}\", \"dest\" : \"#{dest}\" },\n")
      			end
      		end
	  end
    end
}  
target.write("         ]\n")
target.write("    }\n")
target.write("  ;\n")
target.close()
