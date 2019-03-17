require "file"
require "kemal"
require "random/secure"

class Pastebin

  def initialize(@port = 3000)
  end

  get "/:name" do |env|
    name = env.params.url["name"]
    path = "files/#{name}"
    if File.exists?(path)
      paste = File.read(path)
      render "src/views/paste.ecr", "src/views/layouts/paste.ecr"
    else
      text = "Paste not found: #{name}"
      render "src/views/page.ecr", "src/views/layouts/page.ecr"
    end
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

  error 404 do
    "404: Not Found"
  end

  error 500 do
    "500: Server Error"
  end
end

server = Pastebin.new
server.run
