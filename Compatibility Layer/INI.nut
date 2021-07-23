// Wrapper functions for offical Ini plugin
// ------------------------------------------------------- //

function ReadIniBool(fn, sec, key) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    return Doc.GetBoolean(sec, key, false);
}

function ReadIniInteger(fn, sec, key) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    return Doc.GetInteger(sec, key, 0);
}

function ReadIniNumber(fn, sec, key) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    return Doc.GetFloat(sec, key, 0.0);
}

function ReadIniString(fn, sec, key) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    return Doc.GetValue(sec, key, "");
}

function WriteIniBool(fn, sec, key, value) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    Doc.SetBoolean(sec, key, value);
    Doc.SaveFile(fn, true);
}

function WriteIniInteger(fn, sec, key, value) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    Doc.SetInteger(sec, key, value);
    Doc.SaveFile(fn, true);
}

function WriteIniNumber(fn, sec, key, value) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    Doc.SetFloat(sec, key, value);
    Doc.SaveFile(fn, true);
}

function WriteIniString(fn, sec, key, value) 
{ 
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    Doc.SetValue(sec, key, value);
    Doc.SaveFile(fn, true);
}

function RemoveIniValue(fn, sec, key)
{
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    Doc.DeleteValue(sec, key);
    Doc.SaveFile(fn, true);
}

function DeleteIniSection(fn, sec)
{
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    Doc.DeleteValue(sec);
    Doc.SaveFile(fn, true);
}

function CountIniSection(fn, sec)
{
    local Doc = SqIni.IniDocument();
    Doc.LoadFile(fn);

    return Doc.GetSectionSize(sec);
}