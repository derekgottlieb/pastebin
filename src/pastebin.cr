require "file"
require "kemal"
require "random/secure"

class Pastebin

  def initialize(@port = 3000)
  end

  get "/assets/:name" do |env|
      name = env.params.url["name"]
      path = "assets/#{name}"
      File.read(path)
  end

  get "/:name" do |env|
    name = env.params.url["name"]
    path = "files/#{name}"
    paste = File.read(path)
    render "src/views/paste.ecr", "src/views/layouts/paste.ecr"
  end

  post "/" do |env|
    file = env.params.files["file"].tempfile
    generated_name = Random::Secure.urlsafe_base64 6
    file_path = ::File.join ["files/", generated_name]
    File.open(file_path, "w") do |f|
      IO.copy(file, f)
    end
    generated_name
  end

  def run
    Kemal.run(@port)
  end
end

server = Pastebin.new
server.run
