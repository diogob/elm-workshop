# Preparing the environment 

1. Create the database that will be used during this workshop.

  ```
  psql < src/1-environment/db/elm-workshop.sql
  cat src/1-environment/db/data.sql.gz| gunzip | psql elm_workshop
  ```

1. Run the `postgrest` server using the sample config.

  ```
  postgrest postgrest-api.conf
  ```

1. Open the [Swagger UI](/swagger-ui/index.html) in a separate tab and point it to `http://localhost:3000`.

1. Congratulations, you are ready to start [fetching and rendering packages](/src/2-get-packages).
