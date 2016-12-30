# README

### Understanding how Firebase works with Rails
They don't have native admin support for Auth in Rails (Java or Node.js), but you can access the database using legacy keys.

This answer was the insight into the above: https://github.com/ktamas77/firebase-php/issues/42

And here's a guide to setting up Admin SDK: https://firebase.google.com/docs/admin/setup

### Verifying identity on Rails
Firebase doesn't support native id verification, so we have to write our own
JWT parser. Source: https://firebase.google.com/docs/auth/admin/verify-id-tokens

Here is a detailed setup on getting ID verification working with JWT + Rails:
https://groups.google.com/forum/#!topic/firebase-talk/iefJWQ9LMQE
