# Overview:

This code base:

- Was written in node.js 
- Will import CSV file to FireStore Database
    - In an existing FireBase project.
    - Add data from a `source_data.csv` file into a FireStore Collection `collection`.
        - Each line in the `source_data.csv` file will be a new document in the collection `collection`.
        - The key for each document should be stored in the first column of the `source_data.csv` file.

## Pre-Requisite:

- The Application will be coded in node.js, you need a [Node Dev Machine](../installation/node-js-dev-machine.sh) to run and create the code.
- An active FireBase project `firebase_project`.
- FireStore activated in the FireBase Project.

## Node Packages needed:

- [csv-parse](https://www.npmjs.com/package/csv-parse).
- @google-cloud/firestore.
- @google-cloud/logging

# Step By Step:

## Create a Node project:

On your [Node Dev Machine](../installation/node-js-dev-machine.sh), create a new project `import-csv-to-firestore` for the import application.

## Prepare the `package.json` file:

In the folder `import-csv-to-firestore` create a file `package.json` for your node.js app.

An example of the basic file can be found [here](./package.json)

## Add the dependancies you need:

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

# More Information:

- [Google Lab on how to import CSV file to FireStore](https://www.cloudskillsboost.google/focuses/8392?parent=catalog).