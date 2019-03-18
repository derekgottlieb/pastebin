require "file"
require "kemal"
require "random/secure"

class Pastebin

  def initialize(@port = 3000)
  end

  get "/:name" do |env|
    name = env.params.url["name"]
    path = "files/#{name}"
    halt env, status_code: 404, response: "Paste Not Found" unless File.exists?(path)

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

  post "/new" do |env|
    paste = env.params.body["paste"].as(String)
    generated_name = Random::Secure.urlsafe_base64 6
    file_path = ::File.join ["files/", generated_name]
    File.write(file_path, paste)
    env.redirect(generated_name)
  end

  def run
    Kemal.run(@port)
  end
end

server = Pastebin.new
server.run
