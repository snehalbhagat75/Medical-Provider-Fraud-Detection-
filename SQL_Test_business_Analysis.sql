
# Which providers have the highest total reimbursement amount?
/*
USE Medical_Provider_Fraud_Detection_SQL_Analysis;

SELECT
    Provider,
    ROUND(SUM(InscClaimAmtReimbursed), 2) AS Total_Reimbursement,
    COUNT(*) AS Total_Claims
FROM (
    
    SELECT
        Provider,
        InscClaimAmtReimbursed
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT
        Provider,
        InscClaimAmtReimbursed
    FROM test_outpatientdata
    
) AS All_Claims
GROUP BY Provider
ORDER BY Total_Reimbursement DESC
LIMIT 10;
*/

# Which providers have the highest average reimbursement per claim?

/*
SELECT
    Provider,
    COUNT(*) AS Total_Claims,
    ROUND(AVG(InscClaimAmtReimbursed), 2) AS Avg_Reimbursement_Per_Claim
FROM (
    
    SELECT Provider, InscClaimAmtReimbursed
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT Provider, InscClaimAmtReimbursed
    FROM test_outpatientdata
    
) AS All_Claims
GROUP BY Provider
HAVING COUNT(*) >= 10
ORDER BY Avg_Reimbursement_Per_Claim DESC
LIMIT 10;
*/ 


# Which providers have the highest number of unique beneficiaries?
/*
SELECT
    Provider,
    COUNT(DISTINCT BeneID) AS Unique_Beneficiaries,
    COUNT(*) AS Total_Claims
FROM (
    
    SELECT Provider, BeneID
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT Provider, BeneID
    FROM test_outpatientdata
    
) AS All_Claims
GROUP BY Provider
ORDER BY Unique_Beneficiaries DESC
LIMIT 10;
*/


# Which providers have the highest number of claims per beneficiary? 
/*
SELECT
    Provider,
    COUNT(*) AS Total_Claims,
    COUNT(DISTINCT BeneID) AS Unique_Beneficiaries,
    ROUND(
        COUNT(*) / COUNT(DISTINCT BeneID),
        2
    ) AS Claims_Per_Beneficiary
FROM (
    
    SELECT Provider, BeneID
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT Provider, BeneID
    FROM test_outpatientdata
    
) AS All_Claims
GROUP BY Provider
HAVING COUNT(DISTINCT BeneID) > 0
ORDER BY Claims_Per_Beneficiary DESC
LIMIT 10;
 */ 
 
 
 # Which providers have the highest proportion of high-cost claims?
 /*
 
 WITH All_Claims AS (
    
    SELECT
        Provider,
        InscClaimAmtReimbursed
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT
        Provider,
        InscClaimAmtReimbursed
    FROM test_outpatientdata
),

Overall_Average AS (
    SELECT
        AVG(InscClaimAmtReimbursed) AS Avg_Claim_Amount
    FROM All_Claims
)

SELECT
    a.Provider,
    COUNT(*) AS Total_Claims,
    
    SUM(
        CASE
            WHEN a.InscClaimAmtReimbursed > o.Avg_Claim_Amount
            THEN 1
            ELSE 0
        END
    ) AS High_Cost_Claims,
    
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN a.InscClaimAmtReimbursed > o.Avg_Claim_Amount
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS High_Cost_Claim_Percentage

FROM All_Claims a
CROSS JOIN Overall_Average o
GROUP BY a.Provider
ORDER BY High_Cost_Claim_Percentage DESC
LIMIT 10;
*/

# Which providers have the longest average inpatient length of stay?

/*
SELECT
    Provider,
    COUNT(*) AS Inpatient_Claims,
    
    ROUND(
        AVG(
            DATEDIFF(
                ClaimEndDt,
                ClaimStartDt
            )
        ),
        2
    ) AS Avg_Length_of_Stay
    
FROM test_inpatientdata
WHERE
    ClaimStartDt IS NOT NULL
    AND ClaimEndDt IS NOT NULL

GROUP BY Provider
HAVING COUNT(*) >= 5
ORDER BY Avg_Length_of_Stay DESC
LIMIT 10;
*/


# Which providers receive the highest reimbursement per beneficiary?

/*
SELECT
    Provider,
    COUNT(DISTINCT BeneID) AS Unique_Beneficiaries,
    
    ROUND(
        SUM(InscClaimAmtReimbursed),
        2
    ) AS Total_Reimbursement,
    
    ROUND(
        SUM(InscClaimAmtReimbursed)
        / COUNT(DISTINCT BeneID),
        2
    ) AS Reimbursement_Per_Beneficiary

FROM (
    
    SELECT
        Provider,
        BeneID,
        InscClaimAmtReimbursed
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT
        Provider,
        BeneID,
        InscClaimAmtReimbursed
    FROM test_outpatientdata
    
) AS All_Claims

GROUP BY Provider
ORDER BY Reimbursement_Per_Beneficiary DESC
LIMIT 10;
*/



# Which providers have an unusually high inpatient claim percentage?

/*
WITH Provider_Claims AS (

    SELECT
        Provider,
        'Inpatient' AS Claim_Type
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT
        Provider,
        'Outpatient' AS Claim_Type
    FROM test_outpatientdata
)

SELECT
    Provider,
    
    COUNT(*) AS Total_Claims,
    
    SUM(
        CASE
            WHEN Claim_Type = 'Inpatient'
            THEN 1
            ELSE 0
        END
    ) AS Inpatient_Claims,
    
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Claim_Type = 'Inpatient'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Inpatient_Claim_Percentage

FROM Provider_Claims
GROUP BY Provider
ORDER BY Inpatient_Claim_Percentage DESC
LIMIT 10;
*/


# Which beneficiaries have visited the highest number of different providers?

/*
SELECT
    BeneID,
    COUNT(DISTINCT Provider) AS Unique_Providers,
    COUNT(*) AS Total_Claims
    
FROM (
    
    SELECT
        BeneID,
        Provider
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT
        BeneID,
        Provider
    FROM test_outpatientdata
    
) AS All_Claims

GROUP BY BeneID
ORDER BY Unique_Providers DESC, Total_Claims DESC
LIMIT 10;
*/


# Which providers should be prioritized for fraud investigation based on multiple risk indicators?

/*
WITH All_Claims AS (

    SELECT
        Provider,
        BeneID,
        InscClaimAmtReimbursed
    FROM test_inpatientdata
    
    UNION ALL
    
    SELECT
        Provider,
        BeneID,
        InscClaimAmtReimbursed
    FROM test_outpatientdata
),

Provider_Metrics AS (

    SELECT
        Provider,
        
        COUNT(*) AS Total_Claims,
        
        COUNT(DISTINCT BeneID) AS Unique_Beneficiaries,
        
        SUM(InscClaimAmtReimbursed) AS Total_Reimbursement,
        
        AVG(InscClaimAmtReimbursed) AS Avg_Reimbursement,
        
        COUNT(*) /
        COUNT(DISTINCT BeneID) AS Claims_Per_Beneficiary,
        
        SUM(InscClaimAmtReimbursed) /
        COUNT(DISTINCT BeneID) AS Reimbursement_Per_Beneficiary
        
    FROM All_Claims
    GROUP BY Provider
),

Overall_Metrics AS (

    SELECT
        AVG(Total_Reimbursement) AS Avg_Total_Reimbursement,
        AVG(Avg_Reimbursement) AS Avg_Reimbursement_Value,
        AVG(Claims_Per_Beneficiary) AS Avg_Claims_Per_Beneficiary,
        AVG(Reimbursement_Per_Beneficiary) AS Avg_Reimbursement_Per_Beneficiary
    FROM Provider_Metrics
)

SELECT
    p.Provider,
    p.Total_Claims,
    p.Unique_Beneficiaries,
    
    ROUND(p.Total_Reimbursement, 2)
        AS Total_Reimbursement,
    
    ROUND(p.Avg_Reimbursement, 2)
        AS Avg_Reimbursement,
    
    ROUND(p.Claims_Per_Beneficiary, 2)
        AS Claims_Per_Beneficiary,
    
    ROUND(p.Reimbursement_Per_Beneficiary, 2)
        AS Reimbursement_Per_Beneficiary,

    (
        CASE
            WHEN p.Total_Reimbursement >
                 o.Avg_Total_Reimbursement
            THEN 1 ELSE 0
        END
        
        +
        
        CASE
            WHEN p.Avg_Reimbursement >
                 o.Avg_Reimbursement_Value
            THEN 1 ELSE 0
        END
        
        +
        
        CASE
            WHEN p.Claims_Per_Beneficiary >
                 o.Avg_Claims_Per_Beneficiary
            THEN 1 ELSE 0
        END
        
        +
        
        CASE
            WHEN p.Reimbursement_Per_Beneficiary >
                 o.Avg_Reimbursement_Per_Beneficiary
            THEN 1 ELSE 0
        END

    ) AS Risk_Score

FROM Provider_Metrics p
CROSS JOIN Overall_Metrics o

ORDER BY
    Risk_Score DESC,
    Total_Reimbursement DESC;
    */