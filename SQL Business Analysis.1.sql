
# Q1. How does reimbursement per beneficiary differ between fraudulent and non-fraudulent providers?
/*
SELECT
    p.PotentialFraud,
    COUNT(DISTINCT c.BeneID) AS unique_beneficiaries,
    SUM(c.InscClaimAmtReimbursed) AS total_reimbursement,
    ROUND(
        SUM(c.InscClaimAmtReimbursed) /
        COUNT(DISTINCT c.BeneID),
        2
    ) AS reimbursement_per_beneficiary
FROM (
    SELECT Provider, BeneID, InscClaimAmtReimbursed
    FROM inpatient_claims

    UNION ALL

    SELECT Provider, BeneID, InscClaimAmtReimbursed
    FROM outpatient_claims
) c
JOIN providers p
    ON c.Provider = p.Provider
GROUP BY p.PotentialFraud
ORDER BY reimbursement_per_beneficiary DESC;
*/ 


## Q2. How does claim volume differ between fraudulent and non-fraudulent providers?

/*
SELECT
    p.PotentialFraud,
    COUNT(*) AS total_claims,
    COUNT(DISTINCT c.Provider) AS provider_count,
    ROUND(
        COUNT(*) * 1.0 /
        COUNT(DISTINCT c.Provider),
        2
    ) AS average_claims_per_provider
FROM (
    SELECT Provider
    FROM inpatient_claims

    UNION ALL

    SELECT Provider
    FROM outpatient_claims
) c
JOIN providers p
    ON c.Provider = p.Provider
GROUP BY p.PotentialFraud
ORDER BY average_claims_per_provider DESC;
*/


## Q3. What proportion of high-value claims is associated with fraudulent providers?
/*
SELECT
    p.PotentialFraud,
    COUNT(*) AS high_value_claims,
    SUM(c.InscClaimAmtReimbursed) AS high_value_reimbursement,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_high_value_claims
FROM (
    SELECT Provider, InscClaimAmtReimbursed
    FROM inpatient_claims

    UNION ALL

    SELECT Provider, InscClaimAmtReimbursed
    FROM outpatient_claims
) c
JOIN providers p
    ON c.Provider = p.Provider
WHERE c.InscClaimAmtReimbursed >= 10000
GROUP BY p.PotentialFraud
ORDER BY high_value_reimbursement DESC; 
*/

## Q4. Which providers rank highest based on total reimbursement?
/*
SELECT
    Provider,
    SUM(InscClaimAmtReimbursed) AS total_reimbursement,
    COUNT(*) AS total_claims,
    COUNT(DISTINCT BeneID) AS unique_beneficiaries,
    RANK() OVER (
        ORDER BY SUM(InscClaimAmtReimbursed) DESC
    ) AS reimbursement_rank
FROM (
    SELECT Provider, BeneID, InscClaimAmtReimbursed
    FROM inpatient_claims

    UNION ALL

    SELECT Provider, BeneID, InscClaimAmtReimbursed
    FROM outpatient_claims
) c
GROUP BY Provider
ORDER BY reimbursement_rank
LIMIT 20;
*/


## Q5. Which fraudulent providers have the highest total reimbursement?
/*
SELECT
    c.Provider,
    SUM(c.InscClaimAmtReimbursed) AS total_reimbursement,
    COUNT(*) AS total_claims,
    COUNT(DISTINCT c.BeneID) AS unique_beneficiaries,
    ROUND(
        SUM(c.InscClaimAmtReimbursed) / COUNT(DISTINCT c.BeneID),
        2
    ) AS reimbursement_per_beneficiary
FROM (
    SELECT Provider, BeneID, InscClaimAmtReimbursed
    FROM inpatient_claims

    UNION ALL

    SELECT Provider, BeneID, InscClaimAmtReimbursed
    FROM outpatient_claims
) c
JOIN providers p
    ON c.Provider = p.Provider
WHERE p.PotentialFraud = 'Yes'
GROUP BY c.Provider
ORDER BY total_reimbursement DESC
LIMIT 10;
*/


## Q6. How many beneficiaries receive both inpatient and outpatient services?
/*
SELECT
    COUNT(*) AS beneficiaries_using_both_services
FROM (
    SELECT DISTINCT i.BeneID
    FROM inpatient_claims i
    INNER JOIN outpatient_claims o
        ON i.BeneID = o.BeneID
) b;
*/ 


# Q7. What is the combined inpatient and outpatient reimbursement per beneficiary?

/*
SELECT
    BeneID,
    SUM(InscClaimAmtReimbursed) AS combined_reimbursement,
    COUNT(*) AS total_claims
FROM (
    SELECT BeneID, InscClaimAmtReimbursed
    FROM inpatient_claims

    UNION ALL

    SELECT BeneID, InscClaimAmtReimbursed
    FROM outpatient_claims
) c
GROUP BY BeneID
ORDER BY combined_reimbursement DESC
LIMIT 20;
*/


## Q8. Which providers deliver both inpatient and outpatient services?
/*
SELECT
    Provider,
    SUM(inpatient_claims) AS inpatient_claims,
    SUM(outpatient_claims) AS outpatient_claims
FROM (
    SELECT
        Provider,
        COUNT(*) AS inpatient_claims,
        0 AS outpatient_claims
    FROM inpatient_claims
    GROUP BY Provider

    UNION ALL

    SELECT
        Provider,
        0 AS inpatient_claims,
        COUNT(*) AS outpatient_claims
    FROM outpatient_claims
    GROUP BY Provider
) x
GROUP BY Provider
HAVING SUM(inpatient_claims) > 0
   AND SUM(outpatient_claims) > 0
ORDER BY
    (SUM(inpatient_claims) + SUM(outpatient_claims)) DESC;
*/



## Q9. What is the combined reimbursement exposure of fraudulent providers?

/*
SELECT
    p.PotentialFraud,
    SUM(c.InscClaimAmtReimbursed) AS combined_reimbursement,
    COUNT(*) AS total_claims,
    COUNT(DISTINCT c.Provider) AS provider_count
FROM (
    SELECT Provider, InscClaimAmtReimbursed
    FROM inpatient_claims

    UNION ALL

    SELECT Provider, InscClaimAmtReimbursed
    FROM outpatient_claims
) c
JOIN providers p
    ON c.Provider = p.Provider
GROUP BY p.PotentialFraud
ORDER BY combined_reimbursement DESC;
*/



## Q30  Which providers have the highest overall Fraud Risk Score?

/*
WITH provider_metrics AS (

    SELECT
        c.Provider,

        COUNT(*) AS total_claims,

        COUNT(DISTINCT c.BeneID) AS unique_beneficiaries,

        SUM(c.InscClaimAmtReimbursed) AS total_reimbursement

    FROM (
        SELECT
            Provider,
            BeneID,
            InscClaimAmtReimbursed
        FROM inpatient_claims

        UNION ALL

        SELECT
            Provider,
            BeneID,
            InscClaimAmtReimbursed
        FROM outpatient_claims
    ) c

    GROUP BY c.Provider
),

risk_metrics AS (

    SELECT
        pm.*,
        p.PotentialFraud,

        PERCENT_RANK() OVER (
            ORDER BY pm.total_claims
        ) AS claim_volume_score,

        PERCENT_RANK() OVER (
            ORDER BY pm.total_reimbursement
        ) AS reimbursement_score,

        PERCENT_RANK() OVER (
            ORDER BY pm.unique_beneficiaries
        ) AS beneficiary_score

    FROM provider_metrics pm

    JOIN providers p
        ON pm.Provider = p.Provider
)

SELECT
    Provider,
    PotentialFraud,
    total_claims,
    unique_beneficiaries,
    total_reimbursement,

    ROUND(
        (
            claim_volume_score * 0.30
            +
            reimbursement_score * 0.50
            +
            beneficiary_score * 0.20
        ) * 100,
        2
    ) AS fraud_risk_score

FROM risk_metrics

ORDER BY fraud_risk_score DESC

LIMIT 20;
*/






