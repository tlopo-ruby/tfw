# frozen_string_literal: true

resource 'local_file', 'foo' do
  content 'foo'
  filename '/tmp/foo'

  provisioner 'local-exec' do
    command 'bash -c "sleep 15"'
  end
end
