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