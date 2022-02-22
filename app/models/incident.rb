class Incident
  include ActiveModel::Model

  attr_accessor :channel_id, :channel_name

  def calling_channel=(calling_channel)
    Rails.cache.write("#{channel_id}_calling_channel", calling_channel)
  end

  def calling_channel
    Rails.cache.read("#{channel_id}_calling_channel")
  end
end
