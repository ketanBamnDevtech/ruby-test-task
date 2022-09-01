# frozen_string_literal: true

# app/serializer.rb
class Serializer
  @@attrs = {}

  attr_reader :object, :serializable

  def initialize(object)
    @object = object
    @serializable = self.class.name
  end

  def serialize
    serializable_hash.transform_values do |value|
      serialize_field(value)
    end
  end

  def serialize_field(value)
    case value
    when Symbol  then object.send(value)
    when String  then object.send(value.to_sym)
    when Proc    then instance_exec(&value)
    else
      value
    end
  end

  def serializable_hash
    @@attrs[serializable]
  end

  def self.attribute(*fields, &block)
    fields.each do |field|
      scoped_attributes[field.to_sym] = block_given? ? block : field
    end
  end

  def self.scoped_attributes
    @@attrs[name] ||= {}
  end
end
