class JSON
{
    static VERSION = "2.0.0";

    // max structure depth
    // anything above probably has a cyclic ref
    static _maxDepth = 32;

    // ------------------------------------------------------- //
    
	static function Parse(String) {
        return SqFromJSON(String);
	}

	// ------------------------------------------------------- //

	static function ParseFile(Path)
	{
		// Read from file
		local Data = SqStream.FileToString(Path);

		// Forward the string
		return Parse(Data);
	}

    // Functions below are taken from:
    // ------------------------------------------------------- //
    // Copyright (c) 2017 Electric Imp
    // This file is licensed under the MIT License
    // http://opensource.org/licenses/MIT

    static function Encode(Value)
	{
        /**
        * Encode to JSON string
        * @param {table|array|*} Value
        * @returns {string}
        */
		return this._encode(Value);
	}

    // ------------------------------------------------------- //

    static function _encode(val, depth = 0)
    {
        /**
        * @param {table|array} val
        * @param {integer=0} depth – current depth level
        * @private
        */
        
        // detect cyclic reference
        if (depth > this._maxDepth) throw "Possible cyclic reference";

        local
        r = "",
        s = "",
        i = 0;

        switch (typeof val) 
        {
            case "table":
            case "class":
            {
                s = "";

                // serialize properties, but not functions
                foreach (k, v in val) {
                    if (typeof v != "function") {
                        s += ",\"" + k + "\":" + this._encode(v, depth + 1);
                    }
                }

                s = s.len() > 0 ? s.slice(1) : s;
                r += "{" + s + "}";
                break;
            }

            case "array":
            {
                s = "";

                for (i = 0; i < val.len(); i++) {
                    s += "," + this._encode(val[i], depth + 1);
                }

                s = (i > 0) ? s.slice(1) : s;
                r += "[" + s + "]";
                break;
            }

            case "integer":
            case "float":
            case "bool":
                r += val;
                break;

            case "null":
                r += "null";
                break;

            case "instance":
            {
                if ("_serializeRaw" in val && typeof val._serializeRaw == "function") {

                    // include value produced by _serializeRaw()
                    r += val._serializeRaw().tostring();

                } else if ("_serialize" in val && typeof val._serialize == "function") {

                // serialize instances by calling _serialize method
                r += this._encode(val._serialize(), depth + 1);

                } else {

                s = "";

                try {

                    // iterate through instances which implement _nexti meta-method
                    foreach (k, v in val) {
                        s += ",\"" + k + "\":" + this._encode(v, depth + 1);
                    }

                } catch (e) {

                    // iterate through instances w/o _nexti
                    // serialize properties, but not functions
                    foreach (k, v in val.getclass()) {

                        if (typeof v != "function") {
                            s += ",\"" + k + "\":" + this._encode(val[k], depth + 1);
                        }
                    }

                }

                s = s.len() > 0 ? s.slice(1) : s;
                r += "{" + s + "}";
                }

                break;
            }

            case "blob":
            {
                // This is a workaround for a known bug:
                // on device side Blob.tostring() returns null
                // (instaead of an empty string)
                r += "\"" + (val.len() ? this._escape(val.tostring()) : "") + "\"";
                break;
            }

            // strings and all other
            default:
                r += "\"" + this._escape(val.tostring()) + "\"";
                break;
        }

        return r;
    }

    // ------------------------------------------------------- //
    
    function _escape(str) 
    {
        /**
        * Escape strings according to http://www.json.org/ spec
        * @param {string} str
        */

        local res = "";

        for (local i = 0; i < str.len(); i++) 
        {
            local ch1 = (str[i] & 0xFF);

            if ((ch1 & 0x80) == 0x00) 
            {
                // 7-bit Ascii

                ch1 = format("%c", ch1);

                if (ch1 == "\"") {
                    res += "\\\"";
                } else if (ch1 == "\\") {
                    res += "\\\\";
                } else if (ch1 == "/") {
                    res += "\\/";
                } else if (ch1 == "\b") {
                    res += "\\b";
                } else if (ch1 == "\f") {
                    res += "\\f";
                } else if (ch1 == "\n") {
                    res += "\\n";
                } else if (ch1 == "\r") {
                    res += "\\r";
                } else if (ch1 == "\t") {
                    res += "\\t";
                } else if (ch1 == "\0") {
                    res += "\\u0000";
                } else {
                    res += ch1;
                }

            } 
            else 
            {
                if ((ch1 & 0xE0) == 0xC0) 
                {
                    // 110xxxxx = 2-byte unicode
                    local ch2 = (str[++i] & 0xFF);
                    res += format("%c%c", ch1, ch2);
                } 
                else if ((ch1 & 0xF0) == 0xE0) 
                {
                    // 1110xxxx = 3-byte unicode
                    local ch2 = (str[++i] & 0xFF);
                    local ch3 = (str[++i] & 0xFF);
                    res += format("%c%c%c", ch1, ch2, ch3);
                } 
                else if ((ch1 & 0xF8) == 0xF0) 
                {
                    // 11110xxx = 4 byte unicode
                    local ch2 = (str[++i] & 0xFF);
                    local ch3 = (str[++i] & 0xFF);
                    local ch4 = (str[++i] & 0xFF);
                    res += format("%c%c%c%c", ch1, ch2, ch3, ch4);
                }
            }
        }

        return res;
    }
}

// ------------------------------------------------------- //