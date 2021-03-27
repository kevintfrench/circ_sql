/* 
 Created by Daniel Messer http://tanglewoodhill.ddns.net:8085/daniel/useful-polaris-sql
!!! CAUTION !!!
This query updates the ItemCheckouts table en masse to adjust due dates. This cannot be undone.
Use this query to adjust item due dates because of closures, emergencies, and so on.
*/

-- Declare some variables
DECLARE @StartDate datetime;
DECLARE @EndDate datetime;

SET
  @StartDate = '20210215'; -- The date you want to start from, all items on and after this date will be reset to @EndDate
SET
  @EndDate = '20210222'; -- Set this to your new due date

-- Set up a temporary table as an index.
-- This table is used to bypass adjusting the due dates on items that don't make sense to adjust. (eBooks, Laptops, etc)
DECLARE @ItemsOutTemp TABLE
(ItemRecordID INT)

-- Populate that table.
INSERT @ItemsOutTemp

SELECT
  ico.ItemRecordID

FROM
  Polaris.Polaris.ItemCheckouts ico WITH (NOLOCK)

JOIN
  Polaris.Polaris.ItemRecords ir WITH (NOLOCK) ON ir.ItemRecordID = ico.ItemRecordID
WHERE
  ir.MaterialTypeID NOT IN (38,39,161,157,45,164,13,55,133,62,147,148,172,149) -- Eliminate eContent, odds, sods, and special stuff.
AND
  ico.OrganizationID IN (2,3) -- Limit to specific organizations if needed.

-- Now adjust the due dates based upon that table
UPDATE
  Polaris.Polaris.ItemCheckouts
SET
  DueDate = @EndDate
WHERE
  DueDate BETWEEN @StartDate AND @EndDate
  AND ItemRecordID IN (
    SELECT
      ItemRecordID
    FROM
      @ItemsOutTemp
  )