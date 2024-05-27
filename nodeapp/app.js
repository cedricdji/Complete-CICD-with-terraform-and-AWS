const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('My Ultime Service is up and running!');
});

app.listen(8080, () => {
  console.log('Server is up');
});