# AccessSchema gem - ACL/plans for your app

AccessSchema provides decoupled from Rails and ORM agnostic tool
to define ACL schemas with realy simple DSL.

Inspired by [ya_acl](https://github.com/kaize/ya_acl)

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

    def role
      AccessSchema.schema(:plans).with_options({
        :role => Rails.development? && params[:debug_role] || current_user.try(:role) || :none
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
  role.require! review, :mark_privileged

```

Or views:

```ruby
  - if role.allow? review, :add_photo
    = render :partial => "add_photo"
```


On the ather side there are no any current_user accessible. In a Service Layer for
example. So we have to pass extra options:


```ruby
  #./app/services/review_service.rb

  class ReviewService < BaseSevice

    def mark_privileged(review_id, options)

      review = Review.find(review_id)

      acl = AccessSchema.schema(:acl).with_options(:roles => options[:actor].roles)
      acl.require! review, :mark_privileged

      plans = AccessSchema.schema(:plans).with_options(:plans => options[:actor].plans)
      plans.require! review, :mark_privileged

      review.privileged = true
      review.save!

    end

    def update(review_id, attrs)

      review = Review.find(review_id)

      acl = AccessSchema.schema(:acl).with_options(:roles => options[:actor].roles)
      acl.require! review, :edit

      plans = AccessSchema.schema(:plan).with_options(:plan => options[:actor].plan)
      plans.require! review, :edit, :new_attrs => attrs

      review.update_attributes(attrs)

    end

  end

```

### Definition

```ruby
  # config/roles.rb

  roles do
    role :none
    role :bulb
    role :flower
    role :bouquet
  end

  asserts do

    assert :photo_limit, [:limit] do
      subject.photos_count < limit
    end

    assert :attrs, [:new_attrs, :disallow] do
      # check if any disallowed attributes are changing in subject with new_attrs
    end

  end

  resource "Review" do

    privilege :mark_privileged, [:flower, :bouquet]

    privilege :add_photo, [:bouquet] do
      assert :photo_limit, [:none], :limit => 1
      assert :photo_limit, [:bulb], :limit => 5
      assert :photo_limit, [:flower], :limit => 10
    end

    privilege :edit, [:bouquet] do
      assert :attrs, [:bulb], :disallow => [:greeting, :logo, :site_url]
      assert :attrs, [:flower], :disallow => [:site_url]
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

  resource "Review" do

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

    schema :plans, AccessSchema.build_file('config/plans.rb')
    schema :acl, AccessSchema.build_file('config/acl.rb')

    logger Rails.logger

  end

```


