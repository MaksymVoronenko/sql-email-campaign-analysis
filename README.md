# Account and Email Campaign Analysis

SQL portfolio project by **Maksym Voronenko**.

## Overview

This query creates a reporting view combining account counts with email sends, opens, and visits. It groups the metrics by date, country, send interval, verification status, and unsubscribe status.

The query calculates country totals and ranks countries by account counts and sent-message counts. It keeps rows for countries within the top 10 ranks on either measure; ties and the two separate rankings can produce more than 10 countries.

## SQL techniques

* Common table expressions (CTEs) to organize the processing steps.
* Inner joins and left joins to combine account, session, and email tables.
* `COUNT(DISTINCT ...)` for account and message counts.
* Date arithmetic to derive email send dates.
* `UNION ALL` and grouped aggregation to combine the metrics.
* `SUM(...) OVER (PARTITION BY country)` for country totals.
* `DENSE\_RANK()` for country rankings.

## Source tables

The query references:

* `DA.account`
* `DA.account\_session`
* `DA.session`
* `DA.session\_params`
* `DA.email\_sent`
* `DA.email\_open`
* `DA.email\_visit`

## Output

The view contains the grouping dimensions, account and email counts, country totals, and the two country rankings. The final rows are ordered by date and country.

## Running and validation

The query creates or replaces `Students.v\_Voronenko\_Adva\_Mod`. It requires access to the source tables and permission to create or replace the target view. Adjust the dataset or schema names to match your environment.

The source data was not supplied with this package, so query execution and metric correctness have not been verified. The SQL logic has been preserved from the original document.

