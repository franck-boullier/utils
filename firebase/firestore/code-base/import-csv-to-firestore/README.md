# Overview:

- This application will be coded in node.js.
- THIS IS NOT WORKING!!! You can create, edit and run the code directly from the Google Cloud Shell.

## What it Does:

Will import CSV file to FireStore Database
- In an existing FireBase project.
- from a CSV file into a FireStore Collection `collection`.
    - Each line in the CSV file will be a new document in the collection `collection`.
    - The key for each document should be stored in the first column of the CSV file.

## Pre-Requisite:

- An active GCP project `firebase-project`
- An active FireBase project `firebase-project` associated to your GCP project `firebase-project`.
- A user that is allowed to interact with FireBase on the project.
- FireStore activated in the FireBase Project.
- The latest copy of this repository on the GCP console.

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

# How to Import a `.csv` file:

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
node importCsv data.csv
```

# How The Code was Built:

## Create a Node project:

On your [Node Dev Machine](../installation/node-js-dev-machine.sh), create a new project `import-csv-to-firestore` for the import application.

## Prepare the `package.json` file:

In the folder `import-csv-to-firestore` create a file `package.json` for your node.js app.

An example of the basic file can be found [here](./package.json).

## Add the dependancies you need:

We need the following Node Packages:

- [csv-parse](https://www.npmjs.com/package/csv-parse).
- @google-cloud/firestore.
- @google-cloud/logging

In the folder `import-csv-to-firestore` run the following commands to get the dependencies you need:

```bash
yarn add csv-parse
yarn add @google-cloud/firestore
yarn add @google-cloud/logging
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

```

## Create the `index.js` file:

The file `index.js` is where you will put the code that you need to perform what's needed.

A commented version of the file is available in this repo [here](./index.js).

# More Information:

- [Google Lab on how to import CSV file to FireStore](https://www.cloudskillsboost.google/focuses/8392?parent=catalog).
- [Import CVS files to FireStore](https://levelup.gitconnected.com/import-csv-data-to-firestore-using-gcp-f8d11581080f).
- [More details and options on how to use parse-csv](https://stackabuse.com/reading-and-writing-csv-files-in-nodejs-with-node-csv/).
- [Automate Importing data to FireStore (from a JSON file)](https://javascript.plainenglish.io/automate-importing-data-to-firestore-836b0a2cdcfd).