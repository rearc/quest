const express = require('express');
const {exec} = require('child_process');
const app = express();

// Define connection information
const host = process.env.HOST || '0.0.0.0';
const port = process.env.PORT || 3000;

/**
 * Interviewer Note: Ely Erin Haughie
 * exec in practice is extremely dangerous, while I understand this is an interview question, even if containerized, there's always the possibility of an unknown exploit that could escape.
 * Imagine if I ran this on my machine without knowing what that binary is. My machine would be compromised, I would be wiping it right now.
 * I've created a Makefile with a debug option to drop me into a containerized shell and figure out how your binaries work :)
 *
 * Other changes:
 *  - Changed connection information to be environment variable based, this allows for more flow control/ACLs.
 *  - Moved the exec/child_process import to the top of the class, avoid WET code.
 */

app.get('/', function (req, res) {
    exec('bin/001', (err, stdout, stderr) => {
        if (err) {
            return res.send(`${stderr}`);
        }
        return res.send(`${stdout}`);
    });
});

app.get('/aws', function (req, res) {

    exec('bin/002', (err, stdout, stderr) => {
        return res.send(`${stdout}`);
    });
});

app.get('/docker', function (req, res) {
    exec('bin/003', (err, stdout, stderr) => {
        return res.send(`${stdout}`);
    });
});

app.get('/loadbalanced', function (req, res) {
    exec('bin/004 ' + JSON.stringify(req.headers), (err, stdout, stderr) => {
        return res.send(`${stdout}`);
    });
});

app.get('/tls', function (req, res) {
    exec('bin/005 ' + JSON.stringify(req.headers), (err, stdout, stderr) => {
        return res.send(`${stdout}`);
    });
});

app.get('/secret_word', function (req, res) {
    exec('bin/006 ' + JSON.stringify(req.headers), (err, stdout, stderr) => {
        return res.send(`${stdout}`);
    });
});

app.listen(port, host, () => console.log(`Rearc quest listening on port http://${host}:${port}!`))
