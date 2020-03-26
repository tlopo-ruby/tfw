# TFW - Terraform Wrapper

Terraform Wrapper writes terraform configuration using TFDSL (Terraform DSL for Ruby) and invokes the terraform binary. 

## Motivation (Short Version)

Terraform is an excellent tool, but it lacks funcionalities like Loops and Conditionals, actually since version 0.12+ it has loops as meta-arguments which is a hacky implementation in my humble opinion. 

For years I was templating terraform configuration with ERB / Jinja, that's reasonable way to avoid repetition in terraform but it's not very flexible nor reusable. 

The solution was writing a tool which mimics terraform usage but writes configuration in plain Ruby. 


## Usage:

1. let's create a file called `foo.rb`
```ruby
resource 'local_file', 'foo' do 
  content 'foo'
  filename '/tmp/foo.txt'
end
```

2. Just like in terrraform, run init and apply
```
$ tfw init && tfw apply
... <omitted output>
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.foo will be created
  + resource "local_file" "foo" {
      + content              = "foo"
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "/tmp/foo.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.foo: Creating...
local_file.foo: Creation complete after 0s [id=0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## How it works

TFW will create a subdirectory called `.tfw`, and it will create a file called `.tfw/stack.tf` which is the dynamically generated terraform file, and will invoke terrafom in that directory. 


