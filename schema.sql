DROP TABLE IF EXISTS admin;
CREATE TABLE admin (
  org varchar(32),
  name text,
  email text,
  password text
);

CREATE UNIQUE INDEX admin_org ON admin(org);
