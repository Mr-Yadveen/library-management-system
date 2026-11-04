# Library Management System (DBMS Project)

A relational database project that manages books, authors, categories, members, staff and book issue/return records, with automatic fine calculation and stock tracking.

**Author:** Yadveen Singh
**UID:** 25BSC10041
**Program:** BSc Computer Science, Chandigarh University, Mohali
**Subject:** Database Management Systems (DBMS)
**Database:** MySQL 8.x

## Features

- Normalized design (3NF) with primary keys, foreign keys, UNIQUE and CHECK constraints
- Many-to-many relation between books and authors (`Book_Author`)
- Triggers that automatically:
  - limit each member to 3 active loans
  - block issuing when no copies are available
  - set the due date to 14 days after issue
  - update `available_copies` on issue and return
  - calculate a fine of Rs. 5 per late day
- Stored procedures: `issue_book`, `return_book`
- Views: `book_details`, `overdue_books`
- 10 ready-made analytical queries

## ER Diagram (text form)

```
Category 1 ---- N Book N ---- M Author
                   |
                   1
                   |
                   N
Member 1 ---- N  Issue  N ---- 1 Staff
```

## Tables

| Table | Purpose |
|---|---|
| Category | Book categories |
| Author | Author details |
| Book | Book catalogue and stock counts |
| Book_Author | Links books and authors (M:N) |
| Member | Library members |
| Staff | Library staff |
| Issue | Issue/return transactions and fines |

## Project Structure

```
library-management-system/
├── README.md
└── sql/
    ├── 01_schema.sql         # database + tables
    ├── 02_sample_data.sql    # sample records
    ├── 03_triggers.sql       # business-rule triggers
    ├── 04_procedures.sql     # issue_book, return_book
    ├── 05_views.sql          # book_details, overdue_books
    ├── 06_queries.sql        # 10 sample queries
    └── setup_all.sql         # files 01-05 combined
```

## How to Run

1. Install MySQL 8.x (or use MySQL Workbench).
2. Clone this repository:
   ```bash
   git clone https://github.com/<your-username>/library-management-system.git
   cd library-management-system
   ```
3. Create everything in one step:
   ```bash
   mysql -u root -p < sql/setup_all.sql
   ```
   (Or run files `01` to `05` in order.)
4. Try the sample queries:
   ```bash
   mysql -u root -p < sql/06_queries.sql
   ```

## Example Usage

```sql
USE library_db;

CALL issue_book(1, 1, 1);   -- issue book 1 to member 1 via staff 1
SELECT title, available_copies FROM Book WHERE book_id = 1;   -- 5 -> 4

CALL return_book(1);        -- return it; fine is calculated if late
SELECT * FROM overdue_books;
```

## Business Rules

- Maximum 3 books per member at a time
- Loan period: 14 days
- Fine: Rs. 5 per day after the due date

## Future Scope

- Front end using Python (Flask/Django) or Java
- Book reservation and renewal
- Email/SMS due-date reminders
- Role-based access control
- Deployment on AWS RDS

## Author

**Yadveen Singh** – BSc Computer Science, Chandigarh University
