WITH monthly_user_revenue AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', payment_date)::date AS payment_month,
        SUM(revenue_amount_usd) AS revenue_amount_usd
    FROM project.games_payments 
    GROUP BY 
        user_id,
        DATE_TRUNC('month', payment_date)::date
),
user_life_cycle AS (
    SELECT 
        user_id,
        payment_month,
        revenue_amount_usd,
        LAG(payment_month) OVER (PARTITION BY user_id ORDER BY payment_month) AS previous_payment_month,
        LEAD(payment_month) OVER (PARTITION BY user_id ORDER BY payment_month) AS next_payment_month,
        (payment_month - INTERVAL '1 month')::date AS previous_calendar_month,
        (payment_month + INTERVAL '1 month')::date AS next_calendar_month,
        LAG(revenue_amount_usd) OVER (PARTITION BY user_id ORDER BY payment_month) AS previous_revenue
    FROM monthly_user_revenue 
),
mrr_classification AS (
    SELECT 
        *,
        
        CASE 
            WHEN previous_payment_month IS NULL THEN 'New MRR'
            WHEN previous_payment_month = previous_calendar_month AND revenue_amount_usd > previous_revenue THEN 'Expansion MRR'
            WHEN previous_payment_month = previous_calendar_month AND revenue_amount_usd < previous_revenue THEN 'Contraction MRR'
            WHEN previous_payment_month = previous_calendar_month AND revenue_amount_usd = previous_revenue THEN 'Retained MRR'
            ELSE 'Resubscribed MRR'
        END AS mrr_type
        
    FROM user_life_cycle
)
SELECT 
    m.*,
    u.language,
    u.age
FROM mrr_classification m
LEFT JOIN project.games_paid_users u 
    ON m.user_id = u.user_id;