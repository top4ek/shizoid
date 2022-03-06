# frozen_string_literal: true

module CommandParameters
  private

  def command_parameters
    @command_parameters ||= text_without_command.downcase
  end

  def first_parameter
    @first_parameter ||= command_parameters.split(' ').first
  end

  def second_parameter
    @second_parameter ||= command_parameters.split[1..].join(' ')
  end
end
