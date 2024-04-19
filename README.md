# DBS - Zadanie 5
**Adam Candrák**
FIIT STU

## Zmeny od zadania 4
- Zmeny nazvov tabuliek do pluralu a zjednotenie štýlu
- Vymazanie `Ended_exhibitions`
- Pridanie novych ENUM typov 
  - `status` pouzity v `artefacts`
  - `ownership` pouzity v `artefacts`
  - `institute_types` pouzity v `institutes`
- v tabulke `artefacts`, zmena `condition` -> `state`
- Skratenie názvov stĺpcov a tabulky `foreign_institute` -> `institutes`
- Zmena nazvu tabulky `control` -> `checks`
  - a `duration` INT -> INTERVAL
- `loan_id` v tabulke `check` je nullable v pripade ze by sme chceli kontroli na vlastnych exemplaroch
- v `institutes` rozdelenie `address` na viacero stlpcov

## Popis Funkcií


## Constraints
- `artefacts`
  - Je mozne aby artefact bol zapisany v zone zatial co je v exhibicii ktora sa v danej zone nedeje