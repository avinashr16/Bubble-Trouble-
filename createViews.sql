-- ============================================================================
-- CITS1402 Relational Database Management Systems
-- Project: Bubble Trouble
-- Mission 5: Providing Management with a Dashboard
-- File: createViews.sql
-- ============================================================================

DROP VIEW IF EXISTS MonthlySales;
DROP VIEW IF EXISTS MemberSummary;

-- ----------------------------------------------------------------------------
-- View A: MonthlySales
-- ----------------------------------------------------------------------------
CREATE VIEW MonthlySales AS
SELECT 
    strftime('%Y-%m', sales.orderDate) AS orderMonth,
    store.storeName,
    prod.productName,
    SUM(item.quantity) AS totalQuantity,
    SUM(item.lineTotal) AS totalRevenue
FROM OrderItem item
JOIN SalesOrder sales ON item.orderId = sales.orderId
JOIN Store store ON sales.storeId = store.storeId
JOIN Product prod ON item.productId = prod.productId
WHERE item.lineTotal IS NOT NULL
GROUP BY 
    strftime('%Y-%m', sales.orderDate),
    store.storeName,
    prod.productName;

-- ----------------------------------------------------------------------------
-- View B: MemberSummary
-- ----------------------------------------------------------------------------
CREATE VIEW MemberSummary AS
SELECT 
    mem.memberId,
    mem.memberName,
    COUNT(DISTINCT sales.orderId) AS totalOrders,
    COALESCE(SUM(item.quantity), 0) AS totalDrinks,
    COALESCE(SUM(item.lineTotal), 0) AS totalSpent
FROM Member mem
LEFT JOIN SalesOrder sales ON mem.memberId = sales.memberId
LEFT JOIN OrderItem item ON sales.orderId = item.orderId AND item.lineTotal IS NOT NULL
GROUP BY 
    mem.memberId,
    mem.memberName;