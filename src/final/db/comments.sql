-- Create webuser, a single role for all authenticated users

CREATE ROLE webuser;
GRANT webuser TO postgrest;
GRANT USAGE ON SCHEMA api TO webuser;

CREATE TABLE public.comments (
       email text NOT NULL,
       package_name text NOT NULL REFERENCES public.packages,
       content text NOT NULL,
       created_at timestamp NOT NULL DEFAULT current_timestamp,
       PRIMARY KEY (created_at, package_name, email)
);

CREATE OR REPLACE VIEW api.comments AS
SELECT
  email,
  package_name,
  content,
  created_at
FROM public.comments;

GRANT SELECT, INSERT ON api.comments TO webuser;
GRANT SELECT ON api.comments TO anonymous;

CREATE OR REPLACE FUNCTION public.before_insert_comments() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
  NEW.email := current_setting('request.jwt.claim.email', true);
  RETURN NEW;
END;
$$;

CREATe TRIGGER before_insert_comments
BEFORE INSERT ON public.comments
FOR EACH ROW
EXECUTE PROCEDURE public.before_insert_comments();
