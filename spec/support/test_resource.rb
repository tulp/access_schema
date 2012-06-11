class TestResource
  def to_s
    "#{self.class.name}:#{object_id}"
  end
end

