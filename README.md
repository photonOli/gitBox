
##What is gitBox?##

gitBox automatically and seamlessly synchronizes your files among several computers.

gitBox is an alternative to dropBox for paranoid people like me, who do not want to show their data to a private company.

##Requirement##

To use gitBox, you need your own server and a URL. It works only on linux.

##Install##

Then launch ./gitbox.sh 
The installation program will ask you for your server URL.
Then it will add a shortcut to your gitBox on your Desktop.
Now, your gitBox is synced with your server every 10 minutes.
If you install, gitBox on another computer, all your gitBoxes will be synced together.

##Technical details##
./gitbox.sh or ./gitbox.sh install will do the following:

-check that your server exists and has a ssh server.
-check if git is installed locally and remotely, and install it if needed.
-check that you have private/public key to access to your server without password to your server, and set that up if needed.
-if no gitBox repo is on your server, it will setup a bare git rep on your server in ~/.gitBoxServer
-if no gitBox repo is setup locally, it will make one in ~/.gitBox, and copy gitBox.sh in ~/.gitBox/.gitBox/.gitBox.sh
-if it's not done yet, it will set up a chron job, to launch "~/.gitBox/.gitBox/.gitBox.sh sync" every 10 minutes.
-it will ass a shortcut from your desktop to 
-.gitBox.sh sync will be executed every 10 minutes, it will pull, then add all new files and remove all delete files and commit and then push. It will also remove git locks if there is one since more than one hour.

*BUT* to do all of that gitBox needs your passwords. So if you don't trust gitBox, install git on local machine and server and install public/private keys for password-less ssh connexion, before launching the install.

You can sync at any moment by doing: "./gitBox.sh sync"


