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
