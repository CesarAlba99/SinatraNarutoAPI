require 'sinatra/base'
require 'json'

class NarutoApp < Sinatra::Base # in the previous class we saw an example using this, but why to use ::Base?
  @@characters ||= {
    '1' => { 'id' => '1', 'name' => 'Naruto', 'village' => 'Konoha', 'level' => 'kage' },
    '2' => { 'id' => '2', 'name' => 'Sasuke', 'village' => 'Konoha', 'level' => 'Kage' },
    '3' => { 'id' => '3', 'name' => 'Shikamaru', 'village' => 'Konoha', 'level' => 'Jounin' }
  }

  # this is for parse the request to ruby object
  def parse_body
    @payload ||= begin
      body = request.body.read
      JSON.parse body
    end
  end

  # READ
  # get all the characters
  get '/characters' do
    content_type :json
    @@characters.values.to_json
  end
  # get an specific character
  get '/characters/:id' do
    content_type :json
    character = @@characters[params[:id]]

    if character
      character.to_json
    else
      status 404
      { 'error' => 'character not found' }.to_json
    end
  end

  # CREATE
  # create a new character
  post '/characters' do
    content_type :json
    payload = parse_body

    if payload['id'].nil? || payload['name'].nil?
      status 400
      return { 'error' => 'Bad request, id and name are necessary' }.to_json
    end

    if @@characters[payload['id']]
      status 409
      return { 'error' => 'Character already exists' }.to_json
    end

    @@characters[payload['id']] = payload

    status 201
    payload.to_json
  end

  # UPDATE
  # uodate a character
  put '/characters/:id' do
    content_type :json
    character = @@characters[params[:id]]

    if character
      payload = parse_body
      payload['id'] = params[:id]
      @@characters[params[:id]] = payload
      payload.to_json
    else
      status 404
      { 'error' => 'character not found' }.to_json
    end
  end

  # DELETE
  # delete a character
  delete '/characters/:id' do
    content_type :json
    character = @@characters[params[:id]]

    if character
      @@characters.delete(params[:id])
      status 204
      ''
    else
      status 404
      { 'error' => 'character not found' }.to_json
    end
  end

  # initialize the server

  run! if __FILE__ == $0
end
