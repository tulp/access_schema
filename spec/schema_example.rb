
roles do
  role :none
  role :bulb
  role :flower
  role :bouquet

  role :admin
  role :user
end

asserts do

  assert :photo_limit, [:limit] do
    subject.photos_count < limit
  end

  assert :false do
    false
  end

end

resource "Review" do

  privilege :mark_featured, [:flower, :bouquet]

  privilege :add_photo, [:bouquet] do
    assert :photo_limit, [:none], :limit => 1
    assert :photo_limit, [:bulb], :limit => 5
    assert :photo_limit, [:flower], :limit => 10
  end

  privilege :update, [:admin] do
    assert :false, [:user]
  end

end
