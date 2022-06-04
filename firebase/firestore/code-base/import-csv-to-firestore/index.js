// Parse the file in a JSON like format
// Only import `createReadStream` from the `fs` package
// Create a to read each line
// Log what it does
// WIP - write to FireStore - NOT WORKING!!
// Tidy up the code

// ******************************************
// * START - PARAMETERS THAT YOU CAN CHANGE *
// ******************************************
// Name of the collection that will receive the data
const collectionName = 'myCollection';
// Name of the file containing the data:
const filePath = './import-csv-to-firestore/data.csv';
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

// START - Code to import the data from the file

// Needed to read the file
const {createReadStream} = require("fs");
// Needed to parse the content of the file
const csvParser = require("csv-parser");

// The counter for the loop
let i = 1;

// Function to import the data.
const importCsv = () => {createReadStream(filePath, 'utf-8')
  .pipe(csvParser())
  // Iterate through the lines
  .on("data", (data) => {
    // Log what we are doing
    console.log('We got line',
      i,
      'The data is:',
      data
    );
    // TO DO: Write that line to FireStore
    // Trying to write the record
    try {
      console.log('writing record',
      data.docId
      );
      // we use the `writeToFireStore` function
      // THIS IS NOT WORKING
      await writeToFirestore(data);
      // END - THIS IS NOT WORKING
    } catch (error) {
      // Log the error if any
      console.error('Unable to write record: '
        , error
      );
      // Exit the script with error
      process.exit(1);
    }
    //Increment the loop
    i++
  })
  // The end of the file
  .on("end", () => {
    // Log what happened
    console.log('End of the File',
      'we found',
      (i-1),
      'lines'
      );
  });
}

// We have everything this is what we want to run
importCsv();