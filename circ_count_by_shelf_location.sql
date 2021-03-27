/*
 Created by Daniel Messer http://tanglewoodhill.ddns.net:8085/daniel/useful-polaris-sql 
This query will pull circ stats (check outs) for items with a given set of shelf location codes. Because this
query pulls from the Transactions database, it's historical in nature. Even if the shelf location has changed,
it'll come up in this query based on what that shelf location was at the time.
*/


SELECT
    o.Name AS "Branch/Library",
    COUNT(DISTINCT th.TransactionID) AS "Circ Count"

FROM
    PolarisTransactions.Polaris.TransactionHeaders th WITH (NOLOCK)

INNER JOIN
    PolarisTransactions.Polaris.TransactionDetails td WITH (NOLOCK) ON (th.TransactionID = td.TransactionID)  
INNER JOIN
    Polaris.Polaris.Organizations o WITH (NOLOCK) ON (th.OrganizationID = o.OrganizationID)

WHERE
    th.TransactionTypeID = 6001 -- Item checked out
AND
    th.TranClientDate between '2019-01-28 00:00:00.000' and '2019-05-24 23:59:59.999' -- Adjust dates as needed.
AND
    th.OrganizationID in (2,3,4,5,6,109,111) -- Limit by organization IDs.
AND
    td.TransactionSubTypeID = 296 -- Look for Shelf Location in Transaction Detail
AND
    td.numValue IN (5,48,77,121,150) -- Shelf Location codes

GROUP BY
    o.Name