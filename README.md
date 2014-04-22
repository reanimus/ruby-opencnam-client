# Simple Ruby OpenCNAM Client

This is a simple OpenCNAM client written in ruby using nysa/ruby-opencnam.

It's really nothing incredilby complex, but I figured it was worth sharing with anyone interested in a simple implementation.

## Usage

```
Usage: cnam.rb [options] PHONENUMBER
    -a, --authenticate               Authenticate with OpenCNAM API using built-in credentials.
        --disable-ssl                Don't use SSL for requests (not recommended)
    -s, --sid SID                    Set OpenCNAM Account SID
    -t, --token TOKEN                Set OpenCNAM Auth Token
    -v, --verbose                    Output verbose lookup results
```

## Configuration

It's ready to use right out the box. Just make sure ruby-opencnam is installed, then run it. If you only provide a number, it'll look it up as a Hobbyist Tier lookup. You can use `-s` and `-t` to provide authentication info, or you can edit the script to add built in authentication credentials.

Toward the top, you'll see a place to set `auth_sid` and `auth_token`. Set these to use built in authentication. Otherwise, it'll throw an error when you use `-a`.