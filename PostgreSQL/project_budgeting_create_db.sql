CREATE DATABASE project_budgeting
	WITH OWNER = postgres
	ENCODING = 'UTF8'
	TEMPLATE = template0
    CONNECTION LIMIT = -1;

CREATE SCHEMA IF NOT EXISTS department_projects;

-- Drop the table "employees" if it already exists inside the schema "department_projects"
DROP TABLE IF EXISTS department_projects.eployees;

-- Create the "departments" table
CREATE table IF NOT EXISTS department_id.departments (
    department_id INT PRIMARY KEY NOT NULL,
    department_name VARCHAR(50) NOT NULL,
    department_budget
);

-- Create the "eployees" table
CREATE TABLE department_projects.employees (
	employee_id INT PRIMARY KEY NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(254) NOT NULL,
	job_title TEXT,
	salary NUMERIC(12, 2),
	hire_date DATE,
	department_id INT,
	CONSTRAINT fk_employees_department
		FOREIGN KEY (department_id)
		REFERENCES department_projects.departments (department_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);