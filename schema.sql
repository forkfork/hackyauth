DROP TABLE IF EXISTS user;
CREATE TABLE user (
  user_id char(12) NOT NULL,
  org_name varchar(32) NOT NULL,
  name text,
  email varchar(255),
  password text,
  salt text,
  pub_info varchar(2048) DEFAULT '{}',
  priv_info varchar(2048) DEFAULT '{}'
) DEFAULT CHARSET=utf8;

CREATE UNIQUE INDEX user_org_email ON user(org_name, email);
CREATE UNIQUE INDEX user_org_id ON user(org_name, user_id);

DROP TABLE IF EXISTS org;
CREATE TABLE org (
  name varchar(32),
  cert text,
  primary_email varchar(255),
  private_key text,
  public_key text,
  status varchar(32) DEFAULT 'pending',
  region varchar(32) DEFAULT 'us-west-1'
) DEFAULT CHARSET=utf8;

CREATE UNIQUE INDEX org_name ON org(name);

INSERT INTO org (name, status) VALUES ('evilcorp', 'active');
INSERT INTO org (name, status) VALUES ('smallauth', 'active');

DROP TABLE IF EXISTS apikey;
CREATE TABLE apikey (
  org_name varchar(32) NOT NULL,
  token varchar(32) NOT NULL,
  description varchar(255)
) DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS password_reset;
CREATE TABLE password_reset (
  org_name varchar(32) NOT NULL,
  email char(255) NOT NULL,
  token varchar(32) NOT NULL,
  status varchar(8) default 'active',
  expiry timestamp NOT NULL
) DEFAULT CHARSET=utf8;

CREATE UNIQUE INDEX password_reset_org_id ON password_reset(org_name, email);
CREATE UNIQUE INDEX password_reset_token ON password_reset(token);
