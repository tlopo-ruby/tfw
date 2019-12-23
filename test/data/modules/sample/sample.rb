# frozen_string_literal: true

input = @_input

resource 'local_file', input['name'] do
  content input['content']
  filename './foo.bar'
end
