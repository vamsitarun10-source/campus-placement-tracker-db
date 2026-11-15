\# Campus Placement Tracker — Relational Database System (MySQL 8.x)



A normalized 7-table relational database built in \*\*MySQL 8.x\*\* to automate campus recruitment tracking—from company job postings and student applications to multi-round interview evaluations, offer management, and immutable status auditing.



\## Database Architecture



The schema resolves Many-to-Many ($M:N$) student-to-job relationships through an `applications` bridge table and enforces data integrity directly at the storage layer:



1\. \*\*`students`\*\* — Master student profiles, CGPA validation (`CHECK 0.00–10.00`), and placement status.

2\. \*\*`companies`\*\* — Recruiting organization master records.

3\. \*\*`jobs`\*\* — Role openings ($1:N$ with `companies`) with minimum CGPA and positive CTC constraints.

4\. \*\*`applications`\*\* — Bridge table ($M:N$) preventing duplicate submissions via composite `UNIQUE (student\_id, job\_id)`.

5\. \*\*`interviews`\*\* — Round-by-round evaluations ($1:N$ with `applications`, `ON DELETE CASCADE`).

6\. \*\*`offers`\*\* — Final CTC and acceptance tracking ($1:1$ with `applications`, `ON DELETE CASCADE`).

7\. \*\*`application\_audit`\*\* — Immutable audit trail populated automatically via database triggers.



\## Key Engineering Highlights



\- \*\*Automated Audit Trail:\*\* `trg\_after\_application\_status\_update` (`AFTER UPDATE` trigger) captures `OLD.status`, `NEW.status`, and `USER()` whenever an application status changes.

\- \*\*Reusable Reporting Views:\*\* `vw\_active\_applications` and `vw\_placed\_students` abstract multi-table joins into single-line queries.

\- \*\*ACID Transactions:\*\* Offer acceptance and student placement status updates execute atomically (`START TRANSACTION` / `COMMIT`).

\- \*\*Advanced Analytics:\*\* Implements scalar/correlated subqueries, Common Table Expressions (`WITH`), and window functions (`DENSE\_RANK()`, `AVG() OVER (PARTITION BY ...)`).

\- \*\*Query Optimization:\*\* Composite index (`idx\_students\_dept\_cgpa`) accelerates departmental eligibility filtering.



\## How to Run



Execute the scripts sequentially in MySQL 8.0+:



```bash

mysql -u root -p < 01\_schema.sql

mysql -u root -p < 02\_seed\_data.sql

mysql -u root -p < 03\_views\_and\_triggers.sql

mysql -u root -p < 04\_analytical\_queries.sql

