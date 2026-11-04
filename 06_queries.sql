USE library_db;

-- Q1. All books with authors and categories
SELECT * FROM book_details;

-- Q2. Search books by keyword
SELECT title, author_name FROM book_details WHERE title LIKE '%Database%';

-- Q3. Books currently issued and to whom
SELECT m.full_name, b.title, i.issue_date, i.due_date
FROM Issue i
JOIN Member m ON i.member_id = m.member_id
JOIN Book b   ON i.book_id = b.book_id
WHERE i.return_date IS NULL;

-- Q4. Overdue books
SELECT * FROM overdue_books;

-- Q5. Total fine per member
SELECT m.full_name, SUM(i.fine_amount) AS total_fine
FROM Issue i
JOIN Member m ON i.member_id = m.member_id
GROUP BY m.member_id, m.full_name
HAVING SUM(i.fine_amount) > 0;

-- Q6. Most popular books
SELECT b.title, COUNT(*) AS times_issued
FROM Issue i
JOIN Book b ON i.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY times_issued DESC
LIMIT 5;

-- Q7. Number of books per category
SELECT c.category_name, COUNT(b.book_id) AS total_books
FROM Category c
LEFT JOIN Book b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name;

-- Q8. Members who never borrowed
SELECT full_name FROM Member
WHERE member_id NOT IN (SELECT DISTINCT member_id FROM Issue);

-- Q9. Books with no copies available
SELECT title FROM Book WHERE available_copies = 0;

-- Q10. Borrowing history of member 1
SELECT b.title, i.issue_date, i.return_date, i.fine_amount
FROM Issue i
JOIN Book b ON i.book_id = b.book_id
WHERE i.member_id = 1
ORDER BY i.issue_date DESC;
