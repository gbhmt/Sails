CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES house(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "26th and Guerrero"), (2, "Dolores and Market"), (3, "974 St. Nicholas Ave.");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Jon", "Arbuckle", 1),
  (2, "Taylor", "Herron", 3),
  (3, "Lorem", "Ipsum", 2),
  (4, "Will", "Hawley", 3);

INSERT INTO
  cats (id, name, owner_id)
VALUES
  (1, "Garfield", 1),
  (2, "Carmen", 2),
  (3, "Haskell", 3),
  (4, "Markov", 3),
  (5, "Stray Cat", NULL);
