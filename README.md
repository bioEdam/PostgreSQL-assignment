# DBS - Zadanie 5
**Adam Candrák**
FIIT STU

## Obsah
<!-- TOC -->
* [DBS - Zadanie 5](#dbs---zadanie-5)
  * [Obsah](#obsah)
  * [Zmeny od zadania 4](#zmeny-od-zadania-4)
  * [Popis Funkcií](#popis-funkcií)
  * [With Triggers](#with-triggers)
    * ['artefact_exclusivity'](#artefact_exclusivity)
    * ['check_zone_capacity'](#check_zone_capacity)
    * ['correct_date_order'](#correct_date_order)
    * ['log_artefact_changes'](#log_artefact_changes)
    * ['update_updated_at'](#update_updated_at)
    * ['zone_exclusivity'](#zone_exclusivity)
  * [Without Triggers](#without-triggers)
    * ['artefact_arrival'](#artefact_arrival)
    * ['check_artefact_zone'](#check_artefact_zone)
  * [Procedures](#procedures)
    * ['update_current_exhibition'](#update_current_exhibition)
    * ['loan_foreign_artefact'](#loan_foreign_artefact)
    * ['loan_our_artefact'](#loan_our_artefact)
    * ['create_exhibition'](#create_exhibition)
  * [Procesy](#procesy)
    * [Naplánovanie expozície (exhibície)](#naplánovanie-expozície-exhibície)
    * [Vkladanie nového exempláru (artefaktu)](#vkladanie-nového-exempláru-artefaktu)
    * [Presun exempláru (artefaktu) do inej zóny](#presun-exempláru-artefaktu-do-inej-zóny)
    * [Prevzatie exemplá](#prevzatie-exemplá)
  * [Zapožičanie exempláru (artefaktu) z inej inštitúcie](#zapožičanie-exempláru-artefaktu-z-inej-inštitúcie)
  * [Ohraničenia](#ohraničenia)
<!-- TOC -->

## Zmeny od zadania 4
- Zmeny názvov tabuliek do plurálu a zjednotenie štýlu
- Vymazanie `Ended_exhibitions`
- Pridanie nových ENUM typov 
  - `status` použitý v `artefacts`
  - `ownership` použitý v `artefacts`
  - `institute_types` použitý v `institutes`
- v tabulke `artefacts`, zmena `condition` -> `state`
- Skrátenie názvov stĺpcov a tabuľky `foreign_institute` -> `institutes`
- Zmena názvu tabuľky `control` -> `checks`
  - a `duration` INT -> INTERVAL
- `loan_id` v tabuľke `check` je nullable v prípade že by sme chceli kontroli na vlastných exemplároch
- v `institutes` rozdelenie `address` na viacero stĺpcov

## Popis Funkcií

## With Triggers

### 'artefact_exclusivity'
Zabraňuje vytváraniu exhibícií, ktoré by obsahovali artefakty, ktoré sú v zadanom časovom úseku inej exhibície.

### 'check_zone_capacity'
Kontroluje kapacitu zóny pri update `exhibition_id` v artefaktoch. Kontrola prebieha spočítaním výskytov danej ID v artefaktoch a porovnaním s kapacitou zóny.

### 'correct_date_order'
Kontroluje pridávanie dátumov do `exhibition` a `loans` tabuliek. Kontroluje, či dátumy sú v správnom poradí start < end.

### 'log_artefact_changes'
Loguje zmeny v artefaktoch. Pri zmene kategórie, stavu alebo vlastníctva sa vytvor

í nový riadok v tabuľke `artefact_changes`.

### 'update_updated_at'
Tento komicky nazvaná funkcia slúži na aktualizáciu `updated_at` z každej tabuľky. Pri zmene riadku sa aktualizuje `updated_at`.
Pri hľadaní tabuliek, ktoré obsahujú `updated_at` sa používa pg_tables a information_schema.columns.

### 'zone_exclusivity'
Zabraňuje vytváraniu exhibícií, ktoré by obsahovali zóny, ktoré sú v zadanom časovom úseku súčasťou inej exhibície.

## Without Triggers

### 'artefact_arrival'
Funkcia slúži pre zamestnancov a kurátorov na aktualizovanie stavu artefaktu na `in_storage` a pridanie `arrival_date`.

### 'check_artefact_zone'
Funkcia slúži na kontrolu, či artefakt je v správnej zóne. Vracia TRUE, ak je artefakt v zóne, ktorá je súčasťou exhibície, ktorej je aj artefakt súčasťou.
Vo funkcii je použitá procedúra [update_current_exhibition](#update_current_exhibition). 
V prípade, že zóna nie je súčasťou exhibície a zóna tiež nie je súčasťou exhibície, vráti TRUE.

## Procedures

### 'update_current_exhibition'
Procedúra slúži na aktualizáciu `exhibition_id` v tabuľke `artefacts`.
V prípade, že artefakt nie je súčasťou žiadnej exhibície, `exhibition_id` sa nastaví na NULL.

### 'loan_foreign_artefact'
Slúži na vytvorenie nového artefaktu, ktorý sme si vypožičali od inej inštitúcie (inštitúcia musí existovať).
V tejto procedúre sa stav artefaktu nastavý na 'in_transit'.

### 'loan_our_artefact'
Slúži na vypožičanie artefaktu inej inštitúcii. Artefakt musí existovať v databáze a musí mať naše vlastníctvo.

### 'create_exhibition'
Slúži na vytvorenie novej exhibície pre existujúce artefakty a zóny. Pri vytváraní exhibície sa kontrolujú všetky vypožičané exempláre (ownership = 'loaned').
Vďaka [zone_exclusivity](#zone_exclusivity) a [artefact_exclusivity](#artefact_exclusivity) sa kontroluje, či sa vytvára 
exhibícia, ktorá by obsahovala artefakty alebo zóny, ktoré sú súčasťou inej exhibície v zadaný čas.

## Procesy

### Naplánovanie expozície (exhibície)
1. Zistenie ID artefaktov, ktoré chceme vystaviť
2. Zistenie ID zón, ktoré chceme vystaviť
3. Zavolanie procedúry `create_exhibition` s ID artefaktov a zón
4. V `create_exhibition` sa skontroluje, či artefakty a zóny nie sú súčasťou inej exhibície v danom čase
5. Vytvorenie novej exhibície s artefaktami a zónami

### Vkladanie nového exempláru (artefaktu)
1. Jednoduchý INSERT, ktorý vloží nový artefakt
2. Určenie kategórií

### Presun exempláru (artefaktu) do inej zóny
1. Zistenie ID artefaktu a ID zóny
2. Zavolanie funkcie [check_artefact_zone](#check_artefact_zone) s ID artefaktu. Funkcia vráti TRUE, ak je artefakt v správnej zóne.

### Prevzatie exemplá

ru (artefaktu) z inej inštitúcie
1. Na prevzatie sa používa funkcia [loan_our_artefact](#loan_our_artefact). Na vypožičanie sa používa procedúra [loan_foreign_artefact](#loan_foreign_artefact)
2. V prípade, že artefakt je vypožičaný z inej inštitúcie (loan_type = 'loan_in'), je možné ho prevziať s funkciou [artefact_arrival](#artefact_arrival)
3. Funkcia nastaví stav artefaktu na 'in_storage' a pridá `arrival_date` na aktuálny dátum.

## Zapožičanie exempláru (artefaktu) z inej inštitúcie
1. Na vypožičanie sa používa procedúra [loan_foreign_artefact](#loan_foreign_artefact)
2. Táto procedúra vytvorí nový artefakt s ownership = 'loaned' a state = 'in_transit'
3. Vytvorý sa nový riadok v tabuľke `loans` s `loan_type` = 'loan_out' a artefact_id = 'nový artefakt'
   4. V prípade, že artefakt v minulosti už bol vypožičaný, sa vytvorí nový riadok v tabuľke `loans` s `loan_type` = 'loan_out' a artefact_id = 'už existujúci artefakt'

## Ohraničenia
- `artefacts`
  - Je možné, aby artefakt bol vystavený v zóne, ktorá je súčasťou inej exhibície, ktorej ale artefakt nie je súčasťou 
[check_artefact_zone](#check_artefact_zone) nás ale vie informovať, že sa nachádza v zóne, do ktorej nepatrí
  - História pri zmene kategórie sa neukladá
  - `state` môže nezodpovedať skutočnému stavu artefaktu

- `exhibitions`
  - pri vytváraní novej exhibície sa nekontroluje kapacita zón
  - v pripade zmeny udajov sa neuchovava historia
  - artefakty ktoré su evidované ako požicané 
a este nie prevziaté nemôžu byý sučastou novej exhibicie pokial start_date je vačší ako arrival_date 
  
- `checks`
  - kontroly sa nedajú vytvárať hromadne

"Na viac hriechov sa už nepamätám"
```