# AccessSchema gem - ACL/plans for your app

AccessSchema provides a tool to define ACL schema with simple DSL.
Inspired by [ya_acl](https://github.com/kaize/ya_acl)

With a couple of aliases in DSL it enables you to deal with tariff plans. Plan and role, feature and privilege are synonyms.

```
  gem install access_schema
```

## An example of typical use

```ruby
  #somewhere.rb

  acl.require! review, :edit

  plan.allow? review, :add_photo

  plan.require! review, :mark_featured

```

```ruby
  # config/plans.rb
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
```

```ruby
  # config/acl.rb
  roles do
    role :none
    role :admin
  end

  asserts do

    assert :owner, [:user_id] do
      subject.author.id == user_id
    end

  end

  namespace "Review" do

    privelege :edit, [:admin] do
      assert :owner, [:none]
    end

  end
```


```ruby
  #access_schema_helper.rb

  class AccessSchemaHelper

    def plan
      @plan ||= AccessSchema.build_file "config/plans.rb"
      AccessSchema.with_options(@plan, {
        :plan => Rails.development? && params[:debug_plan] || current_user.try(:plan) || :none
      })
    end

    def acl
      @acl ||= AccessSchema.build_file "config/acl.rb"
      AccessSchema.with_options(@acl, {
        :role => current_user.try(:role) || :none,
        :user_id => current_user.try(:id)
      })
    end

  end

```
