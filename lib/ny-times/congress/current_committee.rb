module NYTimes
  module Congress
    class CurrentCommittee < Base
      include AttributeTransformation
      attr_reader :attributes, :id

      ATTRIBUTE_MAP = { 
        :string_for  =>  [:id, :name, :url, :democratic_rss, :democratic_rss,
                          :api_uri, :chair, :chair_id, :chair_party, :chair_state,
                          :chair_uri, :ranking_member_id]
      }
      ATTRIBUTES = ATTRIBUTE_MAP.values.flatten
      ATTRIBUTES.each {|attribute| define_lazy_reader_for_attribute_named(attribute) }

      def initialize(args={})
        prepare_arguments(args)
        @attributes = {}
        @transformed_arguments.each_pair {|name, value| attributes[name.to_sym] = value }
      end

      def to_s
        id
      end

      private
      def fully_loaded?
        fully_loaded
      end

      def load_fully
        # Need to implement
      end

      def prepare_arguments(hash)
        args = hash.dup
        @id = args['id']
        raise ArgumentError, "could not assign ID" unless @id.is_a?(String)
        @transformed_arguments = transform(args, ATTRIBUTE_MAP)
      end

    end
  end
end
