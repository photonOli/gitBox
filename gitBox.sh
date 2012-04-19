#! /bin/bash


GITBOXDIR=~/.gitBox
GITBOXSERVERDIR="~/.gitBoxServer"

if [ $# -eq "0" ]; then
  read -p "Do you want to install gitBox (y/n)? " -n 1 -r
  echo ""
  if [ $REPLY = "y" ]; then
    task="install"
  else
    echo "Please, type :"
    echo "  'gitBox.sh install' to install gitBox."
    echo "  'gitBox.sh sync' to synchronise your gitBox with the server"
    echo "  'gitBox.sh uninstall' to uninstall gitBox"
    exit
  fi
else
  task=$1
fi

case $task in

###### installation ######
install)


  #ask server name
  echo "In order to use gitBox, you need your own server with an URL address."
  read -p "Please enter the URL address of your server. " -r
  echo ""
  server=$REPLY
  if [ -z $server ]; then
    echo "No server name given. Installation aborted."
    exit
  fi
  if [ -z  "`ping -c 1 $server 2> /dev/null`" ]; then
    echo "Server does not exist. Installation aborted"
    exit
  fi
  echo "server answers. OK"

  #check if git is installed
  if [ -z `which git` ]; then
    read -p "git is not installed and required, do you want to install it here (password required) (y/n)? " -n 1 -r
    echo ""
    if [ $REPLY = "y" ]; then
      sudo apt-get install git
    else
      echo "You should run 'sudo apt-get install git' and relaunch installation."
      exit
    fi
  fi
  echo "git is installed. OK"


  #check is ssh-server is installed on server
  if [ `nc -z $server 22` ]; then
    echo "Your server has no ssh server installled. You should run 'sudo apt-get install openssh' on your server"
    exit
  fi


  # check connexion without password
  pubKeyAuth=`ssh -o PasswordAuthentication=no  $server "echo success" | grep success`
  if [ -z "$pubKeyAuth" ]; then
    echo "cannot login passwordlessly to the server."
    read -p "Do you want to automatically setup password-less ssh connexion to your server (password required) (y/n)? " -n 1 -r
    echo ""
    if [ $REPLY = "y" ]; then
      ssh-keygen -P "" -f ~/.ssh/id_rsa_gitBox
      ssh-copy-id $server
    else
      echo "You should run 'ssh-keygen -P \"\" -f ~/.ssh/id_rsa_gitBox' and 'ssh-copy-id $server'"
      exit
    fi
  fi
  echo "passworless connexion. OK"

  #check git installed on server
  if [ -z "`ssh $server \"which git\"`" ]; then
    read -n 1 -r -p "Do you want to automatically install git on your server (password required) (y/n)? "
    echo ""
    if [ $REPLY = "y" ]; then
      ssh $server "sudo apt-get install git"
    else
      echo "You should run 'ssh $server \"sudo apt-get install git\"'"
      exit
    fi
  fi
  echo "git is installed on server. OK"

  echo "start installing gitBox on server...."
  
  #make bare git repository on server

  if [ -z "`ssh $server \"ls ${GITBOXSERVERDIR}\"`" ]; then
    ssh $server `git init --bare ${GITBOXSERVERDIR}`
    echo "GitBox installed on server... OK"
  else
    echo "GitBox is already on the server."
  fi

  echo "start installing gitBox locally...."

  #clone repository locally
  git clone $server:.gitBoxServer/ ${GITBOXDIR}
  mkdir ${GITBOXDIR}/.gitBox/
  cp gitBox.sh ${GITBOXDIR}/.gitBox/
  cd ${GITBOXDIR}/
  git add -A
  git commit -m "init"
  git push origin master

 
  if [ -z "`crontab -l | grep gitBox`" ]; then
    crontab -l > /tmp/cron
    echo "*/10 * * * * ${GITBOXDIR}/.gitBox/gitBox.sh sync"  >> /tmp/cron
    crontab /tmp/cron
    rm /tmp/cron
    echo "cronjob set.... OK"
  else
    echo "cronjob already set."
  fi

  if [ -d $HOME/Desktop ]; then 
    desktopFolder=$HOME/Desktop
  else
    desktopFolder=`xdg-user-dir DESKTOP`
  fi

  ln -s ${GITBOXDIR} ${desktopFolder}/gitBox

  echo "Installation done."
  echo "You can find your gitBox folder in ${desktopFolder}/gitBox/";;


###### syncing ######
sync)
  echo "syncing..."

  cd ${GITBOXDIR}/

  if [ -n "`find .git -mmin +60 -name "index.lock"`" ]; then
    rm .git/index.lock
  fi

  git add -A
  git commit -m "bla"
  PULL=`git pull origin master`
  git add -A
  git commit -m "bla"
  git push origin master
  #NEWFILES= `echo $PULL | grep "create mode" | cut -d" " -f5 | sed 'N;s/\n/ /;'`

  #if [ -n $NEWFILES ]; then
  #  if [ -n "`which notify-send`" ]; then
  #    notify-send "GitBox Update" "New files added: $NEWFILES"
  #  fi
  #fi

  echo "sync done.";;

uninstall)
    crontab -l  | grep -v gitBox > /tmp/cron
    crontab /tmp/cron
    rm /tmp/cron
    echo "cronjob removed.... OK"
    rm -rf ${GITBOXDIR}
    rm -rf ${GITBOXSERVERDIR}

    echo "uninstall done." ;;


*)
  echo "Bad argument. Only 'install', 'sync' and 'uninstall' are accepted."
  exit;;

esac












