dbdir: first .z.x

([getInMemoryTables; buildPersistedDB]): use `$"...capmkts";

fail: {-2 x;'`failed}

PWD: first system "pwd";

testInMemoryTables: {[(trade; quote; nbbo; master; exnames)]
  / Check if all tables have data
  if[not all count each (trade; quote; nbbo; master; exnames);
    fail "empty table(s) found"];

  /check attributes
  if[not all `g = {meta[x][`sym]`a} each (trade; quote; nbbo);
     fail "missing `g attribute from `sym"];

  if[not all `s = {meta[x][`time]`a} each (trade; quote; nbbo);
    fail "missing `s attribute from `time"];

  / Check if we can run some basic queries
  if[0=count asc select sum size by exch: exnames ex from trade;
    fail "simple select failed"];
  if[0=count aj[`sym`time; select from trade where sym in `MSFT`GOOG`AMZN; select sym, time, bid, ask from quote];
    fail "aj failed"];
  }

testPersistedTables: {[dbdir]
  system "l ", dbdir;
  if[not all `daily`exnames`master`sym in key hsym `$dbdir;
    fail "Missing files from DB root"];
  / Check if all tables have data
  if[not all count each (trade; quote; nbbo; master; exnames);
    fail "empty table(s) found"];

  /check attributes
  if[not all `p = {meta[x][`sym]`a} each (trade; quote; nbbo);
    fail "missing `p attribute from `sym"];

  / Check if we can run some basic queries
  if[0=count asc select sum size by exch: exnames ex from trade where date=max date;
    fail "simple select failed"];
  if[0=count aj[`sym`time; select from trade where date=min date, sym in `MSFT`GOOG`AMZN; select sym, time, bid, ask from quote where date=min date];
    fail "aj failed"];
  }

///////////////////////////////////////////////////////////
testInMemoryTables getInMemoryTables[]

/ Check if we can pass trades per day parameter
testInMemoryTables getInMemoryTables[2000]

res: .[getInMemoryTables;(2000; `dummyparameter); ::]
if[not res like "Too many parameters passed to getInMemoryTables";
  fail "Too many parameters check failure"];

res: @[getInMemoryTables; `notadictionary; ::]
if[not res like "A numeric or a dictionary is expected as optional parameter";
  fail "Dictionary type check failure"];

res: @[getInMemoryTables; ([tradesPerDay: 2000; invalidkey: 3]); ::]
if[not res like "Unknown parameter(s): invalidkey";
  fail "Invalid parameter check failure"];

/ Check if we can pass exchange open/close times of different formats (minute vs second)
exchopen: 10:00;
exchclose: 15:00:00;
testInMemoryTables (trade;;;;): getInMemoryTables ([tradesPerDay: 2000; exchopen; exchclose])
if[count select from trade where time<exchopen;
  fail "trade before exchopen"];

if[count select from trade where time>exchclose;
  fail "trade after exchclose"];

-1 "All in-memory tests passed";
///////////////////////////////////////////////////////////

-1 "DB directory: ", dbdir;

buildPersistedDB dbdir;
testPersistedTables dbdir;
system "cd ", PWD;
system "rm -rf ", dbdir;

buildPersistedDB[dbdir; 2000];
testPersistedTables dbdir;
system "cd ", PWD;
system "rm -rf ", dbdir;

res: .[buildPersistedDB; (dbdir; ()!(); `dummyparameter); ::]
if[not res like "Too many parameters passed to buildPersistedDB";
  fail "Too many parameters check failure"];

res: .[buildPersistedDB; (dbdir; `notadictionary); ::]
if[not res like "A numeric or a dictionary is expected as optional parameter";
  fail "Type check failure"];

res: .[buildPersistedDB; (dbdir; ([tradesPerDay: 2000; invalidkey: 3])); ::]
if[not res like "Unknown parameter(s): invalidkey";
  fail "Invalid parameter check failure"];

segdirs: first system "mktemp -d";
-1 "segmented directory pattern: ", segdirs,"{}";
segmentNr: 4;
buildPersistedDB[dbdir; ([tradesPerDay:2000; segmentNr; segmentPattern: segdirs,"{}"])];
testPersistedTables dbdir;
system "cd ", PWD;
system "rm -rf ", dbdir;
system "rm -rf ", " " sv segdirs,/:string til segmentNr;

///////////////////////////////////////////////////////////
-1 "All persistent DB tests passed";

if[not "-debug" in .z.x; exit 0]