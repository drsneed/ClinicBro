CREATE TABLE account (
	[uid] INTEGER PRIMARY KEY,
    [name] TEXT NULL, -- max-length 16
	[email] TEXT NOT NULL UNIQUE, -- max-length 256
	[phone] TEXT NOT NULL, -- max-length 15
    [mod] INTEGER NOT NULL, -- modifier (stores role, status, etc)
    [iat] INTEGER NOT NULL, -- issued at timestamp
    [uat] INTEGER NOT NULL, -- updated at timestamp
    [key] BLOB NOT NULL     -- password hash
);

CREATE TABLE client (
    [id] INTEGER PRIMARY KEY,
    [first_name] TEXT NOT NULL,
    [middle_name] TEXT NULL,
    [last_name] TEXT NOT NULL,
    [suffix] TEXT NULL,
	[email] TEXT NOT NULL UNIQUE, -- max-length 256
	[phone] TEXT NOT NULL, -- max-length 15
    [dob] INTEGER NOT NULL,
    [gender] TEXT NOT NULL,
    [iat] INTEGER NOT NULL, -- issued at timestamp
    [uat] INTEGER NOT NULL, -- updated at timestamp
    [uid] INTEGER NOT NULL, -- updated by
    [key] BLOB NOT NULL     -- password hash
);