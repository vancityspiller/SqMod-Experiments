// Wrapper functions for offical MySQL plugin
// ------------------------------------------------------- //

function mysql_connect(h, u, p, n)
{
    local a = MySQL.Account(h, u, p, n);
    return a.Connect();
}
function mysql_close(db) { db.Disconnect(); return true; }

function mysql_error(db) { return db.LastErrStr; }
function mysql_errno(db) { return db.LastErrNo; }

function mysql_query(db, qs) 
{
    local qs_ = SqString(qs).ToLower().Trim();

    // check what kind of query it is
    if(qs_.StartsWith("select"))
    {
        local st = db.Query(qs);
        return st.Step() ? st : null;
    }

    if(qs_.StartsWith("insert"))
    return db.Insert(qs);

    return db.Execute(qs);    
}

function mysql_num_rows(st) { return st.RowCount; }
function mysql_fetch_assoc(st) 
{ 
    local rs = st.FieldsTable, result = {};

    // build up a table manually with string values
    foreach(key, val in rs)
    result.rawset(key, val.String);

    // need to step to next row as in mysql plugin
    st.Step();
    return result;    
}
function mysql_fetch_row(st) 
{ 
    local rs = st.FieldsArray, result = [];

    // build up an array manually with string values
    foreach(val in rs)
    result.append(val.String);

    // need to step to next row as in mysql plugin
    st.Step();
    return result;    
}

function mysql_escape_string(db, s) { return db.EscapeString(s); }
function mysql_free_result(st) { /*nothing to do. cleans itself up*/ }