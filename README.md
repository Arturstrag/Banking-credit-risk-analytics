# Banking-credit-risk-analytics

## Project Description

The project focuses on analyzing the credit portfolio of a simulated bank, **NovaBank**, operating in the Polish retail and SME banking market.

The dataset contains information about customers, loans, monthly loan performance, repayment history and credit products. The analysis is designed to simulate a realistic banking analytics workflow, starting with data quality validation and SQL-based data preparation, followed by business analysis and the creation of an interactive Excel dashboard.

The main analytical areas include portfolio size and structure, delinquency trends, credit risk by product and customer segment, repayment behavior and risk-adjusted profitability.

The project demonstrates practical skills in:
- PostgreSQL
- SQL
- Data Quality
- Data Cleaning
- Data Analysis
- Microsoft Excel
- Pivot Tables
- Dashboard Design
- Business Analysis

---

## Business Objective

The main objective of the project is to assess the quality and risk profile of NovaBank's credit portfolio and identify the areas that contribute most to portfolio deterioration.

The analysis aims to answer the following business questions:

- How does the value of the credit portfolio change over time?
- Is the share of loans with 30+ DPD and 90+ DPD increasing?
- Which credit products generate the highest level of risk?
- How does credit risk differ between Retail and SME customers?
- Are secured loans less risky than unsecured loans?
- How does repayment type, such as Installment or Revolving, affect portfolio risk?
- Which customer risk profiles and credit score groups are associated with higher delinquency?
- How effectively are customers repaying their obligations?
- Is higher credit risk compensated by sufficient interest income?
- Which products generate the highest risk-adjusted income?

The final goal is to provide a clear view of portfolio performance and support management in identifying segments that may require closer monitoring or changes in credit policy.

---

## Data Structure

The core analysis is based on five related tables.

| Table | Description |
|---|---|
| `customers` | Customer-level information including customer segment, age, employment status, monthly income, location, credit score and risk profile. |
| `loans` | Loan contract information including loan amount, interest rate, term, origination date, maturity date, LTV, purpose and loan status. |
| `loan_monthly_snapshot` | Monthly snapshot of each active loan, including outstanding balance, Days Past Due, monthly loan status, interest income and estimated credit loss. |
| `payments` | Repayment history including due date, payment date, due amount, paid amount, payment status and number of days past due. |
| `products` | Credit product dictionary containing product name, customer segment, security type, repayment type, base rate and annual fee rate. |

The main analytical table is `loan_monthly_snapshot`, where each row represents the status of a specific loan in a specific month.

This structure allows the portfolio to be analyzed over time and supports the calculation of key metrics such as:

- Outstanding Balance
- Active Loans
- DPD 30+ Rate
- DPD 90+ Rate
- Interest Income
- Estimated Credit Loss
- Risk Adjusted Income
- Collection Ratio