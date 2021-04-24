const express = require('express')
const app = express()
const port = 3000

app.get('/', function (req, res) {
const { execFile } = require('child_process');
execFile('bin/001', (err, stdout, stderr) => {
  if (err) {
    return res.send(`${stderr}`);
  }
  return res.send(`${stdout}`);
});
});

app.get('/aws', function (req,res) {
const { execFile } = require('child_process');
execFile('bin/002', (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/docker', function (req,res) {
const { execFile } = require('child_process');
execFile('bin/003', (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/loadbalanced', function (req,res) {
const { execFile } = require('child_process');
execFile('bin/004 ' + JSON.stringify(req.headers), (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/tls', function (req,res) {
const { execFile } = require('child_process');
execFile('bin/005 ' + JSON.stringify(req.headers), (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.get('/secret_word', function (req,res) {
const { execFile } = require('child_process');
execFile('bin/006 ' + JSON.stringify(req.headers), (err, stdout, stderr) => {
  return res.send(`${stdout}`);
});
});

app.listen(port, () => console.log(`Rearc quest listening on port ${port}!`))
