
## Q1. Which providers have the highest total claim amount?
/*
SELECT
    Provider,
    SUM(InscClaimAmtReimbursed) AS total_claim_amount
FROM `Medical_Provider_Fraud_Detection_SQL_Analysis`.`train_inpatientdata-1542865627584`
GROUP BY Provider
ORDER BY total_claim_amount DESC
LIMIT 10;
*/

SELECT
    PotentialFraud,
    COUNT(*) AS provider_count
FROM `train-1542865627584 (1)`
GROUP BY PotentialFraud;