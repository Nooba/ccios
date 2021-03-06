require_relative 'code_templater'

class FileCreator
  def initialize(source_path, options = {})
    @source_path = source_path
    @classes_path = source_path + '/Classes'
    @options = options
  end

  def templater_options(target)
    defaults = {
      project_name: target.display_name,
      full_username: git_username,
      date: DateTime.now.strftime("%d/%m/%Y"),
    }
    defaults.merge(@options)
  end

  def git_username
    `cd #{@source_path}; git config user.name`.strip
  end

  def create_file(prefix, suffix, group, target)
    file_path = @classes_path + '/' + prefix + suffix + '.swift'

    raise "File #{file_path} already exists" if File.exists?(file_path)
    file = File.new(file_path, 'w')

    templater_options = templater_options(target)
    code_templater = CodeTemplater.new(templater_options)
    file_content = code_templater.content_for_suffix(prefix, suffix)
    file.puts(file_content)

    file.close
    file_ref = group.new_reference(file_path)
    target.add_file_references([file_ref])
  end

  def print_file_content(prefix, suffix)
    file_path = @classes_path + '/' + suffix + '.swift'

    code_templater = CodeTemplater.new(@options)
    template = code_templater.content_for_suffix(prefix, suffix)

    puts "Add this snippet to #{file_path}"
    puts template
    puts "\n"
  end
end
