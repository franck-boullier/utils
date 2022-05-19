// ******************************************
// * START - PARAMETERS THAT YOU CAN CHANGE *
// ******************************************
// Name of the collection that will receive the data
const collectionName = 'myCollection';
// Name of the file containing the data:
const filePath = './import-json-to-firestore/data.json';
// ****************************************
// * END - PARAMETERS THAT YOU CAN CHANGE *
// ****************************************

// START - Code to write a Document to FireStore

// Dependency needed to access FireStore
const admin = require('./node_modules/firebase-admin');

// The Service Account credentials to connect to FireStore
// This is a file that you have created!!!
const serviceFile = require('./firebase-credentials.json');

// Put the FireBase credentials for the service user in a const
const firebaseCredentials = {credential: admin.credential.cert(serviceFile)};

// Initialize the Application with the FireBase Credentials
admin.initializeApp(firebaseCredentials);

// Prepare a connection to the FireStore Db
const firestore = admin.firestore();
// Optional configure the `timestampsInSnapshots` setting
const settings = {timestampsInSnapshots: true};
firestore.settings(settings);

// Function to write a document to FireStore:
async function writeToFirestore(item) {
    // A const to simplify syntax to connect to the collection
    const collection = firestore.collection(collectionName);
    // Log for Debugging
    // console.log(item);
    console.log('writing record', 
      i,
      'Document ID',
      item.docId,
      'to the collection',
      collectionName
      );
    // The Document we will try to write
    const document = collection.doc(item.docId);
    // Import the data
    try {
      importData = await document.set(item);
      // Log after we have tried to write the item to the collection
      console.log('Record was written at: ', importData._writeTime);
    } catch (error) {
      // Log the error if any
      console.error('Unable to write record: ', error);
      // Exit the script with error
      process.exit(1);
    }
  }

// END -  Code to write a Document to FireStore  

// START - Code to:
// - read the content of the file
// - import the content of file to FireStore

// DEBUGGING Record what is the current working directory
console.log(process.cwd());

// Dependency needed to open the file using a promise
const {readFile} = require('fs').promises;

// The content of file is empty at first
let fileContent = [];
// Document count is null at first
let documentCount = 0;
// Set the initial value for the loop counter
let i = 1;

// The function to import the file
const importFile = async () => {
  // We try to get the data from the file
  try {
    // Update the variable `fileContent`
    fileContent = await readFile(filePath, 'utf8');
    // Log for debug
    console.log(`The content of the file ${fileContent}`);
    // We update the number of documents in the file
    documentCount = JSON.parse(fileContent).length;
    // Log for debug
    console.log(`The number of documents: ${documentCount}`);
  } catch (error) {
    // Log the error if any
    console.error('Unable to read the file: ', error.message);
    // Exit the script with error
    process.exit(1);
  }
  // We try to write to FireStore using the `writeToFireStore` function
  // loop through the data
  // Populate Firestore on each run
  // Display the count
  console.log(`There are ${documentCount} documents to import`);
  // Make sure file has at least one item.
  if (documentCount < 1) {
    console.error('Make sure that the file contains items.');
  }
  // Convert the JSON data in a string we can use:
  const fileData = JSON.parse(fileContent);
  // Log for debugging
  console.log(fileData);
  // Get the data we need to import.
  for (var item of fileData) {
    // Log for debugging
    console.log('the item to write is',
      item
    );
    // Trying to write the record
    try {
      // we use the `writeToFireStore` function
      await writeToFirestore(item);
    } catch (error) {
      // Log the error if any
      console.error('Cannot write to FireStore: ', error.message);
      // Exit the script with error
      process.exit(1);
    }
    // Check if this is the last record
    if (documentCount === i) {
      // Log what we did
      console.log(`Last record - Wrote record ${i}`)
      // print success message
      console.log(`Wrote a total of ${i} records.`);
      // Exit the script (success)
      process.exit(0);
    }
    // Is this NOT the last record
    // Log what we did
    console.log(`Wrote record ${i}`)
    // Iterate
    i++;
  }
}

// We have everything, call the import function!
importFile();
