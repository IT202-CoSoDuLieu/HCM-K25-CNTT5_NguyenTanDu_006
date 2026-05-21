DROP DATABASE IF EXISTS academic_management_db;
CREATE DATABASE academic_management_db;
USE academic_management_db;

CREATE TABLE courses (
	course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(255) NOT NULL,
    course_code VARCHAR(100) NOT NULL ,
    department VARCHAR(255) NOT NULL,
    creation_date DATE
);

CREATE TABLE students (
	student_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    major VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    gpa DECIMAL(2,1) DEFAULT 4.0
);

CREATE TABLE enrollments(
	enrollment_id VARCHAR(50) PRIMARY KEY,
    course_id INT,
	student_id INT,
    enroll_time DATETIME NOT NULL,
    credits INT CHECK(credits > 0),
    status ENUM ('Pending', 'Completed', 'Dropped') DEFAULT 'Pending',
    
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);


CREATE TABLE enrollment_details(
	detail_id VARCHAR(100) PRIMARY KEY,
    enrollment_id VARCHAR(50),
    attendance_check VARCHAR(255) NOT NULL,
    detail_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

CREATE TABLE academic_logs(
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    detail_id VARCHAR(100),
    student_id INT ,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    
	FOREIGN KEY (detail_id) REFERENCES enrollment_details(detail_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

INSERT INTO courses (course_id, course_name, course_code, department, creation_date)
VALUES 
	(1, 'Lập trình Java', 'JAVA01', 'CNTT', '2023-12-03'),
    (2, 'Cấu trúc dữ liệu', 'DSA02', 'Khoa học máy tính', '1996-11-25'),
    (3, 'Cơ sở dữ liệu', 'SQL03', 'CNTT', '2001-07-08'),
    (4, 'Mạng máy tính', 'NET04', 'Truyền thông', '1998-01-19'),
    (5, 'Trí tuệ nhân tạo', 'AI05', 'Khoa học máy tính', '2000-09-30');
    
INSERT INTO students(student_id, full_name, major, phone_number, gpa)
VALUES 
	(1,'Nguyễn Văn Hải', 'Hệ thống TT', '0931112223', 3.8),
    (2,'Trần Thu Hà', 'Kỹ thuật PM', '0932223334', 4.0),
    (3,'NLê Quốc Tuấn', 'An toàn TT', '0933334445', 3.6),
    (4,'Phạm Minh Châu', 'Dữ liệu lớn', '0934445556', 3.9),
    (5,'Hoàng Gia Bảo', 'Hệ thống TT', '0935556667', 3.7);

INSERT INTO enrollments(enrollment_id, course_id, student_id, enroll_time, credits, status)
VALUES 
	('7001', 1, 1, '2024-05-20 08:00', 3, 'Pending'),
    ('7002', 2, 2, '2024-05-20 09:30', 4, 'Completed'),
    ('7003', 3, 3, '2024-05-20 10:15', 3, 'Pending'),
    ('7004', 4, 5, '2024-05-21 07:00', 3, 'Completed'),
    ('7005', 5, 4, '2024-05-21 08:45', 3, 'Dropped');
    
INSERT INTO enrollment_details(detail_id, enrollment_id, attendance_check, detail_date)
VALUES 
	('8001', '7002', 'Đủ điều kiện thi', '2024-05-20 10:00'),
    ('8002', '7004', 'Vắng 1 buổi', '2024-05-21 08:00'),
    ('8003', '7001', 'Đang học', '2024-05-20 09:00'),
    ('8004', '7003', 'Nghỉ phép', '2024-05-20 11:00'),
    ('8005', '7005', 'Không học', '2024-05-21 09:00');
    
INSERT INTO academic_logs(log_id, detail_id, student_id, log_time, note)
VALUES 
	(1, '8003', 1, '2024-05-20 09:05', 'Bắt đầu lớp học'),
    (2, '8001', 2, '2024-05-20 10:05', 'Hoàn tất môn học'),
    (3, '8004', 3, '2024-05-20 11:10', 'Đăng sắp xếp lịch bù'),
    (4, '8002', 5, '2024-05-21 08:10', 'Chờ phê duyệt điểm'),
    (5, '8005', 4, '2024-05-21 09:05', 'Hủy do vắng quá số buổi');
    
-- Update & Delete
-- Thêm 1 tín chỉ cho các bảng ghi có trạng thái Completed và thuộc môn học có năm tạo < 2000
UPDATE enrollments e 
JOIN courses c ON c.course_id = e.course_id
SET credits = credits + 1
WHERE status = 'Completed' AND  YEAR(c.creation_date) < '2000';

-- Xóa bản ghi trong academic_logs
DELETE FROM academic_logs
WHERE log_time > '2024-05-20';

-- Truy vấn cơ bản
-- Liệt kê sinh viên có điểm GPA lớn hơn 3.8 hoặc thuộc chuyên ngành "Kỹ thuật PM"
SELECT full_name, major, gpa FROM students
WHERE major = 'Kỹ thuật PM' OR gpa > 3.8;

-- Liệt kê thông tin môn học có ngày tạo từ 01-01-1998 đến 31-12-2001
SELECT course_name, course_code FROM courses
WHERE creation_date BETWEEN '1998-01-01' AND '2001-12-31';

-- Liệt kê bản ghi đăng ký môn học chỉ hiển thị 2 bản ghi ở trang thứ 2 sắp xếp tín chỉ giảm dần
SELECT enrollment_id, enroll_time, credits FROM enrollments 
ORDER BY credits DESC
LIMIT 2 OFFSET 2;

-- Truy vấn nâng cao 
-- Liệt kê thông tin xử lí học vụ từ nhiều bảng
SELECT c.course_name, s.full_name, s.major, e.credits, e.enroll_time FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses c ON c.course_id = e.course_id;

-- Hiển thị nhưng sinh viên có tổng số tính chỉ lớn hơn 120 
SELECT s.full_name, SUM(e.credits) AS total_credit FROM enrollments e
JOIN students s ON s.student_id = e.student_id
WHERE e.status = 'Completed'
GROUP BY s.full_name
HAVING  total_credit > 120;

-- Thông tin sinh viên có điểm cao nhất
SELECT student_id, full_name, gpa FROM students
WHERE gpa = (SELECT MAX(gpa) FROM students);

