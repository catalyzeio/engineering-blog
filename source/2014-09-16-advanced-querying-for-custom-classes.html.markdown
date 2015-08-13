---
title: Advanced Querying for Custom Classes
date: 2014-09-16
author: alex
author_full: Alex Foran
author_alt:
tags: API, backend, BaaS, custom classes, guide, example
---

We mentioned new querying abilities for custom classes in the [8/28/14 Release Notes](https://catalyze.io/blog/8-28-14-release-notes/), but it's a topic that deserves expansion and examples. The ability to perform custom, multiple-field queries on your entries is immensely powerful.

The docs for this are [in our resources](https://resources.catalyze.io/#custom-classes), but an example might be a better explanation.

## An Example
Let's consider an application that tracks how long people run for and the distance they ran. The fields for that custom class (which I'll call `run_log`) are:

* `duration` - integer (in seconds)
* `distance` - double (in miles)

For this example, I'll use the following made-up users and IDs:

* Bob - `123-bob`
* Jane - `456-jane`
* Dave - `789-dave`

And, finally, the entries in the class (omitting `updatedAt` for brevity):

<table>
    <tr>
        <th><b>entryId</b></th>
        <th><b>usersId</b></th>
        <th><b>createdAt</b></th>
        <th><b>content.duration</b></th>
        <th><b>content.distance</b></th>
    </tr>
    <tr>
        <td>abc-e1</td>
        <td>123-bob</td>
        <td>2014-09-10T12:00:00Z</td>
        <td>1800</td>
        <td>3.1</td>
    </tr>
    <tr>
        <td>abc-e2</td>
        <td>123-bob</td>
        <td>2014-09-12T15:00:00Z</td>
        <td>600</td>
        <td>1.2</td>
    </tr>
    <tr>
        <td>abc-e3</td>
        <td>123-bob</td>
        <td>2014-09-14T12:00:00Z</td>
        <td>300</td>
        <td>1</td>
    </tr>
    <tr>
        <td>abc-e4</td>
        <td>456-jane</td>
        <td>2014-09-08T11:00:00Z</td>
        <td>900</td>
        <td>2.4</td>
    </tr>
    <tr>
        <td>abc-e5</td>
        <td>456-jane</td>
        <td>2014-09-13T11:00:00Z</td>
        <td>900</td>
        <td>2.5</td>
    </tr>
    <tr>
        <td>abc-e6</td>
        <td>456-jane</td>
        <td>2014-09-14T11:00:00Z</td>
        <td>930</td>
        <td>2.5</td>
    </tr>
    <tr>
        <td>abc-e7</td>
        <td>789-dave</td>
        <td>2014-09-11T20:00:00Z</td>
        <td>2400</td>
        <td>5</td>
    </tr>
    <tr>
        <td>abc-e8</td>
        <td>789-dave</td>
        <td>2014-09-12T20:00:00Z</td>
        <td>2400</td>
        <td>5</td>
    </tr>
    <tr>
        <td>abc-e9</td>
        <td>789-dave</td>
        <td>2014-09-13T20:00:00Z</td>
        <td>2400</td>
        <td>5</td>
    </tr>
</table>

## Retrieving all entries

To retrieve _all_ entries, like the table above, the `GET /v2/classes/{name}/query` route can be given no parameters (where `name` is the name of the class, `run_log`). This will return the list, sorted by `createdAt`, ascending, with up to 10 items returned (which is fine, because we have only 9 entries). If you've used the query route before, you'll note that the pagination functionality isn't new - controlled by the optional parameters `pageSize` and `pageNumber` - but the ordering functionality is new.

Ordering parameters:

* `orderBy` - the field name by which to order.
* `direction` - the order in which to return results - either `asc` for ascending, or `desc` for descending.

If we wanted to sort by the duration of the run, longest first, we'd set `orderBy`
to `duration`, and `direction` to `desc` (`GET /v2/classes/run_log/query?orderBy=duration&direction=desc`). Any field that's part of the defined schema will work. To reference `createdAt` or `updatedAt`, use the special values `@createdAt` and `@updatedAt`.

To retrieve only entries for a single user instead of all, use the `GET /v2/classes/{name}/query/{usersId}` route (for example, `GET /v2/classes/run_log/query/456-jane`). All of the same optional query parameters can be used.

## Retrieving a filtered set of entries

To retrieve only _some_ entries, you can pass extra parameters to the route, with the names being the field name, and the value being the value to check for equality to. For example, to filter for a `duration` of 900 seconds, you'd add `?duration=900`. That would find only Jane's two entries (`abc-e4` and `abc-e5`).

Multiple fields can be used to filter - just add multiple parameters. To match `duration` of 900 seconds and `distance` of 2.5 miles, you'd add `?duration=900&distance=2.5`. That would find only one entry - `abc-e5`.

The limitation of this route becomes quickly apparent - it's simple to use, but can only do equality checks - no inequalities, and no compound logic. That's why we now refer to these two routes (all and user) as "filter", not "query." For true querying, read on.

## Querying entries

We've devised an expressive JSON structure for constructing complex and compound queries. You can read about the nitty-gritty details [in the docs](https://resources.catalyze.io/#custom-classes) (which I recommend at least making a quick pass through), but I'll give a few examples here. All requests are `POST` to the same path, instead of `GET` (`POST /v2/classes/{name}/query` and `POST /v2/classes/{name}/query/{usersId`).

The first query (duration = 900) can be expressed by the JSON body:

```
{ "=": ["duration", 900] }
```

And the second (duration = 900, distance = 2.5) can be expressed as:

```
{
    "and": [
        { "=": ["duration", 900] },
        { "=": ["distance", 2.5] }
    ]
}
```

Now, something we couldn't do with the filter route: an inequality. For distances over 3 miles (finding one of Bob's and all of Dave's):

```
{ ">": ["distance", 3] }
```

For distances between 1 and 3 miles, inclusive (finding Bob's other two and all of Jane's):

```
{
    "and": [
        { ">=": ["distance", 1] },
        { "<=": ["distance", 3] }
    ]
}
```

The inverse of that (distances under 1 or over 3):

```
{
    "or": [
        { "<": ["distance", 1] },
        { ">": ["distance", 3] }
    ]
}
```

Expressions can also be compound (nested logical operators) - for example, finding runs between 10 and 20 minutes, or runs longer than 3 miles, or exactly 2.4 miles:

```
{
    "or": [
        {
            "and": [
                { ">=": ["duration", 600] },
                { "<=": ["duration", 1200] }
            ]
        },
        { ">": ["distance", 3] },
        { "=": ["distance", 2.4] }
    ]
}
```

The available comparative operators:

* `=`, `!=`
* `<`, `<=`
* `>`, `>=`

The available logical operators:

* `and`
* `or`

The structure of expressions is discussed [in the docs](https://resources.catalyze.io/#query-class-entries) in depth, including how to deal with values in nested objects.

## Permissions

For the query/filter routes that don't take a user ID (`/v2/classes/{name}/query`), the querying user must either be:

1. An **admin** or **dev** for the organization,
2. A **supervisor** for the application,
3. A member of a group that has the `RETRIEVE` ACL permission granted, or
4. Have the `RETRIEVE` ACL permission granted directly to them.

The routes that do take a user ID (`/v2/classes/{name}/query/{usersId}`), the same permissions apply, with the addition that a user can query/filter their own entries. For more information on ACLs and groups, [check out our guide](https://docs.catalyze.io/guides/api/latest/permissions_and_acls/acls_for_custom_classes_and_files.html).

Thank you for reading - if you run into issues using any of this, need help, or think we should add new functionality to it, please [let us know](mailto:support@catalyze.io).