-- ================================================================================
-- Create a new database for project budgeting
CREATE DATABASE project_budgeting
	WITH OWNER = postgres	-- owner of the database
	ENCODING = 'UTF8'		-- encoding to support international text
	TEMPLATE = template0	-- base template for a clean database
    CONNECTION LIMIT = -1;	-- unlimitted connections allowed

-- Create schema inside the database (to organise all tables under one namespace)
CREATE SCHEMA IF NOT EXISTS project_budgeting;
-- ================================================================================

-- ================================================================================
/*
	Drop existing tables if they exist inside schema "project_budgeting"
	This ensures the script can be re-run without conflicts.
	The order is chosen carefully to avoid foreign key dependency issues.
*/
DROP TABLE IF EXISTS project_budgeting.epmloyees;
DROP TABLE IF EXISTS project_budgeting.departments;
DROP TABLE IF EXISTS project_budgeting.projects;
DROP TABLE IF EXISTS project_budgeting.completed_projects;
DROP TABLE IF EXISTS project_budgeting.project_assignments;
DROP TABLE IF EXISTS project_budgeting.head_shots;
DROP TABLE IF EXISTS project_budgeting.upcoming_projects;
-- ================================================================================

-- ================================================================================
-- Table: departments (stores company departments)
CREATE TABLE IF NOT EXISTS project_budgeting.departments (
    department_id INT PRIMARY KEY NOT NULL,
    department_name TEXT NOT NULL,
    department_budget NUMERIC(12, 2),
	head_of_department VARCHAR(150),
	number_of_employees INT,
	department_goals TEXT,
	location TEXT	-- physical office location
);

-- Table: employees (stores employee information)
CREATE TABLE IF NOT EXISTS project_budgeting.employees (
	employee_id INT PRIMARY KEY NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(254) NOT NULL,
	job_title TEXT,
	salary NUMERIC(12, 2),
	hire_date DATE,
	department_id INT,		-- reference to the department they belong to
	CONSTRAINT fk_employees_department
		FOREIGN KEY (department_id)
		REFERENCES project_budgeting.departments (department_id)
		ON DELETE SET NULL	-- if department is deleted, keep employee but set department_id NULL
		ON UPDATE CASCADE	-- if department_id changes, update employees accordingly
);

-- Table: projects (stores active projects)
CREATE TABLE IF NOT EXISTS project_budgeting.projects (
	project_id INT PRIMARY KEY NOT NULL,
	project_name TEXT,
	project_budget NUMERIC(12, 2),
	start_date DATE,
	end_date DATE,
	department_id INT,		-- reference to responsible department
	CONSTRAINT fk_projects_department
		FOREIGN KEY (department_id)
		REFERENCES project_budgeting.departments (department_id)
		ON DELETE SET NULL	-- if department is deleted, keep employee but set department_id NULL
		ON UPDATE CASCADE	-- if department_id changes, update employees accordingly
);

-- Table: completed_projects (stores projects that are finished)
CREATE TABLE IF NOT EXISTS project_budgeting.completed_projects (
	project_id INT PRIMARY KEY NOT NULL,
	project_name TEXT,
	project_budget NUMERIC(12, 2),
	project_start_date DATE,
	project_end_date DATE,
	department_id INT,		-- reference to responsible department
	CONSTRAINT fk_completed_projects_department
		FOREIGN KEY (department_id)
		REFERENCES project_budgeting.departments (department_id)
		ON DELETE SET NULL	-- if department is deleted, keep employee but set department_id NULL
		ON UPDATE CASCADE	-- if department_id changes, update employees accordingly
);

-- Table: upcoming_projects (stores planned/future projects)
CREATE TABLE IF NOT EXISTS project_budgeting.upcoming_projects (
	project_id INT PRIMARY KEY NOT NULL,
	project_name TEXT,
	project_budget NUMERIC(12, 2),
	project_start_date DATE,
	project_end_date DATE,
	department_id INT,		-- reference to responsible department
	project_lead VARCHAR(155),
	CONSTRAINT fk_upcoming_projects_department
		FOREIGN KEY (department_id)
		REFERENCES project_budgeting.departments (department_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

-- Table: project_assignments (link table between employees and projects)
CREATE TABLE IF NOT EXISTS project_budgeting.project_assignments (
	assignment_id INT PRIMARY KEY NOT NULL,
	employee_id INT,
	project_id INT,
	CONSTRAINT fk_project_assignments_employee
		FOREIGN KEY (employee_id)
		REFERENCES project_budgeting.employees (employee_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	CONSTRAINT fk_project_assignments_project
		FOREIGN KEY (project_id)
		REFERENCES project_budgeting.projects (project_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

-- Table: head_shots (stores employee headshot photos by URL)
CREATE TABLE IF NOT EXISTS project_budgeting.head_shots (
	employee_id INT PRIMARY KEY,	-- links directly to employees table
	head_shot TEXT NOT NULL,		-- photo URL (from CSV file)
	CONSTRAINT fk_head_shots_employee
		FOREIGN KEY (employee_id)
		REFERENCES project_budgeting.employees (employee_id)
		ON DELETE CASCADE			-- if employee is deleted, delete headshot too
		ON UPDATE CASCADE
);
-- ================================================================================