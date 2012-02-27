# AccessSchema gem - ACL/plans for your app

AccessSchema provides decoupled from Rails and ORM agnostic tool
to define ACL schemas with realy simple DSL.

Inspired by [ya_acl](https://github.com/kaize/ya_acl)

With a couple of aliases in DSL it enables you to deal with tariff plans. Plan and role, feature and privilege are synonyms.

```
  gem install access_schema
```

## An example of use


### Accessing from application code

In Rails controllers we usualy have a current_user and we can
add some default options in helpers:

```ruby
  #access_schema_helper.rb

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

So at may be used in controllers:

```ruby
  acl.require! review, :edit
  plan.require! review, :mark_featured

```

Or views:

```ruby
  - if plan.allow? review, :add_photo
    = render :partial => "add_photo"
```


On the ather side there are no any current_user accessible. In a Service Layer for
example. So we have to pass extra options:


```ruby
  #./app/services/review_service.rb

  class ReviewService < BaseSevice

    def mark_featured(review_id, options)

      review = Review.find(review_id)

      acl = AccessSchema.schema(:acl).with_options(:role => options[:actor].roles)
      acl.require! review, :mark_featured

      plans = AccessSchema.schema(:plans).with_options(:plan => options[:actor].plan)
      plans.require! review, :mark_featured

      review.featured = true
      review.save!

    end

    def update(review_id, attrs)

      review = Review.find(review_id)

      plans = AccessSchema.schema(:plans).with_options(:plan => options[:actor].plan)

      plans.require!(review, :add_site_url) if attrs[:site_url].present?
      plans.require!(review, :greeting_greeting) if attrs[:greeting].present?
      # end 5 more checks

      review.update_attributes(attrs)

    end

  end

```



### Definition


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

## Configuration

Configured schema can be accessed with AccessSchema.schema(name)
anywhere in app. Alternatively it can be assempled with ServiceLocator.


```ruby
  #config/initializers/access_schema.rb

  AccessSchema.configure do

    define_schema :plans, AccessSchema.build_file('config/plans.rb')
    define_schema :acl, AccessSchema.build_file('config/acl.rb')

  end

```


