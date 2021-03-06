module SpreeYandexKassa
  class Engine < Rails::Engine
    require 'offsite_payments'
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_yandex_kassa'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    # Default yandex_kassa_identity field
    config.yandex_kassa_identity = 'email'

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      ActionView::Base.send(:include, OffsitePayments::ActionViewHelper)
      config.after_initialize do |app|
        app.config.spree.payment_methods << Spree::BillingIntegration::YandexkassaIntegration
      end
    end

    initializer "spree.yandex_kassa", :after => "spree.environment" do |app|
      Spree::PermittedAttributes.taxon_attributes << :category_code
    end

    config.to_prepare &method(:activate).to_proc
  end
end
