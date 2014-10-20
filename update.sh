cd app;
git pull;
meteor bundle --directory ../bundle;
cd ../bundle/programs/server && npm install;
cd ../../../;
./restart.sh
