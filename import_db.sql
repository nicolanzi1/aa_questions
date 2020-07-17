DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

PRAGMA foreign_keys = ON; -- This helps on turn on the foreign key constraints to ensure data integrity


-- USERS


CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
);

INSERT INTO
    users (fname, lname)
VALUES
    ("Rocky", "Balboa"), ("John", "Spartan"), ("Spots", "Cat");


-- QUESTIONS


CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    author_id INTEGER NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
    questions (title, body, author_id)
SELECT
    "Rocky Question", "ROCKY ROCKY ROCKY", users.id
FROM
    users
WHERE
    users.fname = "Rocky" AND users.lname = "Balboa";

INSERT INTO
    questions (title, body, author_id)
SELECT
    "John Question", "JOHN JOHN JOHN", users.id
FROM
    users
WHERE
    users.fname = "John" AND users.lname = "Spartan";

INSERT INTO
    questions (title, body, author_id)
SELECT
    "Spots Question", "MEOW MEOW MEOW", users.id
FROM
    users
WHERE
    users.fname = "Spots" AND users.lname = "Cat";


-- QUESTIONS_FOLLOWS


CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    question_follows (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = "Rocky" AND lname = "Balboa"),
    (SELECT id FROM questions WHERE title = "Spots Question")),

    ((SELECT id FROM users WHERE fname = "John" AND lname = "Spartan"),
    (SELECT id FROm questions WHERE title = "Spots Question")
);


-- REPLIES


CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    author_id INTEGER NOT NULL,
    body TEXT NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
    FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
    replies (question_id, parent_reply_id, author_id, body)
VALUES
    ((SELECT id FROM questions WHERE title = "Spots Question"),
    NULL,
    (SELECT id FROM users WHERE fname = "Rocky" AND lname = "Balboa"),
    "Did you say NOW NOW NOW?"
);

INSERT INTO
    replies (question_id, parent_reply_id, author_id, body)
VALUES
    ((SELECT id FROM questions WHERE title = "Spots Question"),
    (SELECT id FROM replies WHERE body = "Did you say NOW NOW NOW?"),
    (SELECT id FROM users WHERE fname = "John" AND lname = "Spartan"),
    "I think she said MEOW MEOW MEOW."
);


-- QUESTION LIKES


CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    question_likes (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = "John" AND lname = "Spartan"),
    (SELECT id FROm questions WHERE title = "Spots Question")
);

-- Here's another way to add seed data:
INSERT INTO question_likes (user_id, question_id) VALUES (1, 1);
INSERT INTO question_likes (user_id, question_id) VALUES (1, 2);