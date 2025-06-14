CREATE OR REPLACE DATABASE ecommerce_project;
CREATE OR REPLACE SCHEMA analytics;
CREATE OR REPLACE WAREHOUSE ecommerce_wh;


--Create internal stage
CREATE OR REPLACE STAGE analytics.ecom_stage
FILE_FORMAT = (
    TYPE = 'CSV',
    FIELD_OPTIONALLY_ENCLOSED_BY = '"',
    SKIP_HEADER = 1
);

-- basic Raw data table
CREATE OR REPLACE TABLE analytics.ecommerce_raw (
    Order_ID STRING,
    Order_Date DATE,
    Customer_ID STRING,
    Region STRING,
    Segment STRING,
    Category STRING,
    Product STRING,
    Quantity INT,
    Price FLOAT,
    Sales FLOAT,
    Cost FLOAT,
    Profit FLOAT
);


-- copy data
COPY INTO analytics.ecommerce_raw
FROM @analytics.ecom_stage/ecommerce_sales_data.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"' ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE);


show tables;

select * from analytics.ecommerce_raw;


-- Currency formatting function
CREATE OR REPLACE FUNCTION analytics.format_currency(amount FLOAT)
RETURNS STRING
AS $$
    CASE
        WHEN ABS(amount) >= 1000000000 THEN CONCAT('₹', ROUND(amount/1000000000, 2), 'B')
        WHEN ABS(amount) >= 1000000 THEN CONCAT('₹', ROUND(amount/1000000, 2), 'M')
        WHEN ABS(amount) >= 1000 THEN CONCAT('₹', ROUND(amount/1000, 2), 'K')
        ELSE CONCAT('₹', ROUND(amount, 2))
    END
$$;


select * from analytics.ecommerce_raw;


-- Percentage formatting function
CREATE OR REPLACE FUNCTION analytics.format_percentage(pct FLOAT)
RETURNS STRING
AS $$
    CONCAT(ROUND(pct, 1), '%')
$$;



-- Performance tag function (enhanced)
CREATE OR REPLACE FUNCTION analytics.get_perf_tag(profit_margin_pct FLOAT)
RETURNS STRING
AS $$
    CASE
        WHEN profit_margin_pct > 30 THEN 'Excellent'
        WHEN profit_margin_pct > 15 THEN 'Good'
        WHEN profit_margin_pct > 0 THEN 'Moderate'
        ELSE 'Loss'
    END
$$;


-- views
CREATE OR REPLACE TABLE analytics.ecommerce_clean AS
SELECT *,
       ROUND(Profit / NULLIF(Sales, 0) * 100, 2) AS profit_margin_pct,
       -- Add formatted columns for dashboard display
       ROUND(Sales, 2) AS sales_clean,
       ROUND(Profit, 2) AS profit_clean,
       ROUND(Cost, 2) AS cost_clean,
       ROUND(Price, 2) AS price_clean
FROM analytics.ecommerce_raw
WHERE Sales IS NOT NULL;


-- dashboard 
CREATE OR REPLACE TABLE analytics.ecommerce_dashboard AS
SELECT *,
       get_perf_tag(profit_margin_pct) AS perf_tag,
       -- Formatted display columns
       format_currency(sales_clean) AS sales_display,
       format_currency(profit_clean) AS profit_display,
       format_currency(cost_clean) AS cost_display,
       format_currency(price_clean) AS price_display,
       format_percentage(profit_margin_pct) AS margin_display
FROM analytics.ecommerce_clean;


-- Regional Summary with proper formatting
CREATE OR REPLACE VIEW analytics.region_summary AS
SELECT region,
       COUNT(*) AS total_orders,
       ROUND(SUM(Sales), 2) AS total_sales_raw,
       ROUND(SUM(Profit), 2) AS total_profit_raw,
       ROUND(AVG(profit_margin_pct), 2) AS avg_margin_raw,
       -- Formatted display columns
       format_currency(SUM(Sales)) AS total_sales_display,
       format_currency(SUM(Profit)) AS total_profit_display,
       format_percentage(AVG(profit_margin_pct)) AS avg_margin_display
FROM analytics.ecommerce_dashboard
GROUP BY region
ORDER BY total_sales_raw DESC;



-- Category Summary with formatting
CREATE OR REPLACE VIEW analytics.category_summary AS
SELECT category,
       COUNT(*) AS total_orders,
       ROUND(SUM(Sales), 2) AS total_sales_raw,
       ROUND(SUM(Profit), 2) AS total_profit_raw,
       ROUND(AVG(profit_margin_pct), 2) AS avg_margin_raw,
       -- Formatted display columns
       format_currency(SUM(Sales)) AS total_sales_display,
       format_currency(SUM(Profit)) AS total_profit_display,
       format_percentage(AVG(profit_margin_pct)) AS avg_margin_display
FROM analytics.ecommerce_dashboard
GROUP BY category
ORDER BY total_profit_raw DESC;




-- top performance 

CREATE OR REPLACE VIEW analytics.top_performers AS
WITH top_profit AS (
    SELECT 
        'Top Profit Product' AS category,
        Product AS name,
        format_currency(SUM(Profit)) AS value
    FROM analytics.ecommerce_dashboard
    GROUP BY Product
    ORDER BY SUM(Profit) DESC
    LIMIT 1
),
top_revenue AS (
    SELECT 
        'Top Revenue Product' AS category,
        Product AS name,
        format_currency(SUM(Sales)) AS value
    FROM analytics.ecommerce_dashboard
    GROUP BY Product
    ORDER BY SUM(Sales) DESC
    LIMIT 1
),
best_margin AS (
    SELECT 
        'Best Margin Product' AS category,
        Product AS name,
        format_percentage(AVG(profit_margin_pct)) AS value
    FROM analytics.ecommerce_dashboard
    GROUP BY Product
    HAVING COUNT(*) >= 3
    ORDER BY AVG(profit_margin_pct) DESC
    LIMIT 1
)
SELECT * FROM top_profit
UNION ALL
SELECT * FROM top_revenue
UNION ALL
SELECT * FROM best_margin;




