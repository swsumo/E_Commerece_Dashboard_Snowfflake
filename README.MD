#  Ecommerce Sales Analysis Project

##  Project Overview

This project analyzes ecommerce sales data using Snowflake, focusing on:

* Sales, cost, and profit trends
* Region and category performance
* Product-level KPIs and performance tags
* Readable dashboards with currency & percentage formatting

---

##  Technologies Used

* **Snowflake** Data Warehouse
* **SQL** for data transformation and aggregation
* **UDFs** for currency, percentage, and tag formatting
* **Views and Tables** for structured dashboards

---

##  Setup Instructions

1. Run the `snowflake_stage.sql` file located in the `setup/` directory.
2. Upload your `ecommerce_sales_data.csv` file to the Snowflake internal stage (`@analytics.ecom_stage`).
3. Execute all SQL steps to create raw, clean, and dashboard tables along with summary views.

---

##  How to Use

1. Load your dataset using:

   ```sql
   PUT file://<your_path>/ecommerce_sales_data.csv @analytics.ecom_stage;
   ```
2. Run the full setup script:

   ```sql
   -- From within Snowflake Worksheet
   USE DATABASE ecommerce_project;
   USE SCHEMA analytics;
   RUN FILE = 'setup/snowflake_stage.sql';
   ```
3. Explore your dashboard tables and views:

   * `analytics.ecommerce_dashboard`
   * `analytics.region_summary`
   * `analytics.category_summary`
   * `analytics.top_performers`

---

##  Dashboard Queries Included

*  Regional Summary: Total sales, profit, and average margins by region
* ** Category Summary:** Performance across product categories
* ** Top Performers:** Highest revenue, profit, and margin products
* ** Clean Table:** Enhanced with margin calculation and formatting
* ** UDFs:** Custom formatting for currency (`₹`) and percentage (`%`)

---

##  Functions and Tags

* `format_currency(amount)` → `₹12.4K` / `₹2.1M`
* `format_percentage(pct)` → `14.6%`
* `get_perf_tag(margin)` → `Excellent`, `Good`, `Moderate`, `Loss`

---

##  Create a Dashboard

To create a full Snowflake dashboard:

1. Go to **Snowsight** (Snowflake UI).
2. Create a new dashboard.
3. Add a **tile** for each of the following:

   * `SELECT * FROM analytics.region_summary`
   * `SELECT * FROM analytics.category_summary`
   * `SELECT * FROM analytics.top_performers`
   * `SELECT COUNT(*) FROM analytics.ecommerce_raw` *(Total Orders)*
   * `SELECT SUM(Sales) FROM analytics.ecommerce_dashboard` *(Total Sales)*

---

##  Future Improvements

* Integrate with Python/Streamlit for dynamic analytics
* Use Snowflake **Tasks** and **Streams** for automated updates
* Add anomaly detection on unusually high/low margins

---

![Ecommerce Dashboard](Screenshot%202025-06-14%20185249.png)

© 2025 Swapnil Mogal
For queries or suggestions, feel free to connect.
