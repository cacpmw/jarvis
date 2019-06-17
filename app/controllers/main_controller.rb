# frozen_string_literal: true

class MainController < ApplicationController

  def create
    text = set_text
    if text.include? '/dolar'
      puts '/dolar'
      get_usd_brl
    elsif text.include? '/simounao'
      puts '/simounao'
      response = yes_or_no
      answer = response.answer
      send_message(answer.sub("no", "nao").sub("yes", "sim"))
      if response.image.include? '.gif'
        puts 'gif'
        send_animation(response.image)
      else
        puts 'image'
        send_photo(response.image)
      end
    elsif text.include?('/spotify')
      puts '/spotify'
      result = spotify_search(text.split('#'))
      if result == 0 || result.nil?
        puts 'not found'
        text = 'Perdão, não fui capaz de encontrar o que o senhor procura'
        send_message(text)
      else
        puts 'found'
        text = 'Aqui está o resultado da sua pesquisa senhor:'
        send_message(text)
        send_message(result.external_urls['spotify'])
      end
    elsif text.include?('/ajuda')
      puts '/ajuda'
      send_message(get_help)
    elsif text.include?('/btc')
      get_btc_brl
    elsif text.include?('/domain')
      response = check_domain_availability(text.split('#'))
      debugger
    else
      puts 'unknown command'
      response = 'Não conheço este comando senhor'
      send_message(response)
    end

  end

  private

  def set_chat_id
    request.params[:message]["chat"]["id"].to_s
  end

  def set_username
    request.params[:message]["from"]["first_name"].to_s
  end

  def set_text
    request.params[:message]["text"].to_s
  end

  def get_usd_brl
    key = Rails.application.credentials.dig(:secret_apilayer_key)
    #Getting USDBRL quotation
    response = Faraday.get("http://apilayer.net/api/live?access_key=#{key}&currencies=BRL&format=1")
    quotation = ActiveSupport::JSON.decode(response.body)
    #Sending response to bot
    response_text = "#{set_username} o dolar está custando: R$" + (quotation['quotes']['USDBRL']).round(2).to_s
    send_message(response_text)
  end

  def check_domain_availability(domain)
    key = Rails.application.credentials.dig(:jsonwhois_api_key)
    response = Faraday.get("https://api.jsonwhois.io/availability?key=#{key}&domain=#{domain}")
    response.body
  end

  def get_btc_brl

    response = Faraday.get("https://www.mercadobitcoin.net/api/btc/ticker/")
    quotation = JSON.parse(response.body, object_class: OpenStruct)
    response_text =
        " aqui está o resumo de operações executadas segundo
<strong>Mercado Bitcoin</strong>:
Valor atual: R$ #{(quotation.ticker.last).to_f.round(2)}

Aqui estão mais alguns dados complementares das últimas 24h para o senhor:

<strong>Maior preço:</strong> R$#{(quotation.ticker.high).to_f.round(2)}
<strong>Menor preço:</strong> R$#{(quotation.ticker.low).to_f.round(2)}
<strong>Volume:</strong> R$#{(quotation.ticker.vol).to_f.round(2)}
<strong>Preço de compra:</strong> R$#{(quotation.ticker.buy).to_f.round(2)}
<strong>Preço de venda:</strong> R$#{(quotation.ticker.sell).to_f.round(2)}
        "
    send_message(response_text)
  end

  def get_help
    'Estou preparado para lhe ajudar no que o senhor precisar.

A seguir o senhor verá a lista de comandos que eu posso executar:

<strong>/dolar</strong> - Consultar o preço do Dolar em R$
<strong>/btc</strong> - Consultar o preço do Bitcoin em R$
<strong>/simounao</strong> - Permitir que eu tome uma decisão pelo senhor
<strong>/spotify #termo1#termo 2</strong> - Realizar uma busca no spotify

Por favor, substitua o <strong>termo1</strong> por umas destas opções: musica, album ou artista
Por favor, substitua o <strong>termo 2</strong> pelo o que o senhor deseja buscar. Qualquer caracter é permitido.'
  end

  def yes_or_no
    JSON.parse(Faraday.get('https://yesno.wtf/api/').body, object_class: OpenStruct)
  end

  def spotify_search(term)
    client_id = Rails.application.credentials.dig(:spotify_cliend_id)
    client_secret = Rails.application.credentials.dig(:spotify_client_secret)
    RSpotify.authenticate(client_id, client_secret)
    if term[1] === 'musica'
      song = RSpotify::Track.search(term[2]).sort_by &:popularity
      song.select {|s| s.available_markets.size > 1}.first
    elsif term[1] === 'artista'
      artist = RSpotify::Artist.search(term[2]).sort_by &:followers['total']
      artist.first
    elsif term[1] === 'album'
      RSpotify::Album.search(term[2]).shuffle.first
    else
      0
    end

  end

  def send_message(text)
    key = Rails.application.credentials.dig(:telegram_the_annoying_bot)

    Faraday.post("https://api.telegram.org/bot#{key}/sendMessage",
                 chat_id: set_chat_id,
                 text: text,
                 parse_mode: "HTML",
                 disable_notification: true)
  end

  def send_photo(url)
    key = Rails.application.credentials.dig(:telegram_the_annoying_bot)

    Faraday.post("https://api.telegram.org/bot#{key}/sendPhoto",
                 chat_id: set_chat_id,
                 photo: url)
  end

  def send_animation(url)
    key = Rails.application.credentials.dig(:telegram_the_annoying_bot)

    Faraday.post("https://api.telegram.org/bot#{key}/sendAnimation",
                 chat_id: set_chat_id,
                 animation: url)
  end
end
