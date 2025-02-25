Functions and Aggregates
  
DELIMITER $$

CREATE FUNCTION calculate_age(date_of_birth DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE age INT;
    SET age = TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE());
    
    IF MONTH(date_of_birth) > MONTH(CURDATE()) OR (MONTH(date_of_birth) = MONTH(CURDATE()) AND DAY(date_of_birth) > DAY(CURDATE())) THEN
        SET age = age - 1;
    END IF;
    
    RETURN age;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE enroll_student_in_course(IN student_id INT, IN course_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = student_id AND course_id = course_id) THEN
        INSERT INTO enrollments (student_id, course_id)
        VALUES (student_id, course_id);
        
        SELECT 'Student successfully enrolled in the course' AS message;
    ELSE
        SELECT 'Student is already enrolled in this course' AS message;
    END IF;
END $$

DELIMITER ;

SELECT c.department, AVG(
    CASE 
        WHEN e.grade = 'A' THEN 4
        WHEN e.grade = 'B' THEN 3
        WHEN e.grade = 'C' THEN 2
        WHEN e.grade = 'D' THEN 1
        WHEN e.grade = 'F' THEN 0
        ELSE NULL
    END
) AS average_grade
FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
GROUP BY c.department;

ALTER TABLE Students
ADD CONSTRAINT unique_email UNIQUE (email);

DELIMITER $$

CREATE PROCEDURE enroll_student_if_capacity(IN p_student_id INT, IN p_course_id INT)
BEGIN
    DECLARE enrolled_students INT;
    DECLARE course_capacity INT;

    START TRANSACTION;

    SELECT COUNT(*) INTO enrolled_students
    FROM Enrollments
    WHERE course_id = p_course_id;

    SELECT capacity INTO course_capacity
    FROM Courses
    WHERE course_id = p_course_id;

    IF enrolled_students < course_capacity THEN
        INSERT INTO Enrollments (student_id, course_id)
        VALUES (p_student_id, p_course_id);
        COMMIT;
        SELECT 'Student successfully enrolled' AS message;
    ELSE
        ROLLBACK;
        SELECT 'Enrollment failed: Course is full' AS message;
    END IF;
END $$

DELIMITER ;

CREATE INDEX idx_course_code ON Courses(course_code);

EXPLAIN 
SELECT s.student_id, s.first_name, s.last_name
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.course_id = 101;

SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name, 
    c.course_id, 
    c.course_name, 
    c.course_code
FROM Students s
INNER JOIN Enrollments e ON s.student_id = e.student_id
INNER JOIN Courses c ON e.course_id = c.course_id;

SELECT 
    i.instructor_id, 
    i.first_name, 
    i.last_name, 
    c.course_id, 
    c.course_name, 
    c.course_code
FROM Instructors i
LEFT JOIN Course_Assignments ca ON i.instructor_id = ca.instructor_id
LEFT JOIN Courses c ON ca.course_id = c.course_id;

SELECT 
    student_id AS id, 
    first_name, 
    last_name, 
    'Student' AS role
FROM Students

UNION

SELECT 
    instructor_id AS id, 
    first_name, 
    last_name, 
    'Instructor' AS role
FROM Instructors;

SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name, 
    s.email, 
    s.major, 
    c.course_id, 
    c.course_name, 
    c.course_code, 
    i.first_name AS instructor_first_name, 
    i.last_name AS instructor_last_name, 
    e.grade, 
    c.credits, 
    (SELECT SUM(c2.credits) 
     FROM Enrollments e2 
     JOIN Courses c2 ON e2.course_id = c2.course_id 
     WHERE e2.student_id = s.student_id) AS total_credits
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
JOIN Course_Assignments ca ON c.course_id = ca.course_id
JOIN Instructors i ON ca.instructor_id = i.instructor_id
ORDER BY s.student_id, c.course_name;
