require File.join( File.dirname(__FILE__), "orm", "dm_ext")

module MerbSeed
  class Seeder
    def self.plant(model_class, *constraints, &block)
      constraints = [:id] if constraints.empty?
      seed = Seeder.new(model_class)

      options = constraints.last if (constraints.last.is_a? Hash)
      constraints.delete_at(*constraints.length-1) if (constraints.last.is_a? Hash)

      insert_only = constraints.last.is_a? TrueClass
      constraints.delete_at(*constraints.length-1) if (constraints.last.is_a? TrueClass or constraints.last.is_a? FalseClass)
      seed.set_constraints(*constraints)
      yield seed
      seed.plant!({:insert_only => insert_only}.merge(options||{}))
    end

    def initialize(model_class)
      @model_class = model_class
      @constraints = [:id]
      @data = {}
    end

    def set_constraints(*constraints)
      raise "You must set at least one constraint." if constraints.empty?
      @constraints = []
      constraints.each do |constraint|
        raise "Your constraint `#{constraint}` is not a column in #{@model_class}. Valid columns are `#{@model_class.column_names.join("`, `")}`." unless @model_class.column_names.include?(constraint.to_s)
        @constraints << constraint.to_sym
      end
    end

    def set_attribute(name, value)
      @data[name.to_sym] = value
    end
    
    def after_seed(&block)
      if block
        @after_seed_block = block
      else
        @after_seed_block
      end
    end

    def plant!(options)
      insert_only = options[:insert_only].nil? ? false : options[:insert_only]

      record = get
      return if !record.new_record? and insert_only
      @data.each do |k, v|
        record.send("#{k}=", v)
      end
      record.save || raise("Validation Failed. Use :validate => false in order to skip this:\n#{record.errors.inspect}")
      puts " - #{@model_class} #{condition_hash.inspect}"      
      
      # fire off after_seed event
      self.after_seed.call(record) if self.after_seed
      
      record
    end

    def method_missing(method_name, *args) #:nodoc:
      if (match = method_name.to_s.match(/(.*)=$/)) && args.size == 1
        set_attribute(match[1], args.first)
      else
        super
      end
    end

    protected

    def get
      records = @model_class.all(:conditions => condition_hash)
      raise "Given constraints yielded multiple records." unless records.size < 2
      if records.any?
        return records.first
      else
        return @model_class.new
      end
    end

    def condition_hash
      @data.reject{|a,v| !@constraints.include?(a)}
    end
  end
end