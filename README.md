## Instructions


To run the project, you must first clone it to your local machine:

```shell
git clone https://github.com/GoncaloOliveira7/seQura.git
cd seQura
ruby bin/run_disbursements.rb
```

Note: To run the script, you must have at least Ruby 3.2.2 installed on your machine.

To access the disbursements.csv file, it can be found at `data/disbursements.csv`.
To run tests, simply execute:

```shell
bundle install
ruby bin/test.rb
```

## Assumptions

I assumed that the orders and merchants CSVs are sorted by merchant_reference/reference and created_at (for orders). The data structure used is based on the CSV files provided in the challenge.

## Technical Choices and Tradeoffs

The goal of this script was to build a solution that isn't too reliant on RAM, at the cost of more CPU usage and runtime. I decided to implement models for Orders, Merchants, and Disbursements to encapsulate some of the business logic and reduce complexity, adding modularity while maintaining readability.

I used the least number of dependencies possible, as I believe it makes more sense for this exercise.

### Float Point Calculation

To solve issues with floating-point numerical miscalculations, I had three options:
1. Converting euros to cents, which would solve the issue with percentage calculations.
2. Using a gem like Money or something similar, but this solution requires adding a dependency to the project.
3. Using BigDecimal, which allows for floating-point calculations without adding any additional dependencies.

### Unique Identifier

I chose to use a combination of a sequence number and a timestamp converted to 32-bit hexadecimal. This way, the sequence guarantees uniqueness between disbursements, and the timestamp ensures uniqueness if we rerun the script.

### Use of Models for CSV rows

Using models allowed me to cast fields like dates and numbers to more useful types such as BigDecimal and Date. It also helps separate logic for each model, removing complexity from the service.

## Limitations and Improvements

The script processes all orders regardless of the day it's run, meaning it's incapable of generating disbursements for a given day only. All weekly disbursements are always considered full weeks.

All disbursements have to be reprocessed when new orders or merchants are added.

The lack of a database (e.g., a document database or relational database) hinders the ability to query existing data. A database would facilitate data access through querying.

Testing of the script is limited to certain methods and would need more coverage to be truly reliable.


## Result

|Year|Number of disbursements|Amount disbursed to merchants|Amount of order fees|Number of monthly fees charged|Amount of monthly fee charged |
|----|-----------------------|-----------------------------|--------------------|------------------------------|------------------------------|
|2023|10352                  |188.363.118,18 €             |1.692.163,42 €      |0                             |0.0 €                         |
|2022|1548                   |39.173.739,73 €              |350.774,71 €        |11                            |191.04 €                      |
