require File.expand_path('base_test_case', File.dirname(__FILE__))

class TestChannelStatistics < Test::Unit::TestCase
  include BaseTestCase

  def test_get_channel_statistics_whithout_created_channel
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_channel_statistics_whithout_created_channel'

    EventMachine.run {
      pub_1 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=' + channel.to_s).get :head => headers, :timeout => 30
      pub_1.callback {
        assert_equal(404, pub_1.response_header.status, "Channel was founded")
        assert_equal(0, pub_1.response_header.content_length, "Recieved a non empty response")
        EventMachine.stop
      }
    }
  end

  def test_get_channel_statistics_to_existing_channel
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_channel_statistics_to_existing_channel'
    body = 'body'

    #create channel
    publish_message(channel, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=' + channel.to_s).get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(channel, response["channel"].to_s, "Channel was not recognized")
        assert_equal(1, response["published_messages"].to_i, "Message was not published")
        assert_equal(1, response["stored_messages"].to_i, "Message was not stored")
        assert_equal(0, response["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    }
  end

  def test_get_channel_statistics_to_existing_channel_with_subscriber
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_channel_statistics_to_existing_channel_with_subscriber'
    body = 'body'

    create_channel_by_subscribe(channel, headers) do
      pub_1 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=' + channel.to_s).get :head => headers, :timeout => 30
      pub_1.callback {
        assert_equal(200, pub_1.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_1.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_1.response)
        assert_equal(channel, response["channel"].to_s, "Channel was not recognized")
        assert_equal(0, response["published_messages"].to_i, "Wrong number for published messages")
        assert_equal(0, response["stored_messages"].to_i, "Wrong number for stored messages")
        assert_equal(1, response["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    end
  end

  def test_get_detailed_channels_statistics_whithout_created_channels
    headers = {'accept' => 'application/json'}

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ALL').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(0, response["infos"].length, "Received info whithout_created_channels")
        EventMachine.stop
      }
    }
  end

  def test_get_detailed_channels_statistics_to_existing_channel
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_detailed_channels_statistics_to_existing_channel'
    body = 'body'

    #create channel
    publish_message(channel, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ALL').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(1, response["infos"].length, "Didn't received info about the only created channel")
        assert_equal(channel, response["infos"][0]["channel"].to_s, "Channel was not recognized")
        assert_equal(1, response["infos"][0]["published_messages"].to_i, "Message was not published")
        assert_equal(1, response["infos"][0]["stored_messages"].to_i, "Message was not stored")
        assert_equal(0, response["infos"][0]["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    }
  end

  def config_test_get_detailed_channels_statistics_to_existing_broadcast_channel
    @broadcast_channel_prefix = 'bd_'
    @broadcast_channel_max_qtd = 1
  end

  def test_get_detailed_channels_statistics_to_existing_broadcast_channel
    headers = {'accept' => 'application/json'}
    channel = 'bd_test_get_detailed_channels_statistics_to_existing_broadcast_channel'
    body = 'body'

    #create channel
    publish_message(channel, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ALL').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(1, response["infos"].length, "Didn't received info about the only created channel")
        assert_equal(0, response["channels"].to_i, "Channel was not recognized")
        assert_equal(1, response["broadcast_channels"].to_i, "Channel was not recognized")
        assert_equal(channel, response["infos"][0]["channel"].to_s, "Channel was not recognized")
        assert_equal(1, response["infos"][0]["published_messages"].to_i, "Message was not published")
        assert_equal(1, response["infos"][0]["stored_messages"].to_i, "Message was not stored")
        assert_equal(0, response["infos"][0]["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    }
  end

  def test_detailed_channels_statistics_to_existing_channel_with_subscriber
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_detailed_channels_statistics_to_existing_channel_with_subscriber'
    body = 'body'

    create_channel_by_subscribe(channel, headers) do
      pub_1 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ALL').get :head => headers, :timeout => 30
      pub_1.callback {
        assert_equal(200, pub_1.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_1.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_1.response)
        assert_equal(1, response["infos"].length, "Didn't received info about the only created channel")
        assert_equal(channel, response["infos"][0]["channel"].to_s, "Channel was not recognized")
        assert_equal(0, response["infos"][0]["published_messages"].to_i, "Wrong number for published messages")
        assert_equal(0, response["infos"][0]["stored_messages"].to_i, "Wrong number for stored messages")
        assert_equal(1, response["infos"][0]["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    end
  end

  def test_get_summarized_channels_statistics_whithout_created_channels
    headers = {'accept' => 'application/json'}

    EventMachine.run {
      pub_1 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => headers, :timeout => 30
      pub_1.callback {
        assert_equal(200, pub_1.response_header.status, "Don't get channels statistics")
        assert_not_equal(0, pub_1.response_header.content_length, "Don't received channels statistics")
        begin
          response = JSON.parse(pub_1.response)
          assert(response.has_key?("channels"), "Didn't received the correct answer with channels info")
          assert_equal(0, response["channels"].to_i, "Returned values with channels created")
        rescue JSON::ParserError
          fail("Didn't receive a valid response")
        end
        EventMachine.stop
      }
    }
  end

  def test_get_summarized_channels_statistics_to_existing_channel
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_summarized_channels_statistics_to_existing_channel'
    body = 'body'

    #create channel
    publish_message(channel, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Don't get channels statistics")
        assert_not_equal(0, pub_2.response_header.content_length, "Don't received channels statistics")
        begin
          response = JSON.parse(pub_2.response)
          assert(response.has_key?("channels"), "Didn't received the correct answer with channels info")
          assert_equal(1, response["channels"].to_i, "Don't returned values with created channel")
          assert_equal(1, response["published_messages"].to_i, "Message was not published")
          assert_equal(0, response["subscribers"].to_i, "Wrong number for subscribers")
        rescue JSON::ParserError
          fail("Didn't receive a valid response")
        end
        EventMachine.stop
      }
    }
  end

  def config_test_get_summarized_channels_statistics_to_existing_broadcast_channel
    @broadcast_channel_prefix = 'bd_'
    @broadcast_channel_max_qtd = 1
  end

  def test_get_summarized_channels_statistics_to_existing_broadcast_channel
    headers = {'accept' => 'application/json'}
    channel = 'bd_test_get_summarized_channels_statistics_to_existing_broadcast_channel'
    body = 'body'

    #create channel
    publish_message(channel, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Don't get channels statistics")
        assert_not_equal(0, pub_2.response_header.content_length, "Don't received channels statistics")
        begin
          response = JSON.parse(pub_2.response)
          assert(response.has_key?("channels"), "Didn't received the correct answer with channels info")
          assert_equal(0, response["channels"].to_i, "Don't returned values with created channel")
          assert_equal(1, response["broadcast_channels"].to_i, "Don't returned values with created channel")
          assert_equal(1, response["published_messages"].to_i, "Message was not published")
          assert_equal(0, response["subscribers"].to_i, "Wrong number for subscribers")
        rescue JSON::ParserError
          fail("Didn't receive a valid response")
        end
        EventMachine.stop
      }
    }
  end

  def test_summarized_channels_statistics_to_existing_channel_with_subscriber
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_summarized_channels_statistics_to_existing_channel_with_subscriber'
    body = 'body'

    create_channel_by_subscribe(channel, headers) do
      pub_1 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => headers, :timeout => 30
      pub_1.callback {
        assert_equal(200, pub_1.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_1.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_1.response)
        assert(response.has_key?("channels"), "Didn't received the correct answer with channels info")
        assert_equal(1, response["channels"].to_i, "Don't returned values with created channel")
        assert_equal(0, response["published_messages"].to_i, "Wrong number for published messages")
        assert_equal(1, response["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    end
  end

  def test_accepted_methods_channel_statistics
    EventMachine.run {
      multi = EventMachine::MultiRequest.new

      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get)
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').put :body => 'body')
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').post)
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').delete)
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').head)

      multi.callback  {
        assert_equal(5, multi.responses[:succeeded].length)

        assert_not_equal(405, multi.responses[:succeeded][0].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][0].method, "Array is with wrong order")

        assert_equal(405, multi.responses[:succeeded][1].response_header.status, "Statistics does not accept PUT")
        assert_equal("PUT", multi.responses[:succeeded][1].method, "Array is with wrong order")

        assert_equal(405, multi.responses[:succeeded][2].response_header.status, "Statistics does not accept POST")
        assert_equal("POST", multi.responses[:succeeded][2].method, "Array is with wrong order")

        assert_equal(405, multi.responses[:succeeded][3].response_header.status, "Statistics does not accept DELETE")
        assert_equal("DELETE", multi.responses[:succeeded][3].method, "Array is with wrong order")

        assert_equal(405, multi.responses[:succeeded][4].response_header.status, "Statistics does not accept HEAD")
        assert_equal("HEAD", multi.responses[:succeeded][4].method, "Array is with wrong order")

        EventMachine.stop
      }
    }
  end

  def test_accepted_content_types
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_accepted_content_types'
    body = 'body'

    #create channel
    publish_message(channel, headers, body)

    EventMachine.run {

      multi = EventMachine::MultiRequest.new

      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get) # default content_type
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => {'accept' => 'text/plain'})
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => {'accept' => 'application/json'})
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => {'accept' => 'application/yaml'})
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => {'accept' => 'application/xml'})
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => {'accept' => 'text/x-json'})
      multi.add(EventMachine::HttpRequest.new(nginx_address + '/channels-stats').get :head => {'accept' => 'text/x-yaml'})

      multi.callback  {
        assert_equal(7, multi.responses[:succeeded].length)

        i = 0
        assert_equal(200, multi.responses[:succeeded][i].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][i].method, "Array is with wrong order")
        assert_equal("application/json", multi.responses[:succeeded][i].response_header["CONTENT_TYPE"], "wrong content-type")

        i+=1
        assert_equal(200, multi.responses[:succeeded][i].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][i].method, "Array is with wrong order")
        assert_equal("text/plain", multi.responses[:succeeded][i].response_header["CONTENT_TYPE"], "wrong content-type")

        i+=1
        assert_equal(200, multi.responses[:succeeded][i].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][i].method, "Array is with wrong order")
        assert_equal("application/json", multi.responses[:succeeded][i].response_header["CONTENT_TYPE"], "wrong content-type")

        i+=1
        assert_equal(200, multi.responses[:succeeded][i].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][i].method, "Array is with wrong order")
        assert_equal("application/yaml", multi.responses[:succeeded][i].response_header["CONTENT_TYPE"], "wrong content-type")

        i+=1
        assert_equal(200, multi.responses[:succeeded][i].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][i].method, "Array is with wrong order")
        assert_equal("application/xml", multi.responses[:succeeded][i].response_header["CONTENT_TYPE"], "wrong content-type")

        i+=1
        assert_equal(200, multi.responses[:succeeded][i].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][i].method, "Array is with wrong order")
        assert_equal("text/x-json", multi.responses[:succeeded][i].response_header["CONTENT_TYPE"], "wrong content-type")

        i+=1
        assert_equal(200, multi.responses[:succeeded][i].response_header.status, "Statistics does accept GET")
        assert_equal("GET", multi.responses[:succeeded][i].method, "Array is with wrong order")
        assert_equal("text/x-yaml", multi.responses[:succeeded][i].response_header["CONTENT_TYPE"], "wrong content-type")

        EventMachine.stop
      }
    }
  end

  def config_test_get_detailed_channels_statistics_to_many_channels
    @max_reserved_memory = '200m'
  end

  def test_get_detailed_channels_statistics_to_many_channels
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_detailed_channels_statistics_to_many_channels_'
    body = 'body'
    number_of_channels = 20000

    #create channels
    0.step(number_of_channels - 1, 10) do |i|
      EventMachine.run {
        publish_message_inline("#{channel}#{i + 1}", headers, body)
        publish_message_inline("#{channel}#{i + 2}", headers, body)
        publish_message_inline("#{channel}#{i + 3}", headers, body)
        publish_message_inline("#{channel}#{i + 4}", headers, body)
        publish_message_inline("#{channel}#{i + 5}", headers, body)
        publish_message_inline("#{channel}#{i + 6}", headers, body)
        publish_message_inline("#{channel}#{i + 7}", headers, body)
        publish_message_inline("#{channel}#{i + 8}", headers, body)
        publish_message_inline("#{channel}#{i + 9}", headers, body)
        publish_message_inline("#{channel}#{i + 10}", headers, body) { EventMachine.stop }
      }
    end

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ALL').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(number_of_channels, response["infos"].length, "Didn't received info about the created channels")
        EventMachine.stop
      }
    }
  end

  def test_get_detailed_channels_statistics_whithout_created_channels_using_prefix
    headers = {'accept' => 'application/json'}

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=prefix_*').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(0, response["infos"].length, "Received info whithout_created_channels")
        EventMachine.stop
      }
    }
  end

  def test_get_detailed_channels_statistics_to_existing_channel_using_prefix
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_detailed_channels_statistics_to_existing_channel_using_prefix'
    channel_1 = 'another_ch_test_get_detailed_channels_statistics_to_existing_channel_using_prefix'
    body = 'body'

    #create channels
    publish_message(channel, headers, body)
    publish_message(channel_1, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ch_test_*').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(1, response["infos"].length, "Didn't received info about the only created channel")
        assert_equal(channel, response["infos"][0]["channel"].to_s, "Channel was not recognized")
        assert_equal(1, response["infos"][0]["published_messages"].to_i, "Message was not published")
        assert_equal(1, response["infos"][0]["stored_messages"].to_i, "Message was not stored")
        assert_equal(0, response["infos"][0]["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    }
  end

  def test_get_detailed_channels_statistics_using_prefix_as_same_behavior_ALL
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_detailed_channels_statistics_using_prefix_as_same_behavior_ALL'
    channel_1 = 'another_ch_test_get_detailed_channels_statistics_using_prefix_as_same_behavior_ALL'
    body = 'body'

    #create channels
    publish_message(channel, headers, body)
    publish_message(channel_1, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=*').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(2, response["infos"].length, "Didn't received info about the only created channel")
        assert_equal(channel, response["infos"][0]["channel"].to_s, "Channel was not recognized")
        assert_equal(1, response["infos"][0]["published_messages"].to_i, "Message was not published")
        assert_equal(1, response["infos"][0]["stored_messages"].to_i, "Message was not stored")
        assert_equal(0, response["infos"][0]["subscribers"].to_i, "Wrong number for subscribers")
        assert_equal(channel_1, response["infos"][1]["channel"].to_s, "Channel was not recognized")
        assert_equal(1, response["infos"][1]["published_messages"].to_i, "Message was not published")
        assert_equal(1, response["infos"][1]["stored_messages"].to_i, "Message was not stored")
        assert_equal(0, response["infos"][1]["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    }
  end

  def config_test_get_detailed_channels_statistics_to_existing_broadcast_channel_using_prefix
    @broadcast_channel_prefix = 'bd_'
    @broadcast_channel_max_qtd = 1
  end

  def test_get_detailed_channels_statistics_to_existing_broadcast_channel_using_prefix
    headers = {'accept' => 'application/json'}
    channel = 'bd_test_get_detailed_channels_statistics_to_existing_broadcast_channel_using_prefix'
    body = 'body'

    #create channel
    publish_message(channel, headers, body)

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=bd_test_*').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(1, response["infos"].length, "Didn't received info about the only created channel")
        assert_equal(0, response["channels"].to_i, "Channel was not recognized")
        assert_equal(1, response["broadcast_channels"].to_i, "Channel was not recognized")
        assert_equal(channel, response["infos"][0]["channel"].to_s, "Channel was not recognized")
        assert_equal(1, response["infos"][0]["published_messages"].to_i, "Message was not published")
        assert_equal(1, response["infos"][0]["stored_messages"].to_i, "Message was not stored")
        assert_equal(0, response["infos"][0]["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    }
  end

  def test_detailed_channels_statistics_to_existing_channel_with_subscriber_using_prefix
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_detailed_channels_statistics_to_existing_channel_with_subscriber_using_prefix'
    body = 'body'

    create_channel_by_subscribe(channel, headers) do
      pub_1 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ch_test_*').get :head => headers, :timeout => 30
      pub_1.callback {
        assert_equal(200, pub_1.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_1.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_1.response)
        assert_equal(1, response["infos"].length, "Didn't received info about the only created channel")
        assert_equal(channel, response["infos"][0]["channel"].to_s, "Channel was not recognized")
        assert_equal(0, response["infos"][0]["published_messages"].to_i, "Wrong number for published messages")
        assert_equal(0, response["infos"][0]["stored_messages"].to_i, "Wrong number for stored messages")
        assert_equal(1, response["infos"][0]["subscribers"].to_i, "Wrong number for subscribers")
        EventMachine.stop
      }
    end
  end

  def config_test_get_detailed_channels_statistics_to_many_channels_using_prefix
    @max_reserved_memory = '200m'
  end

  def test_get_detailed_channels_statistics_to_many_channels_using_prefix
    headers = {'accept' => 'application/json'}
    channel = 'ch_test_get_detailed_channels_statistics_to_many_channels_using_prefix_'
    body = 'body'
    number_of_channels = 20000

    #create channels
    0.step(number_of_channels - 1, 10) do |i|
      EventMachine.run {
        publish_message_inline("#{channel}#{i + 1}", headers, body)
        publish_message_inline("#{channel}#{i + 2}", headers, body)
        publish_message_inline("#{channel}#{i + 3}", headers, body)
        publish_message_inline("#{channel}#{i + 4}", headers, body)
        publish_message_inline("#{channel}#{i + 5}", headers, body)
        publish_message_inline("#{channel}#{i + 6}", headers, body)
        publish_message_inline("#{channel}#{i + 7}", headers, body)
        publish_message_inline("#{channel}#{i + 8}", headers, body)
        publish_message_inline("#{channel}#{i + 9}", headers, body)
        publish_message_inline("#{channel}#{i + 10}", headers, body) { EventMachine.stop }
      }
    end

    EventMachine.run {
      pub_2 = EventMachine::HttpRequest.new(nginx_address + '/channels-stats?id=ch_test_*').get :head => headers, :timeout => 30
      pub_2.callback {
        assert_equal(200, pub_2.response_header.status, "Request was not accepted")
        assert_not_equal(0, pub_2.response_header.content_length, "Empty response was received")
        response = JSON.parse(pub_2.response)
        assert_equal(number_of_channels, response["infos"].length, "Didn't received info about the created channels")
        EventMachine.stop
      }
    }
  end
end
