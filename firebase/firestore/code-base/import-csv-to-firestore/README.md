# Overview:

Simple Node.js script to import data (CSV format) to FireStore.

- THIS IS NOT WORKING!!! You can create, edit and run the code directly from the Google Cloud Shell.

## What it Does:

- Import a CSV file 
- To a FireStore Database inside an existing FireBase project.
- Into a FireStore Collection `collection`.
- Each line in the CSV file will be a new document in the collection `collection`.
- A unique key for each document:
  - MUST exist.
  - Should be named `docId` in the CSV file.
  - Is usually the first column in the CSV file.

## Pre-requisite:

- A GCP project `my-project`.
- A FireBase project `my-project` associated to the GCP project `my-project`.
- FireStore Activated in the FireBase project.
- A [FireBase service account](#firebase-service-account-access) to connect to the FireStore database.
- A [Node development machine](../../../../installation/node-js-dev-machine.sh) to develop and run the code.
- Download a copy of this repository.

# Format of the `.csv` file:

In order for the script to work the `.csv` file needs to be compatible with that script.

The example script below assumes that the `.csv` file is built on the following format:
- 3 columns

| Column | Col Title | Description |
|---|---|---|
|col 1| docId | The ID of the document in the Firestore Collection |
|col 2| eCode | An eCode for the document |
|col 3| voucherGuid | A GUID that we need in the collection |

We have creates a file with sample data [here](./data.csv).

# Customisation:

## What We Can Customize:

- Name of the FireStore collection that will receive the data.
- Name the file containing the data

## How It's Done:

In the File `index.js`

- To change the name of the collection that will receive the data, update the line

```js
const collectionName = 'update-the-collection-here';
```

- By default the file containing the data should be named `data.csv` to change the name of the file that contains the data, you can update the line.

```js
const filePath = './import-csv-to-firestore/update-the-file-name-here.csv';
```

# How to Import a `.csv` file:


- Go to the folder where the code is (in the folder `/firebase/firestore/code-base/import-csv-to-firestore/`).
- Copy the file `data.csv` to the folder `import-csv-to-firestore` where the code is.
- Make sure you have created the file `firebase-credentials.json` containing the credentials for the [FireBase Service Account Access](#firebase-service-account-access) for the FireBase project that you are using.
- In the folder `import-csv-to-firestore`, initialize the App and make sure you have the node packages you need

```bash
yarn install
```
- Move out of the folder where the code is

```bash
cd ..
```

- run the script

```bash
node import-csv-to-firestore
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

# How The Code was Created:

## Create a Node project:

On your [Node Dev Machine](../installation/node-js-dev-machine.sh), create a new project `import-csv-to-firestore` for the import application.

## Prepare the `package.json` file:

In the folder `import-csv-to-firestore` create a file `package.json` for your node.js app.

An example of the basic file can be found [here](./package.json).

## Files to Exclude in `.gitignore`:

Create a `.gitignore` file to exclude the sensitive and unnecessary files and folders:

- `firebase-credentials.json` from the repo
- `data.json`
- /node_modules/

## Node packages we need:

We need the following Node Packages:

- `firebase-admin` to connect to FireBase and FireStore.
- `fs` to read the source file.
- [csv-parser](https://www.npmjs.com/package/csv-parser).

**WARNING**
We do NOT use the [csv-parse](https://www.npmjs.com/package/csv-parse) module since the syntax is more complex to implement...

In the folder `import-csv-to-firestore` run the following commands to get the dependencies you need:

```bash
yarn add firebase-admin
yarn add fs
yarn add csv-parser
```

## Check that the dependencies are installed:

Open the file `package.json` and check that you have lines like:

```json
(...)
  "dependencies": {
    "@google-cloud/firestore": "^5.0.2",
    "@google-cloud/logging": "^9.8.3",
    "csv-parse": "^5.0.4"
  }
(...)
```

## The Code to Import the File:

The file `index.js` is where you will put the code that you need to perform what's needed.

A commented version of the file is available in this repo [here](./index.js).

# More Information:

- [Google Lab on how to import CSV file to FireStore](https://www.cloudskillsboost.google/focuses/8392?parent=catalog).
- [Import CVS files to FireStore](https://levelup.gitconnected.com/import-csv-data-to-firestore-using-gcp-f8d11581080f).
- [More details and options on how to use parse-csv](https://stackabuse.com/reading-and-writing-csv-files-in-nodejs-with-node-csv/).
- [Automate Importing data to FireStore (from a JSON file)](https://javascript.plainenglish.io/automate-importing-data-to-firestore-836b0a2cdcfd).

# TO DO:

## WIP - Document How to Run the Code from the GCP Cloud Shell Editor:

Key benefit: NO NEED to create a Node.js machine!!!

- Go to GCP.
- Connect as a user authorised to use the project `firebase-project`
- Open the GCP Cloud Shell Editor
- Set the project in the Cloud Shell editor

```bash
gcloud config set project firebase-project
```

- Check if this repository exists on the GCP Cloud Shell

```bash
ls
```

you should see a folder `utils` there.

```bash
your_username@cloudshell:~ (firebase-project)$ ls
README-cloudshell.txt  utils
```

- If you do NOT see the folder `utils` then clone this repository on the GCP cloud Shell

```bash
git clone https://github.com/franck-boullier/utils.git
```

- Swith to the `utils` folder

```bash
cd utils
```

- Make sure you get the lates version of the repository

```bash
git pull
```

- Go to the folder where the code has been prepared.

```bash
cd firebase/firestore/code-base/import-csv-to-firestore
```

- Check that you have the files you need

```bash
ls
```

you should see something like 

```bash
your_username@cloudshell:~/firebase/firestore/code-base/import-csv-to-firestore (firebase-project)$ ls
index.js  package.json
```

- Make sure the node modules are installed

```bash
yarn install
```

- Upload the file `data.csv` that contains the data you want to import to the FireStore Collection in the folder `~/firebase/firestore/code-base/import-csv-to-firestore` on the GCP Cloud Shell.

- Run the following command to import the file:

```bash
node import-csv-to-firestore
```

## Other:

- See how we can make this code for FireStore outside of FireBase: use 
`@google-cloud/firestore` node.js package instead of `firebase-admin` to connect to FireStore.

```bash
yarn add @google-cloud/logging
```

- See how we can create logs in the GCP Cloud using the `@google-cloud/logging` node.js package.

```bash
yarn add @google-cloud/logging
```