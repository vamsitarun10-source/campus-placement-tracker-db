-- ============================================================================
-- Campus Placement Tracker Database - Schema Definition (MySQL 8.x)
-- ============================================================================

DROP DATABASE IF EXISTS placement_tracker_db;
CREATE DATABASE placement_tracker_db;
USE placement_tracker_db;

-- 1. Students Master Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    roll_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    department VARCHAR(50) NOT NULL,
    cgpa DECIMAL(3,2) NOT NULL,
    placement_status VARCHAR(25) DEFAULT 'Unplaced',
    CONSTRAINT chk_student_cgpa CHECK (cgpa >= 0.00 AND cgpa <= 10.00)
);

-- 2. Recruiting Companies Master Table
CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(50) NOT NULL UNIQUE,
    industry VARCHAR(50) NOT NULL,
    website VARCHAR(100),
    contact_email VARCHAR(100) NOT NULL
);

-- 3. Open Job Roles (1:N with companies)
CREATE TABLE jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    role_type VARCHAR(50) DEFAULT 'Full-Time',
    package_lpa DECIMAL(4, 2) NOT NULL,
    min_cgpa DECIMAL(3, 2) NOT NULL DEFAULT 6.00,
    location VARCHAR(100) NOT NULL,
    CONSTRAINT fk_jobs_company FOREIGN KEY (company_id) REFERENCES companies(company_id),
    CONSTRAINT chk_jobs_min_cgpa CHECK (min_cgpa >= 0.00 AND min_cgpa <= 10.00),
    CONSTRAINT chk_jobs_package CHECK (package_lpa > 0.00)
);

-- 4. Student Applications (Bridge table resolving M:N between students & jobs)
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    job_id INT NOT NULL,
    application_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Applied',
    CONSTRAINT fk_apps_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_apps_job FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT uq_student_job UNIQUE (student_id, job_id),
    CONSTRAINT chk_app_status CHECK (status IN ('Applied', 'Shortlisted', 'In_Progress', 'Selected', 'Rejected'))
);

-- 5. Interview Rounds Evaluation (1:N with applications)
CREATE TABLE interviews (
    interview_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    round_number INT NOT NULL,
    round_type VARCHAR(50) NOT NULL,
    interview_date DATE NOT NULL,
    result VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT fk_interviews_app FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    CONSTRAINT uq_app_round UNIQUE (application_id, round_number),
    CONSTRAINT chk_interview_result CHECK (result IN ('Pending', 'Passed', 'Failed'))
);

-- 6. Final Placement Offers (1:1 with applications)
CREATE TABLE offers (
    offer_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL UNIQUE,
    offered_ctc DECIMAL(4, 2) NOT NULL CHECK (offered_ctc > 0.00),
    offer_date DATE NOT NULL,
    joining_date DATE,
    offer_status VARCHAR(20) DEFAULT 'Pending' CHECK (offer_status IN ('Pending', 'Accepted', 'Rejected', 'Expired')),
    CONSTRAINT fk_offers_app FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE
);

-- 7. Immutable Status Change Audit Log
CREATE TABLE application_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT 'SYSTEM',
    CONSTRAINT fk_audit_app FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE
);

-- Performance Index for Department & CGPA Eligibility Filtering
CREATE INDEX idx_students_dept_cgpa ON students(department, cgpa);