# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "rubygems"
require "json-schema"

# This  filter will validate the message against a json schema
# provided in the configuration.
#
# It adds a jsonschemafailure tag if the message does not validate
class LogStash::Filters::JsonSchema < LogStash::Filters::Base

  config_name "json_schema"
  
  # The schema to validate messages against.
  config :schema, :validate => :string, :default => "{}"
  

  public
  def register
    # Add instance variables 
  end # def register

  public
  def filter(event)
    body = event.get("message")
    begin
      if !JSON::Validator.validate(@schema, body)
        tag_as_schema_failure(event)
      end
    rescue Exception => e
      logger.error("Exception thrown while validating entry", { "schema" => @schema, "log entry" => body, "exception" => e})
      tag_as_schema_failure(event)
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

  def tag_as_schema_failure(event)
    tags = event.get("tags")
    tags = [] if !tags
    tags.push("jsonschemafailure")
    event.set("tags", tags)
  end
end # class LogStash::Filters::JsonSchema
