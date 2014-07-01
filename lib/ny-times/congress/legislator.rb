module NYTimes
  module Congress
    class Legislator < Base
      include AttributeTransformation
      attr_reader :attributes, :id

      ATTRIBUTE_MAP = { 
        :date_for    =>  [:date_of_birth, :start_date],
        :roles_for   =>  [:roles],
        :appearances_for => [:appearances],
        :integer_for =>  [:govtrack_id, :district, :seniority, :cspan_id, :next_election, :thomas_id],
        :string_for  =>  [:url, :state, :gender, :first_name, :middle_name, :last_name, :name, :current_party, :missed_votes_pct, :votes_with_party_pct, :twitter_id, :youtube_id, :facebook_account, :party, :twitter_account ] 
      }
      ATTRIBUTES = ATTRIBUTE_MAP.values.flatten
      ATTRIBUTES.each {|attribute| define_lazy_reader_for_attribute_named(attribute) }

      def self.find(id)
        response = invoke("members/#{id}.json")
        new(response['results'].first)
      end

      def initialize(args={})
        prepare_arguments(args)
        @attributes = {}
        @transformed_arguments.each_pair {|name, value| attributes[name.to_sym] = value }
        @fully_loaded = false
      end

      def to_s
        id
      end

      def positions
        @positions ||= fetch_positions
      end
      alias votes positions

      def appearances
        @appearances ||= fetch_appearances
      end

      def bills(type)
        if type == 'introduced'
          @bills_introduced ||= fetch_bills(type)
        elsif type == 'updated'
          @bills_updated ||= fetch_bills(type)
        end
      end

      private
      attr_reader :fully_loaded

      def prepare_arguments(hash)
        args = hash.dup
        @id = args.delete('member_id') || args.delete('id')
        raise ArgumentError, "could not assign ID" unless @id.is_a?(String)
        @transformed_arguments = transform(args, ATTRIBUTE_MAP)
      end

      def fully_loaded?
        fully_loaded
      end

      def load_fully
        full_legislator = Legislator.find(id)
        attributes.merge!(full_legislator.attributes)
        @fully_loaded = true
      end

      def fetch_positions
        response = Base.invoke("members/#{id}/votes.json")
        response = response['results'].first['votes']
        positions_for(response)
      end

      def fetch_appearances
        response = Base.invoke("members/#{id}/floor_appearances.json")
        response = response['results'].first['appearances']
        appearances_for(response)
      end

      def fetch_bills(type)
        response = Base.invoke("members/#{id}/bills/#{type}.json")
        response = response['results'].first['bills']
        bills_for(response)
      end

      #end of private methods
    end
  end
end
