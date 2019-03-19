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

  post "/new" do |env|
    generated_name = Random::Secure.urlsafe_base64 6
    file_path = ::File.join ["files/", generated_name]

    if env.params.body.has_key?("paste")
      paste = env.params.body["paste"].as(String)
      File.write(file_path, paste)
      env.redirect(generated_name)
    else
      file = env.params.files["paste"].tempfile
      File.open(file_path, "w") { |f| IO.copy(file, f) }
      generated_name
    end
  end

  def run
    Kemal.run(@port)
  end
end
