module NYTimes
	module Congress
		class Congress < Base
		  attr_reader :number, :session, :chamber
		  
		  include AttributeTransformation
      
      def initialize(number, chamber, session = nil)
        @number, @session = integer_for(number), integer_for(session)
        @chamber = symbol_for(chamber)
        raise AttributeError unless number && chamber
      end
      
      def members(params = {})        
        @members ||= fetch_members(Base.invoke("#{api_path}/members.json")['results'].first['members'])
      end
      
      def self.new_members(params = {})
        Congress.fetch_new_members
      end
      
      def current_member_for_state_district(state, district=nil)
        if district
          api_path = "members/house/#{state}/#{district}/current.json"
        else
          api_path = "members/senate/#{state}/current.json"
        end
        response = Base.invoke(api_path)['results']
        fetch_current_members(response)
      end

      def current_members
        fetch_current_members(Base.invoke("#{api_path}/members.json")['results'].first['members'])
      end

      def current_committees
        fetch_current_committees(Base.invoke("#{api_path}/committees.json")["results"].first["committees"])
      end

      
      def roll_call_vote(session_number, roll_call_number, params = {})
        results = Base.invoke("#{api_path}/sessions/#{session_number}/votes/#{roll_call_number}.json")['results']['votes']
        RollCallVote.new(results)
      end
      
      def to_s
        "#{number} #{chamber.upcase}"
      end
      
      def compare(legislator_1, legislator_2)
        response = Base.invoke("members/#{legislator_1}/compare/#{legislator_2}/#{number}/#{chamber}.json")
        if response 
          LegislatorVoteComparison.new(response['results'].first)
        end
      end
      
      def votes(type)
        members = fetch_members_by_type(Base.invoke("#{number}/#{chamber}/votes/#{type}.json")['results'].first['members'])
      end
      
      def bills(type)
        bills = bills_for(Base.invoke("#{number}/#{chamber}/bills/#{type}.json")['results'].first['bills'])
      end
      
      protected
      
      def fetch_members(results)
  			results.inject({}) do |hash, member| 
  			  hash[member['id']] = Legislator.new(member)
  			  hash
  			end
      end

      def fetch_current_members(results)
    		results.inject({}) do |hash, member|
    			hash[member['id']] = CurrentMember.new(member)
    			hash
    		end
      end

      def fetch_current_committees(results)
        results.inject({}) do |hash, committee|
          hash[committee['id']] = CurrentCommittee.new(committee)
          hash
        end
      end
      
      def fetch_members_by_type(results)
        h = Hash.new
  			results.each do |member|
  			  h[member['id']] = MemberVoteType.new(member)
  			  h
  			end
      end

      def self.fetch_new_members
        results = Base.invoke("/members/new.json")['results'].first
  			results['members'].inject({}) do |hash, member|
  			  hash[member['id']] = Legislator.new(member)
  			  hash
  			end
      end
      
      def api_path
        "#{number}/#{chamber}"
      end        
    end
    
  end
end
