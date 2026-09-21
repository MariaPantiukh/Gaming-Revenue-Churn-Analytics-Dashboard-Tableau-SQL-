# Gaming Revenue & Churn Analytics Dashboard (Tableau & SQL)

![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=flat&logo=Tableau&logoColor=white)


## Executive Summary
This repository contains an end-to-end analytics solution designed for mobile and online gaming products. The primary goal of this project is to provide **Product Managers, Game Designers, and User Acquisition (UA) Analysts** with an interactive **Tableau Public** dashboard driven by a **PostgreSQL** data pipeline. 

The dashboard provides deep visibility into Monthly Recurring Revenue (**MRR**) performance, tracks monetization unit economics, monitors player churn dynamics, and evaluates the financial drivers of player retention.

---

## 🎯 Business Problem & Requirements
In mobile and online gaming, focusing solely on total monthly revenue obscures critical underlying dynamics. To make data-driven decisions on player retention and monetization strategy, product teams need answers to specific operational questions:
* **Revenue Factor Analysis:** How do individual monetization drivers (*New MRR, Expansion MRR, Contraction MRR, Churned Revenue, and Resubscribed MRR*) contribute to net MRR growth each month?
* **Paying User & Churn Dynamics:** Is paying player acquisition outstripping churn, and what is the financial magnitude of lost paying players?
* **Monetization Economics:** How are core unit economics (**ARPPU**, **Customer Lifetime**, and **Lifetime Value**) trending over time?
* **Segmented Root-Cause Analysis:** How do monetization and churn metrics vary across player cohorts (*Language/Locale, Age Groups, Game Titles, and Device Performance Flags*)?

---

## ⚙️ Data Architecture & Solution Design

### 1. PostgreSQL Pipeline & CTE Architecture
A multi-stage SQL pipeline (`gaming_revenue_query.sql`) was developed to process transactional data at the database level, optimizing query speed and structuring monetization categories:
* **`monthly_user_revenue` (CTE 1):** Aggregates raw in-app transaction records (`project.games_payments`) into monthly spending totals per player.
* **`user_life_cycle` (CTE 2):** Applies window functions (`LAG` and `LEAD`) to establish historical payment contexts, evaluating prior vs. subsequent payment months and spending levels per user.
* **`mrr_classification` (CTE 3):** Classifies each player-month payment into explicit revenue buckets (*New MRR*, *Expansion MRR*, *Contraction MRR*, *Retained MRR*, *Resubscribed MRR*) and calculates explicit churn flags.
* **User Attribute Integration (Main Query):** Performs a `LEFT JOIN` with `project.games_paid_users` to enrich transaction data with player demographic and technical attributes (`language`, `age`, `game_name`, `has_older_device_model`).

### 2. Tableau Data Modeling & Core Metrics
The dashboard models **10+ primary game industry metrics** using calculated fields and table calculations:

| Metric | Metric Calculation / Logic | Business Context in Gaming |
| :--- | :--- | :--- |
| **Paid Users (PU)** | `COUNTD([User Id])` | Total count of unique active paying players per month. |
| **New Paid Users** | `SUM([Is New Paid User])` | Volume of first-time paying player conversions. |
| **Monthly Recurring Revenue (MRR)** | `SUM([Revenue Amount Usd])` | Gross monthly recurring revenue from in-app transactions. |
| **New MRR & Expansion MRR** | `SUM([User New Mrr])` / `SUM([Expansion Mrr])` | Gains from new converted players and existing upselling players. |
| **Contraction & Churned Revenue** | `SUM([Contraction Mrr])` / Balance Formula Calculation | Revenue lost to decreased spending or player churn. |
| **ARPPU** | `SUM([Revenue Amount Usd]) / COUNTD([User Id])` | Average monetization yield generated per active paying player. |
| **User Churn Rate (%)** | `[Churned Users] / LOOKUP(COUNTD([User Id]), -1)` | Percentage loss of active paying players month-over-month. |
| **Revenue Churn Rate (%)** | `[Churned Revenue] / LOOKUP(SUM([Revenue Amount Usd]), -1)` | Financial loss impact relative to the prior month's MRR. |
| **Customer Lifetime (LT)** | `ROUND(1 / [Churn Rate], 0)` | Projected average duration (in months) a paying player remains active. |
| **Lifetime Value (LTV)** | `[ARPPU] * [LT]` | Projected long-term revenue generated per paying player. |

---

## 🖥️ Tableau Dashboard Walkthrough

🔗 **[View Live Dashboard on Tableau Public](INSERT_YOUR_TABLEAU_PUBLIC_URL_HERE)**

The dashboard is structured into four main visual zones designed for high-level monitoring and deep-dive analysis:

1. **Executive Scorecards (KPI Header):**
   * Displays high-level health metrics for instant assessment: **Total MRR**, **Paid Users**, **ARPPU**, **LT**, and **LTV**.
2. **MRR Breakdown & Driver Analysis (Waterfall Diagram):**
   * A stacked/waterfall visualization breaking down monthly revenue momentum.
   * Visualizes positive revenue drivers (*New MRR, Expansion, Resubscribed*) against negative offsets (*Contraction, Churned Revenue*) to isolate net monthly growth.
3. **Paid User Acquisition vs. Churn (Diverging Bar + Line Combo):**
   * Tracks monthly paying player acquisition (*New Paid Users*) against monthly churned players (*Churned Users*) alongside total active paying player trends.
4. **Churn Trends & Monetization Economics (Dual-Axis Trends):**
   * Evaluates **User Churn Rate (%)** against **Revenue Churn Rate (%)** over time.
   * Pinpoints periods where revenue churn outpaces user churn, highlighting the loss of high-value paying cohorts (whales/VIPs).
5. **Interactive Segmentation Filters:**
   * Global slicers for `Game Name`, `Language / Locale`, `Age Group`, and `Has Older Device Model` allow analysts to pinpoint technical issues (e.g., lag on legacy devices) or demographic-specific churn.

---

## 📁 Repository Structure
