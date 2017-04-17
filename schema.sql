DROP TABLE IF EXISTS admin;
CREATE TABLE admin (
  org varchar(32),
  name text,
  email varchar(255),
  password text,
  salt text
) DEFAULT CHARSET=utf8;

CREATE UNIQUE INDEX admin_org ON admin(org);
CREATE UNIQUE INDEX admin_email ON admin(email);
