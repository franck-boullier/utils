# Overview:

Syntax to create users and grant privileges
List the Database users that we need to create so that the automated scripts and basic functionalities work as expected:

# `view.data`:

A user who has read-only permission to all the tables and views.

The command to create this user:

```sql
CREATE USER 'view.data'@'%' IDENTIFIED BY '<the-password-for-this-user>';
```

# `view.statuses`:

A user who has read-only permission to all the `statuses` tables and views.

The command to create this user:

```sql
CREATE USER 'view.statuses'@'%' IDENTIFIED BY '<the-password-for-this-user>';
```

# `view.lists`:

A user who has read-only permission to all the `lists` tables and views.

The command to create this user:

```sql
CREATE USER 'view.lists'@'%' IDENTIFIED BY '<the-password-for-this-user>';
```

