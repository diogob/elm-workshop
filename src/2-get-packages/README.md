# Fetching and rendering packages

1. Create the `GET packages` endpoint.

  ```
  psql elm_workshop < src/2-get-packages/db/packages.sql
  ```

1. On the browser tab where you have the [Swagger UI](/swagger-ui/index.html), click the button `Explore` on the top right corner to refresh the API view.

1. The `packages` endpoint should now be visible, click on it to see its description.

1. Let's try a request, click on `Try it out` on the right corner inside the `GET /packages` description box.

1. Several input boxes for the parameters should open. Scroll down to the parameter `limit`, input the number `10` and click on execute.

1. Open the module [RenderPackages.elm](RenderPackages.elm) in a separate tab.

1. Fix the module [RenderPackages.elm](RenderPackages.elm) so it has a proper init function.

1. Change the code of [RenderPackages.elm](RenderPackages.elm) so it renders a list of the first 10 packages from the GET /packages endpoint.
