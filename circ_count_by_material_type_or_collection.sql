/*
Created by Daniel Messer http://tanglewoodhill.ddns.net:8085/daniel/useful-polaris-sql
This query pulls circulation (check outs) for a given library or set of libraries. You can limit the circ
stats to a set of given Collections or a set of Material Types.
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
    th.TranClientDate between '2018-08-27 00:00:00.000' and '2018-12-17 23:59:59.999' -- Adjust dates as needed.
AND
    th.OrganizationID in (2,3,4,5,6,109,111) -- Limit by organization IDs. This should match the organization IDs below.
AND
    td.TransactionSubTypeID = 38 -- Look for ItemRecordID in the TransactionDetails table.
AND
    td.numValue in (
        -- Limit to a given material type and/or collection. 
        SELECT
            ir.ItemRecordID
        FROM
            Polaris.Polaris.ItemRecords ir WITH (NOLOCK)
        WHERE
            OwningBranchID IN (2,3,4,5,6,109,111) -- Limit by organization IDs. This should match the organization IDs above.
        --AND
            --MaterialTypeID IN (133) -- Set for a specific material type.
        AND
            AssignedCollectionID IN (432) -- Set for a specific collection
)

GROUP BY
    o.Name 

ORDER BY
    o.Name