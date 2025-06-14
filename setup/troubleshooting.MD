# Troubleshooting Guide for Ecommerce Snowflake Setup

### 1. COPY INTO Failed: File Not Found
**Error:** `Cannot perform operation. File does not exist.`
- Make sure `ecommerce_sales_data.csv` is uploaded to `@analytics.ecom_stage`.
- Use: `PUT file://<local_path>/ecommerce_sales_data.csv @analytics.ecom_stage`

---

### 2. Data Type Mismatch Errors
**Error:** `Numeric value 'abc' is not recognized`
-  Ensure your CSV contains valid values for columns like `Quantity`, `Sales`, `Profit`.

---

### 3. NULL or Divide-by-Zero in profit_margin_pct
**Cause:** `Sales` might be `0` or `NULL`.
-  Handled via `NULLIF(Sales, 0)`—no action needed unless data quality is very poor.

---

### 4. Function Not Found
**Error:** `Function FORMAT_CURRENCY does not exist`
-  Confirm that you've run the UDF creation section.
-  Re-run `CREATE OR REPLACE FUNCTION analytics.format_currency(...)`.

---

### 5. Nothing Showing in Views
- Ensure that:
  - `COPY INTO` was successful.
  -  Raw data exists: `SELECT COUNT(*) FROM analytics.ecommerce_raw;`
  -  Dashboard table was created and populated.

---

### 6. Insufficient Privileges
- Check you’re using a role with permissions to create objects (e.g., `SYSADMIN`).
