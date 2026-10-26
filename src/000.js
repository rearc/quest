const express = require('express')
const { execFile } = require('child_process');
const app = express()
const port = 3000

const headerArgs = headers => Object.entries(headers).map(([k, v]) => `${k}:${v}`);

app.get('/', function (req, res) {
execFile('bin/001', (err, stdout, stderr) => {
  if (err) {
    return res.send(`${stderr}`);
  }
  return res.send(`${stdout}`);
});
});

app.get('/aws', function (req,res) {
execFile('bin/002', (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/docker', function (req,res) {
execFile('bin/003', (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/loadbalanced', function (req,res) {
execFile('bin/004', headerArgs(req.headers), (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/tls', function (req,res) {
execFile('bin/005', headerArgs(req.headers), (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/secret_word', function (req,res) {
execFile('bin/006', headerArgs(req.headers), (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.listen(port, () => console.log(`Rearc quest listening on port ${port}!`))
