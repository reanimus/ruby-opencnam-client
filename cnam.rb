#!/usr/bin/env ruby

# import argument parsing and OpenCNAM client lib
require 'optparse'
require 'opencnam'

#
# CONFIGURABLE: BUILT IN CREDENTIALS
#

auth_sid = 'AUTHSIDHERE'
auth_token = 'AUTHTOKENHERE'

#
# END CONFIGURABLE
#

# Spawn client
client = Opencnam::Client.new

# Let's be secure
client.use_ssl = true


options = {}
opts = OptionParser.new
opts.banner = "Usage: cnam.rb [options] PHONENUMBER"

# Switch to enable authentication
opts.on("-a", "--authenticate", "Authenticate with OpenCNAM API using built-in credentials.") do |a|
options[:auth] = a
end

# Switch to enable authentication
opts.on("--disable-ssl", "Don't use SSL for requests (not recommended)") do |d|
client.use_ssl = false
end

# Override built-in credentials
opts.on("-s", "--sid SID", "Set OpenCNAM Account SID") do |s|
options[:authsid] = s
end
opts.on("-t", "--token TOKEN", "Set OpenCNAM Auth Token") do |t|
options[:authtoken] = t
end

# Output timestamps, price, etc.
opts.on("-v", "--verbose", "Output verbose lookup results") do |v|
options[:verbose] = v
end
opts.parse!

# Parse authentication logic
if(options[:authsid] || options[:authtoken])

	# We have to have both
	if(options[:authsid] && options[:authtoken])
		client.account_sid = options[:authsid]
		client.auth_token = options[:authtoken]
	else
		# Bail if only one is set
		puts "[ERROR] If either Account SID or Auth Token is provided, both must be given."
		puts "[ERROR] Supply both -s/--sid and -t/--token"
		exit
	end
elsif(options[:auth])
	# Check if built-in auth has been configured.
	if(auth_sid == 'AUTHSIDHERE' || auth_token == 'AUTHTOKENHERE')
		puts '[ERROR] Your script file has no built in credentials.'
		puts '[ERROR] Add them at the top to enable built-in authentication.'
		exit
	end

	# Set the auth credentials
	client.account_sid =  auth_sid
	client.auth_token = auth_token
end

# Check if there are any arguments.
if ARGV.first
	begin
		# Check if we're being verbose; if so, get the JSON
		if(options[:verbose])

			# Look it up!
			lookup = client.phone(ARGV[0], :format => :json)

			# Dump info!
			puts 'Phone Number: ' + lookup[:number]
			puts 'Result: ' + lookup[:name]
			if(lookup[:created])
				puts 'Entry Created: ' + lookup[:created].asctime
			end
			if(lookup[:updated])
				puts 'Entry Updated: ' + lookup[:updated].asctime
			end
			if(lookup[:price])
				puts 'Lookup Cost: ' + lookup[:price].to_s
			end
		else

			# Look up, output basic info + results
			lookup = client.phone(ARGV[0], :format => :text)
			puts 'Phone Number: ' + ARGV.first
			puts 'Result: ' + lookup
		end
	rescue Opencnam::OpencnamError => e

		# Handle exceptions based on type; each is based on the HTTP return status
		# See https://www.opencnam.com/docs/v2/apiref#cnam-status-codes
		case e.message
		when 'FORBIDDEN'
			puts '[ERROR] You have reached the maximum number of free lookups per hour for Hobbyist users.'
			puts '[ERROR] Please use API Authentication.'
		when 'BAD REQUEST'
			puts '[ERROR] The phone number you looked up was invalid.'
		when 'UNAUTHORIZED'
			puts '[ERROR] API Authentication failed. Please verify your credentials.'
		when 'PAYMENT REQUIRED'
			puts '[ERROR] Your API account has insufficient funds for this lookup.'
			puts '[ERROR] Please go to https://www.opencnam.com/ to add more.'
		when 'NOT FOUND'
			puts 'There is no lookup information available for ' + ARGV.first
		else
			puts '[ERROR] The lookup failed with an unknown error: ' + e.message
		end
	end
else
	puts opts.help()
end

