
## Q1. Which providers have unusually high claim frequency per patient?
/* 
SELECT
    Provider,
    COUNT(DISTINCT ClaimID) AS total_claims,
    COUNT(DISTINCT BeneID) AS unique_patients,
    ROUND(
        COUNT(DISTINCT ClaimID) * 1.0 /
        NULLIF(COUNT(DISTINCT BeneID), 0),
        2
    ) AS claims_per_patient
FROM inpatient_claims
GROUP BY Provider
HAVING COUNT(DISTINCT BeneID) >= 20
ORDER BY claims_per_patient DESC
LIMIT 20;
*/


## Q2. Which providers generate the highest reimbursement per patient?

/*
SELECT
    Provider,
    COUNT(DISTINCT BeneID) AS unique_patients,
    SUM(InscClaimAmtReimbursed) AS total_reimbursement,
    ROUND(
        SUM(InscClaimAmtReimbursed) * 1.0 /
        NULLIF(COUNT(DISTINCT BeneID), 0),
        2
    ) AS reimbursement_per_patient
FROM inpatient_claims
GROUP BY Provider
HAVING COUNT(DISTINCT BeneID) >= 20
ORDER BY reimbursement_per_patient DESC
LIMIT 20;
*/


## Q3. Which providers have high claim volume but low average claim value?
/*
SELECT
    Provider,
    COUNT(*) AS total_claims,
    SUM(InscClaimAmtReimbursed) AS total_reimbursement,
    ROUND(
        AVG(InscClaimAmtReimbursed), 2
    ) AS avg_claim_amount
FROM inpatient_claims
GROUP BY Provider
HAVING COUNT(*) >= 100
ORDER BY total_claims DESC, avg_claim_amount ASC
LIMIT 20;
*/ 

## Q4. Which providers have the highest reimbursement-to-deductible ratio?
/*
SELECT
    Provider,
    SUM(InscClaimAmtReimbursed) AS total_reimbursement,
    SUM(DeductibleAmtPaid) AS total_deductible,
    ROUND(
        SUM(InscClaimAmtReimbursed) * 1.0 /
        NULLIF(SUM(DeductibleAmtPaid), 0),
        2
    ) AS reimbursement_deductible_ratio
FROM inpatient_claims
GROUP BY Provider
HAVING SUM(DeductibleAmtPaid) > 0
ORDER BY reimbursement_deductible_ratio DESC
LIMIT 20;
*/

## Q5. Which beneficiaries have claims from multiple providers?
/*
SELECT
    BeneID,
    COUNT(DISTINCT Provider) AS unique_providers,
    COUNT(DISTINCT ClaimID) AS total_claims
FROM inpatient_claims
GROUP BY BeneID
HAVING COUNT(DISTINCT Provider) >= 5
ORDER BY unique_providers DESC, total_claims DESC
LIMIT 20;
*/ 


## Q6. Which providers have the highest number of unique beneficiaries?
/*
SELECT
    Provider,
    COUNT(DISTINCT BeneID) AS unique_beneficiaries,
    COUNT(DISTINCT ClaimID) AS total_claims,
    ROUND(
        COUNT(DISTINCT ClaimID) * 1.0 /
        NULLIF(COUNT(DISTINCT BeneID), 0),
        2
    ) AS claims_per_patient
FROM inpatient_claims
GROUP BY Provider
ORDER BY unique_beneficiaries DESC
LIMIT 20;
*/


## Q7. Which providers have unusually high average length of hospital stay?
/*
SELECT
    Provider,
    COUNT(*) AS total_admissions,
    ROUND(
        AVG(
            DATEDIFF(DischargeDt, AdmissionDt)
        ),
        2
    ) AS avg_length_of_stay
FROM inpatient_claims
GROUP BY Provider
HAVING COUNT(*) >= 20
ORDER BY avg_length_of_stay DESC
LIMIT 20;
*/


## Q8. Which providers have the highest number of missing physician records?
/*
SELECT
    Provider,
    COUNT(*) AS total_claims,

    SUM(
        CASE
            WHEN AttendingPhysician IS NULL
                 OR TRIM(AttendingPhysician) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_physician_claims,

    ROUND(
        SUM(
            CASE
                WHEN AttendingPhysician IS NULL
                     OR TRIM(AttendingPhysician) = ''
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS missing_physician_rate

FROM inpatient_claims

GROUP BY Provider

HAVING COUNT(*) >= 20

ORDER BY missing_physician_rate DESC
LIMIT 20;
*/


## Q9. What percentage of inpatient reimbursement comes from high-value claims?
/*
SELECT
    COUNT(*) AS total_claims,

    SUM(InscClaimAmtReimbursed) AS total_reimbursement,

    SUM(
        CASE
            WHEN InscClaimAmtReimbursed >= 20000
            THEN InscClaimAmtReimbursed
            ELSE 0
        END
    ) AS high_value_reimbursement,

    ROUND(
        SUM(
            CASE
                WHEN InscClaimAmtReimbursed >= 20000
                THEN InscClaimAmtReimbursed
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(SUM(InscClaimAmtReimbursed), 0),
        2
    ) AS high_value_reimbursement_pct

FROM inpatient_claims;
*/


## Q10. Which providers contribute the most to high-value claim reimbursement?

SELECT
    Provider,
    COUNT(*) AS high_value_claims,

    SUM(InscClaimAmtReimbursed) AS high_value_reimbursement,

    ROUND(
        AVG(InscClaimAmtReimbursed), 2
    ) AS avg_high_value_claim

FROM inpatient_claims

WHERE InscClaimAmtReimbursed >= 20000

GROUP BY Provider

HAVING COUNT(*) >= 3

ORDER BY high_value_reimbursement DESC

LIMIT 20;