# frozen_string_literal: true

require_relative "google_bard/version"
require 'httparty'
require 'json'
require 'cgi'

class GoogleBard
  class Error < StandardError; end
  include HTTParty
  HEADERS = {
    'Host' => 'bard.google.com',
    'X-Same-Domain' => '1',
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36',
    'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8',
    'Origin' => 'https://bard.google.com',
    'Referer' => 'https://bard.google.com/'
  }

  def initialize(token = nil, timeout = 20, proxies = nil)
    @token = token || ENV['GOOGLE_BARD_SECURE_1PSID']
    @timeout = timeout
    @proxies = proxies
    @reqid = rand(1000..9999)
    @conversation_id = ''
    @response_id = ''
    @choice_id = ''
    @snim0e = get_snim0e
  end

  def get_snim0e
    if @token.nil? || !@token.end_with?('.')
      raise '__Secure-1PSID value must end with a single dot. Enter correct __Secure-1PSID value.'
    end

    response = self.class.get('https://bard.google.com/', timeout: @timeout, cookies: { '__Secure-1PSID' => @token })
    raise "Response code not 200. Response Status is #{response.code}" unless response.code == 200

    snim0e_match = response.body.match(/SNlM0e":"(.*?)"/)
    raise 'SNlM0e value not found in response. Check __Secure-1PSID value.' unless snim0e_match

    snim0e_match[1]
  end

  def completion(text_input)
    # Send the request with the payload in the body
    response = HTTParty.post(
      'https://bard.google.com/_/BardChatUi/data/assistant.lamda.BardFrontendService/StreamGenerate',
      query: query,
      body: payload(text_input),
      headers: HEADERS,
      cookies: { '__Secure-1PSID' => @token },
      timeout: @timeout
    )
    puts "*********************"
    puts "Google Answer:"
    puts response
    puts "*********************"
    handle_response(response)
  end

  def query
    {
      'bl' => 'boq_assistant-bard-web-server_20230419.00_p1',
      '_reqid' => @reqid.to_s,
      'rt' => 'c'
    }
  end

  def payload(text_input)
    input_text_struct = [[text_input], nil, [@conversation_id, @response_id, @choice_id]]
    nested_json = [nil, input_text_struct.to_json].to_json
    data = {
      'f.req' => nested_json,
      'at' => @snim0e
    }
    payload = URI.encode_www_form(data)
  end

  def handle_response(response)
    response_dict = JSON.parse(response.body.split("\n")[3])[0][2]

    if !response_dict.nil?
      parsed_answer = JSON.parse(response_dict)
      bard_answer = OpenStruct.new(
        success: true,
        content: parsed_answer[0][0],
        conversation_id: parsed_answer[1][0],
        response_id: parsed_answer[1][1],
        factualityQueries: parsed_answer[3],
        textQuery: (parsed_answer[2][0] if parsed_answer[2]),
        choices: parsed_answer[4]&.map { |i| { id: i[0], content: i[1] } }
      )
      @conversation_id = bard_answer.conversation_id
      @response_id = bard_answer.response_id
      @choice_id = bard_answer.choices[0][:id]
      @reqid += 100_000
      bard_answer
    else
      OpenStruct.new(
        success: false,
        content: "Error: #{response.body}."
      )
    end
  end
end
