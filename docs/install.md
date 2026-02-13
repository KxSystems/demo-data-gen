# datagen kdb-x installation

`datagen` is written as a module, under kdb-x's module framework. Though modules can be loaded from anywhere if added to your `$QPATH`, we recommend installing to the `$HOME/.kx/mod/kx` folder. This is to avoid name clashes with other user defined modules, as well as providing a location for other KX modules to cross reference each other.

```bash
export QPATH="$QPATH:$HOME/.kx/mod"
mkdir -p ~/.kx/mod/kx/
cp -r datagen ~/.kx/mod/kx/
```

Now from anywhere you can import the `datagen` library.

```q
q)([getInMemoryTables; buildPersistedDB]): use `kx.datagen.capmkts
q)(trade; quote; nbbo; master; exnames): getInMemoryTables[]
q)asc select sum size by exch: exnames ex from trade where date=last date
exch                                | size
------------------------------------| ------
"NASDAQ OMX PSX"                    | 49247
"The Investors' Exchange"           | 51202
"FINRA Alternative Display Facility"| 52043
```

Add the export to your `.bashrc` or equivalent to persist across sessions.
