-- Library Management System: Schema
-- Author: Yadveen Singh (UID: 25BSC10041)
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

CREATE TABLE Category (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Author (
    author_id   INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    country     VARCHAR(50)
);

CREATE TABLE Book (
    book_id          INT AUTO_INCREMENT PRIMARY KEY,
    title            VARCHAR(150) NOT NULL,
    isbn             VARCHAR(20) UNIQUE,
    category_id      INT,
    publisher        VARCHAR(100),
    year_published   YEAR,
    total_copies     INT NOT NULL CHECK (total_copies >= 0),
    available_copies INT NOT NULL CHECK (available_copies >= 0),
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE SET NULL
);

CREATE TABLE Book_Author (
    book_id   INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id)   REFERENCES Book(book_id)     ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Author(author_id) ON DELETE CASCADE
);

CREATE TABLE Member (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email     VARCHAR(100) UNIQUE,
    phone     VARCHAR(15),
    address   VARCHAR(200),
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE Staff (
    staff_id  INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    role      VARCHAR(50),
    email     VARCHAR(100) UNIQUE
);

CREATE TABLE Issue (
    issue_id    INT AUTO_INCREMENT PRIMARY KEY,
    book_id     INT NOT NULL,
    member_id   INT NOT NULL,
    staff_id    INT,
    issue_date  DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date    DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(8,2) DEFAULT 0,
    FOREIGN KEY (book_id)   REFERENCES Book(book_id),
    FOREIGN KEY (member_id) REFERENCES Member(member_id),
    FOREIGN KEY (staff_id)  REFERENCES Staff(staff_id)
);
USE library_db;

INSERT INTO Category (category_name) VALUES
('Computer Science'), ('Fiction'), ('History'), ('Science');

INSERT INTO Author (author_name, country) VALUES
('Abraham Silberschatz', 'USA'),
('Ramez Elmasri', 'USA'),
('R. K. Narayan', 'India'),
('Yuval Noah Harari', 'Israel');

INSERT INTO Book (title, isbn, category_id, publisher, year_published, total_copies, available_copies) VALUES
('Database System Concepts', '9780078022159', 1, 'McGraw-Hill', 2019, 5, 5),
('Fundamentals of Database Systems', '9780133970777', 1, 'Pearson', 2016, 4, 4),
('Malgudi Days', '9780143039655', 2, 'Penguin', 2006, 3, 3),
('Sapiens', '9780099590088', 3, 'Vintage', 2015, 6, 6);

INSERT INTO Book_Author VALUES (1,1), (2,2), (3,3), (4,4);

INSERT INTO Member (full_name, email, phone, address) VALUES
('Yadveen Singh', 'yadveen@example.com', '9876500001', 'Mohali, Punjab'),
('Amit Sharma',   'amit@example.com',    '9876500002', 'Chandigarh'),
('Priya Verma',   'priya@example.com',   '9876500003', 'Ludhiana, Punjab');

INSERT INTO Staff (full_name, role, email) VALUES
('Ravi Kumar', 'Librarian', 'ravi@library.com'),
('Sunita Devi', 'Assistant', 'sunita@library.com');
USE library_db;
DELIMITER //

-- Enforce 3-book limit, check stock, set 14-day due date
CREATE TRIGGER before_issue_check
BEFORE INSERT ON Issue
FOR EACH ROW
BEGIN
    DECLARE active_loans INT;
    DECLARE copies INT;

    SELECT COUNT(*) INTO active_loans
    FROM Issue
    WHERE member_id = NEW.member_id AND return_date IS NULL;

    SELECT available_copies INTO copies
    FROM Book WHERE book_id = NEW.book_id;

    IF active_loans >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member already has 3 books issued';
    END IF;

    IF copies <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No copies available';
    END IF;

    SET NEW.due_date = DATE_ADD(NEW.issue_date, INTERVAL 14 DAY);
END//

-- Reduce available copies after issue
CREATE TRIGGER after_issue_insert
AFTER INSERT ON Issue
FOR EACH ROW
BEGIN
    UPDATE Book
    SET available_copies = available_copies - 1
    WHERE book_id = NEW.book_id;
END//

-- Calculate fine (Rs. 5/day) on return
CREATE TRIGGER before_return_update
BEFORE UPDATE ON Issue
FOR EACH ROW
BEGIN
    IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN
        IF NEW.return_date > OLD.due_date THEN
            SET NEW.fine_amount = DATEDIFF(NEW.return_date, OLD.due_date) * 5;
        ELSE
            SET NEW.fine_amount = 0;
        END IF;
    END IF;
END//

-- Restore available copies after return
CREATE TRIGGER after_return_update
AFTER UPDATE ON Issue
FOR EACH ROW
BEGIN
    IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN
        UPDATE Book
        SET available_copies = available_copies + 1
        WHERE book_id = NEW.book_id;
    END IF;
END//

DELIMITER ;
USE library_db;
DELIMITER //

CREATE PROCEDURE issue_book(IN p_book INT, IN p_member INT, IN p_staff INT)
BEGIN
    -- due_date is overwritten with issue_date + 14 days by the trigger
    INSERT INTO Issue (book_id, member_id, staff_id, issue_date, due_date)
    VALUES (p_book, p_member, p_staff, CURRENT_DATE, CURRENT_DATE);
END//

CREATE PROCEDURE return_book(IN p_issue INT)
BEGIN
    UPDATE Issue
    SET return_date = CURRENT_DATE
    WHERE issue_id = p_issue AND return_date IS NULL;
END//

DELIMITER ;

-- Usage:
-- CALL issue_book(1, 1, 1);
-- CALL return_book(1);
USE library_db;

CREATE VIEW book_details AS
SELECT b.book_id, b.title, a.author_name, c.category_name,
       b.publisher, b.year_published, b.available_copies
FROM Book b
JOIN Book_Author ba ON b.book_id = ba.book_id
JOIN Author a       ON ba.author_id = a.author_id
LEFT JOIN Category c ON b.category_id = c.category_id;

CREATE VIEW overdue_books AS
SELECT i.issue_id, m.full_name AS member, b.title,
       i.due_date, DATEDIFF(CURRENT_DATE, i.due_date) AS days_overdue
FROM Issue i
JOIN Member m ON i.member_id = m.member_id
JOIN Book b   ON i.book_id = b.book_id
WHERE i.return_date IS NULL AND i.due_date < CURRENT_DATE;
