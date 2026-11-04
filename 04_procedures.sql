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
