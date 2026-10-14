# Banking-credit-risk-analytics

## Opis projektu

Projekt koncentruje się na analizie portfela kredytowego symulowanego banku **NovaBank**, działającego na polskim rynku bankowości detalicznej oraz obsługującego małe i średnie przedsiębiorstwa (MŚP).

Zbiór danych zawiera informacje o klientach, kredytach, miesięcznych wynikach kredytów, historii spłat oraz produktach kredytowych. Analiza odzwierciedla realistyczny proces analityczny w bankowości: rozpoczyna się od weryfikacji jakości danych i ich przygotowania za pomocą SQL, a następnie obejmuje analizę biznesową i utworzenie dashboardu w programie Excel.

Główne obszary analizy to wielkość i struktura portfela, trendy dotyczące zaległości w spłacie, ryzyko kredytowe według produktu i segmentu klientów, zachowania płatnicze oraz rentowność skorygowana o ryzyko.

## Cel biznesowy

Głównym celem projektu jest ocena jakości i profilu ryzyka portfela kredytowego NovaBanku oraz wskazanie obszarów, które w największym stopniu przyczyniają się do pogorszenia jego jakości.

Analiza ma odpowiedzieć na następujące pytania biznesowe:

- Jak zmienia się wartość portfela kredytowego w czasie?
- Czy rośnie udział kredytów z opóźnieniem w spłacie wynoszącym co najmniej 30 lub 90 dni (DPD)?
- Które produkty kredytowe wiążą się z najwyższym ryzykiem?
- Czym różni się ryzyko kredytowe klientów detalicznych i klientów z segmentu MŚP?
- Czy kredyty zabezpieczone są mniej ryzykowne niż kredyty niezabezpieczone?
- Jak rodzaj spłaty, na przykład ratalna (Installment) lub odnawialna (Revolving), wpływa na ryzyko portfela?
- Które profile ryzyka klientów i przedziały scoringu kredytowego wiążą się z większymi zaległościami?
- Jak skutecznie klienci spłacają swoje zobowiązania?
- Czy wyższe ryzyko kredytowe jest rekompensowane odpowiednio wysokimi przychodami odsetkowymi?
- Które produkty generują najwyższy dochód skorygowany o ryzyko?

Celem końcowym jest przedstawienie przejrzystego obrazu wyników portfela oraz wsparcie kierownictwa w identyfikacji segmentów wymagających dokładniejszego monitorowania lub zmian w polityce kredytowej.

---

## Struktura danych

Podstawą analizy jest pięć powiązanych ze sobą tabel.

| Tabela | Opis |
|---|---|
| `customers` | Informacje o klientach, w tym segment klienta, wiek, status zatrudnienia, miesięczny dochód, lokalizacja, scoring kredytowy i profil ryzyka. |
| `loans` | Informacje o umowach kredytowych, w tym kwota kredytu, oprocentowanie, okres, data udzielenia, data zapadalności, LTV, cel i status kredytu. |
| `loan_monthly_snapshot` | Miesięczny obraz każdego aktywnego kredytu, obejmujący saldo do spłaty, liczbę dni opóźnienia (Days Past Due), miesięczny status kredytu, przychody odsetkowe i szacowaną stratę kredytową. |
| `payments` | Historia spłat, w tym termin płatności, data płatności, kwota należna, kwota zapłacona, status płatności i liczba dni opóźnienia. |
| `products` | Słownik produktów kredytowych zawierający nazwę produktu, segment klienta, rodzaj zabezpieczenia, rodzaj spłaty, stopę bazową i roczną stawkę opłat. |

Główną tabelą analityczną jest `loan_monthly_snapshot`, w której każdy wiersz przedstawia status konkretnego kredytu w danym miesiącu.

Taka struktura pozwala analizować portfel w czasie i obliczać kluczowe wskaźniki, takie jak:

- Saldo do spłaty (Outstanding Balance)
- Aktywne kredyty (Active Loans)
- Wskaźnik DPD 30+
- Wskaźnik DPD 90+
- Przychody odsetkowe (Interest Income)
- Szacowana strata kredytowa (Estimated Credit Loss)
- Dochód skorygowany o ryzyko (Risk Adjusted Income)
- Wskaźnik ściągalności (Collection Ratio)



## 🧹 Jakość i przygotowanie danych

Przed rozpoczęciem analizy portfela kredytowego sprawdzono jakość danych we wszystkich pięciu podstawowych tabelach:

- `customers`
- `loans`
- `loan_monthly_snapshot`
- `payments`
- `products`

Weryfikacja obejmowała:

- brakujące wartości,
- zduplikowane rekordy,
- nieprawidłowe wartości liczbowe,
- niespójności w logice biznesowej,
- integralność referencyjną między powiązanymi tabelami,
- zduplikowane obserwacje dla kredytu i miesiąca.

Poniżej przedstawiono najważniejsze problemy z jakością danych oraz wybrane zapytania SQL użyte do ich wykrycia.

Pełny zestaw zapytań weryfikacyjnych znajduje się w pliku:

`NOVABANK_data_analysis.sql`

---

## 👤 Tabela `customers`

W tabeli `customers` sprawdzono brakujące wartości, zduplikowane identyfikatory klientów oraz nieprawidłowe atrybuty, takie jak wiek, dochód i scoring kredytowy.

Zidentyfikowano dwa główne problemy z jakością danych:

- brakujące wartości w kolumnie `monthly_income_pln`,
- brakujące wartości w kolumnie `city`.

### 1. Brakujące dochody klientów

Wartości w kolumnie `monthly_income_pln` były brakujące dla **140 klientów**.

```sql
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE monthly_income_pln IS NULL
    ) AS missing_income
FROM customers;
``` 

Brakujących wartości nie zastępowano automatycznie wartościami szacunkowymi, ponieważ nie było wystarczających informacji, aby ustalić prawidłowy dochód bez wprowadzania sztucznych założeń.

### 2. Brakujące informacje o mieście
W 85 rekordach brakowało wartości w kolumnie miasta.
```sql
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE city IS NULL
    ) AS missing_city
FROM customers;
```

Na potrzeby raportowania brakujące wartości miasta można przypisać w oczyszczonej warstwie analitycznej do kategorii `Unknown` (Nieznane). Dzięki temu rekordy pozostają w zbiorze danych, bez przypisywania im nieprawidłowej lokalizacji.


### 3. Weryfikacja atrybutów klientów
Przeprowadzono dodatkowe kontrole w celu wykrycia potencjalnie nieprawidłowych atrybutów klientów.

```sql
SELECT *
FROM customers
WHERE age < 18
   OR age > 100
   OR credit_score < 300
   OR credit_score > 850
   OR monthly_income_pln < 0;
```

Weryfikacja pozwoliła upewnić się, że atrybuty klientów mieszczą się w uzasadnionych biznesowo zakresach, zanim wykorzystano je w dalszej analizie.

## 💳 Tabela `loans`
Tabela `loans` zawiera informacje o poszczególnych umowach kredytowych.
Główne problemy z jakością danych dotyczyły nieprawidłowych wartości liczbowych w kolumnach:
- interest_rate,
- original_amount_pln.

### 1. Ujemne oprocentowanie
W 45 rekordach kredytów występowała nieprawidłowa, ujemna wartość oprocentowania.

```sql
SELECT *
FROM loans
WHERE interest_rate <= 0;
```

Na potrzeby symulowanego portfela kredytów detalicznych i dla MŚP ujemne oprocentowanie uznano za nieprawidłowe.
Rekordy te wykluczono z oczyszczonego analitycznego zbioru kredytów.

### 2. Ujemne kwoty początkowe kredytów
W 35 rekordach występowała ujemna wartość w kolumnie `original_amount_pln`.

```sql
SELECT *
FROM loans
WHERE original_amount_pln <= 0;
```

Ujemna początkowa kwota kredytu nie opisuje prawidłowej umowy kredytowej, dlatego uznano ją za problem z jakością danych. Rekordy te wykluczono z oczyszczonej warstwy analitycznej zamiast zastępować wartościami oszacowanymi w sposób sztuczny.

### 3. Kontrola spójności danych o kredytach
Zastosowano dodatkowe reguły biznesowe, aby wykryć inne potencjalnie nieprawidłowe rekordy kredytów.
```sql
SELECT *
FROM loans
WHERE original_amount_pln <= 0
   OR interest_rate <= 0
   OR term_months <= 0
   OR maturity_date < origination_date;
```

Weryfikacja sprawdza, czy:
- początkowa kwota kredytu jest dodatnia,
- oprocentowanie jest dodatnie,
- okres kredytowania jest prawidłowy,
- data zapadalności przypada po dacie udzielenia kredytu.

## 💰 Tabela `payments`
Tabela `payments` zawiera informacje o zaplanowanych i zrealizowanych spłatach kredytów.
Głównym zidentyfikowanym problemem z jakością danych były zduplikowane rekordy płatności.
### 1. Zduplikowane identyfikatory płatności
Zduplikowane wartości `payment_id` wykryto przez grupowanie rekordów płatności według identyfikatora.

```sql
SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

Dane źródłowe zawierały 300 celowo zduplikowanych rekordów płatności.
Ponieważ duplikaty mogły zawyżać kwoty spłat i zniekształcać wskaźniki dotyczące zachowań płatniczych, należało je usunąć przed dalszą analizą.

### 2. Weryfikacja pełnych duplikatów rekordów
Oprócz sprawdzenia zduplikowanych identyfikatorów porównano kompletne rekordy płatności, aby ustalić, czy duplikaty są identycznymi kopiami.

```sql
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
```

To rozróżnienie jest istotne, ponieważ powielony identyfikator nie zawsze oznacza, że dwa wiersze są dokładnymi duplikatami.

### 3. Nieprawidłowe wartości płatności
Przeprowadzono dodatkowe kontrole nieprawidłowych wartości kwot oraz liczby dni opóźnienia (Days Past Due).
```sql
SELECT *
FROM payments
WHERE due_amount_pln < 0
   OR paid_amount_pln < 0
   OR days_past_due < 0;
``` 

Ta weryfikacja pozwala upewnić się, że kwoty spłat i miary zaległości są logicznie spójne, zanim zostaną wykorzystane w analizie portfela.

## 📅 Tabela `loan_monthly_snapshot`
Tabela `loan_monthly_snapshot` jest główną tabelą faktów wykorzystywaną w analizie.
Każdy wiersz przedstawia miesięczny status konkretnego kredytu.
Chociaż w tej tabeli nie wprowadzono celowo istotnych problemów z jakością danych, przeprowadzono kilka kontroli, ponieważ służy ona do obliczania głównych KPI portfela.

### 1. Zduplikowane obserwacje kredytu i miesiąca
Każdy kredyt powinien mieć tylko jedną obserwację dla danego miesiąca sprawozdawczego.

```sql
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
```
Zduplikowane obserwacje kredytu i miesiąca mogłyby prowadzić do podwójnego zliczania sald do spłaty, przychodów odsetkowych i strat kredytowych.

### 2. Nieprawidłowe wartości w migawce
```sql
SELECT *
FROM loan_monthly_snapshot
WHERE loan_age_months < 0
   OR outstanding_balance_pln < 0
   OR days_past_due < 0
   OR monthly_interest_income_pln < 0
   OR estimated_credit_loss_pln < 0;
```

Kontrole te przeprowadzono, aby potwierdzić, że główne miary portfela nadają się do dalszej analizy.

## 📦 Tabela `products`
Tabela `products` pełni funkcję wymiaru produktów i zawiera informacje o produktach kredytowych banku.
Nie zidentyfikowano w niej istotnych, celowo wprowadzonych problemów z jakością danych.
Weryfikacja koncentrowała się głównie na brakujących wartościach i spójności atrybutów kategorycznych.
```sql
SELECT DISTINCT customer_segment
FROM products;

SELECT DISTINCT security_type
FROM products;

SELECT DISTINCT repayment_type
FROM products;
```

Ta kontrola pozwala upewnić się, że kategorie takie jak Retail, SME, Secured, Unsecured, Installment i Revolving są zapisywane w spójny sposób.

## 🔗 Integralność referencyjna
Sprawdzono również relacje między głównymi tabelami.
Na przykład zweryfikowano, czy dla każdego rekordu płatności wartość `loan_id` występuje w tabeli `loans`.

```sql
SELECT
    p.*
FROM payments p
LEFT JOIN loans l
    ON p.loan_id = l.loan_id
WHERE l.loan_id IS NULL;
```

Podobne kontrole przeprowadzono dla relacji między:
- tabelami `loans` i `customers`,
- tabelami `loans` i `products`,
- tabelami `loan_monthly_snapshot` i `loans`,
- tabelami `payments` i `loans`.
Ten krok pomaga zapobiec opieraniu wyników analizy na rekordach, których nie można powiązać z podstawowymi encjami bankowymi.
