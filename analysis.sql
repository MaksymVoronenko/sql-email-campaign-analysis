Create or replace View `Students.v_Voronenko_Adva_Mod` as
WITH base AS (
    SELECT
        acs.account_id,
        sp.country,
        s.date
    FROM `DA.account_session` acs
    JOIN `DA.session_params` sp ON acs.ga_session_id = sp.ga_session_id
    JOIN `DA.session` s ON acs.ga_session_id = s.ga_session_id
),


account_metrics AS (
    SELECT
        b.country,
        b.date,
        a.send_interval,
        a.is_unsubscribed,
        a.is_verified,      
       COUNT(DISTINCT a.id) AS account_cnt,
        0 AS sent_msg,
        0 AS open_msg,
        0 AS visit_msg
    FROM base b
    JOIN `DA.account` a ON b.account_id = a.id
    GROUP BY
        b.country,b.date,a.send_interval,a.is_unsubscribed,a.is_verified
),


email_metrics AS (
    SELECT
        sp.country,
        DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
        a.send_interval,
        a.is_unsubscribed,
        a.is_verified,
       0 AS account_cnt,
        COUNT(DISTINCT es.id_message) AS sent_msg,
        COUNT(DISTINCT eo.id_message) AS open_msg,
        COUNT(DISTINCT ev.id_message) AS visit_msg
    FROM `DA.email_sent` es
    LEFT JOIN `DA.email_open` eo ON es.id_message = eo.id_message
    LEFT JOIN `DA.email_visit` ev ON es.id_message = ev.id_message
    JOIN `DA.account` a ON es.id_account = a.id
    JOIN `DA.account_session` acs ON es.id_account = acs.account_id
    JOIN `DA.session`s ON acs.ga_session_id = s.ga_session_id
    JOIN `DA.session_params` sp  ON acs.ga_session_id = sp.ga_session_id
    GROUP BY
        DATE_ADD(s.date, INTERVAL es.sent_date DAY),
        sp.country,
        a.send_interval,
        a.is_unsubscribed,
        a.is_verified
),
final_data AS (
    SELECT * FROM account_metrics
    UNION ALL
    SELECT * FROM email_metrics
),


aggregated AS (
    SELECT
        date,
        country,
        send_interval,
        is_unsubscribed,
        is_verified,
        SUM(account_cnt) AS account_cnt,
        SUM(sent_msg) AS sent_msg,
        SUM(open_msg) AS open_msg,
        SUM(visit_msg) AS visit_msg
    FROM final_data
    GROUP BY
        date,country, send_interval, is_unsubscribed, is_verified
),


totals AS (
    SELECT
    *,
        SUM(account_cnt) OVER(PARTITION BY country) AS total_country_account_cnt,
        SUM(sent_msg) OVER(PARTITION BY country) AS total_country_sent_cnt
    FROM aggregated
), MAIN as (
SELECT
    date,
    country,
    send_interval,
    is_unsubscribed,
    is_verified,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    total_country_account_cnt,
    total_country_sent_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
FROM totals
    )
SELECT * FROM main
WHERE rank_total_country_account_cnt <= 10
   OR rank_total_country_sent_cnt <= 10
ORDER BY
    date, country;
