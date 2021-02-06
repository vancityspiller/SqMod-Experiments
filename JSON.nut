// ------------------------------------------------------- //

/*
*   The parser wasn't working for me,
* 	so I made this.
*
*	(~) Spiller
*/

// ------------------------------------------------------- //

class JSON 
{
	static function Parse(String_)
	{
		local Table = null;

		// remove any whitespace
		String_ = strip(String_);

		// JSON notation is supported 
		// for squirrel tables
		Table 	= ::compilestring(format("return %s", String_));

		// return the table
		return Table();
	}

	// ------------------------------------------------------- //

	static function ParseFile(String_)
	{
		// Read from file
		local 	Reader 	= file("config.json", "rb"), Data = "",
				Blob_ 	= Reader.readblob(Reader.len());

		// And store it in "Data"
		for(local i = 0 ; i < Reader.len() ; i++)
		Data += format("%c", Blob_.readn('b'));

		Reader.close();

		// Forward the string
		return Parse(Data);
	}

	// ------------------------------------------------------- //

	static function Stringify(Table_)
	{
		// String to store the data into
		local String_ = "{";

		String_ += Recurse(Table_);

		// Remove the extra ","
		if(String_.slice(String_.len() - 1) == ",")
		String_ = String_.slice(0, String_.len() - 1);

		// Close the string
		String_ += "}";

		// Return the result
		return String_;
	}

	static function Recurse(Table)
	{
		local String_ = "";
		foreach (Key, Value in Table) 
		{
			switch(typeof(Value))
			{
				case "array":
				{
					String_ += format("\"%s\": [", Key);
					String_ += Recurse(Value);
					String_ += "]";
					break;
				}

				case "table":
				{
					String_ += format("\"%s\": {", Key);
					String_ += Recurse(Value);
					String_ += "}";
					break;
				}

				case "bool":
				{
					String_ += format("\"%s\": %s", Key, Value ? "true" : "false");
					break;
				}

				case "null":
				{
					String_ += format("\"%s\": %s", Key, "null");
					break;
				}

				case "string":
				{
					String_ += format("\"%s\": \"%s\"", Key, Value);
					break;
				}

				default:
				String_ += format("\"%s\":", Key) + Value;
			}

			String_ += ",";
		}

		String_ = String_.slice(0, String_.len() - 1);
		return String_;
	}
}

// ------------------------------------------------------- //