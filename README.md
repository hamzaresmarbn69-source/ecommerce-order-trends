# E-Commerce Order Trends Analytics 📊

A complete MySQL database project designed to model, manage, and analyze e-commerce platform data. This project tracks customer behavior, product stock, coupon discounts, and shipment logs, utilizing advanced SQL concepts like custom views, window functions, and automation triggers to extract meaningful business insights.

## 🚀 Key Features & Architectural Highlights

* **Relational Database Schema:** Modeled with optimized data types, primary keys, and foreign keys across 8 foundational tables (`Customers`, `Products`, `Orders`, `OrderDetails`, `Coupons`, `OrderCoupons`, `ProductReviews`, and `Shipments`).
* **Automated Inventory Management:** Implements an `AFTER INSERT` trigger on order transactions to dynamically handle real-time product stock deductions.
* **Analytical Views:** Combines complex multi-table joins into clean, reusable structural views to track distribution log patterns.
* **Advanced Analytics:** Leverages window functions (`RANK() OVER`), aggregate logic (`HAVING`), conditional data categorization (`CASE WHEN`), and date computations (`DATEDIFF`) to run comprehensive business intelligence queries.

## 📂 Database Schema Overview

The database structural design captures the complete end-to-end e-commerce workflow:

1.  **Customers & Products:** Manages user credentials and active inventory listings.
2.  **Orders & OrderDetails:** Processes transactional values, order states (`Pending`, `Shipped`, `Delivered`, `Cancelled`), and exact item quantities.
3.  **Coupons & Reviews:** Keeps a history of loyalty discount configurations and client satisfaction scores.
4.  **Shipments:** Documents fulfillment tracking, specific handling carriers, and logistics timelines.

## 📊 Core Business Questions Answered

The included analytical script solves 15 distinct operational problems, including:
* Identifying top 5 best-selling items and category-wide pricing trends.
* Calculating specific delivery turnaround intervals for completed shipments.
* Ranking VIP clients based on their historical structural spending profiles.
* Generating periodic tracking arrays to review order density trends by month.

## 🛠️ How to Get Started

### Prerequisites
* **Database Engine:** MySQL Server (v5.7 or v8.0+) or MariaDB.
* **Database Client:** TablePlus, DBeaver, or command line terminal interface.

### Installation & Execution
1. Clone this repository or copy the core script.
2. Open your favorite database client and establish a connection to your local instance.
3. Execute the script to drop existing iterations, configure the fresh structural schema, populate seed records, and generate analytical outputs.

```sql
-- To run via terminal interface:
mysql -u root -p < e_commerce_order_trends.sql
