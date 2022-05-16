require 'ox'

module UPS
  module Builders
    class PackageBuilder < BuilderBase
      include Ox

      attr_accessor :name, :opts

      def initialize(name, opts = {})
        self.name = name
        self.opts = opts
      end

      def packaging_type(packaging_options_hash)
        code_description 'PackagingType', packaging_options_hash[:code], packaging_options_hash[:description]
      end

      def reference_number
        Element.new('ReferenceNumber').tap do |org|
          org << element_with_value('Code', opts[:reference_number][:type]) if opts[:reference_number][:type]
          org << element_with_value('Value', opts[:reference_number][:value])
        end
      end

      def reference_number_2
        Element.new('ReferenceNumber').tap do |org|
          org << element_with_value('Code', opts[:reference_number_2][:type]) if opts[:reference_number_2][:type]
          org << element_with_value('Value', opts[:reference_number_2][:value])
        end
      end

      def description
        element_with_value('Description', 'Rate')
      end

      def package_weight(weight, unit)
        Element.new('PackageWeight').tap do |org|
          org << unit_of_measurement(unit)
          org << element_with_value('Weight', weight)
        end
      end

      def customer_supplied_packaging
        { code: '02', description: 'Customer Supplied Package' }
      end

      def package_dimensions(dimensions)
        Element.new('Dimensions').tap do |org|
          org << unit_of_measurement(dimensions[:unit])
          org << element_with_value('Length', dimensions[:length].to_s[0..8])
          org << element_with_value('Width', dimensions[:width].to_s[0..8])
          org << element_with_value('Height', dimensions[:height].to_s[0..8])
        end
      end

      def package_delivery_confirmation(dcis_type)
        Element.new('PackageServiceOptions').tap do |element|
          element << Element.new('DeliveryConfirmation').tap do |delivery_confirmation|
            delivery_confirmation << element_with_value('DCISType', dcis_type)
          end
        end
      end

      def to_xml
        Element.new(name).tap do |product|
          product << reference_number if opts[:reference_number]
          product << reference_number_2 if opts[:reference_number_2]
          product << packaging_type(opts[:packaging_type] || customer_supplied_packaging)
          product << description
          product << package_weight(opts[:weight], opts[:unit])
          product << package_dimensions(opts[:dimensions]) if opts[:dimensions]
          product << package_delivery_confirmation(opts[:delivery_confirmation]) if opts[:delivery_confirmation]
        end
      end
    end
  end
end
