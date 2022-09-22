```sql
-- things have to be replaced
-- 1. authenticator pwd: __authenticator_password__
-- 2. jwt key: __jwt_key__
-- 3. authenticated user: __sample_user__
-- 4. dbname: __db_name__

-- notes
-- web_anon user couldn't access any resource, for login purposes only

-- pre-requisite:
-- db is exists, with name __db_name__
-- all of this script executed inside __db_name__ by postgres user
-- extension available: postgis, pgcrypto, pgjwt

-- prepare extensions
create extension if not exists postgis;
create extension if not exists pgcrypto;	
create extension if not exists pgjwt;

-- db vars
ALTER DATABASE __db_name__ SET "app.jwt_secret" TO '__jwt_key__';



-- api schema
create schema api;

-- todos table, for testing purposes only
create table api.todos (
  id serial primary key,
  done boolean not null default false,
  task text not null,
  due timestamptz
);

insert into api.todos (task) values
  ('finish tutorial 0'), ('pat self on back');
  
  
-- spatial table example
CREATE TABLE api.gpstrack (
	id serial NOT NULL primary key,
	ts timestamp NULL,
	geom public.geometry(point, 4326) NULL,
	altitude int4 NULL,
	hdop int4 NULL,
	vdop int4 NULL,
	pdop int4 NULL,
	nstas int4 NULL,
	speed int4 NULL,
	course int4 NULL,
	vid varchar(50) NULL,
	tscreated timestamptz NULL DEFAULT timezone('Asia/Jakarta'::text, CURRENT_TIMESTAMP),
	comsrc varchar(3) NULL
);

insert into api.gpstrack(ts, geom, vid, speed, course) values(now(), 'SRID=4326;POINT(106.3 -6.8)', 'suneo', 40, 23);


-- web anon & authenticator
-- web anon may access todos table, read-only
-- drop role if exists web_anon;
create role web_anon nologin;

grant usage on schema api to web_anon;
grant select on api.todos to web_anon;

-- drop role  if exists authenticator;
create role authenticator noinherit login password '__authenticator_password__';
grant web_anon to authenticator;


-- authenticated user
-- drop role if exists __sample_user__;
create role __sample_user__ nologin;
grant __sample_user__ to authenticator;

grant usage on schema api to __sample_user__;

grant all on api.todos to __sample_user__;
grant usage, select on sequence api.todos_id_seq to __sample_user__;

grant all on api.gpstrack to __sample_user__;
grant usage, select on sequence api.gpstrack_id_seq to __sample_user__;



-- storing user & password for login purposes

create schema if not exists basic_auth;

create table if not exists
basic_auth.users (
  email    text primary key check ( email ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512),
  role     name not null check (length(role) < 512)
);

create or replace function
basic_auth.check_role_exists() returns trigger as $$
begin
  if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
    raise foreign_key_violation using message =
      'unknown database role: ' || new.role;
    return null;
  end if;
  return new;
end
$$ language plpgsql;

-- drop trigger if exists ensure_user_role_exists on basic_auth.users;

create constraint trigger ensure_user_role_exists
  after insert or update on basic_auth.users
  for each row
  execute procedure basic_auth.check_role_exists();	

create or replace function
    basic_auth.encrypt_pass() returns trigger as $$
    begin
      if tg_op = 'INSERT' or new.pass <> old.pass then
        new.pass = crypt(new.pass, gen_salt('bf'));
      end if;
      return new;
    end
    $$ language plpgsql;

-- drop trigger if exists encrypt_pass on basic_auth.users;

create trigger encrypt_pass
      before insert or update on basic_auth.users
      for each row
      execute procedure basic_auth.encrypt_pass();	
      
      
create or replace function
    basic_auth.user_role(email text, pass text) returns name
      language plpgsql
      as $$
    begin
      return (
      select role from basic_auth.users
       where users.email = user_role.email
         and users.pass = crypt(user_role.pass, users.pass)
      );
    end;
    $$;	 


insert into basic_auth.users(email, pass, role)
    values('__sample_user__@gmail.com', '__sample_user__', 		 		
    '__sample_user__');


CREATE TYPE basic_auth.jwt_token AS (
  token text
);	
    
    
create or replace function
    api.login(email text, pass text) returns basic_auth.jwt_token as $$
    declare
      _role name;
      result basic_auth.jwt_token;
    begin
      -- check email and password
      select basic_auth.user_role(email, pass) into _role;
      if _role is null then
        raise invalid_password using message = 'invalid user or password';
      end if;

      select sign(
          row_to_json(r), current_setting('app.jwt_secret')
        ) as token
        from (
          select _role as role, login.email as email,
             extract(epoch from now())::integer + 60*60 as exp
        ) r
        into result;
      return result;
    end;
    $$ language plpgsql security definer;	
    
	
	
	-- additional: auto reload schema cache
	-- Create an event trigger function
CREATE OR REPLACE FUNCTION public.pgrst_watch() RETURNS event_trigger
  LANGUAGE plpgsql
  AS $$
BEGIN
  NOTIFY pgrst, 'reload schema';
END;
$$;

-- This event trigger will fire after every ddl_command_end event

-- DROP EVENT TRIGGER IF EXISTS pgrst_watch;

CREATE EVENT TRIGGER pgrst_watch
  ON ddl_command_end
  EXECUTE PROCEDURE public.pgrst_watch();
	
	
	
