#!/usr/bin/env ruby
# command line tweeting script

require 'rubygems'
require 'rest_client'
require 'httparty'

class Tweet
   include HTTParty
   base_uri 'ip-address.domaintools.com'
   TwitterPostUrl = "http://twitter.com/statuses/update.xml"
   
   def initialize(accountname, message)
      @account = accountname

      @message = accountname=="mikeslaptop" ? getlocation(massage(message)) : massage(message)
      ##@message = accountname=="mytesttweets" ? getlocation(massage(message)) : massage(message)
      
      if @message.length > 140 
         puts "\nlength exceeded 140 character limit (#{@message.length.to_s}), try again\n"
      else
         # lookup account info from YAML file
         path = File.join(File.join(ENV['HOME'], ".twitter"), "tweetlist.yml")
         tweetlist = YAML::load_file(path)
         @pw = tweetlist[@account]['password']
      end
   end

   def massage(msg)
      mess = msg.gsub(/\$/, '\$')
   end
   
   def getlocation(mess)
      response = self.class.get('/myip.xml')
      dnstools = response['dnstools']
      isp      = dnstools['isp']
      city     = dnstools['city']
      state    = dnstools['region']
      ip       = dnstools['ip_address']
      location = "#{city}, #{state}"

      # type message like "Yamato Road, Boca Raton" to identify the store
      location = get_panera(mess) if isp =~ /^Nuvox/

      # all Broward and PB County courthouses say FTL and Bellsouth
      location = get_courthouse(mess) if isp =~ /^Bellsouth/ && city == "Ft. Lauderdale"

      return "Hello from #{location}. I'm tweeting from #{isp} as #{ip}"
   end
   
   def update
      if @message.length < 141
         RestClient.log = "stdout"
         resource  = RestClient::Resource.new(TwitterPostUrl, :user => @account, :password => @pw)
         resource.post :status => @message
         puts "tweet to #{@account}: #{@message}"
      end
   end

   private

   def get_panera(where)
      store = "Panera Bread Company "
      panera = {
         "militarytrail" => "Military Trail, Boca Raton FL",
         "towncenter"	=> "Military Trail, Boca Raton FL",
         "yamato"	=> "Yamato Road, Boca Raton FL",
         "glades"	=> "Glades & 441, Boca Raton FL",
         "delray"	=> "US1, Delray Beach FL",
         "delraybeach"	=> "US1, Delray Beach FL",
         "copans"	=> "Copans Road, Pompano Beach FL",
         "coralsprings"	=> "University Dr. Coral Springs FL",
         "university"	=> "University Dr. Coral Springs FL",
         "boyntonbeach"	=> "Boynton Beach Mall",
         "boynton"	=> "Boynton Beach Mall"
      }
      return store + panera[where]
   end

   def get_courthouse(where)
      courthouse = {
         "broward" => "Broward Courthouse, Ft. Lauderdale",
         "fortlauderdale" => "Broward Courthouse, Ft. Lauderdale",
         "ftl" => "Broward Courthouse, Ft. Lauderdale",
         "deerfield" => "Broward Courthouse, Deerfield Beach",
         "hollywood" => "Broward Courthouse, Hollywood FL",
         "wpb" => "West Palm Beach Courthouse",
         "westpalmbeach" => "West Palm Beach Courthouse"
      }
      return courthouse[where]
   end

end

tweet = Tweet.new(ARGV[0], ARGV[1]).update
