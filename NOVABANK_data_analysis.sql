-- ============================================================

-- NOVABANK - ETAP 1

-- DATA QUALITY & INITIAL DATA REVIEW

-- PostgreSQL

--

-- Główne tabele:

-- 1. customers

-- 2. loans

-- 3. loan_monthly_snapshot

-- 4. payments

-- 5. products

--

-- Cel:

-- - sprawdzenie liczby rekordów

-- - identyfikacja braków danych

-- - wykrycie błędnych / nielogicznych wartości

-- - wykrycie duplikatów

-- - sprawdzenie relacji między tabelami

-- - poznanie podstawowych rozkładów danych

-- ============================================================

-- ============================================================

-- 1. ROW COUNT

-- Sprawdzenie liczby rekordów w każdej tabeli

-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'loans', COUNT(*)
FROM loans
UNION ALL
SELECT 'loan_monthly_snapshot', COUNT(*)
FROM loan_monthly_snapshot
UNION ALL
SELECT 'payments', COUNT(*)
FROM payments
UNION ALL
SELECT 'products', COUNT(*)
FROM products
ORDER BY table_name;

-- ============================================================

-- 2. CUSTOMERS - MISSING VALUES

-- Sprawdzenie brakujących wartości w tabeli customers

-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,
    COUNT(*) FILTER (
        WHERE customer_type IS NULL
    ) AS missing_customer_type,
    COUNT(*) FILTER (
        WHERE age IS NULL
    ) AS missing_age,
    COUNT(*) FILTER (
        WHERE employment_status IS NULL
    ) AS missing_employment_status,
    COUNT(*) FILTER (
        WHERE monthly_income_pln IS NULL
    ) AS missing_income,
    COUNT(*) FILTER (
        WHERE city IS NULL
    ) AS missing_city,
    COUNT(*) FILTER (
        WHERE region IS NULL
    ) AS missing_region,
    COUNT(*) FILTER (
        WHERE macro_region IS NULL
    ) AS missing_macro_region,
    COUNT(*) FILTER (
        WHERE credit_score IS NULL
    ) AS missing_credit_score,
    COUNT(*) FILTER (
        WHERE relationship_start_date IS NULL
    ) AS missing_relationship_start_date,
    COUNT(*) FILTER (
        WHERE branch_id IS NULL
    ) AS missing_branch_id,
    COUNT(*) FILTER (
        WHERE risk_profile IS NULL
    ) AS missing_risk_profile
FROM customers;


SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE city IS NULL
    ) AS null_city,
    COUNT(*) FILTER (
        WHERE city = ''
    ) AS empty_city
FROM customers;
-- ============================================================

-- 3. CUSTOMERS - INVALID VALUES

-- Sprawdzenie nielogicznych wartości

-- ============================================================

SELECT *
FROM customers
WHERE age < 18
   OR age > 100
   OR credit_score < 300
   OR credit_score > 850
   OR monthly_income_pln < 0;

-- ============================================================

-- 4. CUSTOMERS - VALUE RANGES

-- Sprawdzenie minimalnych, maksymalnych i średnich wartości

-- ============================================================

SELECT
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age), 2) AS avg_age,
    MIN(credit_score) AS min_credit_score,
    MAX(credit_score) AS max_credit_score,
    ROUND(AVG(credit_score), 2) AS avg_credit_score,
    MIN(monthly_income_pln) AS min_income,
    MAX(monthly_income_pln) AS max_income,
    ROUND(AVG(monthly_income_pln), 2) AS avg_income
FROM customers;

-- ============================================================

-- 5. CUSTOMERS - DUPLICATES

-- Sprawdzenie, czy customer_id jest unikalne

-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================

-- 6. CUSTOMERS - CUSTOMER TYPE DISTRIBUTION

-- Rozkład klientów Retail / SME

-- ============================================================

SELECT
    customer_type,
    COUNT(*) AS customers
FROM customers
GROUP BY customer_type
ORDER BY customers DESC;

-- ============================================================

-- 7. CUSTOMERS - RISK PROFILE DISTRIBUTION

-- Rozkład klientów według profilu ryzyka

-- ============================================================

SELECT
    risk_profile,
    COUNT(*) AS customers
FROM customers
GROUP BY risk_profile
ORDER BY customers DESC;

-- ============================================================

-- 8. CUSTOMERS - REGION DISTRIBUTION

-- Liczba klientów według regionu

-- ============================================================

SELECT
    region,
    COUNT(*) AS customers
FROM customers
GROUP BY region
ORDER BY customers DESC;

-- ============================================================

-- 9. CUSTOMERS - CATEGORY CONSISTENCY

-- Sprawdzenie, czy w kategoriach nie ma niespójnych wartości

-- np. Retail / retail / RETAIL

-- ============================================================

SELECT DISTINCT customer_type
FROM customers
ORDER BY customer_type;

SELECT DISTINCT employment_status
FROM customers
ORDER BY employment_status;

SELECT DISTINCT risk_profile
FROM customers
ORDER BY risk_profile;

-- ============================================================

-- 10. LOANS - MISSING VALUES

-- Sprawdzenie brakujących wartości w tabeli loans

--

-- Uwaga:

-- LTV może być NULL dla produktów niezabezpieczonych,

-- dlatego NULL w LTV nie musi oznaczać błędu.

-- ============================================================

SELECT
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_id IS NULL
    ) AS missing_loan_id,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_product_id,
    COUNT(*) FILTER (
        WHERE branch_id IS NULL
    ) AS missing_branch_id,
    COUNT(*) FILTER (
        WHERE origination_date IS NULL
    ) AS missing_origination_date,
    COUNT(*) FILTER (
        WHERE maturity_date IS NULL
    ) AS missing_maturity_date,
    COUNT(*) FILTER (
        WHERE original_amount_pln IS NULL
    ) AS missing_original_amount,
    COUNT(*) FILTER (
        WHERE interest_rate IS NULL
    ) AS missing_interest_rate,
    COUNT(*) FILTER (
        WHERE term_months IS NULL
    ) AS missing_term_months,
    COUNT(*) FILTER (
        WHERE purpose IS NULL
    ) AS missing_purpose,
    COUNT(*) FILTER (
        WHERE status IS NULL
    ) AS missing_status
FROM loans;

-- ============================================================

-- 11. LOANS - INVALID VALUES

-- Wyszukanie nielogicznych wartości kredytów

-- ============================================================

SELECT *
FROM loans
WHERE original_amount_pln <= 0
   OR interest_rate <= 0
   OR term_months <= 0
   OR maturity_date < origination_date;

-- ============================================================

-- 12. LOANS - VALUE RANGES

-- Podstawowe statystyki kredytów

-- ============================================================

SELECT
    MIN(original_amount_pln) AS min_loan_amount,
    MAX(original_amount_pln) AS max_loan_amount,
    ROUND(AVG(original_amount_pln), 2) AS avg_loan_amount,
    MIN(interest_rate) AS min_interest_rate,
    MAX(interest_rate) AS max_interest_rate,
    ROUND(AVG(interest_rate), 4) AS avg_interest_rate,
    MIN(term_months) AS min_term_months,
    MAX(term_months) AS max_term_months,
    ROUND(AVG(term_months), 2) AS avg_term_months
FROM loans;

-- ============================================================

-- 13. LOANS - DUPLICATE LOAN IDS

-- loan_id powinno być unikalne

-- ============================================================

SELECT
    loan_id,
    COUNT(*) AS duplicate_count
FROM loans
GROUP BY loan_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================

-- 14. LOANS - STATUS DISTRIBUTION

-- Poznanie struktury statusów kredytów

-- ============================================================

SELECT
    status,
    COUNT(*) AS loans
FROM loans
GROUP BY status
ORDER BY loans DESC;

-- ============================================================

-- 15. LOANS - PURPOSE DISTRIBUTION

-- Najczęstsze cele kredytowania

-- ============================================================

SELECT
    purpose,
    COUNT(*) AS loans
FROM loans
GROUP BY purpose
ORDER BY loans DESC;

-- ============================================================

-- 16. LOANS - ORPHAN CUSTOMERS

-- Kredyty przypisane do nieistniejących klientów

-- ============================================================

SELECT
    l.*
FROM loans l
LEFT JOIN customers c
    ON l.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- ============================================================

-- 17. LOANS - ORPHAN PRODUCTS

-- Kredyty przypisane do nieistniejących produktów

-- ============================================================

SELECT
    l.*
FROM loans l
LEFT JOIN products p
    ON l.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ============================================================

-- 18. LOAN MONTHLY SNAPSHOT - MISSING VALUES

-- Sprawdzenie braków w głównej tabeli faktów

-- ============================================================

SELECT
    COUNT(*) AS total_snapshots,
    COUNT(*) FILTER (
        WHERE snapshot_month IS NULL
    ) AS missing_snapshot_month,
    COUNT(*) FILTER (
        WHERE loan_id IS NULL
    ) AS missing_loan_id,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_product_id,
    COUNT(*) FILTER (
        WHERE branch_id IS NULL
    ) AS missing_branch_id,
    COUNT(*) FILTER (
        WHERE loan_age_months IS NULL
    ) AS missing_loan_age,
    COUNT(*) FILTER (
        WHERE outstanding_balance_pln IS NULL
    ) AS missing_balance,
    COUNT(*) FILTER (
        WHERE days_past_due IS NULL
    ) AS missing_dpd,
    COUNT(*) FILTER (
        WHERE loan_status_month IS NULL
    ) AS missing_status,
    COUNT(*) FILTER (
        WHERE monthly_interest_income_pln IS NULL
    ) AS missing_interest_income,
    COUNT(*) FILTER (
        WHERE estimated_credit_loss_pln IS NULL
    ) AS missing_estimated_loss
FROM loan_monthly_snapshot;

-- ============================================================

-- 19. LOAN MONTHLY SNAPSHOT - INVALID VALUES

-- Nielogiczne wartości miesięcznych snapshotów

-- ============================================================

SELECT *
FROM loan_monthly_snapshot
WHERE loan_age_months < 0
   OR outstanding_balance_pln < 0
   OR days_past_due < 0
   OR monthly_interest_income_pln < 0
   OR estimated_credit_loss_pln < 0;


-- ============================================================

-- 20. LOAN MONTHLY SNAPSHOT - DPD RANGE

-- Sprawdzenie zakresu Days Past Due

-- ============================================================

SELECT
    MIN(days_past_due) AS min_dpd,
    MAX(days_past_due) AS max_dpd,
    ROUND(AVG(days_past_due), 2) AS avg_dpd
FROM loan_monthly_snapshot;

-- ============================================================

-- 21. LOAN MONTHLY SNAPSHOT - STATUS DISTRIBUTION

-- Rozkład miesięcznych statusów kredytów

-- ============================================================

SELECT
    loan_status_month,
    COUNT(*) AS records
FROM loan_monthly_snapshot
GROUP BY loan_status_month
ORDER BY records DESC;

-- ============================================================

-- 22. LOAN MONTHLY SNAPSHOT - DUPLICATE SNAPSHOTS

--

-- Jeden kredyt powinien posiadać maksymalnie jeden rekord

-- dla danego miesiąca.

-- ============================================================

SELECT
    loan_id,
    snapshot_month,
    COUNT(*) AS duplicate_count
FROM loan_monthly_snapshot
GROUP BY
    loan_id,
    snapshot_month
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================

-- 23. LOAN MONTHLY SNAPSHOT - ORPHAN LOANS

-- Snapshoty bez odpowiadającego kredytu w loans

-- ============================================================

SELECT
    s.*
FROM loan_monthly_snapshot s
LEFT JOIN loans l
    ON s.loan_id = l.loan_id
WHERE l.loan_id IS NULL;

-- ============================================================

-- 24. PAYMENTS - MISSING VALUES

-- Sprawdzenie brakujących wartości w historii spłat

-- ============================================================

SELECT
    COUNT(*) AS total_payments,
    COUNT(*) FILTER (
        WHERE payment_id IS NULL
    ) AS missing_payment_id,
    COUNT(*) FILTER (
        WHERE loan_id IS NULL
    ) AS missing_loan_id,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,
    COUNT(*) FILTER (
        WHERE due_date IS NULL
    ) AS missing_due_date,
    COUNT(*) FILTER (
        WHERE payment_date IS NULL
    ) AS missing_payment_date,
    COUNT(*) FILTER (
        WHERE due_amount_pln IS NULL
    ) AS missing_due_amount,
    COUNT(*) FILTER (
        WHERE paid_amount_pln IS NULL
    ) AS missing_paid_amount,
    COUNT(*) FILTER (
        WHERE days_past_due IS NULL
    ) AS missing_dpd,
    COUNT(*) FILTER (
        WHERE payment_status IS NULL
    ) AS missing_payment_status
FROM payments;

-- ============================================================

-- 25. PAYMENTS - DUPLICATE PAYMENT IDS

-- ============================================================

SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================

-- 26. PAYMENTS - FULL DUPLICATE ROWS

--

-- Sprawdzenie dokładnych duplikatów całych rekordów.

-- Jest to bardziej szczegółowa kontrola niż samo payment_id.

-- ============================================================

SELECT
    payment_id,
    loan_id,
    customer_id,
    due_date,
    payment_date,
    due_amount_pln,
    paid_amount_pln,
    days_past_due,
    payment_status,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY
    payment_id,
    loan_id,
    customer_id,
    due_date,
    payment_date,
    due_amount_pln,
    paid_amount_pln,
    days_past_due,
    payment_status
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================

-- 27. PAYMENTS - INVALID VALUES

-- Sprawdzenie nielogicznych kwot i DPD

-- ============================================================

SELECT *
FROM payments
WHERE due_amount_pln < 0
   OR paid_amount_pln < 0
   OR days_past_due < 0;

-- ============================================================

-- 28. PAYMENTS - DATE CONSISTENCY

--

-- Jeżeli DPD > 0, płatność nie powinna mieć daty płatności

-- wcześniejszej niż termin płatności.

-- ============================================================

SELECT *
FROM payments
WHERE days_past_due > 0
  AND payment_date < due_date;

-- ============================================================

-- 29. PAYMENTS - STATUS DISTRIBUTION

-- Struktura statusów płatności

-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS payments
FROM payments
GROUP BY payment_status
ORDER BY payments DESC;

-- ============================================================

-- 30. PAYMENTS - DPD RANGE

-- Zakres opóźnień w płatnościach

-- ============================================================

SELECT
    MIN(days_past_due) AS min_dpd,
    MAX(days_past_due) AS max_dpd,
    ROUND(AVG(days_past_due), 2) AS avg_dpd
FROM payments;

-- ============================================================

-- 31. PAYMENTS - ORPHAN LOANS

-- Płatności bez odpowiadającego kredytu

-- ============================================================

SELECT
    p.*
FROM payments p
LEFT JOIN loans l
    ON p.loan_id = l.loan_id
WHERE l.loan_id IS NULL;

-- ============================================================

-- 32. PAYMENTS - ORPHAN CUSTOMERS

-- Płatności przypisane do nieistniejących klientów

-- ============================================================

SELECT
    p.*
FROM payments p
LEFT JOIN customers c
    ON p.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- ============================================================

-- 33. PRODUCTS - MISSING VALUES

-- Sprawdzenie braków w słowniku produktów

-- ============================================================

SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_product_id,
    COUNT(*) FILTER (
        WHERE product_name IS NULL
    ) AS missing_product_name,
    COUNT(*) FILTER (
        WHERE customer_segment IS NULL
    ) AS missing_customer_segment,
    COUNT(*) FILTER (
        WHERE security_type IS NULL
    ) AS missing_security_type,
    COUNT(*) FILTER (
        WHERE repayment_type IS NULL
    ) AS missing_repayment_type,
    COUNT(*) FILTER (
        WHERE base_rate IS NULL
    ) AS missing_base_rate,
    COUNT(*) FILTER (
        WHERE annual_fee_rate IS NULL
    ) AS missing_annual_fee_rate
FROM products;

-- ============================================================

-- 34. PRODUCTS - FULL PRODUCT DICTIONARY

-- Podgląd wszystkich produktów

-- ============================================================

SELECT *
FROM products
ORDER BY product_id;

-- ============================================================

-- 35. PRODUCTS - DUPLICATE PRODUCT IDS

-- product_id powinno być unikalne

-- ============================================================

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================

-- 36. PRODUCTS - CATEGORY CONSISTENCY

-- Sprawdzenie kategorii tekstowych

-- ============================================================

SELECT DISTINCT customer_segment
FROM products
ORDER BY customer_segment;

SELECT DISTINCT security_type
FROM products
ORDER BY security_type;

SELECT DISTINCT repayment_type
FROM products
ORDER BY repayment_type;

-- ============================================================

-- 37. PRODUCTS - INVALID RATES

-- Sprawdzenie ujemnych stawek

-- ============================================================

SELECT *
FROM products
WHERE base_rate < 0
   OR annual_fee_rate < 0;


-- ============================================================
-- NOVABANK
-- STAGE 2 - CONSISTENT CLEAN DATA LAYER
-- PostgreSQL
--
-- Cel:
-- - zachowanie tabel RAW bez zmian,
-- - przygotowanie spójnych widoków CLEAN,
-- - usunięcie / oznaczenie problemów wykrytych w Etapie 1,
-- - zapewnienie spójności pomiędzy tabelami.
--
-- Kolejność:
-- 1. v_customers_clean
-- 2. v_products_clean
-- 3. v_loans_clean
-- 4. v_payments_clean
-- 5. v_loan_monthly_snapshot_clean
-- ============================================================



-- ============================================================
-- 1. CUSTOMERS CLEAN
--
-- Zidentyfikowane problemy:
-- - missing monthly_income_pln -> pozostawiamy jako NULL
-- - brakujące city zapisane jako pusty tekst -> 'Unknown'
--
-- Nie usuwamy klienta tylko dlatego, że nie znamy jego
-- dochodu lub miasta.
--
-- Dodatkowo kontrolujemy podstawowe zakresy biznesowe.
-- ============================================================

CREATE OR REPLACE VIEW v_customers_clean AS
SELECT
    customer_id,
    customer_type,
    age,
    employment_status,
    -- Brak dochodu pozostaje NULL.
    -- Nie wykonujemy sztucznej imputacji.
    monthly_income_pln,
    -- TRIM usuwa potencjalne spacje.
    -- NULLIF zamienia pusty tekst na NULL.
    -- COALESCE zamienia NULL na 'Unknown'.
    COALESCE(
        NULLIF(TRIM(city), ''),
        'Unknown'
    )::varchar AS city,
    region,
    macro_region,
    credit_score,
    relationship_start_date,
    branch_id,
    risk_profile
FROM customers
WHERE age BETWEEN 18 AND 100
  AND credit_score BETWEEN 300 AND 850
  AND (
        monthly_income_pln IS NULL
        OR monthly_income_pln >= 0
      );



-- ============================================================
-- 2. PRODUCTS CLEAN
--
-- W tabeli products nie znaleziono głównych błędów.
--
-- Widok służy przede wszystkim do zapewnienia spójnej
-- warstwy analitycznej.
-- ============================================================

CREATE OR REPLACE VIEW v_products_clean AS
SELECT
    product_id,
    product_name,
    customer_segment,
    security_type,
    repayment_type,
    base_rate,
    annual_fee_rate
FROM products
WHERE product_id IS NOT NULL
  AND product_name IS NOT NULL
  AND customer_segment IS NOT NULL
  AND security_type IS NOT NULL
  AND repayment_type IS NOT NULL
  AND base_rate >= 0
  AND annual_fee_rate >= 0;



-- ============================================================
-- 3. LOANS CLEAN
--
-- Zidentyfikowane problemy:
-- - original_amount_pln <= 0
-- - interest_rate <= 0
--
-- Nie próbujemy poprawiać tych wartości ręcznie,
-- ponieważ nie znamy prawidłowej wartości biznesowej.
--
-- Rekordy zostają wykluczone z warstwy CLEAN.
--
-- Dodatkowo:
-- - kredyt musi posiadać istniejącego clean customer,
-- - kredyt musi posiadać istniejący clean product.
-- ============================================================

CREATE OR REPLACE VIEW v_loans_clean AS
SELECT
    l.loan_id,
    l.customer_id,
    l.product_id,
    l.branch_id,
    l.origination_date,
    l.maturity_date,
    l.original_amount_pln,
    l.interest_rate,
    l.term_months,
    l.ltv,
    l.purpose,
    l.status
FROM loans l
INNER JOIN v_customers_clean c
    ON l.customer_id = c.customer_id
INNER JOIN v_products_clean p
    ON l.product_id = p.product_id
WHERE l.original_amount_pln > 0
  AND l.interest_rate > 0
  AND l.term_months > 0
  AND l.maturity_date >= l.origination_date;



-- ============================================================
-- 4. PAYMENTS CLEAN
--
-- Zidentyfikowany problem:
-- - duplicated payment_id / duplicate payment records
--
-- ROW_NUMBER przypisuje kolejność rekordom posiadającym
-- ten sam payment_id.
--
-- Zachowujemy tylko rn = 1.
--
-- Następnie INNER JOIN do v_loans_clean sprawia,
-- że płatności dotyczące kredytów wykluczonych z clean layer
-- również nie trafiają do clean payments.
-- ============================================================

CREATE OR REPLACE VIEW v_payments_clean AS
WITH ranked_payments AS (
    SELECT
        p.payment_id,
        p.loan_id,
        p.customer_id,
        p.due_date,
        p.payment_date,
        p.due_amount_pln,
        p.paid_amount_pln,
        p.days_past_due,
        p.payment_status,
        ROW_NUMBER() OVER (
            PARTITION BY p.payment_id
            ORDER BY
                p.payment_date,
                p.loan_id,
                p.customer_id
        ) AS rn
    FROM payments p
)
SELECT
    rp.payment_id,
    rp.loan_id,
    rp.customer_id,
    rp.due_date,
    rp.payment_date,
    rp.due_amount_pln,
    rp.paid_amount_pln,
    rp.days_past_due,
    rp.payment_status
FROM ranked_payments rp
INNER JOIN v_loans_clean l
    ON rp.loan_id = l.loan_id
WHERE rp.rn = 1
  AND rp.due_amount_pln >= 0
  AND rp.paid_amount_pln >= 0
  AND rp.days_past_due >= 0;



-- ============================================================
-- 5. LOAN MONTHLY SNAPSHOT CLEAN
--
-- Snapshot jest główną tabelą analityczną projektu.
--
-- Nie traktujemy ujemnego monthly_interest_income_pln
-- jako osobnego problemu do naprawienia tutaj.
--
-- Wcześniejsza analiza wykazała, że wartości te były
-- konsekwencją błędnego interest_rate w loans.
--
-- Dlatego eliminujemy problem u źródła:
-- snapshot pozostaje tylko wtedy, gdy loan_id występuje
-- w v_loans_clean.
-- ============================================================

CREATE OR REPLACE VIEW v_loan_monthly_snapshot_clean AS
SELECT
    s.snapshot_month,
    s.loan_id,
    s.customer_id,
    s.product_id,
    s.branch_id,
    s.loan_age_months,
    s.outstanding_balance_pln,
    s.days_past_due,
    s.loan_status_month,
    s.monthly_interest_income_pln,
    s.estimated_credit_loss_pln
FROM loan_monthly_snapshot s
INNER JOIN v_loans_clean l
    ON s.loan_id = l.loan_id
WHERE s.loan_age_months >= 0
  AND s.outstanding_balance_pln >= 0
  AND s.days_past_due >= 0
  AND s.estimated_credit_loss_pln >= 0;



-- ============================================================
-- 6. RAW VS CLEAN ROW COUNT
--
-- Porównanie liczby rekordów przed i po czyszczeniu.
-- ============================================================

SELECT
    'customers' AS dataset,
    (SELECT COUNT(*) FROM customers) AS raw_rows,
    (SELECT COUNT(*) FROM v_customers_clean) AS clean_rows,
    (SELECT COUNT(*) FROM customers)
        - (SELECT COUNT(*) FROM v_customers_clean) AS excluded_rows
UNION ALL
SELECT
    'products',
    (SELECT COUNT(*) FROM products),
    (SELECT COUNT(*) FROM v_products_clean),
    (SELECT COUNT(*) FROM products)
        - (SELECT COUNT(*) FROM v_products_clean)
UNION ALL
SELECT
    'loans',
    (SELECT COUNT(*) FROM loans),
    (SELECT COUNT(*) FROM v_loans_clean),
    (SELECT COUNT(*) FROM loans)
        - (SELECT COUNT(*) FROM v_loans_clean)
UNION ALL
SELECT
    'payments',
    (SELECT COUNT(*) FROM payments),
    (SELECT COUNT(*) FROM v_payments_clean),
    (SELECT COUNT(*) FROM payments)
        - (SELECT COUNT(*) FROM v_payments_clean)
UNION ALL
SELECT
    'loan_monthly_snapshot',
    (SELECT COUNT(*) FROM loan_monthly_snapshot),
    (SELECT COUNT(*) FROM v_loan_monthly_snapshot_clean),
    (SELECT COUNT(*) FROM loan_monthly_snapshot)
        - (SELECT COUNT(*) FROM v_loan_monthly_snapshot_clean)
ORDER BY dataset;



-- ============================================================
-- 7. CUSTOMERS VALIDATION
--
-- Oczekiwany wynik:
-- missing_city = 0
-- invalid_age = 0
-- invalid_credit_score = 0
-- negative_income = 0
--
-- missing_income może pozostać > 0.
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE city IS NULL
           OR TRIM(city) = ''
    ) AS missing_city,

    COUNT(*) FILTER (
        WHERE city = 'Unknown'
    ) AS unknown_city,

    COUNT(*) FILTER (
        WHERE monthly_income_pln IS NULL
    ) AS missing_income,

    COUNT(*) FILTER (
        WHERE age < 18 OR age > 100
    ) AS invalid_age,

    COUNT(*) FILTER (
        WHERE credit_score < 300 OR credit_score > 850
    ) AS invalid_credit_score,

    COUNT(*) FILTER (
        WHERE monthly_income_pln < 0
    ) AS negative_income

FROM v_customers_clean;



-- ============================================================
-- 8. LOANS VALIDATION
--
-- Wszystkie wartości powinny wynosić 0.
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE original_amount_pln <= 0
    ) AS invalid_amount,

    COUNT(*) FILTER (
        WHERE interest_rate <= 0
    ) AS invalid_interest_rate,

    COUNT(*) FILTER (
        WHERE term_months <= 0
    ) AS invalid_term,

    COUNT(*) FILTER (
        WHERE maturity_date < origination_date
    ) AS invalid_dates

FROM v_loans_clean;



-- ============================================================
-- 9. DUPLICATE PAYMENTS VALIDATION
--
-- Powinno zwrócić 0 rekordów.
-- ============================================================

SELECT
    payment_id,
    COUNT(*) AS duplicate_count

FROM v_payments_clean

GROUP BY payment_id

HAVING COUNT(*) > 1;



-- ============================================================
-- 10. PAYMENTS VS CLEAN LOANS
--
-- Powinno zwrócić 0.
-- ============================================================

SELECT
    COUNT(*) AS payments_without_clean_loan

FROM v_payments_clean p

LEFT JOIN v_loans_clean l
    ON p.loan_id = l.loan_id

WHERE l.loan_id IS NULL;



-- ============================================================
-- 11. SNAPSHOT VS CLEAN LOANS
--
-- Powinno zwrócić 0.
-- ============================================================

SELECT
    COUNT(*) AS snapshots_without_clean_loan

FROM v_loan_monthly_snapshot_clean s

LEFT JOIN v_loans_clean l
    ON s.loan_id = l.loan_id

WHERE l.loan_id IS NULL;



-- ============================================================
-- 12. LOANS VS CLEAN CUSTOMERS
--
-- Powinno zwrócić 0.
-- ============================================================

SELECT
    COUNT(*) AS loans_without_clean_customer

FROM v_loans_clean l

LEFT JOIN v_customers_clean c
    ON l.customer_id = c.customer_id

WHERE c.customer_id IS NULL;



-- ============================================================
-- 13. LOANS VS CLEAN PRODUCTS
--
-- Powinno zwrócić 0.
-- ============================================================

SELECT
    COUNT(*) AS loans_without_clean_product

FROM v_loans_clean l

LEFT JOIN v_products_clean p
    ON l.product_id = p.product_id

WHERE p.product_id IS NULL;



-- ============================================================
-- 14. CUSTOMER CONSISTENCY IN PAYMENTS
--
-- Sprawdzenie, czy customer_id płatności zgadza się
-- z customer_id przypisanym do kredytu.
--
-- Oczekiwany wynik: 0.
-- ============================================================

SELECT
    COUNT(*) AS inconsistent_payment_customer

FROM v_payments_clean p

JOIN v_loans_clean l
    ON p.loan_id = l.loan_id

WHERE p.customer_id <> l.customer_id;



-- ============================================================
-- 15. SNAPSHOT CUSTOMER CONSISTENCY
--
-- customer_id w snapshot powinien być zgodny
-- z właścicielem kredytu.
--
-- Oczekiwany wynik: 0.
-- ============================================================

SELECT
    COUNT(*) AS inconsistent_snapshot_customer
FROM v_loan_monthly_snapshot_clean s
JOIN v_loans_clean l
    ON s.loan_id = l.loan_id
WHERE s.customer_id <> l.customer_id;



-- ============================================================
-- 16. SNAPSHOT PRODUCT CONSISTENCY
--
-- product_id w snapshot powinien być zgodny
-- z product_id kredytu.
--
-- Oczekiwany wynik: 0.
-- ============================================================

SELECT
    COUNT(*) AS inconsistent_snapshot_product
FROM v_loan_monthly_snapshot_clean s
JOIN v_loans_clean l
    ON s.loan_id = l.loan_id
WHERE s.product_id <> l.product_id;



-- ============================================================
-- 17. DUPLICATE LOAN-MONTH VALIDATION
--
-- Jeden kredyt powinien posiadać jeden snapshot
-- w danym miesiącu.
--
-- Powinno zwrócić 0 rekordów.
-- ============================================================

SELECT
    loan_id,
    snapshot_month,
    COUNT(*) AS duplicate_count
FROM v_loan_monthly_snapshot_clean
GROUP BY
    loan_id,
    snapshot_month
HAVING COUNT(*) > 1;



-- ============================================================
-- 18. FINAL CLEAN LAYER VALIDATION
--
-- Cztery główne relacje powinny zwrócić po 0.
-- ============================================================

SELECT
    'Loans without customer' AS check_name,
    COUNT(*) AS issue_count
FROM v_loans_clean l
LEFT JOIN v_customers_clean c
    ON l.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT
    'Loans without product',
    COUNT(*)
FROM v_loans_clean l
LEFT JOIN v_products_clean p
    ON l.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT
    'Payments without clean loan',
    COUNT(*)
FROM v_payments_clean p
LEFT JOIN v_loans_clean l
    ON p.loan_id = l.loan_id
WHERE l.loan_id IS NULL
UNION ALL
SELECT
    'Snapshots without clean loan',
    COUNT(*)
FROM v_loan_monthly_snapshot_clean s
LEFT JOIN v_loans_clean l
    ON s.loan_id = l.loan_id
WHERE l.loan_id IS NULL;

