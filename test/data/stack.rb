# frozen_string_literal: true

input = {
  'name' => 'foo',
  'content' => 'foobar'
}

tfw_load_module do
  name 'sample'
  source './modules/sample'
  input input
end
