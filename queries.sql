-- ============================================================================
-- CITS1402 Relational Database Management Systems
-- Project: Bubble Trouble
-- Mission 6: Business Queries
-- File: queries.sql
--
-- STUDENT INSTRUCTIONS
-- 1. Do NOT change the task headings, task numbers, or PRINT statements.
-- 2. Write exactly ONE SQLite query in each STUDENT QUERY area.
-- 3. Every query must end with a semicolon (;).
-- 4. Your query must work for ANY valid Bubble Trouble database.
-- 5. Do NOT hard-code answers from sample data.
-- 6. Do NOT create, alter, insert, update, or delete data in this file.
--
-- Recommended execution:
--     sqlite3 BubbleTrouble.db < queries.sql
-- ============================================================================

.headers on
.mode column
.nullvalue NULL

.print ''
.print '======================================================================'
-- IMPORTANT: Replace 12345678 below with your Student Number
.print ' Student ID: 25031139' 
.print ' CITS1402 - BUBBLE TROUBLE'
.print ' MISSION 6: BUSINESS QUERIES'
.print '======================================================================'
.print ''
.print 'Each task heading is followed by the output of the student query.'
.print ''

-- ============================================================================
-- Q1 - CURRENT MENU                                                        
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q1 - CURRENT MENU'
.print '----------------------------------------------------------------------'
.print 'Task: List productId, productName, category and basePrice for all'
.print '      ACTIVE products. Sort by category, then productName.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q1: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
	productId,
	productName,
	category,
	basePrice
FROM Product
WHERE status = 'ACTIVE'
ORDER BY category, productName;

-- <<< END STUDENT QUERY Q1 >>>

.print '------------------------------ END Q1 ---------------------------------'

-- ============================================================================
-- Q2 - INGREDIENT REACH                                                   
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q2 - INGREDIENT REACH'
.print '----------------------------------------------------------------------'
.print 'Task: For each ingredient, display the ingredient name and the number'
.print '      of DISTINCT products whose recipes use it.'
.print '      Include ingredients that are currently used by no product.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q2: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
	ingr.ingredientName, 
	COUNT(DISTINCT rec.productId) AS productCount
FROM Ingredient ingr
LEFT JOIN Recipe rec ON ingr.ingredientId = rec.ingredientId
GROUP BY ingr.ingredientId, ingr.ingredientName;

-- <<< END STUDENT QUERY Q2 >>>

.print '------------------------------ END Q2 ---------------------------------'

-- ============================================================================
-- Q3 - STORE PERFORMANCE                                                
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q3 - STORE PERFORMANCE'
.print '----------------------------------------------------------------------'
.print 'Task: For each store, display the store name, number of DISTINCT orders'
.print '      and total revenue from priced OrderItem rows.'
.print '      Include stores that have not yet processed an order.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q3: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
    str.storeName,
    COUNT(DISTINCT ord.orderId) AS totalOrders,
    COALESCE(SUM(item.lineTotal), 0) AS totalRevenue
FROM Store str
LEFT JOIN SalesOrder ord ON str.storeId = ord.storeId
LEFT JOIN OrderItem item ON ord.orderId = item.orderId AND item.lineTotal IS NOT NULL
GROUP BY str.storeId, str.storeName;

-- <<< END STUDENT QUERY Q3 >>>

.print '------------------------------ END Q3 ---------------------------------'

-- ============================================================================
-- Q4 - POPULAR PRODUCTS                                                
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q4 - POPULAR PRODUCTS'
.print '----------------------------------------------------------------------'
.print 'Task: Display each product whose total quantity sold is at least'
.print '      20 drinks. Show productName and total quantity sold.'
.print '      Display the most popular product first.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q4: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
	prod.productName, 
	SUM(item.quantity) AS totalQuantity
FROM Product prod
JOIN OrderItem item ON prod.productId = item.productId
GROUP BY prod.productId, prod.productName
HAVING SUM(item.quantity) >= 20
ORDER BY totalQuantity DESC;

-- <<< END STUDENT QUERY Q4 >>>

.print '------------------------------ END Q4 ---------------------------------'

-- ============================================================================
-- Q5 - ACTIVE PRODUCTS NEVER ORDERED                                   
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q5 - ACTIVE PRODUCTS NEVER ORDERED'
.print '----------------------------------------------------------------------'
.print 'Task: Using a SUBQUERY, find all ACTIVE products that have never'
.print '      appeared in any OrderItem. Return productId and productName.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q5: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
	productId, 
	productName
FROM Product
WHERE status = 'ACTIVE'
AND productId NOT IN (SELECT DISTINCT productId FROM OrderItem);

-- <<< END STUDENT QUERY Q5 >>>

.print '------------------------------ END Q5 ---------------------------------'

-- ============================================================================
-- Q6 - HIGH-VALUE MEMBERS                                              
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q6 - HIGH-VALUE MEMBERS'
.print '----------------------------------------------------------------------'
.print 'Task: Find members whose total spending is STRICTLY GREATER than the'
.print '      average total spending of members who have spent more than zero.'
.print '      Return memberName and total spending.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q6: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
    mem.memberName,
    SUM(item.lineTotal) AS totalSpent
FROM Member mem
JOIN SalesOrder sales ON mem.memberId = sales.memberId
JOIN OrderItem item ON sales.orderId = item.orderId
GROUP BY mem.memberId, mem.memberName
HAVING totalSpent > (
    SELECT 
		AVG(sub_spent)
    FROM (
        SELECT 
			SUM(sub_item.lineTotal) AS sub_spent
        FROM SalesOrder sub_sales
        JOIN OrderItem sub_item ON sub_sales.orderId = sub_item.orderId
        GROUP BY sub_sales.memberId
        HAVING SUM(sub_item.lineTotal) > 0
    )
);

-- <<< END STUDENT QUERY Q6 >>>

.print '------------------------------ END Q6 ---------------------------------'

-- ============================================================================
-- Q7 - STORE BEST SELLERS                                              
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q7 - STORE BEST SELLERS'
.print '----------------------------------------------------------------------'
.print 'Task: For EACH store, return the product or products with the greatest'
.print '      total quantity sold at that store. TIES MUST BE RETAINED.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q7: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
    str.storeName,
    prod.productName,
    SUM(item.quantity) AS totalQty
FROM Store str
JOIN SalesOrder ord ON str.storeId = ord.storeId
JOIN OrderItem item ON ord.orderId = item.orderId
JOIN Product prod ON item.productId = prod.productId
GROUP BY str.storeId, str.storeName, prod.productId, prod.productName
HAVING SUM(item.quantity) = (
    SELECT 
		MAX(sub_qty)
    FROM (
        SELECT 
			SUM(sub_item.quantity) AS sub_qty
        FROM SalesOrder sub_ord
        JOIN OrderItem sub_item ON sub_ord.orderId = sub_item.orderId
        WHERE sub_ord.storeId = str.storeId
        GROUP BY sub_item.productId
    )
);

-- <<< END STUDENT QUERY Q7 >>>

.print '------------------------------ END Q7 ---------------------------------'

-- ============================================================================
-- Q8 - ABOVE-CATEGORY PERFORMANCE                                     
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q8 - ABOVE-CATEGORY PERFORMANCE'
.print '----------------------------------------------------------------------'
.print 'Task: Using a CORRELATED SUBQUERY, find products whose total quantity'
.print '      sold is STRICTLY GREATER than the average total quantity sold by'
.print '      products in the SAME category.'
.print '      Return productName, category and total quantity sold.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q8: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>

SELECT 
    prod.productName,
    prod.category,
    SUM(item.quantity) AS totalSold
FROM Product prod
JOIN OrderItem item ON prod.productId = item.productId
GROUP BY prod.productId, prod.productName, prod.category
HAVING SUM(item.quantity) > (
    SELECT 
        AVG(cat_sum)
    FROM (
        SELECT 
            COALESCE(SUM(sub_item.quantity), 0) AS cat_sum
        FROM Product sub_prod
        LEFT JOIN OrderItem sub_item ON sub_prod.productId = sub_item.productId
        WHERE sub_prod.category = prod.category
        GROUP BY sub_prod.productId
    )
);

-- <<< END STUDENT QUERY Q8 >>>

.print '------------------------------ END Q8 ---------------------------------'

.print ''
.print '======================================================================'
.print ' END OF MISSION 6'
.print ' Review the output above carefully before submitting.'
.print '======================================================================'
.print ''
