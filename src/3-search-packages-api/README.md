# Search packages API

1. Create the `POST search_packages` endpoint.
  * The endpoint should have one parameter called query
  * It should return a set of packages so we can use the same interface already on the package list.
  * The match can use any mechanism you want, bonus points for using tsearch and pg_trgm.

1. On the browser tab where you have the [Swagger UI](/swagger-ui/index.html), reload the api and open the `(rpc) search_packages` section.

1. The `POST /rpc/search_packages` endpoint should now be visible, click on it to see its description.

1. Let's try a request, click on `Try it out` on the right corner inside the description box.

1. Change the query and execute the function observing the results, database error messages will be surfaced by the API allowing the developer to debug the function.
