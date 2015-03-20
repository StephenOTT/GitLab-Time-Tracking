
require './app'

use Rack::Static, :urls => ["/css", "/img", "/js", "/images"], :root => "public"

run Sinatra::Application