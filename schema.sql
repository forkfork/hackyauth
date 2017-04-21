DROP TABLE IF EXISTS user;
CREATE TABLE user (
  org_name varchar(32),
  name text,
  email varchar(255),
  password text,
  salt text
) DEFAULT CHARSET=utf8;

CREATE UNIQUE INDEX user_org_email ON user(org_name, email);

DROP TABLE IF EXISTS org;
CREATE TABLE org (
  name varchar(32),
  cert text,
  primary_email varchar(255),
  private_key text,
  public_key text,
  status varchar(32) DEFAULT 'pending'
) DEFAULT CHARSET=utf8;

CREATE UNIQUE INDEX org_name ON org(name);
