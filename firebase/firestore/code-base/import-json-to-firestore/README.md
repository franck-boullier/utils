# Overview:

Simple Node.js script to import data to FireStore

## Pre-requisite:

- A GCP project `my-project`.
- A FireBase project `my-project` associated to the GCP project `my-project`.
- FireStore Activated in the FireBase project.
- A [FireBase service account](#firebase-service-account-access) to connect to the FireStore database.
- A [Node development machine](../../../../installation/node-js-dev-machine.sh) to develop and run the code.
- Download a copy of this repository.

# Format of the `data.json` Source File:

- `.json` file.
- Encoding: `utf8`.
- file name: `data.json`.
- MUST have the following key/vaule pair for each document:
    - `docId`: the ID of the document that we will created in FireStore.
    - `collectionName`: the name of the FireStore collection where the document shall be written.

# Customisation:

In the File `index.js`
- To change the name of the collection that will receive the data, update the line

```js
const collectionName = 'update-the-collection-here';
```

- By default the file containing the data should be named `data.json` to change the name of the file that contains the data, you can update the line.

```js
const filePath = './import-json-to-firestore/update-the-file-name-here.json';
```

# How to run the Code:

- Go to the folder where the code is (in the folder `/firebase/firestore/code-base/import-json-to-firestore/`).
- Copy the file `data.json` to the folder `import-json-to-firestore` where the code is.
- Make sure you have created the file `firebase-credentials.json` containing the credentials for the [FireBase Service Accoun Access](#firebase-service-account-access) for the FireBase project that you are using.
- In the folder `import-json-to-firestore`, initialize the App and make sure you have the node packages you need

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

- DONE - Check that the data have been written as expected!

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

- `firebase-admin` to connect to FireBase and FireStore
- `fs` to read the source file

```bash
yarn add firebase-admin
yarn add fs
```

# More Information:

- [Automate importing data to FireStore](https://javascript.plainenglish.io/automate-importing-data-to-firestore-836b0a2cdcfd).
- [Upload JSON file to FireStore](https://medium.com/lucas-moyer/how-to-import-json-data-into-firestore-2b370486b622).