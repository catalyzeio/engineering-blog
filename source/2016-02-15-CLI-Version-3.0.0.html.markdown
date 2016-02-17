# Catalyze CLI Version 3.0.0

Version 3.0.0 of the Catalyze CLI puts a heavy focus on self-service capabilities. Focusing on self-service commands lays the ground work for an expansion of functionality in the future and ease of use with the CLI. Outlined below are the new commands in version 3.0.0 of the Catalyze CLI along with any updated or removed commands.

## New Commands

### certs {create, list, rm, update}

The `certs` command group allows you to manage SSL certificates for your environments. There are four subcommands: `certs create`, `certs list`, `certs rm`, and `certs update`. You can read more about managing certs, sites, and their interaction by reading [this blog post](LINK-TO-NEW-STRATUM-BLOG-POST).

### db logs

The newest member of the `db` command group is the `db logs` command. This allows you to view logs for historical backup jobs. Logs are normally printed out after any backup job, but if for any reason those are not printed out, you can view them with this command.

### deploy-keys {add, list, rm}

`deploy-keys` is an entirely new command group that allows you to manage shared SSH keys that are attached to a single service. You can upload both private and public SSH keys. Deploy keys are useful for CI/CD workflows and are intended to be shared amongst an organization.

### invites accept

`invites accept` allows you to accept an organization invite from the CLI instead of solely from your browser. You can read more about organizations and their relationship with environments [here](blog-post-about-orgs-and-envs).

### keys {add, list, rm, set}

Much like the `deploy-keys` command, the `keys` command allows you to manage your personal SSH keys. Only public keys can be uploaded with the `keys` command. These should not be shared with anyone. These keys must be globally unique across Catalyze, but one personal key will give you access to all services and environments you are granted access to.

### sites {create, list, rm, show}

One of the newest concepts introduced in version 3.0.0 are sites. The `sites` command is how you manage and configure sites. Sites represent an nginx configuration file along with a `certs` instance that is tied to a single service. These are used for public facing services.

### ssl resolve

Going one step further than the `ssl verify` command, `ssl resolve` will attempt to fix certain issues found with the given SSL certificates rather than just reporting a problem. The `ssl resolve` command will attempt to resolve incomplete certificate chains by downloading any necessary intermediate and root certificates missing in the given chain.

## Updated Commands

### metrics

The most reworked command in version 3.0.0 is the `metrics` command. You can no longer run the `metrics` command directly but must specify the type of metrics you want to see. Available metrics include CPU, memory, network-in, and network-out metrics. Available commands are `metrics cpu`, `metrics memory`, `metrics network-in`, and `metrics network-out`. The options and flags passed to these commands are identical to the original `metrics` command in versions prior to version 3.0.0.

## Removed Commands

### users add

With the latest release of the CLI and the supporting APIs, there is no longer a way to add users directly to environments. The `users add` command has been deprecated since version 2.1.2 and is now removed. To add users to your environments, please use the [invites send](LINK-TO-INVITES-SEND-CMD-ON-RESOURCES) command instead.