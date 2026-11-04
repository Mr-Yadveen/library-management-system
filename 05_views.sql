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
