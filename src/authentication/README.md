# Authentication

Let's create an API endpoint for users to post comments about the packages.

The information we need for each comment is:

```
email text
package_name text
content text
created_at timestamp
```

We will authenticate each user using a JWT. The only user identifier will be the email address to be stored with each comment.
In order to post a comment using a certain email that address must be in my JWT claims.

The JWT claims must also specify a "role" that will set a role in the database.
We should use a different role with privileges to insert in the comments table.

See an example of non-anonymous user setup:
```
CREATE ROLE webuser;
GRANT webuser TO postgrest;
GRANT USAGE ON SCHEMA api TO webuser;
```

When you finish this exercise you should be able to execute a request like:
```
curl -H "Authorization: Bearer some.token.here" \
 -H "Content-Type: application/json" \
 -H "Accept: application/json" \
 -H "Prefer: return=representation" \
 -d '{"package_name":"postgrest","content":"great tool"}' \
 "http://localhost:3000/comments"
```
