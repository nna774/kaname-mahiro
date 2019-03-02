require 'aws-sdk-dynamodb'
require 'json'

TABLE = ENV['TABLE']

class Hash
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end
end

def handler(event:, context:)
  tag = event['tag']
  return { status: :ng, errors: ['need tag.'] } if tag == ''
  now = Time.now.to_i
  client = Aws::DynamoDB::Client.new
  client.put_item({
    table_name: TABLE,
    item: {
      tag: tag,
      unixtime: now,
      raw_body: event['body'].to_json,
    }.reverse_merge(event['body']).select{ |_, v| v&.!= '' },
  })
  { status: :ok }
end
