#!/opt/local/bin/ruby

# command line tweeting script

require 'rubygems'
require 'rest_client'
require 'httparty'

class Tweet
   include HTTParty
   base_uri 'ip-address.domaintools.com'
   @verbose = true
   
   def initialize(accountname, message)
      @account = accountname
      @msg = accountname == "mikeslaptop" ? getlocation(message) : message
      if @msg.length > 141 
         puts "\nlength exceeded 140 character limit (#{@msg.length.to_s}), try again\n"
      else
         # lookup account info from YAML file
         path = File.join(File.join(ENV['HOME'], ".twitter"), "tweetlist.yml")
         tweetlist = YAML::load_file(path)
         @password = tweetlist[@account]['password']
         puts "acct is #{@account} and password is #{@password}" if @verbose
      end
   end
   
   def getlocation(mess)
      response = self.class.get('/myip.xml')
      dnstools = response['dnstools']
      city     = dnstools['city']
      state    = dnstools['region']
      isp      = dnstools['isp']
      ip       = dnstools['ip_address']
      location = "#{city}, #{state}"
      return "Hello from #{mess} in #{location}. I'm tweeting from #{isp} as #{ip}"
   end
   
   def update
      if @msg.length < 141
         RestClient.log = "stdout"
         resource  = RestClient::Resource.new("http://twitter.com/statuses/update.xml", 
                                       :user     => @account, 
                                       :password => @password)
         resource.post :status => @msg
         puts "message posted: #{@msg}" if @verbose
      end
   end
end

tweet = Tweet.new(ARGV[0], ARGV[1]).update
