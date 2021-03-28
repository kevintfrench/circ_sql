/* 

Created by Daniel Messer http://tanglewoodhill.ddns.net:8085/daniel/useful-polaris-sql
Sometimes, you actually need to know the circ stats for every single item in the collection. That's exactly
what this query does. Note: This query can take a lot of time to run. It's not database intensive, but I recommend running it in the
evening after the library has closed. */

-- We need to be able to pull 0 as a column.
DECLARE @NoCircCount INT
SET @NoCircCount = 0

-- Set up a temporary table for items that *have* circed in the given period of time
DECLARE @ItemCircCount TABLE
(   
    "Count" INT,
    "Title" VARCHAR(500),
    "Author" VARCHAR(500),
    "Barcode" VARCHAR(30),
    "Publication Year" VARCHAR(5),
    "Call Number" VARCHAR(100),
    "Material Type" VARCHAR(250),
    "Collection" VARCHAR(250)
);

INSERT @ItemCircCount
(
    "Count",
    "Title",
    "Author",
    "Barcode",
    "Publication Year",
    "Call Number",
    "Material Type",
    "Collection"
)

-- Populate the table
SELECT
    COUNT(distinct th.TransactionID) AS "Count",
    br.BrowseTitle AS "Title",
    br.BrowseAuthor AS "Author",
    ir.Barcode AS "Barcode",
    br.PublicationYear AS "Publication Year",
    ir.CallNumber AS "Call Number",
    mat.[Description] AS "Material Type",
    col.[Name] AS "Collection"

FROM
    PolarisTransactions.Polaris.TransactionHeaders th WITH (NOLOCK)

LEFT OUTER JOIN
    PolarisTransactions.Polaris.TransactionDetails td WITH (NOLOCK) ON th.TransactionID = td.TransactionID
INNER JOIN
    Polaris.Polaris.ItemRecords ir WITH (NOLOCK) ON td.numValue = ir.ItemRecordID
INNER JOIN
    Polaris.Polaris.BibliographicRecords br WITH (NOLOCK) ON br.BibliographicRecordID = ir.AssociatedBibRecordID
INNER JOIN
    Polaris.Polaris.MaterialTypes mat WITH (NOLOCK) ON mat.MaterialTypeID = ir.MaterialTypeID
INNER JOIN
    Polaris.Polaris.Collections col WITH (NOLOCK) ON col.CollectionID = ir.AssignedCollectionID

WHERE
    th.TransactionTypeID = 6001
AND
    td.TransactionSubTypeID = 38
AND
    th.TransactionDate BETWEEN '2021-01-01 00:00:00.000' AND '2021-01-31 23:59:59' -- Shift these dates around as desired.

GROUP BY
    br.BrowseTitle,
    br.BrowseAuthor,
    ir.Barcode,
    br.PublicationYear,
    ir.CallNumber,
    mat.[Description],
    col.[Name]

-- Now lets go get the items that *have not* circulated. We do this by pulling items that aren't in our @ItemCircCount table.
SELECT
    @NoCircCount AS "Count",
    br.BrowseTitle AS "Title",
    br.BrowseAuthor AS "Author",
    ir.Barcode AS "Barcode",
    br.PublicationYear AS "Publication Year",
    ir.CallNumber AS "Call Number",
    mat.[Description] AS "Material Type",
    col.[Name] AS "Collection"

FROM
    Polaris.Polaris.ItemRecords ir WITH (NOLOCK)

INNER JOIN
    Polaris.Polaris.BibliographicRecords br WITH (NOLOCK) ON br.BibliographicRecordID = ir.AssociatedBibRecordID
INNER JOIN
    Polaris.Polaris.MaterialTypes mat WITH (NOLOCK) ON mat.MaterialTypeID = ir.MaterialTypeID
INNER JOIN
    Polaris.Polaris.Collections col WITH (NOLOCK) ON col.CollectionID = ir.AssignedCollectionID

WHERE
    ir.Barcode NOT IN
(
    SELECT
        Barcode
    FROM
        @ItemCircCount
)

-- Now lets merge the results.
UNION

SELECT * FROM @ItemCircCount

ORDER BY "Count" DESC