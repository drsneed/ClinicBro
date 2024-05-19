CREATE TABLE account (
	[id] INTEGER PRIMARY KEY,
    [name] TEXT NULL,
	[email] TEXT NOT NULL UNIQUE,
	[password] TEXT NOT NULL,
    [dtcreated] INTEGER NOT NULL,
    [state] INTEGER NOT NULL,
    [role] INTEGER NOT NULL
);