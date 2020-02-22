resource "local_file" "foo" {
    content = "foo"
    filename = "/tmp/foo"
    provisioner "local-exec" {
        command = "bash -c \"sleep 60\""
    }
}

