# Globus — quick setup & sharing

## Table of contents

- [Create or link a Globus account (University of Missouri)](#create-or-link-a-globus-account-university-of-missouri)
- [Use an HPC / managed Globus endpoint (recommended)](#use-an-hpc--managed-globus-endpoint-recommended)
- [Share data using the lab's collection (Guest Collection)](#share-data-using-the-labs-collection-guest-collection)
- [Using Globus on Hellbender](#using-globus-on-hellbender)
- [Install Globus Connect Personal (only if your system lacks an endpoint)](#install-globus-connect-personal-only-if-your-system-lacks-an-endpoint)
- [Troubleshooting & tips](#troubleshooting--tips)

If you will use Globus to move files to/from the lab, a few important rules up front:

## Use an HPC / managed Globus endpoint (recommended)

- Use an HPC/managed Globus endpoint if one exists for your system — this is the recommended workflow.
- Only set up a Globus Connect Personal endpoint if the system you need to transfer to/from does not expose a managed endpoint.
- The lab server and Hellbender provide managed endpoints, so you normally do not need a personal endpoint to transfer to/from them.
- Globus transfers should include at least one managed/institutional endpoint.

## Create or link a Globus account (University of Missouri)

Create or link a Globus account using your University of Missouri identity before attempting transfers or sharing collections. Institutional identities give you direct access to managed endpoints and simplify sharing.

Steps:

- Go to https://www.globus.org and click **Log In** (upper-right).
- Select **University of Missouri System** from the organization list.
- Authenticate using `username@umsystem.edu` (MU email) and complete multi-factor authentication.
- If this is a new account, follow the sign-up prompts and allow the Globus Web App the requested permissions.
- If you already have a Globus account and want to add MU as an identity, add the new identity from your account settings.

---

## Share data using the lab's collection (Guest Collection)

After you have a MU-authenticated Globus account and an available endpoint (either a managed endpoint or a personal endpoint if required):

- Log in at https://app.globus.org using your MU-authenticated identity.
- Open **File Manager**.
- In the **Collection** search box enter `U MO EECS NAIR` and select the collection result.
  - If you see an access error, click **Try again** — this is a known Globus UI quirk.
- Change the **Path** field to the directory you want to share and browse to the target folder.
- Click **Share** in the right-hand column and follow the prompts to create a Guest Collection and invite users.

Once shared, other Globus endpoints (including the lab server) can connect to the collection and transfer files to/from it. You can start Globus Connect Personal on the other machine and then copy files into the shared collection path so they appear on the lab end.

You do not need a personal endpoint to use the lab or Hellbender collections — both the lab server and Hellbender provide managed endpoints.

---

## Using Globus on Hellbender

On Hellbender you can find the lab's collection by searching for:

```
U MO ITRSS RDE
```

Use **File Manager** → Collection search to locate that collection, then change the Path and Share the intended folder as described above.

## Install Globus Connect Personal (only if your system lacks an endpoint)

Only set up a Globus Connect Personal endpoint when there is no managed endpoint available on the system you need to transfer to/from. Example (Linux clusters or desktop):

```bash
wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz
tar xvzf globusconnectpersonal-latest.tgz
cd globusconnectpersonal
./globusconnectpersonal -setup
```

Control the personal endpoint with:

```bash
./globusconnectpersonal -status    # check status
./globusconnectpersonal -stop      # stop the service
./globusconnectpersonal -start &   # start in background (recommended when used on a cluster)
```

Note: On clusters you typically run `./globusconnectpersonal -start &` in a login session so the process remains active during transfers.

## Troubleshooting & tips

- If the collection does not appear, confirm you're logged in with the MU identity and retry the search.
- Use `./globusconnectpersonal -status` to confirm the personal endpoint is running before transferring.
- For large transfers prefer the Globus web interface or the Globus CLI rather than manual scp/sftp.

---
