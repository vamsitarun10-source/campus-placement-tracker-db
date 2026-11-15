-- ============================================================================
-- Campus Placement Tracker Database - Analytical & Reporting Queries
-- ============================================================================

USE placement_tracker_db;

-- 1. Offer Package Summary Metrics
SELECT 
    COUNT(*) AS total_offers,
    MIN(offered_ctc) AS min_package,
    MAX(offered_ctc) AS max_package,
    ROUND(AVG(offered_ctc), 2) AS avg_package
FROM offers;

-- 2. Placed Students Report (5-Table Inner Join)
SELECT 
    s.roll_number,
    s.first_name,
    s.department,
    c.company_name,
    j.job_title,
    o.offered_ctc
FROM students s
INNER JOIN applications a ON a.student_id = s.student_id
INNER JOIN jobs j ON a.job_id = j.job_id
INNER JOIN companies c ON c.company_id = j.company_id
INNER JOIN offers o ON a.application_id = o.application_id 
WHERE o.offer_status = 'Accepted'
ORDER BY o.offered_ctc DESC;

-- 3. Unengaged Students Check (LEFT JOIN + IS NULL)
SELECT 
    s.student_id,
    s.roll_number,
    s.first_name,
    s.department
FROM students s
LEFT JOIN applications a ON s.student_id = a.student_id
WHERE a.application_id IS NULL;

-- 4. Candidates Passing Technical & HR Rounds
SELECT 
    s.first_name,
    s.roll_number,
    i.round_number,
    i.round_type,
    i.result
FROM students s
INNER JOIN applications a ON a.student_id = s.student_id
INNER JOIN interviews i ON a.application_id = i.application_id
WHERE i.round_type IN ('HR', 'Technical') 
  AND i.result = 'Passed'
ORDER BY s.first_name ASC, i.round_number ASC;

-- 5. Students Above Overall College Average CGPA (Scalar Subquery)
SELECT 
    roll_number,
    first_name,
    department,
    cgpa 
FROM students s
WHERE s.cgpa > (SELECT AVG(cgpa) FROM students)
ORDER BY cgpa DESC;

-- 6. Students Above Their Own Department Average CGPA (Correlated Subquery)
SELECT 
    s1.roll_number,
    s1.first_name,
    s1.department,
    s1.cgpa
FROM students s1
WHERE s1.cgpa > (
    SELECT AVG(s2.cgpa)
    FROM students s2
    WHERE s2.department = s1.department
)
ORDER BY s1.department ASC, s1.cgpa DESC;

-- 7. Companies Offering Top-Tier Packages >= 10 LPA (CTE)
WITH CompanyTopPackages AS (
    SELECT 
        c.company_name,
        MAX(j.package_lpa) AS max_package
    FROM companies c 
    INNER JOIN jobs j ON c.company_id = j.company_id 
    GROUP BY c.company_id, c.company_name
)
SELECT *
FROM CompanyTopPackages
WHERE max_package >= 10.00
ORDER BY max_package DESC;

-- 8. Departmental Academic Ranking & Benchmark Comparison (Window Functions)
SELECT 
    roll_number,
    first_name,
    department,
    cgpa,
    ROUND(AVG(cgpa) OVER (PARTITION BY department), 2) AS dept_avg,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY cgpa DESC) AS dept_rank
FROM students;