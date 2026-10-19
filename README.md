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

## **Tools:**
- **Microsoft Power BI** — used to build the interactive report, visualizations, filters, and drillthrough pages.
- **Power Query** — used to clean, transform, and prepare the source data for the analytical model.
- **DAX** — used to create measures and calculations for sales, margin, growth, and other business metrics.

## Struktura danych

Podstawą analizy jest pięć powiązanych ze sobą tabel.

| Tabela | Opis | Liczba rekordów |
|---|---|---:|
| `customers` | Informacje o klientach, w tym segment klienta, wiek, status zatrudnienia, miesięczny dochód, lokalizacja, scoring kredytowy i profil ryzyka. | 50 000 |
| `loans` | Informacje o umowach kredytowych, w tym kwota kredytu, oprocentowanie, okres, data udzielenia, data zapadalności, LTV, cel i status kredytu. | 72 000 |
| `loan_monthly_snapshot` | Miesięczny obraz każdego aktywnego kredytu, obejmujący saldo do spłaty, liczbę dni opóźnienia (Days Past Due), miesięczny status kredytu, przychody odsetkowe i szacowaną stratę kredytową. | 1 265 930 |
| `payments` | Historia spłat, w tym termin płatności, data płatności, kwota należna, kwota zapłacona, status płatności i liczba dni opóźnienia. | 480 300 |
| `products` | Słownik produktów kredytowych zawierający nazwę produktu, segment klienta, rodzaj zabezpieczenia, rodzaj spłaty, stopę bazową i roczną stawkę opłat. | 8 |
| **Łącznie** |  | **1 868 238** |

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

Przed rozpoczęciem analizy portfela kredytowego sprawdzono jakość danych we wszystkich pięciu głównych tabelach:

- `customers`
- `loans`
- `loan_monthly_snapshot`
- `payments`
- `products`

W ramach kontroli sprawdzono między innymi:

- brakujące wartości,
- duplikaty,
- nieprawidłowe wartości liczbowe,
- niespójności logiczne,
- poprawność dat,
- spójność kategorii tekstowych,
- integralność referencyjną,
- powiązania pomiędzy klientami, kredytami, płatnościami i produktami.

Najważniejsze problemy oraz wybrane fragmenty zapytań SQL pokazujące sposób ich rozwiązania przedstawiono poniżej.

Pełny zestaw zapytań kontrolnych znajduje się w pliku:

`NOVABANK_data_analysis.sql`

Po zakończeniu kontroli utworzono pięć oczyszczonych widoków SQL przeznaczonych do dalszej analizy. Oryginalne tabele pozostawiono bez zmian, dzięki czemu zachowano dane źródłowe i możliwość porównania ich z danymi po zastosowaniu reguł czyszczenia.

---

## Etapy przygotowania danych

### 👤 Tabela `customers`

Tabela `customers` została sprawdzona pod kątem brakujących wartości, duplikatów identyfikatorów klientów, poprawności wieku, poziomu dochodów, scoringu kredytowego oraz spójności kategorii takich jak `customer_type`, `employment_status` i `risk_profile`.

Najważniejsze problemy dotyczyły brakujących wartości w kolumnach `monthly_income_pln` i `city`.

---

#### 1. Brakujące wartości `monthly_income_pln`

W kolumnie `monthly_income_pln` brakowało wartości dla **140 klientów**.

```sql
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE monthly_income_pln IS NULL
    ) AS missing_income
FROM customers;
```


![Missing_Income](images/missing_monthly_income.png)

Brakujących dochodów nie zastępowano średnią ani medianą, ponieważ nie było wystarczających informacji pozwalających wiarygodnie określić rzeczywisty dochód klienta. Wartości pozostawiono jako `NULL`.

Dzięki temu rekord klienta nadal może być wykorzystywany w analizie, a jednocześnie do danych nie są wprowadzane sztucznie oszacowane wartości, które mogłyby zniekształcić analizę ryzyka lub segmentację klientów.

**Potencjalne usprawnienie:** W systemie źródłowym warto wprowadzić obowiązkową walidację dochodu dla produktów, w których informacja ta jest wymagana do oceny zdolności kredytowej.

---

#### 2. Brakujące informacje o mieście

W **85 rekordach** brakowało informacji o mieście.

Brakujące wartości były zapisane jako pusty tekst, a nie jako `NULL`.

```sql
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE city IS NULL
    ) AS null_city,
    COUNT(*) FILTER (
        WHERE city = ''
    ) AS empty_city
FROM customers;
```

![Missing_Income](images/missing_city.png)

Brakujące wartości zastąpiono w wartością `Unknown`.

Klientów bez informacji o mieście nie usuwano, ponieważ brak lokalizacji nie oznacza, że rekord klienta jest nieprawidłowy. Zastąpienie pustych wartości kategorią `Unknown` pozwala zachować klientów w analizie bez przypisywania im sztucznej lokalizacji.

**Potencjalne usprawnienie:** Walidować pole miasta w momencie rejestracji klienta lub wyboru adresu z kontrolowanej listy lokalizacji.

---

#### 3. Weryfikacja zakresów biznesowych

Sprawdzono również, czy podstawowe atrybuty klientów mieszczą się w logicznych zakresach.

```sql
SELECT *
FROM customers
WHERE age < 18
   OR age > 100
   OR credit_score < 300
   OR credit_score > 850
   OR monthly_income_pln < 0;
```

Kontrola obejmowała:

- wiek klienta,
- credit score,
- miesięczny dochód.

Przed utworzeniem widoku przyjęto trzy podstawowe warunki walidacyjne: wiek klienta powinien mieścić się w zakresie od 18 do 100 lat, `credit_score` w zakresie 300–850 przyjętym w projekcie jako prawidłowy zakres scoringu kredytowego, a miesięczny dochód może pozostać nieznany (`NULL`), lecz jeśli jest dostępny, nie powinien być ujemny.

Na tej podstawie utworzono widok:

```sql
CREATE OR REPLACE 
VIEW v_customers_clean AS
SELECT
    customer_id,
    customer_type,
    age,
    employment_status,
    monthly_income_pln,
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
```

Po zastosowaniu reguł w oczyszczonych widokach SQL pozostało wszystkich **50 000 klientów**.

---

### 💳 Tabela `loans`

Tabela `loans` została sprawdzona pod kątem brakujących wartości, unikalności `loan_id`, wysokości kwoty kredytu, oprocentowania, okresu kredytowania, poprawności dat oraz powiązań z klientami i produktami.

Najważniejsze problemy dotyczyły:

- **45 kredytów z nieprawidłowym oprocentowaniem**,
- **35 kredytów z nieprawidłową początkową kwotą kredytu**.

---

#### 1. Nieprawidłowe oprocentowanie

W 45 rekordach znaleziono wartości `interest_rate <= 0`.

```sql
SELECT *
FROM loans
WHERE interest_rate <= 0;
```

![Interest_rate](images/interest_rate.png)

Wartości te uznano za nieprawidłowe dla analizowanego portfela.

Nie zastępowano ich średnim oprocentowaniem ani stawką przypisaną do produktu, ponieważ nie było wiadomo, jaka wartość powinna występować w konkretnym rekordzie.

Kredyty te nie zostały uwzględnione w widoku `v_loans_clean`, który służy jako źródło danych do dalszej analizy.

Takie podejście pozwala uniknąć wprowadzania sztucznie oszacowanych stóp procentowych, które później wpływałyby na przychody odsetkowe i rentowność portfela.

**Potencjalne usprawnienie:** Walidować oprocentowanie już w momencie zapisu umowy kredytowej i blokować wartości mniejsze lub równe zero.

---

#### 2. Nieprawidłowe wartości `original_amount_pln`

W **35 rekordach** występowała wartość `original_amount_pln <= 0`.

```sql
SELECT *
FROM loans
WHERE original_amount_pln <= 0;
```
![Original_amount](images/original_amount.png)

Ujemna lub zerowa wartość początkowa kredytu nie opisuje prawidłowej umowy kredytowej.

Rekordów nie poprawiano automatycznie, ponieważ nie było możliwości jednoznacznego odtworzenia prawidłowej kwoty.

Rekordy te nie zostały uwzględnione w widoku `v_loans_clean`.

**Potencjalne usprawnienie:** Wprowadzić ograniczenie w systemie źródłowym uniemożliwiające zapis kredytu z kwotą mniejszą lub równą zero.

---

#### 3. Kontrola spójności kredytów

Przeprowadzono również dodatkowe kontrole:

```sql
SELECT *
FROM loans
WHERE term_months <= 0
   OR maturity_date < origination_date;
```
Sprawdzono, czy:

- okres kredytowania jest większy od zera,
- data zapadalności nie występuje przed datą udzielenia kredytu.

Na tej podstawie utworzono widok:

```sql
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
```

W zbiorze danych pozostają tylko kredyty posiadające poprawnego klienta i produkt.

Liczba kredytów zmniejszyła się z:

**72 000 do 71 920**

Łącznie wykluczono **80 rekordów**.

---

#### 4. Brakujące wartości LTV

Sprawdzono również brakujące wartości `ltv`.

Analiza wykazała, że brakujące LTV występowało wyłącznie dla produktów typu `Unsecured`, natomiast kredyty `Secured` posiadały wartość tego wskaźnika.

Brak LTV nie został więc potraktowany jako błąd jakości danych.

Dla kredytu niezabezpieczonego nie istnieje wartość zabezpieczenia, dlatego brak wskaźnika Loan-to-Value jest logiczny.

Wartości pozostawiono bez zmian.

**Potencjalne usprawnienie:** Dokumentować w modelu danych, że `NULL` w LTV oznacza „not applicable” dla produktów niezabezpieczonych.

---

### 💰 Tabela `payments`

Tabela `payments` została sprawdzona pod kątem brakujących wartości, duplikatów `payment_id`, pełnych duplikatów rekordów, ujemnych kwot, ujemnych wartości DPD, poprawności dat oraz powiązań z kredytami i klientami.

Najważniejszym problemem było **300 zduplikowanych rekordów płatności**.

---

#### 1. Zduplikowane identyfikatory płatności

Duplikaty zostały wykryte za pomocą:

```sql
SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

![Duplicates](images/duplicates.png)

Pozostawienie duplikatów mogłoby prowadzić do:

- zawyżenia całkowitej kwoty płatności,
- zawyżenia liczby płatności,
- zniekształcenia Collection Ratio,
- błędnej oceny zachowania płatniczego klientów.

---

#### 2. Weryfikacja pełnych duplikatów

Dodatkowo sprawdzono, czy rekordy z powielonym `payment_id` są identycznymi kopiami.

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

Samo powtórzenie identyfikatora nie zawsze oznacza pełny duplikat, dlatego przed usunięciem danych sprawdzono komplet wartości w rekordzie.

---

#### 3. Usunięcie duplikatów

W obrębie każdego `payment_id` zachowano tylko pierwszy rekord.

Pełny widok przygotowany do dalszej analizy:

```sql
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
```

Dodatkowe połączenie z `v_loans_clean` zapewnia, że płatności dotyczące wcześniej wykluczonych kredytów również nie są wykorzystywane w analizie.

Liczba rekordów zmniejszyła się z:

**480 300 do 479 486**

Łącznie wykluczono **814 rekordów**.

Różnica jest większa niż liczba samych duplikatów, ponieważ część płatności była powiązana z kredytami wcześniej wykluczonymi z widoku `v_loans_clean`.

**Potencjalne usprawnienie:** Wprowadzić jednoznaczny identyfikator transakcji płatniczej oraz unikalne ograniczenie na poziomie systemu źródłowego.

---

### 📅 Tabela `loan_monthly_snapshot`

Tabela `loan_monthly_snapshot` została sprawdzona pod kątem duplikatów, nieprawidłowych wartości `loan_age_months`, `outstanding_balance_pln`, `days_past_due`, `monthly_interest_income_pln`, 
`estimated_credit_loss_pln`,    

---

#### 1. Zduplikowane obserwacje kredytu i miesiąca

Każdy kredyt powinien posiadać maksymalnie jeden rekord dla danego miesiąca.

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

Duplikaty mogłyby prowadzić do podwójnego zliczania salda, przychodów odsetkowych oraz liczby aktywnych kredytów.

---

#### 2. Nieprawidłowe wartości w snapshotach

Sprawdzono również nielogiczne wartości:

```sql
SELECT *
FROM loan_monthly_snapshot
WHERE loan_age_months < 0
   OR outstanding_balance_pln < 0
   OR days_past_due < 0
   OR monthly_interest_income_pln < 0
   OR estimated_credit_loss_pln < 0;
```

Podczas tej kontroli znaleziono ujemne wartości `monthly_interest_income_pln`.

Dalsza analiza wykazała jednak, że wszystkie takie rekordy były powiązane z kredytami posiadającymi nieprawidłowe ujemne `interest_rate`.

Problem nie był więc niezależnym błędem tabeli snapshot, lecz skutkiem błędnych danych w tabeli `loans`.

Zamiast filtrować ujemny przychód bezpośrednio w tabeli snapshot, problem usunięto u źródła poprzez wykluczenie błędnych kredytów.

```sql
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
```

Takie podejście usuwa przyczynę błędu zamiast jedynie jego skutku i zapobiega propagowaniu nieprawidłowych danych do KPI.

Liczba rekordów zmniejszyła się z:

**1 265 930 do 1 264 613**

Łącznie wykluczono **1 317 snapshotów**.

**Potencjalne usprawnienie:** Walidować oprocentowanie kredytu przed generowaniem miesięcznych snapshotów, tak aby błędna wartość nie mogła wpływać na późniejsze przychody odsetkowe.

---

### 📦 Tabela `products`

Tabela `products` pełni funkcję wymiaru produktowego.

Sprawdzono:

- brakujące wartości,
- duplikaty `product_id`,
- kompletność nazw produktów,
- `customer_segment`,
- `security_type`,
- `repayment_type`,
- `base_rate`,
- `annual_fee_rate`,
- spójność kategorii tekstowych.

Przykładowe kontrole:

```sql
SELECT DISTINCT customer_segment
FROM products
ORDER BY customer_segment;
SELECT DISTINCT security_type
FROM products
ORDER BY security_type;
SELECT DISTINCT repayment_type
FROM products
ORDER BY repayment_type;
```

Sprawdzono również ujemne wartości stawek:

```sql
SELECT *
FROM products
WHERE base_rate < 0
   OR annual_fee_rate < 0;
```

Nie zidentyfikowano istotnych problemów wymagających korekty.

Mimo to utworzono osobny widok przeznaczony do dalszej analizy:

```sql
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
```

Dzięki temu Power BI korzysta z uporządkowanych i zwalidowanych widoków SQL zamiast bezpośrednio z tabel źródłowych.

W tabeli pozostało wszystkich **8 produktów**.

**Potencjalne usprawnienie:** Ograniczyć wartości pól kategorycznych do kontrolowanego słownika na poziomie systemu źródłowego.

---

Sprawdzono również relacje pomiędzy tabelami oraz sprawdzono utworzone widoki.

Przykładowo zweryfikowano, czy każda płatność odnosi się do istniejącego kredytu:

```sql
SELECT
    p.*
FROM payments p
LEFT JOIN loans l
    ON p.loan_id = l.loan_id
WHERE l.loan_id IS NULL;
```

Analogiczne kontrole przeprowadzono dla relacji:

- `loans → customers`,
- `loans → products`,
- `payments → loans`,
- `payments → customers`,
- `loan_monthly_snapshot → loans`.


## Model danych 🔗

Po przygotowaniu danych zostały one zorganizowane w relacyjny model Power BI oparty na tabeli `v_loans_clean`, która pełni centralną rolę i łączy informacje o klientach, produktach, miesięcznych stanach kredytów oraz płatnościach.

Większość relacji ma klasyczną strukturę jeden-do-wielu. 


Najważniejsze relacje w modelu:

| From | Cardinality | To | Filter direction | Status |
| --- | --- | --- | --- | --- |
| `v_loan_monthly_snapshot_clean[loan_id]` | `*:1` | `v_loans_clean[loan_id]` | `v_loans_clean → v_loan_monthly_snapshot_clean` | Active |
| `v_loans_clean[customer_id]` | `*:1` | `v_customers_clean[customer_id]` | `v_customers_clean → v_loans_clean` | Active |
| `v_loans_clean[product_id]` | `*:1` | `v_products_clean[product_id]` | `v_products_clean → v_loans_clean` | Active |
| `v_payments_clean[loan_id]` | `*:1` | `v_loans_clean[loan_id]` | `v_loans_clean → v_payments_clean` | Active |

Tabela `v_customers_clean` zawiera jeden rekord dla każdego klienta. Jeden klient może posiadać wiele kredytów, dlatego relacja z `v_loans_clean` ma charakter `1:*`. Dzięki temu filtrowanie po typie klienta, profilu ryzyka, scoringu kredytowym czy lokalizacji może wpływać na analizę przypisanych do niego kredytów.

Tabela `v_products_clean` pełni funkcję wymiaru produktowego. Jeden produkt kredytowy może występować w wielu umowach kredytowych. Relacja z `v_loans_clean` umożliwia analizę portfela według takich cech jak nazwa produktu, segment klienta, rodzaj zabezpieczenia czy sposób spłaty.

Tabela `v_loans_clean` pełni centralną rolę w modelu. Każdy kredyt jest przypisany do jednego klienta i jednego produktu, ale może być powiązany z wieloma płatnościami oraz wieloma miesięcznymi obserwacjami. Dzięki temu stanowi główny punkt łączący informacje opisowe z danymi transakcyjnymi i miesięcznymi.

Tabela `v_loan_monthly_snapshot_clean` przechowuje miesięczny stan każdego kredytu. Jeden kredyt może pojawiać się w niej wielokrotnie — po jednym rekordzie dla każdego miesiąca. Na podstawie tej tabeli analizowane są między innymi saldo do spłaty, Days Past Due, miesięczny przychód odsetkowy oraz Estimated Credit Loss.

Tabela `v_payments_clean` zawiera historię spłat. Jeden kredyt może posiadać wiele płatności, dlatego relacja z `v_loans_clean` również ma strukturę `1:*`. Tabela ta służy przede wszystkim do analizy zachowania płatniczego klientów oraz wskaźnika Collection Ratio.

Relacje w modelu są aktywne i wykorzystują jednokierunkowe filtrowanie od tabel po stronie `1` do tabel po stronie `*`. Dzięki temu filtr wybrany na poziomie klienta lub produktu może przejść przez `v_loans_clean` i wpłynąć na dane dotyczące miesięcznych stanów kredytów oraz płatności.

Taki układ pozwala analizować portfel z kilku perspektyw jednocześnie: klienta, produktu, kredytu, zachowania w czasie oraz historii spłat.

![Model relationships](images/data_model.png)

## Analiza danych przy użyciu DAX 📈

Po zbudowaniu modelu danych utworzono miary DAX, które przekształcają dane o kredytach, miesięcznych stanach portfela oraz płatnościach w kluczowe wskaźniki wykorzystywane w analizie ryzyka kredytowego i rentowności.

Najważniejsze obszary analizy obejmują:

- wartość portfela kredytowego,
- liczbę aktywnych kredytów,
- poziom zaległości DPD30+ i DPD90+,
- przychody odsetkowe,
- Estimated Credit Loss,
- Risk Adjusted Income,
- bieżący stan portfela dla najnowszego miesiąca,
- skuteczność spłat klientów.

Poniżej przedstawiono najważniejsze miary używane w raporcie.

```DAX
Outstanding Balance =
SUM(
    v_loan_monthly_snapshot_clean[outstanding_balance_pln]
)
```

Oblicza łączną wartość salda pozostającego do spłaty w bieżącym kontekście filtrowania.

Miara jest wykorzystywana do analizy wielkości portfela kredytowego oraz jego zmian w czasie.

```DAX
DPD30 Rate =
DIVIDE(
    [DPD30 Loans],
    [Active Loans],
    0
)
```

Oblicza udział kredytów z opóźnieniem wynoszącym co najmniej 30 dni w całkowitej liczbie aktywnych kredytów.

Miara pozwala obserwować wczesne pogorszenie jakości portfela.

```DAX
DPD90 Rate =
DIVIDE(
    [DPD90 Loans],
    [Active Loans],
    0
)
```

Oblicza udział kredytów z opóźnieniem wynoszącym co najmniej 90 dni.

Wskaźnik jest jednym z głównych elementów analizy ryzyka i służy do porównywania jakości portfela pomiędzy produktami, segmentami klientów i profilami ryzyka.

```DAX
Interest Income =
SUM(
    v_loan_monthly_snapshot_clean[monthly_interest_income_pln]
)
```

Oblicza łączną wartość przychodów odsetkowych wygenerowanych przez analizowany portfel.

```DAX
Estimated Credit Loss =
SUM(
    v_loan_monthly_snapshot_clean[estimated_credit_loss_pln]
)
```

Oblicza łączną wartość szacowanych strat kredytowych.

Miara jest wykorzystywana do oceny wpływu ryzyka kredytowego na wynik portfela.

```DAX
Risk Adjusted Income =
[Interest Income] - [Estimated Credit Loss]
```

Oblicza różnicę pomiędzy przychodami odsetkowymi a szacowaną stratą kredytową.

W projekcie miara ta pełni funkcję prostego wskaźnika dochodu skorygowanego o ryzyko i pozwala ocenić, czy przychody generowane przez portfel rekompensują oczekiwane straty kredytowe.

```DAX
Current Outstanding Balance =
VAR LatestDate = [Latest Snapshot Date]
RETURN
CALCULATE(
    [Outstanding Balance],
    v_loan_monthly_snapshot_clean[snapshot_month] = LatestDate
)
```

Oblicza saldo portfela dla najnowszego dostępnego miesiąca.

Miara jest wykorzystywana w kartach KPI oraz w analizach przekrojowych pokazujących aktualny stan portfela.

```DAX
Current Active Loans =
VAR LatestDate = [Latest Snapshot Date]
RETURN
CALCULATE(
    [Active Loans],
    v_loan_monthly_snapshot_clean[snapshot_month] = LatestDate
)
```

Oblicza liczbę aktywnych kredytów dla najnowszego dostępnego miesiąca.

```DAX
Current DPD90 Rate =
VAR LatestDate = [Latest Snapshot Date]
RETURN
CALCULATE(
    [DPD90 Rate],
    v_loan_monthly_snapshot_clean[snapshot_month] = LatestDate
)
```

Zwraca wartość DPD90 Rate dla najnowszego dostępnego miesiąca.

Miara jest wykorzystywana do prezentowania aktualnego poziomu poważnych zaległości w portfelu.

```DAX
Collection Ratio =
DIVIDE(
    [Total Paid Amount],
    [Total Due Amount],
    0
)
```

Oblicza relację pomiędzy faktycznie zapłaconą kwotą a kwotą należną.

Wskaźnik pokazuje skuteczność spłat klientów w analizowanym portfelu.

```DAX
Payment Count =
COUNTROWS(v_payments_clean)
```

Oblicza liczbę rekordów płatności.

Miara jest wykorzystywana do porównywania liczby płatności według statusu, np. `On time` i `Late`.

Pełny słownik miar DAX znajduje się w pliku **`NovaBank_DAX_Measures.txt`**.

## Struktura raportu i przebieg analizy 📊

Raport Power BI składa się łącznie z **6 stron**. Cztery z nich tworzą główną historię analityczną, natomiast dwie dodatkowe wspierają bardziej szczegółową eksplorację danych za pomocą funkcji **Tooltip** i **Drillthrough**.

Analiza została ułożona tak, aby przechodzić od ogólnego obrazu portfela, przez koncentrację ryzyka według produktów i klientów, aż do zachowań płatniczych oraz wyniku skorygowanego o ryzyko.

---

### 1. Credit Portfolio Executive Overview 🏠

Pierwsza strona odpowiada na pytanie:

**Jak wygląda ogólna kondycja portfela kredytowego i jak zmieniała się ona w czasie?**

Strona prezentuje najważniejsze KPI dla aktualnego stanu portfela:

- **Current Outstanding Balance**,
- **Current Active Loans**,
- **Current DPD90 Rate**,
- **Current Risk Adjusted Income**.

Dodatkowo znajdują się na niej dwa wykresy czasowe:

- zmiana wartości **Outstanding Balance**,
- zmiana **DPD30 Rate** i **DPD90 Rate**.

Strona może być filtrowana za pomocą:

- `snapshot_month`,
- `customer_segment`,
- `product_name`.

![Report page 1](images/Strona_1.png)

#### Najważniejsze obserwacje 💡

Aktualna wartość portfela wynosi około **8,52 mld PLN**, przy około **67,6 tys. aktywnych kredytów**.

Wartość portfela rosła bardzo dynamicznie — z poziomu poniżej **1 mld PLN na początku 2024 roku** do około **9 mld PLN w 2026 roku**, po czym nastąpił niewielki spadek do obecnego poziomu.

Pomimo silnego wzrostu portfela **DPD90 Rate pozostawał stosunkowo stabilny**, zwykle na poziomie około **0,2–0,3%**. DPD30 Rate utrzymywał się głównie w przedziale około **0,8–1,0%**.

Oznacza to, że rozwój portfela nie przełożył się na proporcjonalne pogorszenie poziomu poważnych zaległości.

Jednocześnie **Current Risk Adjusted Income wynosi około -54,96 mln PLN**, co pokazuje, że stabilny poziom DPD90 nie oznacza automatycznie korzystnego wyniku po uwzględnieniu Estimated Credit Loss.

---

### 2. Risk Concentration by Product 💳

Druga strona przesuwa analizę z poziomu całego portfela na poziom poszczególnych produktów kredytowych.

Odpowiada przede wszystkim na pytanie:

**W których produktach koncentruje się największa ekspozycja i najwyższe ryzyko?**

Analizowane są trzy główne obszary:

- **Current Outstanding Balance by Product**,
- **Current DPD90 Rate by Product**,
- **Risk Adjusted Income by Product**.

Strona może być filtrowana za pomocą:

- `snapshot_month`,
- `security_type`,
- `repayment_type`.

![Report page 2](images/Strona_2.png)

#### Najważniejsze obserwacje 💡

Największą ekspozycję posiada **Mortgage**, którego saldo wynosi około **3,2 mld PLN**, czyli około **37–38% całego aktualnego portfela**.

Kolejne największe produkty to:

- **SME Term Loan** — około **2,0 mld PLN**,
- **SME Investment Loan** — około **1,5–1,6 mld PLN**.

Łącznie te trzy produkty odpowiadają za większość całkowitej ekspozycji portfela, co wskazuje na wyraźną koncentrację wartości kredytów w kilku produktach.

Jednocześnie najwyższy **Current DPD90 Rate** występuje dla **Business Overdraft** i wynosi około **0,8%**, mimo że produkt ten posiada stosunkowo niewielką ekspozycję.

**SME Term Loan** również wyróżnia się podwyższonym poziomem DPD90 — około **0,5%**.

Z kolei **Mortgage**, mimo największego salda, posiada jeden z najniższych poziomów DPD90.

Pokazuje to, że **wartość ekspozycji i intensywność ryzyka nie są tym samym**:

- Mortgage generuje przede wszystkim ryzyko koncentracji wynikające z dużej skali,
- Business Overdraft charakteryzuje się najwyższą intensywnością zaległości.

Analiza Risk Adjusted Income pokazuje również, że największy ujemny wynik przypada na Mortgage, następnie SME Term Loan i SME Investment Loan.

Oznacza to, że produkt o relatywnie niskim DPD90 może nadal mieć duży wpływ na wynik portfela, jeżeli jego ekspozycja jest bardzo wysoka.

---

### 3. Customer Risk Drivers 👥

Trzecia strona skupia się na pytaniu:

**Jakie cechy klientów są związane z wyższym poziomem ryzyka kredytowego?**

Główna macierz porównuje klientów Retail i SME według profilu ryzyka, wykorzystując:

- **Current Outstanding Balance**,
- **Current Active Loans**,
- **Current DPD90 Rate**.

Dodatkowe wykresy pokazują:

- Current DPD90 Rate według `risk_profile`,
- Current DPD30 Rate i Current DPD90 Rate według `Credit Score Band`.

Dostępne filtry:

- `customer_type`,
- `risk_profile`,
- `Credit Score Band`.

![Report page 3](images/Strona_3.png)

#### Najważniejsze obserwacje 💡

Segment **Retail** odpowiada za około **6,65 mld PLN**, czyli około **78% aktualnego salda portfela**, natomiast SME za około **1,87 mld PLN**.

Current DPD90 Rate wynosi:

- **Retail:** około **0,30%**,
- **SME:** około **0,26%**.

Różnica pomiędzy segmentami nie jest więc duża, natomiast znacznie większe różnice występują pomiędzy profilami ryzyka.

Current DPD90 Rate według profilu ryzyka wynosi:

- **Very High:** **0,72%**,
- **High:** **0,42%**,
- **Medium:** **0,25%**,
- **Low:** **0,19%**,
- **Very Low:** **0,14%**.

Widoczna jest więc wyraźna zależność: wraz ze wzrostem profilu ryzyka rośnie poziom poważnych zaległości.

Największą wartość ekspozycji posiada jednak grupa **Medium**, z saldem około **3,07 mld PLN**. Oznacza to, że najwyższy poziom DPD nie zawsze występuje tam, gdzie znajduje się największa część portfela.

Podobną zależność pokazuje Credit Score Band. Wraz ze wzrostem scoringu spada zarówno DPD30 Rate, jak i DPD90 Rate.

Najwyższy poziom zaległości występuje w grupie **<580**, natomiast najniższy w grupie **780+**.

Oznacza to, że zarówno **Risk Profile**, jak i **Credit Score** dobrze różnicują klientów pod względem ryzyka kredytowego.

---

### 4. Payments & Profitability 💰

Czwarta strona łączy zachowania płatnicze klientów z analizą wyniku finansowego portfela.

Odpowiada na pytanie:

**Czy wysoka skuteczność spłat przekłada się również na korzystny wynik po uwzględnieniu ryzyka kredytowego?**

Strona wykorzystuje między innymi:

- **Risk Adjusted Income**,
- **Collection Ratio**,
- **Payment Count**,
- **Interest Income**,
- **Estimated Credit Loss**.

Dostępne filtry:

- `product_name`,
- `customer_segment`,
- `payment_status`.

![Report page 4](images/Strona_4.png)

#### Najważniejsze obserwacje 💡

**Collection Ratio wynosi 99,52%**, a zdecydowana większość płatności posiada status `On time`.

Pokazuje to bardzo wysoką skuteczność bieżących spłat.

Jednocześnie Risk Adjusted Income dla analizowanego okresu wynosi około **-1,10 mld PLN**.

W ramach przyjętej w projekcie definicji oznacza to, że suma Estimated Credit Loss przewyższa wygenerowane przychody odsetkowe.

Na wykresie produktowym widać, że Estimated Credit Loss jest wyższy od Interest Income dla głównych produktów, szczególnie:

- SME Term Loan,
- Mortgage,
- SME Investment Loan.

Najważniejszy wniosek z tej strony jest więc taki, że **wysoka skuteczność płatności nie oznacza automatycznie dodatniego wyniku skorygowanego o ryzyko**.

Portfel może mieć bardzo dobry Collection Ratio i jednocześnie generować ujemny Risk Adjusted Income, jeżeli poziom oczekiwanych strat kredytowych jest wysoki.

---

### 5. Tooltip — podsumowanie produktu 💬

Raport zawiera również ukrytą stronę typu **Tooltip**, która dostarcza dodatkowego kontekstu bez opuszczania aktualnego wykresu.

Po wskazaniu produktu użytkownik może zobaczyć:

- **Current Outstanding Balance**,
- **Current DPD90 Rate**,
- **Estimated Credit Loss**,
- **Risk Adjusted Income**,
- **Collection Ratio**.

Tooltip umożliwia szybkie porównanie skali ekspozycji, poziomu ryzyka i wyniku produktu bez przechodzenia do osobnej strony raportu.

---

### 6. Drillthrough — szczegółowa analiza produktu 🔎

Raport zawiera również stronę typu **Drillthrough** opartą na polu:

`product_name`

Pozwala ona przejść z analizy produktowej do bardziej szczegółowego widoku wybranego produktu.

Tabela zawiera między innymi:

- `product_name`,
- `risk_profile`,
- **Current Outstanding Balance**,
- **Current Active Loans**,
- **Current DPD30 Rate**,
- **Current DPD90 Rate**,
- **Estimated Credit Loss**,
- **Risk Adjusted Income**,
- **Collection Ratio**.

Dzięki temu możliwe jest sprawdzenie, które profile ryzyka w ramach wybranego produktu odpowiadają za największą ekspozycję i najwyższy poziom zaległości.


## Rekomendacje biznesowe ✅

Analiza wskazuje kilka obszarów wymagających szczególnej uwagi.

- **Business Overdraft powinien być dokładniej monitorowany ze względu na najwyższy DPD90 Rate.** Warto przeanalizować limity kredytowe, profile klientów oraz zasady odnawiania ekspozycji.

- **SME Term Loan wymaga monitorowania zarówno pod względem ryzyka, jak i skali ekspozycji.** Produkt łączy stosunkowo dużą wartość portfela z jednym z najwyższych poziomów DPD90.

- **Mortgage wymaga kontroli ryzyka koncentracji.** Pomimo niskiego DPD90 produkt odpowiada za największą część całego portfela, dlatego nawet niewielkie pogorszenie jakości może mieć istotny wpływ na wynik banku.

- **Risk Profile i Credit Score powinny pozostać istotnymi elementami monitorowania klientów.** Oba wskaźniki wyraźnie różnicują poziom zaległości i mogą być wykorzystywane do określania intensywności monitoringu.

- **Klienci z kategorii Very High oraz niskimi wartościami Credit Score powinni być analizowani bardziej szczegółowo.** Można rozważyć dodatkowe limity, częstszy monitoring lub bardziej konserwatywne zasady przyznawania finansowania.

- **Wysoki Collection Ratio powinien być utrzymywany, ale nie powinien być analizowany w oderwaniu od Estimated Credit Loss.** Dobra skuteczność bieżących płatności nie oznacza automatycznie, że portfel generuje korzystny wynik po uwzględnieniu ryzyka.

- **Analiza rentowności produktów powinna uwzględniać zarówno skalę ekspozycji, jak i ryzyko.** Sam poziom DPD nie wystarcza do oceny ekonomicznej produktu.

---

## Możliwości dalszego rozwoju analizy 🚀

Wyniki wskazują kilka kierunków, które można rozwinąć w kolejnych etapach projektu.

- **Analiza migracji DPD.** Warto zbadać, jak kredyty przechodzą pomiędzy poziomami `Current`, DPD30+, DPD60+ i DPD90+ oraz które grupy klientów najczęściej pogarszają swoją jakość.

- **Vintage analysis.** Kredyty można porównywać według miesiąca lub roku udzielenia, aby sprawdzić, czy nowsze kohorty zachowują się lepiej czy gorzej od wcześniejszych.

- **Analiza roll-rate.** Można zmierzyć prawdopodobieństwo przejścia kredytu z jednej kategorii zaległości do kolejnej.

- **Porównanie produktów secured i unsecured.** Dalsza analiza może sprawdzić, czy zabezpieczenie rzeczywiście przekłada się na niższy poziom DPD i Estimated Credit Loss.

- **Rozwinięcie analizy rentowności.** Obecny Risk Adjusted Income jest uproszczonym wskaźnikiem opartym na Interest Income i Estimated Credit Loss. W bardziej zaawansowanej analizie można dodać koszt finansowania, koszty operacyjne, opłaty oraz koszt kapitału.

- **Model predykcyjny ryzyka.** Credit Score, Risk Profile, typ produktu, historia DPD, dochód i inne cechy mogą zostać wykorzystane do stworzenia modelu przewidującego prawdopodobieństwo przejścia klienta do DPD90+.

- **System wczesnego ostrzegania.** Klienci, których DPD lub inne wskaźniki pogarszają się w kolejnych miesiącach, mogliby być automatycznie oznaczani do dodatkowego monitoringu.

## Podsumowanie 📝

Projekt pokazuje, jak można przeprowadzić kompletny proces analizy portfela kredytowego — od kontroli jakości danych i przygotowania spójnych widoków SQL, przez budowę modelu relacyjnego w Power BI, aż po stworzenie raportu prowadzącego użytkownika od ogólnego obrazu portfela do bardziej szczegółowej analizy produktów, klientów, płatności i ryzyka.

Analiza została oparta na pięciu głównych tabelach obejmujących klientów, kredyty, miesięczne stany kredytów, płatności i produkty. Po weryfikacji jakości danych zachowano tabele źródłowe bez zmian, a do dalszej analizy wykorzystano oczyszczone widoki SQL. Pozwoliło to usunąć duplikaty, wykluczyć nieprawidłowe kredyty, zachować logiczne braki danych oraz zapewnić spójność relacji pomiędzy tabelami.

Raport Power BI składa się z czterech głównych stron analitycznych oraz dodatkowych stron Tooltip i Drillthrough. Taki układ pozwala przejść od ogólnej kondycji portfela, przez koncentrację ryzyka według produktów i klientów, aż do analizy zachowań płatniczych i wyniku skorygowanego o ryzyko.

Z perspektywy biznesowej NovaBank posiada portfel o wartości około **8,52 mld PLN** i około **67,6 tys.** aktywnych kredytów. W analizowanym okresie portfel dynamicznie rósł, podczas gdy DPD90 Rate pozostawał relatywnie stabilny i obecnie wynosi około **0,29%**.

Ryzyko nie jest jednak rozłożone równomiernie. Mortgage odpowiada za największą część ekspozycji, natomiast Business Overdraft charakteryzuje się najwyższym poziomem DPD90. Analiza klientów pokazuje również wyraźną zależność pomiędzy poziomem ryzyka a risk_profile oraz Credit Score Band — klienci o wyższym profilu ryzyka i niższym scoringu częściej wykazują zaległości.

Jednocześnie Collection Ratio wynosi **99,52%**, co wskazuje na bardzo wysoką skuteczność bieżących spłat. Mimo tego Risk Adjusted Income pozostaje ujemny. W ramach przyjętej w projekcie definicji oznacza to, że przychody odsetkowe nie rekompensują w pełni Estimated Credit Loss.

Najważniejszy wniosek z projektu jest więc taki, że stabilny poziom zaległości i wysoka skuteczność spłat nie oznaczają automatycznie niskiego ryzyka ani dodatniego wyniku skorygowanego o ryzyko. Ocena portfela wymaga jednoczesnego uwzględnienia skali ekspozycji, jakości klientów, poziomu DPD oraz wpływu oczekiwanych strat kredytowych.

