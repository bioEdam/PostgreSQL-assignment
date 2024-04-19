-- helper query for showing all exhibitions with their artefacts and their zones
SELECT
    e.id,
    e.title,
    e.description,
    e.start_date,
    e.end_date,
    e.description,
    ARRAY_AGG(DISTINCT artefacts.name) AS artefacts,
    ARRAY_AGG(DISTINCT zones.name) AS zones
FROM
    exhibitions AS e
LEFT JOIN
    artefact_exhibition AS ax ON e.id = ax.exhibition_id
LEFT JOIN
    artefacts ON ax.artefact_id = artefacts.id
LEFT JOIN
    exhibition_zone AS ez ON e.id = ez.exhibition_id
LEFT JOIN
    zones ON ez.zone_id = zones.id
GROUP BY
    e.id;