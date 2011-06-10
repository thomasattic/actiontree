APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'sinatra'
require 'koala'
require 'net/http'
require 'rest-client'
require 'json'
require 'haml'

# register your app at facebook to get those infos
APP_ID = 162338397164849 # your app id
APP_CODE = 'bcd8de38951104ab19f51972f4d60eb3' # your app code
SITE_URL = 'http://deep-ice-130.heroku.com/' # your app site url
DB = "#{ENV['CLOUDANT_URL']}/jdata"

class SimpleRubyFacebookExample < Sinatra::Application

	include Koala

	set :root, APP_ROOT
	enable :sessions

	get '/test' do
		if session['access_token']
		  'You are logged in! <a href="/logout">Logout</a>. Token '
		  session['access_token']
			# do some stuff with facebook here
			# for example:
			# @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
			# publish to your wall (if you have the permissions)
			# @graph.put_wall_post("I'm posting from my new cool app!")
			# or publish to someone else (if you have the permissions too ;) )
			# @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")			
		else
			'<a href="/login">Login</a>'
		end
	end

	post '/test' do
		if session['access_token']
		  'You are logged in! <a href="/logout">Logout</a>'
			# do some stuff with facebook here
			# for example:
			# @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
			# publish to your wall (if you have the permissions)
			# @graph.put_wall_post("I'm posting from my new cool app!")
			# or publish to someone else (if you have the permissions too ;) )
			# @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")			
		else
			'<a href="/login">Login</a>'
		end
    end

  get '/' do
    redirect '/index.html'
  end

	get '/login' do
		# generate a new oauth object with your app data and your callback url
		session['oauth'] = Facebook::OAuth.new(APP_ID, APP_CODE, SITE_URL + 'callback')
		# redirect to facebook to get your code
		redirect session['oauth'].url_for_oauth_code()
	end

	get '/logout' do
		session['oauth'] = nil
		session['access_token'] = nil
		redirect '/'
	end

	#method to handle the redirect from facebook back to you
	get '/callback' do
		#get the access token from facebook with your code

		session['access_token'] = session['oauth'].get_access_token(params[:code])
		redirect '/'
	end

  get '/jdata/:doc' do
    if session['access_token']
        RestClient.get("#{DB}/#{params[:doc]}") { |response, request, result|
          case response.code
          when 200
            "It worked !"
            response
          else
            halt response.code, "pass thru '%s'!" % [response.code] 
          end
        }
    else
        halt 401, "Unauthorized"
    end
  end

  put '/jdata/:doc' do
    if session['access_token']
      doc = RestClient.put("#{DB}/#{params[:doc]}", '{"put": true}')
    else
      halt 401, "Unauthorized"
    end
  end
end
