CREATE DATABASE elm_workshop;

\c elm_workshop
-- Private data structures

CREATE TABLE public.packages (
  package_name text PRIMARY KEY,
  version text NOT NULL,
  license text NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  homepage text NOT NULL,
  package_url text NOT NULL,
  repo_type text,
  repo_location text,
  created_at timestamp NOT NULL default current_timestamp,
  updated_at timestamp NOT NULL default current_timestamp
);

CREATE TABLE public.repos (
  package_name text PRIMARY KEY REFERENCES packages,
  stars integer NOT NULL DEFAULT 0,
  forks integer NOT NULL DEFAULT 0,
  collaborators integer NOT NULL DEFAULT 1,
  created_at timestamp NOT NULL default current_timestamp,
  updated_at timestamp NOT NULL default current_timestamp
);

CREATE TABLE public.dependencies (
  dependent text REFERENCES public.packages (package_name),
  dependency text REFERENCES public.packages (package_name),
  version_range text,
  created_at timestamp NOT NULL default current_timestamp,
  updated_at timestamp NOT NULL default current_timestamp,
  PRIMARY KEY (dependent, dependency)
);

CREATE TABLE public.extensions (
  package_name text REFERENCES public.packages (package_name),
  extension text,
  created_at timestamp NOT NULL default current_timestamp,
  updated_at timestamp NOT NULL default current_timestamp,
  PRIMARY KEY (package_name, extension)
);

-- Triggers to update updated_at columns
CREATE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $$
BEGIN
  NEW.updated_at := current_timestamp;
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_updated_at
BEFORE UPDATE ON public.packages
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at();

CREATE TRIGGER update_updated_at
BEFORE UPDATE ON public.dependencies
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at();

CREATE TRIGGER update_updated_at
BEFORE UPDATE ON public.extensions
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at();

CREATE TRIGGER update_updated_at
BEFORE UPDATE ON public.repos
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at();

CREATE VIEW public.package_repos AS
SELECT
  p.package_name,
  r[1] as owner,
  r[2] as repo
FROM
  packages p,
  regexp_matches(repo_location, 'github.com[:\/]([^\/]*)\/([^\. ]*)') r
WHERE
  repo_location ~* 'github';

CREATE OR REPLACE VIEW public.categories AS
SELECT
  p.package_name,
  initcap(btrim(translate(c.c, chr(10) || chr(13), ''))) AS category_name
FROM
  packages p,
  LATERAL regexp_split_to_table(p.category, ','::text) c(c)
WHERE
  btrim(c.c) <> ''::text;

-- API exposed through PostgREST
CREATE SCHEMA api;

CREATE EXTENSION pgcrypto;
CREATE EXTENSION pgjwt;
CREATE EXTENSION pg_trgm;

CREATE USER postgrest NOINHERIT PASSWORD 'temporary_password';
CREATE ROLE anonymous;
GRANT anonymous TO postgrest;
GRANT USAGE ON SCHEMA api TO anonymous;


