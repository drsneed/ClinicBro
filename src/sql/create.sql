CREATE TABLE account (
	[id] INTEGER PRIMARY KEY,
    [name] TEXT NULL,
	[email] TEXT NOT NULL UNIQUE,
    [status] INTEGER NOT NULL,
    [role] INTEGER NOT NULL,
    [dtcreated] INTEGER NOT NULL,
    [key] BLOB NOT NULL
);