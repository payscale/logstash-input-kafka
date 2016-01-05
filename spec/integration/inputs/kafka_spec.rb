# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require "digest"

describe "input/kafka", :integration => true do
  let(:partition3_config) { { 'topics' => ['topic3'], 'codec' => 'plain', 'auto_offset_reset' => 'earliest'} }
  let(:snappy_config) { { 'topics' => ['snappy_topic'], 'codec' => 'plain', 'auto_offset_reset' => 'earliest'} }
  let(:lz4_config) { { 'topics' => ['lz4_topic'], 'codec' => 'plain', 'auto_offset_reset' => 'earliest'} }
  
  let(:tries) { 60 }
  let(:num_events) { 103 }
  
  def thread_it(kafka_input, queue)
    Thread.new do
      begin
        kafka_input.run(queue)
      end
    end
  end
  
  def wait_for_events(queue, num_events)
    begin
      timeout(30) do
        until queue.length == num_events do
          sleep 1
          next
        end
      end
    end
  end  
    
  it "should consume all messages from 3-partition topic" do
    kafka_input = LogStash::Inputs::Kafka.new(partition3_config)
    queue = Array.new
    t = thread_it(kafka_input, queue)
    t.run
    wait_for_events(queue, num_events)
    expect(queue.size).to eq(num_events)
  end
  
  it "should consume all messages from snappy 3-partition topic" do
    kafka_input = LogStash::Inputs::Kafka.new(snappy_config)
    queue = Array.new
    t = thread_it(kafka_input, queue)
    t.run
    wait_for_events(queue, num_events)
    expect(queue.size).to eq(num_events)
  end

  it "should consume all messages from lz4 3-partition topic" do
    kafka_input = LogStash::Inputs::Kafka.new(lz4_config)
    queue = Array.new
    t = thread_it(kafka_input, queue)
    t.run
    wait_for_events(queue, num_events)
    expect(queue.size).to eq(num_events)
  end
  
end
