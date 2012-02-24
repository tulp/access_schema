
plans do
  plan :none
  plan :bulb
  plan :flower
  plan :bouquet
end

asserts do

  assert :photo_limit, [:limit] do
    subject.photos_count < limit
  end

end

namespace "Review" do

  feature :mark_featured, [:flower, :bouquet]

  feature :add_photo, [:bouquet] do
    assert :photo_limit, [:none], :limit => 1
    assert :photo_limit, [:bulb], :limit => 5
    assert :photo_limit, [:flower], :limit => 10
  end

end
