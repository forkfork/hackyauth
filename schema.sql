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
