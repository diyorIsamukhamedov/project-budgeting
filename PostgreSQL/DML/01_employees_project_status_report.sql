-- ================================================================================
-- Retrieve employee details along with their department and assigned project information, 
-- including project status (upcoming or completed) using a CTE to unify project data.
WITH project_status AS (
    SELECT project_id,
        project_name,
        project_budget,
        'upcoming' AS status
    FROM upcoming_projects
    UNION ALL
    SELECT
        project_id,
        project_name,
        project_budget,
        'completed' AS status
    FROM completed_projects
)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    e.salary,
    d.department_name,
    pa.project_id,
    p.project_name,
    p.status
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.department_id
INNER JOIN project_assignments pa
    ON pa.employee_id = e.employee_id
INNER JOIN project_status p
    ON p.project_id = pa.project_id;
-- ================================================================================

-- ================================================================================

