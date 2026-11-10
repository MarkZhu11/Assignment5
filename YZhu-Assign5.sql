-- Question 1: Count the available containers of antibiotics.
SELECT SUM(i.quantityOnHand) AS availableContainers
FROM item AS i
WHERE i.itemDescription = 'bottle of antibiotics';

-- Question 2: Find qualifying volunteers by telephone prefix and last name.
SELECT v.volunteerName
FROM volunteer AS v
WHERE v.volunteerTelephone IS NOT NULL
  AND v.volunteerTelephone NOT LIKE '2%'
  AND v.volunteerName NOT LIKE '% Jones';

-- Question 3: Find volunteers assigned to transporting tasks.
SELECT DISTINCT v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
  ON a.volunteerId = v.volunteerId
JOIN task AS t
  ON t.taskCode = a.taskCode
JOIN task_type AS tt
  ON tt.taskTypeId = t.taskTypeId
WHERE tt.taskTypeName = 'transporting';

-- Question 4: Find tasks that have no volunteer assignments.
SELECT DISTINCT t.taskDescription
FROM task AS t
LEFT JOIN assignment AS a
  ON a.taskCode = t.taskCode
WHERE a.volunteerId IS NULL;

-- Question 5: Find package types containing an item described as a bottle.
SELECT DISTINCT pt.packageTypeName
FROM package_type AS pt
JOIN package AS p
  ON p.packageTypeId = pt.packageTypeId
JOIN package_contents AS pc
  ON pc.packageId = p.packageId
JOIN item AS i
  ON i.itemId = pc.itemId
WHERE i.itemDescription LIKE '%bottle%';

-- Question 6: Find items that are not included in any package.(By the way, can we use not exist in final?)
SELECT i.itemDescription
FROM item AS i
WHERE NOT EXISTS (
    SELECT 1
    FROM package_contents AS pc
    WHERE pc.itemId = i.itemId
);

-- Question 7: Find tasks assigned to volunteers who live in New Jersey.
SELECT DISTINCT t.taskDescription
FROM task AS t
JOIN assignment AS a
  ON a.taskCode = t.taskCode
JOIN volunteer AS v
  ON v.volunteerId = a.volunteerId
WHERE v.volunteerAddress LIKE '%NJ';

-- Question 8: Find volunteers whose assignments began in the first half of 2021.
SELECT DISTINCT v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
  ON a.volunteerId = v.volunteerId
WHERE a.startDateTime >= '2021-01-01 00:00:00'
  AND a.startDateTime < '2021-07-01 00:00:00';

-- Question 9: Find volunteers assigned to packing tasks whose packages include spam.
SELECT DISTINCT v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
  ON a.volunteerId = v.volunteerId
JOIN task AS t
  ON t.taskCode = a.taskCode
JOIN task_type AS tt
  ON tt.taskTypeId = t.taskTypeId
JOIN package AS p
  ON p.taskCode = t.taskCode
JOIN package_contents AS pc
  ON pc.packageId = p.packageId
JOIN item AS i
  ON i.itemId = pc.itemId
WHERE tt.taskTypeName = 'packing'
  AND i.itemDescription = 'can of spam';

-- Question 10: Find items worth exactly $100 within an individual package.
SELECT DISTINCT i.itemDescription
FROM item AS i
JOIN package_contents AS pc
  ON pc.itemId = i.itemId
WHERE i.itemValue * pc.itemQuantity = 100;

-- Question 11: Count distinct assigned volunteers for every task status.
SELECT ts.taskStatusName,
       COUNT(DISTINCT a.volunteerId) AS volunteerCount
FROM task_status AS ts
LEFT JOIN task AS t
  ON t.taskStatusId = ts.taskStatusId
LEFT JOIN assignment AS a
  ON a.taskCode = t.taskCode
GROUP BY ts.taskStatusId,
         ts.taskStatusName
ORDER BY volunteerCount DESC;

-- Question 12: Find the task whose packages have the greatest total weight.
SELECT t.taskCode,
       SUM(p.packageWeight) AS weight
FROM task AS t
JOIN package AS p
  ON p.taskCode = t.taskCode
GROUP BY t.taskCode
ORDER BY weight DESC
LIMIT 1;

-- Question 13: Count tasks whose type is not packing.
SELECT COUNT(*) AS nonPackingTaskCount
FROM task AS t
JOIN task_type AS tt
  ON tt.taskTypeId = t.taskTypeId
WHERE tt.taskTypeName <> 'packing';

-- Question 14: Find packed items touched by fewer than three distinct volunteers.
SELECT i.itemDescription
FROM item AS i
JOIN package_contents AS pc
  ON pc.itemId = i.itemId
JOIN package AS p
  ON p.packageId = pc.packageId
JOIN task AS t
  ON t.taskCode = p.taskCode
JOIN task_type AS tt
  ON tt.taskTypeId = t.taskTypeId
LEFT JOIN assignment AS a
  ON a.taskCode = t.taskCode
WHERE tt.taskTypeName = 'packing'
GROUP BY i.itemId,
         i.itemDescription
HAVING COUNT(DISTINCT a.volunteerId) < 3;

-- Question 15: Find packages whose total item value is greater than $100.
SELECT p.packageId,
       SUM(i.itemValue * pc.itemQuantity) AS totalValue
FROM package AS p
JOIN package_contents AS pc
  ON pc.packageId = p.packageId
JOIN item AS i
  ON i.itemId = pc.itemId
GROUP BY p.packageId
HAVING SUM(i.itemValue * pc.itemQuantity) > 100
ORDER BY totalValue ASC;
