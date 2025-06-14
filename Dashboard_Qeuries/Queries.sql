-- Average Margin Tile
SELECT format_percentage(AVG(profit_margin_pct)) AS avg_margin
FROM analytics.ecommerce_dashboard;


-- Total Orders Tile
SELECT COUNT(*) AS total_orders
FROM analytics.ecommerce_dashboard;


-- Total Revenue Tile
SELECT format_currency(SUM(Sales)) AS total_revenue
FROM analytics.ecommerce_dashboard;



--performace breakdown by tag 
SELECT 
    perf_tag,
    COUNT(*) AS order_count,
    SUM(Profit) AS total_profit_raw,  -- Needed for accurate sorting
    AVG(profit_margin_pct) AS avg_margin_raw,  -- Needed for accurate sorting
    format_currency(SUM(Profit)) AS total_profit_display,
    format_percentage(AVG(profit_margin_pct)) AS avg_margin_display
FROM analytics.ecommerce_dashboard
GROUP BY perf_tag
ORDER BY SUM(Profit) DESC; 


-- top performace by catergory 
SELECT * FROM analytics.top_performers;

--top performance by breakdown 
SELECT 
    category,
    total_orders,
    total_profit_display AS profit,
    avg_margin_display AS margin
FROM analytics.category_summary;

--region wise data 
SELECT 
    region,
    total_orders,
    total_profit_raw/1000 AS profit_thousands,
    avg_margin_raw * 5 AS margin_scaled,  -- Scale up margin for visibility
    -- Keep originals for reference
    total_profit_display AS profit_display,
    avg_margin_display AS margin_display
FROM analytics.region_summary
ORDER BY total_profit_raw DESC;

--data 
SELECT 
    Product,
    COUNT(*) AS orders,
    SUM(Profit)/1000 AS total_profit_thousands, -- Scale down profit
    AVG(profit_margin_pct) AS avg_margin_pct,
    -- Or create ratio-based metrics
    COUNT(*) * 10 AS orders_scaled, -- Scale up orders for visibility
    SUM(Profit) AS total_profit_raw,
    AVG(profit_margin_pct) * 100 AS avg_margin_scaled
FROM analytics.ecommerce_dashboard 
WHERE perf_tag IN ('Loss', 'Moderate') 
GROUP BY Product 
HAVING COUNT(*) >= 2 
ORDER BY AVG(profit_margin_pct) ASC 
LIMIT 5;

--recent orders 
SELECT 
    Order_ID,
    Order_Date,
    Region,
    Category,
    Product,
    profit_display AS profit,
    margin_display AS margin,
    perf_tag
FROM analytics.ecommerce_dashboard
WHERE Profit > (SELECT AVG(Profit) FROM analytics.ecommerce_dashboard)
ORDER BY Order_Date DESC
LIMIT 10;