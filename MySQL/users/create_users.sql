# Create the user `user`
# The user access MUST BE from the location `from_location`.
# This can be:#   - 'ip.address' the IP address that is connecting FROM.
#   - '%' for Anywhere or 
#   - 'localhost' if the Db is on the Same server <--- This is VERY unlikely.
# The authentication will be with the mysql native password 'my_strong_password'

CREATE USER 'user'@'from_location' 
    IDENTIFIED WITH sha256_password BY 'my_strong_password'
;
