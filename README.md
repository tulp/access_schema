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

    privilege :edit, [:admin] do
      assert :owner, [:none]
    end

  end
```


```ruby
  #config/initializers/access_schema.rb

  AccessSchema.configure do

    plans = AccessSchema.build_file('config/plans.rb')

    define_schema :plans, plans
    define_schema :acl,  AccessSchema.build_file('config/plans.rb').with_options({
      :plans => plans
    })


  end

```

```ruby
  #access_schema_helper.rb

  # We have current_user and we can preset some options to
  # simplify checks in controlers/views

  class AccessSchemaHelper

    def plan
      AccessSchema.schema(:plans).with_options({
        :plan => Rails.development? && params[:debug_plan] || current_user.try(:plan) || :none
      })
    end

    def acl
      AccessSchema.schema(:acl).with_options({
        :role => current_user.try(:role) || :none,
        :user_id => current_user.try(:id)
      })
    end

  end

```

```ruby
  #./app/services/review_service.rb

  # Serivces can't use any current_user, so we have to
  # pass some more options

  class ReviewService < BaseSevice

    def mark_featured(review_id, options)

      review = Review.find(review_id)

      acl.require! review, :mark_featured, {
        :role => options[:actor].roles,
        :plan => options[:actor].plan
      }

      review.featured = true
      review.save!

    end

  end



```


