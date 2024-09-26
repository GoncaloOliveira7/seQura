## Instructions


To run the project you must first clone it to your local machine.

```shell
git clone https://github.com/GoncaloOliveira7/seQura.git
cd seQura
ruby bin/run_disbursements.rb
```

Note: To run the script you must have at least ruby 3.2.2 installed on your machine.

To see access the disbursements.csv it can be found at `data/disbursements.csv`.

To run tests simply run

```shell
bundle install
ruby bin/test.rb
```

## Assumptions

I assumed that the orders and merchants csvs are sorted by merchant_reference/reference and created_at(for the case of orders).
The data structure usde by the system csv's given by the challenge.

## Technical Choices and Tradeoffs

With this script the goal was to build something that wasn't too reliant on memory ram at the cost of more cpu usage and runtime.
I've decided to implement models for Orders, Merchants and Disbrursements do encapsulate some of business logic and reduce complexity, add modularity while keeping readability.

Used least number of dependencies as possible, because I think it makes more sense for the exercise.

### Float Point Calculation

To solve the issues with float point numeral miscalculations I had 3 options:
Converting euros to cents would solve the issue with percentage calculations.
Use a Gem Money or something similar, this solution could work but requires addind a depency to the project.
BigDecimal allows to do float point calculation wihout having to add any aditional dependencies so I picked it.

### Unique Identifier

I choose to use the combination of a sequence number and a timestamp converted to 32 hex.
This way the sequence garantees uniqueness between disbursments and the timestamp garantees uniquess if we rerun the script.

### Use of Models for CSV rows

Using Models allowed to cast fields like dates and numbers to more useful types like BigDecimal and Date.
Allow helps seperate logic by each model. Removing complexity from the service.


## Limitations and Improvements

The script processes all orders regardless of the day it's ran. Meaning It's incapable of gererating disbursements for a given day only.
All weekly disbursements are always considered full weeks.

All disbursements have to be reprocessed when new orders or merchants are added.

The lack of a Database eg: (Documental Database or Relational Database) hinders the ability to query existing data.
And would facilitate the access of the data by querying.

Testing of the script is limited to certain methods, and would need more coverage to be truly reliable.


## Result

|Year|Number of disbursements|Amount disbursed to merchants|Amount of order fees|Number of monthly fees charged|Amount of monthly fee charged |
|----|-----------------------|-----------------------------|--------------------|------------------------------|------------------------------|
|2023|10352                  |188.363.118,18 €             |1.692.163,42 €      |0                             |0.0 €                         |
|2022|1548                   |39.173.739,73 €              |350.774,71 €        |11                            |191.04 €                      |
