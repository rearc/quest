# Notes

## Part 1+2

Manually Created an free instance on AWS to test the initial code.
Followed guide here to get Node running on blank instance: <https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html>
Also installed git
I understand that an instance can be used that includes nodeJS and git previously installed, but I like to start with a blank slate when initially testing.

### Commands Used

```bash
sudo yum update
sudo yum install git
sudo yum update curl -o- <https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh> | bash
. ~/.nvm/nvm.sh
nvm install node
git clone https://github.com/jonfinley/quest
cd quest/
node install
npm run start
```

### View Secrete Word

AWS browse to `http://34.207.87.89:3000`
GCP browse to ``
Azure browse to ``

Secret Word was viewed

## Part 3

Dockerfile base was written and updated with the secret_word, seems to get stuck at the end of the build process after `# Rearc quest listening on port 3000!`
Adjusted dockerfile line 21
