// Needed to handle the `.csv` file
const {readFile}  = require('fs').promises;
const {promisify} = require('util');
const parse       = promisify(require('csv-parse'));
// Needed to import data to FireStore
const {Firestore} = require('@google-cloud/firestore');
// Needed so we can log what happens
const {Logging} = require('@google-cloud/logging');    

// Check that we have a file to process
// Exit with error message if no file have been specified
if (process.argv.length < 3) {
  console.error('Please include a path to a csv file');
  process.exit(1);
}

// Create a Const for the FireStore Database Connection
const db = new Firestore();

// Create Const to Log what's happening
const logName = 'logs-importcsv-to-firestore';
// Creates a Logging client
const logging = new Logging();
const log = logging.log(logName);
const resource = {
  type: 'global',
};

// The function that writes to FireStore
function writeToFirestore(records) {
  const batchCommits = [];
  // declares a new database object
  let batch = db.batch();
  // Log where we are
  console.log(`Writing to FireStore`);
  // Loop through each record
  records.forEach((record, i) => {
    // Specify the Document Reference (col `docId` in the source file)
    // Write to the collection `'destinationCollection'`.
    var docRef = db.collection('destinationCollection').doc(record.docId);
    // Log where we are
    console.log(`peparing record ${i + 1}`);
    // Prepare a batch process to write in FireStore
    batch.set(docRef, record);
    if ((i + 1) % 500 === 0) {
      console.log(`Writing record ${i + 1}`);
      batchCommits.push(batch.commit());
      batch = db.batch();
    }
  });
  // Write to the FireStore Database
  batchCommits.push(batch.commit());
  return Promise.all(batchCommits);
}

// The function to import the `.csv` file 
// Arguments needed: 
//  - csvFileName: the full name of the csv file you want to import
async function importCsv(csvFileName) {
  // Read the content of the file and put it in a const
  const fileContents = await readFile(csvFileName, 'utf8');
  // Split the content of the file in records
  const records = await parse(fileContents, { columns: true });
  // Log where we are
  console.log(`Calling the import function`);
  try {
    // use the function to write the records
    await writeToFirestore(records);
  }
  catch (e) {
    // Catch error if any
    console.error(e);
    // Exit if any error
    process.exit(1);
  }
  // Log that we have processed all records in the console
  console.log(`Wrote ${records.length} records`);
  // Log to Firebase Logs
  success_message = `Success: import data from csv - Wrote ${records.length} records`
  const entry = log.entry({resource: resource}, {message: `${success_message}`});
  log.write([entry]);
}

// Export the function so we can use it
importCsv(process.argv[2]).catch(e => console.error(e));
