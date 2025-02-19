CREATE DATABASE task;


CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female') NOT NULL,
    major VARCHAR(100) NOT NULL,
    enrollment_year YEAR NOT NULL
);

CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    credits INT CHECK (credits > 0),
    department VARCHAR(100) NOT NULL
);

CREATE TABLE Instructors (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    department VARCHAR(100) NOT NULL
);

CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade CHAR(2) CHECK (grade IN ('A', 'B', 'C', 'D', 'F', 'W', 'I')),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

CREATE TABLE Course_Assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_id INT NOT NULL,
    course_id INT NOT NULL,
    semester ENUM('Spring', 'Summer', 'Fall', 'Winter') NOT NULL,
    year YEAR NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);




////////////////////////////////////////////////////

-- Insert Students
INSERT INTO Students (first_name, last_name, email, date_of_birth, gender, major, enrollment_year)
VALUES 
('Ali', 'Hassan', 'ali.hassan@email.com', '2002-05-15', 'Male', 'Computer Science', 2021),
('Sara', 'Ahmed', 'sara.ahmed@email.com', '2003-08-22', 'Female', 'Mathematics', 2022),
('Omar', 'Khalid', 'omar.khalid@email.com', '2001-03-10', 'Male', 'Physics', 2020),
('Lina', 'Nour', 'lina.nour@email.com', '2002-11-30', 'Female', 'Biology', 2021),
('Kareem', 'Sami', 'kareem.sami@email.com', '2003-07-19', 'Male', 'Engineering', 2022),
('Hana', 'Youssef', 'hana.youssef@email.com', '2000-12-05', 'Female', 'Business', 2019),
('Tariq', 'Saleh', 'tariq.saleh@email.com', '2002-04-27', 'Male', 'Medicine', 2021),
('Mira', 'Fadi', 'mira.fadi@email.com', '2003-09-14', 'Female', 'Psychology', 2022),
('Nour', 'Bassam', 'nour.bassam@email.com', '2001-06-02', 'Male', 'Computer Engineering', 2020),
('Layla', 'Hadi', 'layla.hadi@email.com', '2003-02-20', 'Female', 'Economics', 2022);

-- Insert Instructors
INSERT INTO Instructors (first_name, last_name, email, hire_date, department)
VALUES 
('Ahmed', 'Ali', 'ahmed.ali@email.com', '2015-09-01', 'Computer Science'),
('Fatima', 'Hassan', 'fatima.hassan@email.com', '2018-06-15', 'Mathematics'),
('Mohamed', 'Sami', 'mohamed.sami@email.com', '2012-03-20', 'Physics'),
('Nadia', 'Youssef', 'nadia.youssef@email.com', '2016-11-10', 'Biology'),
('Youssef', 'Tariq', 'youssef.tariq@email.com', '2020-01-05', 'Engineering');

-- Insert Courses
INSERT INTO Courses (course_name, course_code, credits, department)
VALUES 
('Database Systems', 'CS101', 3, 'Computer Science'),
('Calculus I', 'MATH102', 4, 'Mathematics'),
('Physics Mechanics', 'PHYS103', 3, 'Physics'),
('Organic Chemistry', 'CHEM104', 3, 'Biology'),
('Circuit Analysis', 'ENGR105', 3, 'Engineering');

-- Assign Courses to Instructors
INSERT INTO Course_Assignments (instructor_id, course_id, semester, year)
VALUES 
(1, 1, 'Fall', 2024),
(2, 2, 'Spring', 2024),
(3, 3, 'Summer', 2024),
(4, 4, 'Winter', 2024),
(5, 5, 'Fall', 2024);

-- Enroll Students in Courses (Each student takes at least 2 courses)
INSERT INTO Enrollments (student_id, course_id, grade)
VALUES 
(1, 1, 'A'), (1, 2, 'B'),
(2, 2, 'A'), (2, 3, 'C'),
(3, 3, 'B'), (3, 4, 'A'),
(4, 4, 'B'), (4, 5, 'C'),
(5, 1, 'A'), (5, 5, 'B'),
(6, 2, 'C'), (6, 3, 'A'),
(7, 3, 'B'), (7, 4, 'C'),
(8, 4, 'A'), (8, 5, 'B'),
(9, 1, 'C'), (9, 2, 'A'),
(10, 3, 'B'), (10, 5, 'A');


////////////////////////////////////////////////////////////////



SELECT * FROM Students;


SELECT COUNT(*) AS total_courses FROM Courses;


SELECT S.first_name, S.last_name 
FROM Students S
JOIN Enrollments E ON S.student_id = E.student_id
JOIN Courses C ON E.course_id = C.course_id
WHERE C.course_code = 'CS101';

SELECT first_name, last_name, email 
FROM Instructors 
WHERE department = 'Computer Science';

////////////////////////////////////////////////////////////////////////





SELECT C.course_name, C.course_code, COUNT(E.student_id) AS student_count
FROM Courses C
LEFT JOIN Enrollments E ON C.course_id = E.course_id
GROUP BY C.course_id;

SELECT S.first_name, S.last_name, C.course_name, C.course_code
FROM Students S
JOIN Enrollments E ON S.student_id = E.student_id
JOIN Courses C ON E.course_id = C.course_id
WHERE E.grade = 'A';

SELECT C.course_name, C.course_code, I.first_name, I.last_name, CA.semester, CA.year
FROM Courses C
JOIN Course_Assignments CA ON C.course_id = CA.course_id
JOIN Instructors I ON CA.instructor_id = I.instructor_id
WHERE CA.semester = 'Fall';

SELECT C.course_name, C.course_code, 
       AVG(CASE 
             WHEN E.grade = 'A' THEN 4.0
             WHEN E.grade = 'B' THEN 3.0
             WHEN E.grade = 'C' THEN 2.0
             WHEN E.grade = 'D' THEN 1.0
             WHEN E.grade = 'F' THEN 0.0
             ELSE NULL 
           END) AS average_gpa
FROM Courses C
JOIN Enrollments E ON C.course_id = E.course_id
WHERE C.course_code = 'CS101'
GROUP BY C.course_id;


SELECT s.student_id, s.first_name, s.last_name, COUNT(e.course_id) AS course_count
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.semester = 'Spring 2024'  
GROUP BY s.student_id
HAVING COUNT(e.course_id) > 3;

SELECT s.student_id, s.first_name, s.last_name, c.course_name, e.grade
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE e.grade IS NULL OR e.grade = 'Incomplete';


SELECT s.student_id, s.first_name, s.last_name, ROUND(AVG(e.grade), 2) AS average_grade
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.grade IS NOT NULL
GROUP BY s.student_id
ORDER BY average_grade DESC
LIMIT 1;


SELECT c.department, COUNT(c.course_id) AS course_count
FROM Courses c
WHERE YEAR(NOW()) = 2024  
GROUP BY c.department
ORDER BY course_count DESC
LIMIT 1;


SELECT c.course_id, c.course_name, c.course_code
FROM Courses c
LEFT JOIN Enrollments e ON c.course_id = e.course_id
WHERE e.course_id IS NULL;



