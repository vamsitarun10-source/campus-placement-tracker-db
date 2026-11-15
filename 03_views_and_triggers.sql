-- ============================================================================
-- Campus Placement Tracker Database - Views & Automated Triggers
-- ============================================================================

USE placement_tracker_db;

-- View 1: Active Applications Pipeline
CREATE OR REPLACE VIEW vw_active_applications AS
SELECT 
    a.application_id,
    s.roll_number,
    s.first_name,
    c.company_name,
    j.job_title,
    a.status
FROM students s
INNER JOIN applications a ON a.student_id = s.student_id
INNER JOIN jobs j ON a.job_id = j.job_id
INNER JOIN companies c ON c.company_id = j.company_id
WHERE a.status IN ('Applied', 'In_Progress');

-- View 2: Official Placed Students Dashboard
CREATE OR REPLACE VIEW vw_placed_students AS
SELECT 
    s.roll_number,
    s.first_name,
    s.department,
    c.company_name,
    j.job_title,
    o.offered_ctc,
    o.offer_status
FROM students s
INNER JOIN applications a ON a.student_id = s.student_id
INNER JOIN jobs j ON a.job_id = j.job_id
INNER JOIN companies c ON c.company_id = j.company_id
INNER JOIN offers o ON a.application_id = o.application_id
WHERE o.offer_status = 'Accepted';

-- Trigger: Automatic Audit Logging on Application Status Change
DROP TRIGGER IF EXISTS trg_after_application_status_update;

DELIMITER //

CREATE TRIGGER trg_after_application_status_update
AFTER UPDATE ON applications
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO application_audit (application_id, old_status, new_status, changed_by)
        VALUES (NEW.application_id, OLD.status, NEW.status, USER());
    END IF;
END //

DELIMITER ;