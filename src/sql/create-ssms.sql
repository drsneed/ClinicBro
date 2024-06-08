CREATE TABLE account (
	[uid] INT IDENTITY(1,1) NOT NULL,
    [name] NVARCHAR(16) NULL, -- max-length 16
	[email] NVARCHAR(256) NOT NULL, -- max-length 256
	[phone] VARCHAR(16) NULL, -- max-length 15
    [mod] INT NOT NULL, -- modifier (stores role, status, etc)
    [iat] DATETIME NOT NULL DEFAULT(GETDATE()), -- issued at timestamp
    [uat] DATETIME NOT NULL DEFAULT(GETDATE()), -- updated at timestamp
    [key] VARBINARY(32) NOT NULL,     -- password hash
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED (uid),
    CONSTRAINT [UQ_Account_Email] UNIQUE (email)
)