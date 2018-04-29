CREATE OR REPLACE VIEW api.packages AS
SELECT
  p.package_name,
  p.version,
  p.license,
  p.description,
  p.category,
  p.homepage,
  p.package_url,
  p.repo_type,
  p.repo_location,
  r.stars,
  r.forks,
  r.collaborators,
  (
    SELECT coalesce(json_agg(DISTINCT e.extension), '[]')
    FROM extensions e
    WHERE e.extension IS NOT NULL AND e.package_name = p.package_name
  ) AS extensions,
  (
    SELECT coalesce(json_agg(d.dependency), '[]')
    FROM dependencies d
    WHERE d.dependency IS NOT NULL AND d.dependent = p.package_name
  ) AS dependencies,
  (
    SELECT coalesce(json_agg(d.dependent), '[]')
    FROM dependencies d
    WHERE d.dependent IS NOT NULL AND d.dependency = p.package_name
  ) AS dependents,
  -- when querying created at we usually want to know when it first got into our database
  LEAST(p.created_at, r.created_at) as created_at,
  -- when querying created at we usually want to know when it was last updated
  GREATEST(p.updated_at, r.updated_at) as updated_at
FROM
  packages p
  JOIN repos r USING (package_name)
GROUP BY
  p.package_name, r.package_name;

GRANT SELECT ON api.packages TO anonymous;
