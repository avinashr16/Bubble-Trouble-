-- ============================================================================
-- CITS1402 Relational Database Management Systems
-- Project: Bubble Trouble
-- Mission 4: Historical Pricing (Trigger A) & Bubble Rewards (Trigger B)
-- File: createTriggers.sql
-- ============================================================================

PRAGMA foreign_keys = ON;

DROP TRIGGER IF EXISTS trg_orderitem_price;
DROP TRIGGER IF EXISTS trg_orderitem_loyalty;

-- ----------------------------------------------------------------------------
-- Trigger A: Automatic Historical Pricing
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_orderitem_price
AFTER INSERT ON OrderItem
FOR EACH ROW
WHEN NEW.unitPrice IS NULL
BEGIN
    UPDATE OrderItem
    SET unitPrice = (
        SELECT prod.basePrice + sz.sizeSurcharge
        FROM Product prod, SizeOption sz
        WHERE prod.productId = NEW.productId
          AND sz.size = NEW.size
    )
    WHERE orderId = NEW.orderId 
      AND lineNo = NEW.lineNo;
END;

-- ----------------------------------------------------------------------------
-- Trigger B: Bubble Rewards Line Total
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_orderitem_loyalty
AFTER INSERT ON OrderItem
FOR EACH ROW
WHEN NEW.lineTotal IS NULL
BEGIN
    UPDATE OrderItem
    SET lineTotal = (
        SELECT 
            CASE 
                WHEN CAST(prior.total AS INT) / 10 < CAST(prior.total + NEW.quantity AS INT) / 10
                    THEN (NEW.quantity - 1) * price.unitPrice
                ELSE NEW.quantity * price.unitPrice
            END
        FROM 
            (SELECT COALESCE(SUM(item.quantity), 0) AS total
             FROM OrderItem item
             JOIN SalesOrder sales ON item.orderId = sales.orderId
             WHERE sales.memberId = (
                 SELECT memberId 
                 FROM SalesOrder 
                 WHERE orderId = NEW.orderId
             )
               AND (
                   item.orderId < NEW.orderId 
                   OR (item.orderId = NEW.orderId AND item.lineNo < NEW.lineNo)
               )
            ) AS prior,
            
            (SELECT COALESCE(NEW.unitPrice, prod.basePrice + sz.sizeSurcharge) AS unitPrice
             FROM Product prod, SizeOption sz
             WHERE prod.productId = NEW.productId
               AND sz.size = NEW.size
            ) AS price
    )
    WHERE orderId = NEW.orderId
      AND lineNo = NEW.lineNo;
END;