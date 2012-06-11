
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

  assert :echo, [:result] do
    result
  end

  assert :apples, [:apples_limit] do
    subject.apples_count >= apples_limit
  end

  assert :bananas, [:babanas_limit] do
    subject.bananas_count >= babanas_limit
  end

end


resource "TestResource" do

  privilege :mark_featured, [:flower, :bouquet]

  privilege :add_photo, [:bouquet] do

    pass :photo_limit, [:none], :limit => 1
    pass :photo_limit, [:bulb], :limit => 5
    pass :photo_limit, [:flower], :limit => 10

  end

  privilege :update, [:admin] do
    pass :false, [:user]
  end

  privilege :view

  privilege :echo_privilege do
    pass :echo
  end

  privilege :mix, [:admin] do
    pass :echo, [:flower], :result => true
    pass [:apples, :bananas], :apples_limit => 2, :babanas_limit => 1
  end


end
