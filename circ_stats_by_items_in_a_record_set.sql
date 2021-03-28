/* 
Created by Daniel Messer http://tanglewoodhill.ddns.net:8085/daniel/useful-polaris-sql
This query will pull circulation stats, checkouts and renewals, for items contained in a given
item record set. Useful for tracking circ stats on displays, special collections, etc. */

SELECT 
    CASE td2.numValue WHEN '1' THEN 'Renewal' ELSE 'Check Out' END,
    COUNT(*) as "Circ Count"

FROM
    PolarisTransactions.Polaris.TransactionHeaders AS [th] WITH (NOLOCK)

INNER JOIN
    PolarisTransactions.Polaris.TransactionDetails AS [td1] WITH (NOLOCK) ON th.TransactionID = td1.TransactionID AND td1.TransactionSubTypeID = '38'
INNER JOIN
    Polaris.Polaris.ItemRecordSets AS [irs] WITH (NOLOCK) ON td1.numValue = irs.ItemRecordID
LEFT OUTER JOIN
    PolarisTransactions.Polaris.TransactionDetails AS [td2] WITH (NOLOCK) ON th.TransactionID = td2.TransactionID AND td2.TransactionSubTypeID = '124'

WHERE
    th.TransactionTypeID = '6001'

-- SET CIRC DATES BELOW
AND th.TransactionDate BETWEEN '2020-02-01 00:00:00.000' AND '2020-02-28 23:59:59'


AND
    irs.RecordSetID = '1598' -- Put your ItemRecordSetID here

GROUP BY
    CASE td2.numValue WHEN '1' THEN 'Renewal' ELSE 'Check Out' END