-- ============================================================================
-- Campus Placement Tracker Database - Sample Seed Data
-- ============================================================================

USE placement_tracker_db;

-- 1. Populate Students
INSERT INTO students (roll_number, first_name, last_name, email, department, cgpa, placement_status)
VALUES
    ('24ECE001', 'Aarav', 'Sharma', 'aarav.sharma@college.edu', 'ECE', 9.10, 'Unplaced'),
    ('24ECE002', 'Bhavya', 'Reddy', 'bhavya.reddy@college.edu', 'ECE', 8.45, 'Unplaced'),
    ('24CSE015', 'Chaitanya', 'Verma', 'chaitanya.v@college.edu', 'CSE', 7.80, 'Unplaced'),
    ('24CSE022', 'Divya', 'Nair', 'divya.nair@college.edu', 'CSE', 9.50, 'Unplaced'),
    ('24IT008', 'Eshwar', 'Prasad', 'eshwar.p@college.edu', 'IT', 6.90, 'Unplaced'),
    ('24IT019', 'Farhan', 'Ali', 'farhan.ali@college.edu', 'IT', 8.15, 'Unplaced'),
    ('24MEC004', 'Goutham', 'Rao', 'goutham.rao@college.edu', 'MECH', 7.20, 'Unplaced'),
    ('24ECE033', 'Harika', 'Kaur', 'harika.k@college.edu', 'ECE', 6.40, 'Unplaced');

-- 2. Populate Companies
INSERT INTO companies (company_name, industry, website, contact_email)
VALUES
    ('Nexora Tech', 'Product', 'https://nexora.io', 'careers@nexora.io'),
    ('CloudScale Systems', 'Cloud Infrastructure', 'https://cloudscale.com', 'campus@cloudscale.com'),
    ('FinPulse Analytics', 'Fintech', 'https://finpulse.com', 'talent@finpulse.com'),
    ('Apex Global Solutions', 'IT Services', 'https://apexsolutions.com', 'recruiting@apexsolutions.com');

-- 3. Populate Job Openings
INSERT INTO jobs (company_id, job_title, role_type, package_lpa, min_cgpa, location)
VALUES
    (1, 'Software Engineer', 'Full-Time', 12.00, 8.00, 'Bangalore'),
    (1, 'AI/ML Intern', 'Internship', 6.50, 8.50, 'Hyderabad'),
    (2, 'DevOps Engineer', 'Full-Time', 10.50, 7.50, 'Pune'),
    (3, 'Data Analyst', 'Full-Time', 8.50, 7.00, 'Hyderabad'),
    (4, 'Graduate Trainee', 'Full-Time', 4.50, 6.00, 'Chennai');

-- 4. Populate Applications
INSERT INTO applications (student_id, job_id, status)
VALUES
    (1, 1, 'Selected'),
    (1, 3, 'Applied'),
    (2, 1, 'Selected'),
    (2, 4, 'Applied'),
    (3, 4, 'In_Progress'),
    (4, 1, 'Selected'),
    (4, 2, 'Applied'),
    (5, 5, 'Rejected'),
    (6, 4, 'In_Progress'),
    (7, 5, 'Applied');

-- 5. Populate Interview Rounds
INSERT INTO interviews (application_id, round_number, round_type, interview_date, result)
VALUES
    (1, 1, 'Online Assessment', '2026-09-01', 'Passed'),
    (1, 2, 'Technical', '2026-09-05', 'Passed'),
    (1, 3, 'HR', '2026-09-10', 'Passed'),
    (3, 1, 'Online Assessment', '2026-09-01', 'Passed'),
    (3, 2, 'Technical', '2026-09-05', 'Passed'),
    (3, 3, 'HR', '2026-09-10', 'Passed'),
    (6, 1, 'Online Assessment', '2026-09-01', 'Passed'),
    (6, 2, 'Technical', '2026-09-06', 'Passed'),
    (6, 3, 'HR', '2026-09-11', 'Passed'),
    (8, 1, 'Aptitude Test', '2026-09-02', 'Failed');

-- 6. Populate Accepted Offers & Sync Student Status via ACID Transaction
START TRANSACTION;

INSERT INTO offers (application_id, offered_ctc, offer_date, joining_date, offer_status)
VALUES
    (1, 12.00, '2026-09-15', '2027-07-01', 'Accepted'),
    (3, 12.00, '2026-09-15', '2027-07-01', 'Accepted'),
    (6, 13.00, '2026-09-15', '2027-07-01', 'Accepted');

UPDATE students 
SET placement_status = 'Dream_Placed' 
WHERE student_id IN (1, 2, 4);

COMMIT;