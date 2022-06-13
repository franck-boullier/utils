# This function will create an random string based on:
#   - The list of possible characters we have defined
#   - Requires a parameter `length` : the length of the string we want to generate.
#

# We drop the function first.
DROP FUNCTION IF EXISTS `generate_string`;

# We create the function
# It will:
#   - Accept a parameter `stringLength`: a SMALLINT(3)
#   - Return a value as a VARCHAR (100) using the utf8mb4 Character Set.
DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `generate_string`(stringLength SMALLINT(3))
    RETURNS VARCHAR(100) CHARSET utf8mb4
BEGIN
    # The string is empty at first
    SET @randomString = '';
    # Configure the allowed chars
    SET @allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    # Check the length of the list of Characters we can pick from
    SET @lenghtAllowedChar = LENGTH(@allowedChars);
    # Start a counter for the loop
    SET @i = 0;
    # Generate a random string and add it to the variable that contains the random string
    # Do this until we have reached the desired length
    WHILE (@i < stringLength) DO
	# Select a Random number between 1 and the max length of character list
	SET @whichtStringNumber = (SELECT FLOOR(1 + RAND()*(@lenghtAllowedChar-1)));
	# Extract the String we want to add
	SET @addedString = SUBSTRING(@allowedChars, @whichtStringNumber, 1);
	# Add the new string to the variable
        SET @randomString = CONCAT(@randomString, @addedString);
        # Increment the loop
        SET @i = @i + 1;
    END WHILE;

    # The function returns the random string
    RETURN @randomString;

END $$

DELIMITER ;
