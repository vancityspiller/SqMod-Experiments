// Wrapper functions for offical SQLite plugin
// ------------------------------------------------------- //

function ConnectSQL(p) { return SQLite.Connection(p); }
function DisconnectSQL(p) { p.Release(); return true; }

function QuerySQL(db, qs)
{
    // trim any whitespace
    local qs_ = SqString(qs).Trim().ToLower();

    // check if the query selects records
    if(qs_.StartsWith("select"))
    {
        local st = db.Query(qs);
        return st.Step() ? st : null;
    }

    // if not, just execute it
    return db.Exec(qs);
}

function GetSQLNextRow(st) { return st.Step(); }
function GetSQLColumnCount(st) { return st.DataCount; }
function GetSQLColumnData(st, ci) { return st.Done ? null : st.GetValue(ci); }

function escapeSQLString(s) { return SqData.SQLiteEscapeString(s); }
function FreeSQLQuery(st) { /*nothing to do. cleans itself up*/ }
