# DevOps Data Generator

This module is designed to generate synthetic DevOps data, including the `computer`, and `incidents` tables, along with static data for computers.

Static information, stored in the `master` table, contains details about each desktop computer, keyed by an ID. This includes the department the machine belongs to and its operating system.

Each desktop reports its CPU usage every minute in the `computer` table. The CPU usage is a value between 3% and 100%, fluctuating by -2 to +2 between each sample period. By default, data is generated for 1,000 machines. However, several parameters, such as the number of machines and sample frequency, can be customized.

Incident records, stored in the `incidents` table, are generated whenever a user reports a problem. Each record includes a severity level, which can vary depending on the issue.

## Usage

The module provides a single function that returns in-memory tables.

```q
([getInMemoryTables]): use `kx.datagen.devops
```

The CPU metrics are collected from midnight until the current query time (`.z.T`).

If you run getInMemoryTables without any parameters, it uses the default settings:

```q
(master; computer; incidents): getInMemoryTables[]
```

The three generated tables require approximately 21 MB of memory.

### Parameters

You can pass a dictionary with custom parameters to override the defaults in `getInMemoryTables`. The available keys are:

   * `compNr` (default: 1000): The number of computers.
   * `frequency` (default: one minute, i.e., 00:01:00): The frequency at which computers report CPU usage. The time column captures the update arrival time, which may slightly differ from the intended CPU utilization timestamp.
   * `avgIncNrPerComputer` (default: 2): The average number of incidents per computer.
   * `start` (default: midnight, i.e., 00:00:00): The start time for metrics capture.
   * `end` (default: .z.T): The end time for metrics capture.

Example Usage

To reduce the number of computers to 500 and increase the reporting frequency to one second, use the following command:

```q
(master; computer; incidents): getInMemoryTables ([compNr: 500; frequency: 00:00:01])
```

YTo generate data for a specific time range, such as between 8:00 AM and 10:00 AM, use:

```q
(master; computer; incidents): getInMemoryTables ([start: 08:00; frequency: 10:00])
```