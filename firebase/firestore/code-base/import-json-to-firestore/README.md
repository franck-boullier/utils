# Overview:

Simple Node.js script to import data to FireStore

## Pre-requisite:

- A GCP project `my-project`.
- A FireBase project `my-project` associated to the GCP project `my-project`.
- FireStore Activated in the FireBase project.
- A service account to connect to the FireStore database.
- A [Node development machine](../../../../installation/node-js-dev-machine.sh) to develop and run the code.
- Download a copy of this repository.

# How to run the Code:

- Copy the file `data.json` to the folder `import-json-to-firestore` where the code is.
- Make sure you have created the file `firebase-credentials.json` containing the credentials for the [FireBase Service Accoun Access](#firebase-service-account-access).
- Initialize the App and make sure you have the node packages you need

```bash
yarn install
```
- Move out of the folder where the code is

```bash
cd ..
```

- run the script

```bash
node import-json-to-firestore
```

# FireBase Service Account Access:

- In FireBase.
- Go to [Project Settings > Service Accounts](https://console.firebase.google.com/project/ecode-to-voucher-dev/settings/serviceaccounts/adminsdk)
- Make sure you select the correct FireBase Project.
- Select `Node.js`
- Generate New Private key for the Firbase Admin SDK
- Download the JSON file.
- Store the file in a secure place.
- **NEVER commit this file to any Git repository!!!!**
- Copy the content of the file to a new file `firebase-credentials.json` in the folder `import-json-to-firestore` (the folder where the code is).

# How the Code was Created:

- Open the [Node development machine](../../../../installation/node-js-dev-machine.sh).
- Create folder `import-json-to-firestore` where the code for the project will be stored
- All the code will be located there

```bash
cd import-json-to-firestore
```

- Initialize the project by creating a `package.json` file (see an example [here](./package.json)).
- Create a `.gitignore` file to exclude the sensitive file `firebase-credentials.json` from the repo
- Create the file `index.js` to store the code that will import the data to FireStore.

## Node packages we need:

- firebase-admin

```bash
yarn add firebase-admin
```


# More Information:

- [Automate importing data to FireStore](https://javascript.plainenglish.io/automate-importing-data-to-firestore-836b0a2cdcfd).
- [Upload JSON file to FireStore](https://medium.com/lucas-moyer/how-to-import-json-data-into-firestore-2b370486b622).