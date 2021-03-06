require_relative 'file_creator'
require_relative "pbxproj_parser"

class PresenterGenerator

  def initialize(parser)
    @parser = parser
  end

  def generate(presenter_name, options = {})
    app_group = @parser.app_group
    raise "[Error] Group #{presenter_name} already exists in #{app_group.display_name}" if app_group[presenter_name]
    new_group = app_group.new_group(presenter_name)

    ui_group = new_group.new_group("UI")
    ui_group.new_group("View")
    view_controller_group = ui_group.new_group("ViewController")
    presenter_group = new_group.new_group("Presenter")
    model_group = new_group.new_group("Model")

    file_creator = FileCreator.new(@parser.source_path, options)
    target = @parser.main_target
    file_creator.create_file(presenter_name, 'ViewContract', ui_group, target)
    file_creator.create_file(presenter_name, 'ViewController', view_controller_group, target)
    file_creator.create_file(presenter_name, 'Presenter', presenter_group, target)
    file_creator.create_file(presenter_name, 'PresenterImplementation', presenter_group, target)

    file_creator.print_file_content(presenter_name, 'DependencyProvider')
    file_creator.print_file_content(presenter_name, 'PresenterAssembly')
  end
end
