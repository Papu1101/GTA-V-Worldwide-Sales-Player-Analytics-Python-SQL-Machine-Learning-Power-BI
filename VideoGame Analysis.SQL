CREATE TABLE gta_worldwide_sales (
    transaction_id VARCHAR(20),
    year INT,
    month INT,
    quarter INT,
    country VARCHAR(100),
    iso3_code CHAR(3),
    region VARCHAR(50),
    platform VARCHAR(50),
    game_edition VARCHAR(50),
    sales_channel VARCHAR(20),
    retailer VARCHAR(100),
    units_sold INT,
    gross_revenue_usd DECIMAL(15,2),
    average_selling_price_usd DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    digital_sales_percentage DECIMAL(5,2),
    physical_sales_percentage DECIMAL(5,2),
    new_customers INT,
    returning_customers INT,
    estimated_active_players INT,
    peak_concurrent_players INT,
    online_players INT,
    story_mode_players INT,
    gta_online_players INT,
    dlc_revenue_usd DECIMAL(15,2),
    shark_card_revenue_usd DECIMAL(15,2),
    average_playtime_hours DECIMAL(10,2),
    average_session_length_minutes DECIMAL(10,2),
    holiday_season INT,
    major_sale_event VARCHAR(100),
    marketing_campaign INT,
    customer_rating DECIMAL(3,2),
    review_count INT,
    refund_rate_percentage DECIMAL(5,2),
    currency VARCHAR(20),
    exchange_rate_to_usd DECIMAL(15,6),
    internet_penetration_percentage DECIMAL(5,2),
    gaming_market_size DECIMAL(15,2),
    population_millions DECIMAL(10,2),
    gdp_per_capita_usd DECIMAL(15,2),
    release_phase VARCHAR(30),
    weekend_sales_percentage DECIMAL(5,2),
    weekday_sales_percentage DECIMAL(5,2),
    season VARCHAR(20),
    special_event VARCHAR(100),
    top_game_category VARCHAR(50),
    platform_generation VARCHAR(20)
);

SELECT * FROM gta_worldwide_sales;

--Which countries generated the highest total revenue, and how do they contribute to overall global sales?
SELECT 
  country,
  SUM(gross_revenue_usd) AS Total_Revenue,
  ROUND(
        SUM(gross_revenue_usd) * 100.0 /
        (SELECT SUM(gross_revenue_usd) FROM gta_worldwide_sales),
        2
    ) AS revenue_contribution_percentage
FROM gta_worldwide_sales
GROUP BY country
ORDER BY Total_Revenue DESC;
--Which gaming platform (PC, PlayStation, Xbox) generated the highest revenue and units sold over the entire period?
SELECT
    CASE
        WHEN platform LIKE 'PS%' THEN 'PlayStation'
        WHEN platform LIKE 'Xbox%' THEN 'Xbox'
        WHEN platform = 'PC' THEN 'PC'
    END AS platform_family,
    SUM(gross_revenue_usd) AS total_revenue,
    SUM(units_sold) AS total_units_sold
FROM gta_worldwide_sales
GROUP BY platform_family
ORDER BY total_revenue DESC;
--How has yearly revenue changed from 2013 to 2026, and which years experienced the highest growth or decline?
SELECT
    year,
    SUM(gross_revenue_usd) AS total_revenue,
    ROUND(
        (
            SUM(gross_revenue_usd)
            - LAG(SUM(gross_revenue_usd)) OVER (ORDER BY year)
        ) * 100.0
        / LAG(SUM(gross_revenue_usd)) OVER (ORDER BY year),
        2
    ) AS revenue_growth_percentage
FROM gta_worldwide_sales
GROUP BY year
ORDER BY year;
--Which regions (North America, Europe, Asia, etc.) consistently outperform others in terms of revenue, units sold, and active players?
SELECT
    region,
    SUM(gross_revenue_usd) AS total_revenue,
    SUM(units_sold) AS total_units_sold,
    SUM(estimated_active_players) AS total_active_players,
    RANK() OVER (
        ORDER BY SUM(gross_revenue_usd) DESC
    ) AS revenue_rank,
    RANK() OVER (
        ORDER BY SUM(units_sold) DESC
    ) AS units_sold_rank,
    RANK() OVER (
        ORDER BY SUM(estimated_active_players) DESC
    ) AS active_players_rank
FROM gta_worldwide_sales
GROUP BY region
ORDER BY total_revenue DESC;

--How do digital sales compare with physical sales across different years, and is there a clear shift toward digital distribution?
SELECT
    year,
    ROUND(AVG(digital_sales_percentage), 2) AS avg_digital_sales_percentage,
    ROUND(AVG(physical_sales_percentage), 2) AS avg_physical_sales_percentage
FROM gta_worldwide_sales
GROUP BY year
ORDER BY year;
--Which game edition (Standard, Premium, Legacy, etc.) delivers the highest revenue, customer ratings, and sales volume?
SELECT
    game_edition,
    SUM(gross_revenue_usd) AS total_revenue,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(customer_rating), 2) AS average_customer_rating,
    RANK() OVER (
        ORDER BY SUM(gross_revenue_usd) DESC
    ) AS revenue_rank
FROM gta_worldwide_sales
GROUP BY game_edition
ORDER BY total_revenue DESC;
--Do higher discount percentages lead to increased units sold and higher overall revenue, or do they reduce profitability?
SELECT
    CASE
        WHEN discount_percentage BETWEEN 0 AND 20 THEN '0-20%'
        WHEN discount_percentage BETWEEN 21 AND 40 THEN '21-40%'
        WHEN discount_percentage BETWEEN 41 AND 60 THEN '41-60%'
        ELSE '61-80%'
    END AS discount_range,
    SUM(units_sold) AS total_units_sold,
    SUM(gross_revenue_usd) AS total_revenue,
    ROUND(AVG(average_selling_price_usd), 2) AS avg_selling_price
FROM gta_worldwide_sales
GROUP BY discount_range
ORDER BY discount_range;

--Which major sale events and special events generate the highest revenue and customer engagement?
SELECT
    major_sale_event,
    special_event,
    SUM(gross_revenue_usd) AS total_revenue,
    SUM(estimated_active_players) AS total_active_players,
    SUM(online_players) AS total_online_players,
    ROUND(AVG(average_playtime_hours), 2) AS avg_playtime_hours
FROM gta_worldwide_sales
GROUP BY major_sale_event, special_event
ORDER BY total_revenue DESC;
--How effective are marketing campaigns in driving revenue, customer acquisition, and active player growth?
SELECT
    marketing_campaign,
    SUM(gross_revenue_usd) AS total_revenue,
    SUM(new_customers) AS new_customers,
    SUM(returning_customers) AS returning_customers,
    SUM(estimated_active_players) AS total_active_players,
    ROUND(AVG(average_playtime_hours), 2) AS avg_playtime_hours
FROM gta_worldwide_sales
GROUP BY marketing_campaign
ORDER BY total_revenue DESC;
--How do new customers compare with returning customers across regions and platforms, and which markets have the highest customer retention?
SELECT
    region,
    platform,
    SUM(new_customers) AS total_new_customers,
    SUM(returning_customers) AS total_returning_customers,
    ROUND(
        SUM(returning_customers) * 100.0 /
        (SUM(new_customers) + SUM(returning_customers)),
        2
    ) AS customer_retention_rate
FROM gta_worldwide_sales
GROUP BY region, platform
ORDER BY customer_retention_rate DESC, total_returning_customers DESC;
--Which platform has the highest player engagement based on online players, GTA Online players, playtime, and session length?
SELECT
    platform,
    SUM(online_players) AS total_online_players,
    SUM(gta_online_players) AS total_gta_online_players,
    ROUND(AVG(average_playtime_hours), 2) AS avg_playtime_hours,
    ROUND(AVG(average_session_length_minutes), 2) AS avg_session_length_minutes,
    RANK() OVER (
        ORDER BY
            SUM(online_players) DESC,
            SUM(gta_online_players) DESC,
            AVG(average_playtime_hours) DESC,
            AVG(average_session_length_minutes) DESC
    ) AS engagement_rank
FROM gta_worldwide_sales
GROUP BY platform
ORDER BY engagement_rank;
--How much revenue is generated from DLC purchases and Shark Card sales, and how does their contribution vary across platforms and regions?
SELECT
    region,
    platform,
    SUM(dlc_revenue_usd) AS total_dlc_revenue,
    SUM(shark_card_revenue_usd) AS total_shark_card_revenue,
    SUM(gross_revenue_usd) AS total_gross_revenue,
    ROUND(
        SUM(dlc_revenue_usd) * 100.0 / SUM(gross_revenue_usd),
        2
    ) AS dlc_contribution_percentage,
    ROUND(
        SUM(shark_card_revenue_usd) * 100.0 / SUM(gross_revenue_usd),
        2
    ) AS shark_card_contribution_percentage
FROM gta_worldwide_sales
GROUP BY region, platform
ORDER BY total_gross_revenue DESC;
--Is there a relationship between customer ratings, review counts, and revenue performance across different platforms and game editions?
SELECT
    platform,
    game_edition,
    ROUND(AVG(customer_rating), 2) AS average_customer_rating,
    SUM(review_count) AS total_review_count,
    SUM(gross_revenue_usd) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(gross_revenue_usd) DESC
    ) AS revenue_rank
FROM gta_worldwide_sales
GROUP BY platform, game_edition
ORDER BY total_revenue DESC;
--How do macroeconomic factors such as GDP per capita, population, and internet penetration influence revenue and units sold across countries?
SELECT
    country,
    ROUND(AVG(gdp_per_capita_usd), 2) AS avg_gdp_per_capita,
    ROUND(AVG(population_millions), 2) AS population_millions,
    ROUND(AVG(internet_penetration_percentage), 2) AS avg_internet_penetration,
    SUM(units_sold) AS total_units_sold,
    SUM(gross_revenue_usd) AS total_revenue
FROM gta_worldwide_sales
GROUP BY country
ORDER BY total_revenue DESC;
--Which release phase (Launch, Growth, Legacy) delivers the strongest business performance in terms of revenue, player engagement, and customer acquisition, and what strategic insights can be derived for future game launches?
SELECT
    release_phase,
    SUM(gross_revenue_usd) AS total_revenue,
    SUM(estimated_active_players) AS total_active_players,
    SUM(new_customers) AS total_new_customers,
    SUM(returning_customers) AS total_returning_customers,
    ROUND(AVG(average_playtime_hours), 2) AS avg_playtime_hours,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    RANK() OVER (
        ORDER BY SUM(gross_revenue_usd) DESC
    ) AS revenue_rank
FROM gta_worldwide_sales
GROUP BY release_phase
ORDER BY total_revenue DESC;
   