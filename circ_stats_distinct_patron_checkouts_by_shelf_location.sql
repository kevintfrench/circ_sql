/*
Created by Daniel Messer http://tanglewoodhill.ddns.net:8085/daniel/useful-polaris-sql
This query pulls stats for *distinct* patron check outs based on Shelf Location. In other words, it's checking for
stats where a patron checked out items in a given collection, and only counts that patron once.
*/

SELECT
    o.name AS "Library",
    COUNT(DISTINCT td.numValue) AS "Distinct Patrons Circ"
FROM
    PolarisTransactions.Polaris.TransactionHeaders th WITH (NOLOCK)

JOIN
    PolarisTransactions.Polaris.TransactionDetails td WITH (NOLOCK) ON th.TransactionID = td.TransactionID AND td.TransactionSubTypeID = 6 -- PatronID
JOIN
    PolarisTransactions.Polaris.TransactionDetails td2 WITH (NOLOCK) ON th.TransactionID = td2.TransactionID and td2.TransactionSubTypeID = 296 -- ShelfLocationID
JOIN
    Polaris.Polaris.Organizations o WITH (NOLOCK) ON th.OrganizationID = o.OrganizationID

WHERE
    th.TransactionTypeID = 6001 -- Check out
AND
    th.TranClientDate BETWEEN '2019-08-26 00:00:00.000' AND '2019-12-16 23:59:59.999' -- Set your date range
AND
    th.OrganizationID IN (2,3,4,5,6,109,111) -- Limit to organizations
AND
    td2.numValue IN (5,48,77,121,150) -- Limit to given ShelfLocationIDs

GROUP BY
    o.Name
    
ORDER BY
    o.Name