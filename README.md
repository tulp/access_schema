# AccessSchema gem - ACL and domain policies for your app

AccessSchema is tool to add ACL and domain policy rules to an application. It is framework/ORM agnostic and provides declarative DSL.

Inspired by [ya_acl](https://github.com/kaize/ya_acl)

```
  gem install access_schema
```

## An example of use with Rails

### Definition

```ruby
  # config/policy.rb

  roles do

    # Tariff plans
    role :none
    role :bulb
    role :flower
    role :bouquet

    # To allow admin violate tariff plan rules
    role :admin
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

    privilege :mark_featured, [:flower, :bouquet]

    # Admin is able to add over limit
    privilege :add_photo, [:bouquet, :admin] do
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

  resource "ReviewsController" do

    privilege :index
    privilege :show

    privilege :edit, [:admin] do
      assert :owner, [:none]
    end

    privilege :update, [:admin] do
      assert :owner, [:none]
    end

  end
```

### Configuration

```ruby
  #config/initializers/access_schema.rb

  AccessSchema.configure do

    schema :policy, AccessSchema.build_file('config/policy.rb')
    schema :acl, AccessSchema.build_file('config/acl.rb')

    logger Rails.logger

  end

```

### Accessing from Rails application code

Define a helper:

```ruby
  #access_schema_helper.rb

  class AccessSchemaHelper

    # Use ACL in controllers:
    #
    #   before_filter { required! :reviews, :delete }
    #
    # and views
    #
    #   - if can? :reviews, :delete, :subject => review
    #     = link_to "Delete", review_path(review)
    #

    def required!(route_method, action = nil, options = {})

      url_options = send "hash_for_#{route_method}_path"
      resource = "#{url_options[:controller].to_s.camelize}Controller"

      privilege = action || url_options[:action]
      acl.require! resource, privilege, options

    end

    def can?(*args)
      required!(*args)
    rescue AccessSchema::NotAllowed => e
      false
    else
      true
    end

    def acl

      AccessSchema.schema(:acl).with_options({
        roles: current_roles,
        user_id: current_user.try(:id)
      })

    end

    # Use in controllers and views
    # tarifF plans or other domain logic policies
    #
    #   policy.allow? review, :add_photo
    #


    def policy

      # Policy have to check actor roles and subject owner state (tariff plans for example)
      # to evaluate permission. So we pass proc and deal with particular subject to
      # calculate roles.
      #
      roles_calculator = proc do |options|

        plan = options[:subject].try(:owner).try(:plan)
        plan ||= [ current_user.try(:plan) || :none ]
        current_roles | plan

      end

      AccessSchema.schema(:policy).with_options({
        roles: roles_calculator,
        user_id: current_user.try(:id)
      })

    end

  end

```

But there are no current_user method in a Service Layer! So pass an extra option - actor:

```ruby
  #./app/services/base_service.rb
  class BaseService

    def policy(actor)

      roles_calculator = proc do |options|

        plan = options[:subject].try(:owner).try(:plan)
        plan ||= [ actor.try(:plan) || :none ]
        current_roles | plan

      end

      AccessSchema.schema(:policy).with_options({
        roles: roles_calculator,
        user_id: actor.try(:id)
      })
    end

  end

  #./app/services/review_service.rb

  class ReviewService < BaseSevice

    def mark_featured(review_id, actor)

      review = Review.find(review_id)
      policy(actor).require! review, :mark_featured

      review.featured = true
      review.save!

    end

    def update(review_id, attrs, actor)

      review = Review.find(review_id)
      policy(actor).require! review, :edit, :attrs => attrs

      review.update_attributes(attrs)

    end

  end

```

