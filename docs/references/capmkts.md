# Capital Market Data Generator

This module is designed to generate synthetic capital market data, including `trade`, `quote`, and `nbbo` tables, along with instrument and exchange metadata.

## Quickstart

The module provides two primary functions:

```q
([getInMemoryTables; buildPersistedDB]): use `kx.datagen.capmkts
```

To generate in-memory tables `trade`, `quote`, and `nbbo` along with metadata tables `master` and dictionary `exnames`, use the `getInMemoryTables` function:

```q
(trade; quote; nbbo; master; exnames): getInMemoryTables[]
```

To generate one month of date-partitioned data and store it in a directory (e.g., `testdb`), use the `buildPersistedDB` function:

```q
buildPersistedDB "testdb"
```

Once the data is generated, you can load it into a q session with 4 [worker threads](https://code.kx.com/kdb-x/reference/syscmds.html#s-number-of-secondary-threads) using the following command (or by `\l` in a running q session):

```bash
$ q testdb -s 4
```

You can then run queries on the loaded tables. For example:

```q
q)asc select sum size by exch: exnames ex from trade where date=last date
exch                                | size
------------------------------------| ------
"NASDAQ OMX PSX"                    | 49247
"The Investors' Exchange"           | 51202
"FINRA Alternative Display Facility"| 52043
..

q)aj[`sym`time; select from trade where date=first date, sym in `MSFT`GOOG`AMZN; select sym, time, bid, ask from quote where date=first date]
date       sym  time         price size stop cond ex bid   ask
----------------------------------------------------------------
2026.01.19 AMZN 09:30:00.226 92.01 58   0    V    A  91.12 92.06
2026.01.19 AMZN 09:30:00.500 91.96 75   0    Z    A  91.79 92.28
2026.01.19 AMZN 09:30:01.482 91.86 83   0    L    A  91.3  92.81
..
```

## Parameters

### Data Density/Volume

You can adjust the data density (and overall data volume) by specifying the approximate number of trades per day. Note that the exact number depends on various factors, such as the number of instruments.

```q
(trade; quote; nbbo; master; exnames): getInMemoryTables 10000
```

Similarly, for persistent data generation:

```q
buildPersistedDB["testdb"; 10000]
```

### Date Range (`start` and `end`)

The `buildPersistedDB` function allows you to specify the start and end dates for the data to be generated. These dates are passed as part of a dictionary in the third parameter. For example, to generate one year of data:

```q
buildPersistedDB["testdb"; 10000; ([start: 2025.01.01; end: 2025.12.31])]
```

### Segmented Database

Segmented databases are also supported by `buildPersistedDB`, using the `segmentNr` and `segmentPattern` keys. For instance, to utilize four drives mounted at `/mnt/ssd0`, `/mnt/ssd1`, `/mnt/ssd2`, and `/mnt/ssd3`, you can use the following command:

```q
buildPersistedDB["testdb"; 10000; ([segmentNr: 4; segmentPattern: "/mnt/ssd{}/testdb"])]
```

This will distribute partitions across `/mnt/ssd0/testdb`, `/mnt/ssd1/testdb`, `/mnt/ssd2/testdb`, and `/mnt/ssd3/testdb`.

### Additional Settings

The following parameters can be customized using a dictionary passed to the `buildPersistedDB` function. Default values are provided for convenience:

- `exchopen` (default: `9:30`): The opening time of the exchange. No trades or quotes are generated before this time.
- `exchclose` (default: `16:00`): The closing time of the exchange. No trades or quotes are generated after this time.
- `quotesPerTrade` (default: `10`): The number of quotes generated per trade.
- `nbboPerTrade` (default: `3`): The number of NBBO entries generated per trade.
- `holidays` (default: `("01.01"; "01.19"; "02.16"; "05.25"; "06.19"; "07.03"; "09.07"; "10.12"; "11.11"; "11.26"; "12.25")`): A list of holidays (in addition to weekends) for which no trading data is generated. There is no trading on some exchanges on weekends and on public holidays. This can challenge some algorithms and cause issues in downstream system. Holiday support was added to reflect this condition. Only `buildPersistedDB` considers this parameter.

#### Example Usage

To customize the settings, you can pass a dictionary as shown below:

```q
(trade; quote; nbbo; master: exnames): getInMemoryTables[100000; ([exchopen: 7:00; exchclose: 18:00; quotesPerTrade:20; nbboPerTrade:6])]
```

or

```q
buildPersistedDB["testdb"; 5000; ([quotesPerTrade: 3; nbboPerTrade: 5])]
```

## Resource requirements

   * The kdb+ objects (tables and dictionary) generated with the default getInMemoryTables parameters require 1.3 MB of memory.
   * Persisted data generated with the default parameters occupies 377 MB of disk space.