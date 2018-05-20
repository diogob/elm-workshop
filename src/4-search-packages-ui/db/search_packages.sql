CREATE OR REPLACE FUNCTION api.search_packages(query text)
RETURNS SETOF api.packages
LANGUAGE sql
STABLE
AS $function$
  SELECT
    p.*
  FROM
    api.packages p
  WHERE
    to_tsvector(p.description) @@ plainto_tsquery(query)
    OR
    public.word_similarity_op(p.package_name, query)
  ORDER BY
    ts_rank( setweight(to_tsvector(p.package_name), 'A') || setweight(to_tsvector(p.description), 'B')
    , plainto_tsquery(query)
    ) DESC;
$function$;

GRANT EXECUTE ON FUNCTION api.search_packages TO anonymous;
