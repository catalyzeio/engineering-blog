---
title: Minimize Production Down-Time due to Failed Application Deployment
date: 2016-07-20
author: nate
author_full: Nate Radtke
author_alt: Co-author - Raj Sundaramurthy
tags: deployment, rollback, stratum, 2.1.0
---
### Stratum 2.1 now supports rolling back to a stable prior version of your application

The most recent set of Stratum updates includes a powerful feature we are thrilled to make broadly available to all customers. Compliant rollback capabilities are now accessible to developers who might need to roll back to a previously stable version of their application. We are delighted to offer this advancement in automation while still maintaining the compliance automation you’ve come to rely upon with Stratum.

We tackled this feature knowing the situation customers sometimes find themselves facing: As part of your continuous delivery cycle, you have just completed yet another deployment of your new release on the Stratum Platform. However, unlike most of the previous releases, you encounter a critical issue in your application that will result in production down-time.  For such situations, Stratum 2.1 offers you the ability to roll back to a prior stable release so that down-time and adverse business impact are minimized.

This is primarily a workaround to get your application running while giving you and your teams the time to debug the application and make the necessary fixes.

Through a set of simple Stratum CLI commands, you can review release history and rollback to a prior stable release. Read on to review this feature in detail and also some recommendations/best practices. The steps involved in deploying a new release on Stratum are as below:

![Deployment Model](/assets/img/posts/deployment-model.png)

Whenever you deploy a new version of your application on the Stratum platform, a new release is created and an unique Release Identifier is assigned. The release ID is by default the same as the git commit hash but you can modify it to give a better context - for e.g. Version#.  This commit hash (or the Release Identifier) is tagged to a release and tracked so that rollback to this release is possible at a later time.

## Rolling Back to a prior release:

If you find that the running build has an issue, you have an option to rollback to a previous release by specifying the release ID (corresponding to a commit hash) and submitting the CLI "rollback" command.

`$ catalyze -E {environment name} rollback {service name} {stable release ID}.`

**Key things to note about the rollback process:**

- As the rollback process uses a prior run-time, the process is fast (no re-build is required) and gets you back up and running quickly.
- Upon rollback,  all instances of the application plus the worker jobs will be reverted
- As a part of the new deployment, we recommend that your database changes be backward compliant. The deployment / rollback process does not record the state of the database and manual reconciliation may be required in case of a bad code deploy.
- This process takes between 5 - 10 minutes.


Here is an example of an application rollback for an application MyPatientPortal.

## Step 1: Get a listing of available releases

`$ catalyze releases list MyPatientPortal`


| Release ID | Created At | Notes |
| ---------- | ---------- | ----- |
| * b61535c893e21b255cd21d9fb36111e671f824ce | 2016-05-15 09:30
| 8c5e3ab9e32b9e87d51c280de349a0bf2c0e4c6a | 2016-05-14 09:45 | My App's version 2.3
| 1de459b956281269851da354eaa2f691fc44dfe8 | 2016-05-13 18:15

`* Current deployment`

## Step 2. To Rollback (as an example to the version 2.3 of the app (created on 2016-05-14 9:45)

`$ catalyze rollback MyPatientPortal 8c5e3ab9e32b9e87d51c280de349a0bf2c0e4c6a`

Stratum 2.1 also provides you options to modify the release ID or add notes to a release via the ‘Update’ command. We recommend that you use this command to keep your deployment in sync with your internal versioning scheme.

`$ catalyze releases update MyPatientPortal 1de459b956281269851da354eaa2f691fc44dfe8 --notes “MFA Launch" --release “v2.2”`

The Release Listing will look like this after the update:

| Release ID | Created At | Notes |
| ---------- | ---------- | ----- |
| b61535c893e21b255cd21d9fb36111e671f824ce | 2016-05-15 09:30
| * 8c5e3ab9e32b9e87d51c280de349a0bf2c0e4c6a | 2016-05-14 09:45 | My App's version 2.3
| v2.2 | 2016-05-13 18:15 | MFA Launch

`* Current deployment`

### Notes

- You must now use the Release ID that you have specified for the rollback command rather than the git commit hash (The git commit hash is no longer an option once the release name is updated).
- Since release IDs are git commit hashes this does not mean that you can roll back to any point in your git history. Releases are created by the commit hash at the HEAD reference (the latest commit) bundled in the push operation sent to the Catalyze Git repository.


_Additional References:_

- To deploy your application on Stratum: [resources.catalyze.io/stratum/articles/code-deployment/](https://resources.catalyze.io/stratum/articles/code-deployment/)
- For more information on the Stratum CLI: [resources.catalyze.io/paas/paas-cli-reference/](https://resources.catalyze.io/paas/paas-cli-reference/)
- Stratum FAQ: [resources.catalyze.io/stratum/faq/](https://resources.catalyze.io/stratum/faq/)
