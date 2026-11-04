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
