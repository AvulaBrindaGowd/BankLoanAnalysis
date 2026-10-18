create database BankLoan;
use BankLoan;

select * from Bank_Loan_Data;


SET SQL_SAFE_UPDATES = 0;   -- Workbench blocks UPDATE without WHERE otherwise

-- convert dd-mm-yyyy text into proper dates
UPDATE bank_loan_data SET
    issue_date            = STR_TO_DATE(issue_date,            '%d-%m-%Y'),
    last_credit_pull_date = STR_TO_DATE(last_credit_pull_date, '%d-%m-%Y'),
    last_payment_date     = STR_TO_DATE(last_payment_date,     '%d-%m-%Y'),
    next_payment_date     = STR_TO_DATE(next_payment_date,     '%d-%m-%Y'),
    term                  = TRIM(term);

-- now change the column types
ALTER TABLE bank_loan_data
    MODIFY issue_date            DATE,
    MODIFY last_credit_pull_date DATE,
    MODIFY last_payment_date     DATE,
    MODIFY next_payment_date     DATE,
    MODIFY address_state         CHAR(2),
    MODIFY grade                 CHAR(1),
    MODIFY sub_grade             CHAR(2),
    MODIFY application_type      VARCHAR(20),
    MODIFY emp_length            VARCHAR(20),
    MODIFY emp_title             VARCHAR(100),
    MODIFY home_ownership        VARCHAR(20),
    MODIFY loan_status           VARCHAR(20),
    MODIFY purpose               VARCHAR(30),
    MODIFY term                  VARCHAR(20),
    MODIFY verification_status   VARCHAR(20),
    MODIFY dti                   DECIMAL(6,4),
    MODIFY installment           DECIMAL(8,2),
    MODIFY int_rate              DECIMAL(5,4),
    ADD PRIMARY KEY (id);

-- check: expect 38576 rows, 2021-01-01 to 2021-12-12
SELECT COUNT(*), MIN(issue_date), MAX(issue_date) FROM bank_loan_data;
-- Total Loan Application
select count(id) as Total_Loan_Applications from Bank_Loan_Data;

-- MTD Loan Applications 
select count(id) as Total_MTD_Loan_Applications from Bank_Loan_Data where month(issue_date) = 12;

-- PMTD Loan Applications
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data;

-- MTD Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- PMTD Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data;

-- MTD Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- PMTD Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Average Interest Rate
SELECT ROUND(AVG(int_rate) * 100, 2) AS Avg_Int_Rate FROM bank_loan_data;

-- MTD Average Interest
SELECT ROUND(AVG(int_rate) * 100, 2) AS MTD_Avg_Int_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- PMTD Average Interest
SELECT ROUND(AVG(int_rate) * 100, 2) AS PMTD_Avg_Int_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Avg DTI
SELECT ROUND(AVG(dti) * 100, 2) AS Avg_DTI FROM bank_loan_data;

-- MTD Avg DTI
SELECT ROUND(AVG(dti) * 100, 2) AS MTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- PMTD Avg DTI
SELECT ROUND(AVG(dti) * 100, 2) AS PMTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 11;


/* =====================================================================
   GOOD LOAN ISSUED
   ===================================================================== */

-- Good Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100.0)
    / COUNT(id) AS Good_Loan_Percentage
FROM bank_loan_data;

-- Good Loan Applications
SELECT COUNT(id) AS Good_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- Good Loan Amount Received
SELECT SUM(total_payment) AS Good_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';


/* =====================================================================
   BAD LOAN ISSUED
   ===================================================================== */

-- Bad Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0)
    / COUNT(id) AS Bad_Loan_Percentage
FROM bank_loan_data;

-- Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Charged Off';

-- Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Charged Off';

-- Bad Loan Amount Received
SELECT SUM(total_payment) AS Bad_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Charged Off';


/* =====================================================================
   LOAN STATUS
   ===================================================================== */
SELECT
    loan_status,
    COUNT(id)               AS LoanCount,
    SUM(total_payment)      AS Total_Amount_Received,
    SUM(loan_amount)        AS Total_Funded_Amount,
    AVG(int_rate * 100)     AS Interest_Rate,
    AVG(dti * 100)          AS DTI
FROM bank_loan_data
GROUP BY loan_status;

SELECT
    loan_status,
    SUM(total_payment) AS MTD_Total_Amount_Received,
    SUM(loan_amount)   AS MTD_Total_Funded_Amount
FROM bank_loan_data
WHERE MONTH(issue_date) = 12
GROUP BY loan_status;


/* =====================================================================
   BANK LOAN REPORT | OVERVIEW
   ===================================================================== */

-- MONTH
-- CHANGE: DATENAME(MONTH, issue_date)  ->  MONTHNAME(issue_date)
SELECT
    MONTH(issue_date)       AS Month_Number,
    MONTHNAME(issue_date)   AS Month_name,
    COUNT(id)               AS Total_Loan_Applications,
    SUM(loan_amount)        AS Total_Funded_Amount,
    SUM(total_payment)      AS Total_Amount_Received
FROM bank_loan_data
GROUP BY MONTH(issue_date), MONTHNAME(issue_date)
ORDER BY MONTH(issue_date);

-- STATE
SELECT
    address_state           AS State,
    COUNT(id)               AS Total_Loan_Applications,
    SUM(loan_amount)        AS Total_Funded_Amount,
    SUM(total_payment)      AS Total_Amount_Received
FROM bank_loan_data
GROUP BY address_state
ORDER BY address_state;

-- TERM
SELECT
    term                    AS Term,
    COUNT(id)               AS Total_Loan_Applications,
    SUM(loan_amount)        AS Total_Funded_Amount,
    SUM(total_payment)      AS Total_Amount_Received
FROM bank_loan_data
GROUP BY term
ORDER BY term;

-- EMPLOYEE LENGTH
-- (emp_length is text, so '10+ years' sorts before '2 years'. Same as the original.
--  For a true 0-10 year order, use the ORDER BY below instead.)
SELECT
    emp_length              AS Employee_Length,
    COUNT(id)               AS Total_Loan_Applications,
    SUM(loan_amount)        AS Total_Funded_Amount,
    SUM(total_payment)      AS Total_Amount_Received
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length;
-- Optional numeric ordering:
-- ORDER BY CASE WHEN emp_length LIKE '<%' THEN 0
--               ELSE CAST(emp_length AS UNSIGNED) END;

-- PURPOSE
SELECT
    purpose                 AS PURPOSE,
    COUNT(id)               AS Total_Loan_Applications,
    SUM(loan_amount)        AS Total_Funded_Amount,
    SUM(total_payment)      AS Total_Amount_Received
FROM bank_loan_data
GROUP BY purpose
ORDER BY purpose;

-- HOME OWNERSHIP
SELECT
    home_ownership          AS Home_Ownership,
    COUNT(id)               AS Total_Loan_Applications,
    SUM(loan_amount)        AS Total_Funded_Amount,
    SUM(total_payment)      AS Total_Amount_Received
FROM bank_loan_data
GROUP BY home_ownership
ORDER BY home_ownership;

-- FILTER EXAMPLE (Grade A)
SELECT
    purpose                 AS PURPOSE,
    COUNT(id)               AS Total_Loan_Applications,
    SUM(loan_amount)        AS Total_Funded_Amount,
    SUM(total_payment)      AS Total_Amount_Received
FROM bank_loan_data
WHERE grade = 'A'
GROUP BY purpose
ORDER BY purpose;
